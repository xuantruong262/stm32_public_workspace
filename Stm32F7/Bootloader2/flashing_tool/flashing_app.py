#!/usr/bin/env python3
"""Desktop USB CDC flashing application for the STM32H7 bootloader project."""

from __future__ import annotations

import queue
import json
import struct
import sys
import threading
import time
import uuid
import zlib
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from tkinter import Tk, Toplevel, StringVar, filedialog, messagebox, ttk

try:
    import serial
except ImportError as error:
    raise SystemExit("Missing dependency: install with 'python -m pip install -r requirements.txt'.") from error

SOF = b"\xA5\x5A"
PROTOCOL_VERSION = 1
MAX_FRAME_PAYLOAD = 1024
WRITE_DATA_SIZE = 992
FLASH_WORD_SIZE = 32
CMD_GET_INFO, CMD_BEGIN_UPDATE, CMD_WRITE_BLOCK, CMD_FINALIZE, CMD_ABORT, CMD_RESET = range(1, 7)
STATUS_OK = 0
STATUS_BAD_FRAME = 1
STATUS_BAD_COMMAND = 2
STATUS_BAD_ARGUMENT = 3
BOARD_ID = 0x48374231
BOOT_VERSION = 0x00010005
IMAGE_MAGIC = 0x4837424C
IMAGE_FORMAT_VERSION = 1
HEADER_SIZE = 128
PRIMARY_PAYLOAD_BASE = 0x08020200
PAYLOAD_CAPACITY = 388_608


class FlashingError(RuntimeError):
    pass


class FlashingCancelled(FlashingError):
    pass


def crc32(data: bytes) -> int:
    return zlib.crc32(data) & 0xFFFFFFFF


def is_valid_msp(value: int) -> bool:
    return ((0x20000000 <= value <= 0x20020000) or
            (0x24000000 <= value <= 0x24050000) or
            (0x30000000 <= value <= 0x30008000) or
            (0x38000000 <= value <= 0x38004000))


@dataclass(frozen=True)
class Image:
    payload: bytes
    padded_payload: bytes
    header: bytes


def build_image(path: Path, firmware_version: int = 1, build_number: int = 1) -> Image:
    payload = path.read_bytes()
    if not (8 <= len(payload) <= PAYLOAD_CAPACITY):
        raise FlashingError(f"Payload size must be 8..{PAYLOAD_CAPACITY} bytes; got {len(payload)}.")
    msp, entry_point = struct.unpack_from("<II", payload)
    reset_handler = entry_point & ~1
    if not is_valid_msp(msp):
        raise FlashingError(f"Invalid MSP 0x{msp:08X}.")
    if (entry_point & 1) == 0 or not (PRIMARY_PAYLOAD_BASE <= reset_handler < PRIMARY_PAYLOAD_BASE + len(payload)):
        raise FlashingError(f"Invalid Reset_Handler 0x{entry_point:08X} for this payload.")
    fields = (IMAGE_MAGIC, IMAGE_FORMAT_VERSION, HEADER_SIZE, BOARD_ID, BOOT_VERSION,
              firmware_version, build_number, len(payload), crc32(payload),
              PRIMARY_PAYLOAD_BASE, 0x200, entry_point,
              int(datetime.now(timezone.utc).timestamp()), uuid.uuid4().bytes,
              b"\xFF" * 56, 0)
    raw_header = struct.pack("<IHH" + "I" * 9 + "Q16s56sI", *fields)
    if len(raw_header) != HEADER_SIZE:
        raise AssertionError("Unexpected boot image header size.")
    header = raw_header[:-4] + struct.pack("<I", crc32(raw_header[:-4]))
    return Image(payload, payload + b"\xFF" * ((-len(payload)) % FLASH_WORD_SIZE), header)


class BootProtocol:
    def __init__(self, port: serial.Serial) -> None:
        self.port = port
        self.sequence = 0

    def _read_exact(self, count: int) -> bytes:
        data = self.port.read(count)
        if len(data) != count:
            raise FlashingError("Timed out waiting for bootloader response.")
        return data

    def request_status(self, command: int, payload: bytes = b"") -> tuple[int, bytes]:
        if len(payload) > MAX_FRAME_PAYLOAD:
            raise ValueError("Protocol payload is too large.")
        sequence = self.sequence
        self.sequence = (self.sequence + 1) & 0xFFFF
        header = struct.pack("<BBHH", PROTOCOL_VERSION, command, sequence, len(payload))
        self.port.write(SOF + header + payload + struct.pack("<I", crc32(header + payload)))
        self.port.flush()
        while True:
            if self._read_exact(1) != SOF[:1] or self._read_exact(1) != SOF[1:]:
                continue
            response = self._read_exact(6)
            version, response_command, response_sequence, length = struct.unpack("<BBHH", response)
            if version != PROTOCOL_VERSION or length > MAX_FRAME_PAYLOAD:
                continue
            body = self._read_exact(length)
            received_crc, = struct.unpack("<I", self._read_exact(4))
            if received_crc != crc32(response + body):
                continue
            if response_command != (command | 0x80) or response_sequence != sequence or not body:
                continue
            return body[0], body[1:]

    def request(self, command: int, payload: bytes = b"") -> bytes:
        status, body = self.request_status(command, payload)
        if status != STATUS_OK:
            suffix = f" flash_sr1=0x{struct.unpack('<I', body)[0]:08X}" if len(body) == 4 else ""
            raise FlashingError(f"Bootloader rejected command 0x{command:02X}; status={status}.{suffix}")
        return body

    def get_info(self) -> tuple[int, int, int, int]:
        response = self.request(CMD_GET_INFO)
        if len(response) != 16:
            raise FlashingError("Invalid GET_INFO response length.")
        return struct.unpack("<IIII", response)


def protocol_self_test(port_name: str, timeout: float = 2.0) -> dict[str, object]:
    """Exercise transport recovery without starting a firmware update.

    This is deliberately CLI-only so Sprint 6 can test the same protocol
    implementation used by the GUI while leaving Secondary untouched.
    """
    results: dict[str, bool] = {}

    def request(port: serial.Serial, sequence: int, command: int, payload: bytes = b"",
                corrupt_crc: bool = False) -> tuple[int, bytes]:
        header = struct.pack("<BBHH", PROTOCOL_VERSION, command, sequence, len(payload))
        crc = crc32(header + payload)
        if corrupt_crc:
            crc ^= 1
        port.write(SOF + header + payload + struct.pack("<I", crc)); port.flush()
        response = port.read(2)
        if response != SOF:
            raise FlashingError(f"Unexpected response SOF for command 0x{command:02X}: {response.hex()}")
        header_rx = port.read(6)
        if len(header_rx) != 6:
            raise FlashingError("Timed out reading response header.")
        version, response_command, response_sequence, length = struct.unpack("<BBHH", header_rx)
        body = port.read(length); crc_rx = port.read(4)
        if len(body) != length or len(crc_rx) != 4:
            raise FlashingError("Timed out reading response body.")
        received_crc, = struct.unpack("<I", crc_rx)
        if (version != PROTOCOL_VERSION or response_command != (command | 0x80) or
                response_sequence != sequence or received_crc != crc32(header_rx + body) or not body):
            raise FlashingError("Malformed bootloader response.")
        return body[0], body[1:]

    def get_info(port: serial.Serial, sequence: int) -> tuple[int, tuple[int, int, int, int]]:
        status, body = request(port, sequence, CMD_GET_INFO)
        if status != STATUS_OK or len(body) != 16:
            raise FlashingError("GET_INFO response is invalid.")
        return sequence + 1, struct.unpack("<IIII", body)

    with serial.Serial(port_name, 115200, timeout=timeout, write_timeout=timeout) as port:
        port.reset_input_buffer(); sequence = 0
        sequence, info = get_info(port, sequence)
        results["get_info"] = info == (BOARD_ID, BOOT_VERSION, PAYLOAD_CAPACITY, FLASH_WORD_SIZE)
        status, _ = request(port, sequence, CMD_GET_INFO, corrupt_crc=True); sequence += 1
        results["bad_crc"] = status == STATUS_BAD_FRAME
        status, _ = request(port, sequence, 0x7E); sequence += 1
        results["unknown_command"] = status == STATUS_BAD_COMMAND
        status, _ = request(port, sequence, CMD_BEGIN_UPDATE, b"\x00"); sequence += 1
        results["bad_begin_length"] = status == STATUS_BAD_ARGUMENT
        status, _ = request(port, sequence, CMD_WRITE_BLOCK); sequence += 1
        results["write_while_idle"] = status == STATUS_BAD_ARGUMENT
        status, _ = request(port, sequence, CMD_ABORT); sequence += 1
        results["abort_idle"] = status == STATUS_OK

        # Deliberately leave a frame incomplete; a subsequent valid request
        # must work after the firmware's RX idle timeout.
        partial = SOF + struct.pack("<BBHH", PROTOCOL_VERSION, CMD_GET_INFO, sequence, 4) + b"\xAA"
        port.write(partial); port.flush(); time.sleep(1.2)
        sequence, info = get_info(port, sequence + 1)
        results["incomplete_frame_timeout"] = info == (BOARD_ID, BOOT_VERSION, PAYLOAD_CAPACITY, FLASH_WORD_SIZE)
        status, _ = request(port, sequence, CMD_RESET)
        results["reset_ack"] = status == STATUS_OK

    # Reset disconnects CDC. The invalid-Primary test setup should enumerate
    # recovery again and answer a fresh GET_INFO request.
    deadline = time.monotonic() + 5.0
    reset_recovered = False
    while time.monotonic() < deadline:
        try:
            with serial.Serial(port_name, 115200, timeout=timeout, write_timeout=timeout) as port:
                port.reset_input_buffer()
                _, info = get_info(port, 0)
                reset_recovered = info == (BOARD_ID, BOOT_VERSION, PAYLOAD_CAPACITY, FLASH_WORD_SIZE)
                if reset_recovered:
                    break
        except serial.SerialException:
            pass
        time.sleep(0.25)
    results["reset_recovery"] = reset_recovered
    return {"port": port_name, "passed": all(results.values()), "results": results}


def secondary_abort_test(port_name: str, firmware: Path, timeout: float = 3.0) -> dict[str, object]:
    """Start then abort a download, exercising rejected block forms first."""
    image = build_image(firmware)
    cancel = threading.Event()
    port, protocol = open_bootloader(port_name, timeout, cancel)
    try:
        protocol.request(CMD_BEGIN_UPDATE, image.header)
        bad_offset, _ = protocol.request_status(CMD_WRITE_BLOCK, struct.pack("<I", FLASH_WORD_SIZE) + image.padded_payload[:FLASH_WORD_SIZE])
        bad_length, _ = protocol.request_status(CMD_WRITE_BLOCK, struct.pack("<I", 0) + image.padded_payload[:31])
        abort_status, _ = protocol.request_status(CMD_ABORT)
        results = {"bad_offset_rejected": bad_offset == STATUS_BAD_ARGUMENT,
                   "bad_length_rejected": bad_length == STATUS_BAD_ARGUMENT,
                   "abort_ack": abort_status == STATUS_OK}
        return {"passed": all(results.values()), "results": results}
    finally:
        port.close()


def secondary_download_test(port_name: str, firmware: Path, timeout: float = 3.0) -> dict[str, object]:
    """Download a complete image to Secondary and stop at PENDING (no reset)."""
    image = build_image(firmware)
    cancel = threading.Event()
    port, protocol = open_bootloader(port_name, timeout, cancel)
    try:
        protocol.request(CMD_BEGIN_UPDATE, image.header)
        for offset in range(0, len(image.padded_payload), WRITE_DATA_SIZE):
            block = image.padded_payload[offset:offset + WRITE_DATA_SIZE]
            protocol.request(CMD_WRITE_BLOCK, struct.pack("<I", offset) + block)
        protocol.request(CMD_FINALIZE)
        return {"passed": True, "payload_bytes": len(image.payload),
                "padded_bytes": len(image.padded_payload), "payload_crc32": f"0x{crc32(image.payload):08X}",
                "payload_sha256": __import__("hashlib").sha256(image.payload).hexdigest()}
    finally:
        port.close()


def request_update_from_app(port_name: str, timeout: float) -> None:
    with serial.Serial(port_name, 115200, timeout=timeout, write_timeout=timeout) as port:
        port.reset_input_buffer()
        port.write(b"ENTER_UPDATE\n")
        port.flush()
        # Read incrementally.  A CDC device is allowed to disconnect soon
        # after its short acknowledgement when it resets into bootloader; a
        # single read(64) can otherwise lose a partial "OK\\n" on Windows.
        received = bytearray()
        deadline = time.monotonic() + timeout
        port.timeout = min(timeout, 0.1)
        while time.monotonic() < deadline:
            try:
                byte = port.read(1)
            except serial.SerialException:
                break
            if byte:
                received += byte
                if b"OK\n" in received:
                    return
        raise FlashingError("Application did not acknowledge ENTER_UPDATE.")


def open_bootloader(port_name: str, timeout: float, cancel: threading.Event) -> tuple[serial.Serial, BootProtocol]:
    deadline = time.monotonic() + 10.0
    last_error: Exception | None = None
    while time.monotonic() < deadline:
        if cancel.is_set():
            raise FlashingCancelled("Update cancelled.")
        port: serial.Serial | None = None
        try:
            port = serial.Serial(port_name, 115200, timeout=timeout, write_timeout=timeout)
            protocol = BootProtocol(port)
            board_id, _, _, _ = protocol.get_info()
            if board_id != BOARD_ID:
                raise FlashingError(f"Unexpected board ID 0x{board_id:08X}.")
            return port, protocol
        except (serial.SerialException, FlashingError) as error:
            last_error = error
            if port is not None:
                port.close()
            time.sleep(0.25)
    raise FlashingError(f"Could not open bootloader on {port_name}: {last_error}")


class FirmwareUpdateWindow:
    def __init__(self, parent: "FlashingApp", app_port: str, boot_port: str) -> None:
        self.parent = parent
        self.window = Toplevel(parent.root)
        self.window.title("Firmware update")
        self.window.resizable(False, False)
        self.window.transient(parent.root)
        self.window.grab_set()
        self.window.protocol("WM_DELETE_WINDOW", self.close)
        self.app_port, self.boot_port = app_port.strip(), boot_port.strip()
        self.image: Image | None = None
        self.cancel_event = threading.Event()
        self.events: queue.Queue[tuple[str, object]] = queue.Queue()
        self.active = False

        frame = ttk.Frame(self.window, padding=16)
        frame.grid(sticky="nsew")
        ttk.Label(frame, text="Firmware update", font=("TkDefaultFont", 12, "bold")).grid(row=0, column=0, columnspan=3, sticky="w")
        self.device_text = StringVar(value="Device: waiting for bootloader")
        ttk.Label(frame, textvariable=self.device_text).grid(row=1, column=0, columnspan=3, sticky="w", pady=(6, 12))
        ttk.Label(frame, text="Firmware:").grid(row=2, column=0, sticky="w")
        self.file_text = StringVar(value="No file selected")
        ttk.Label(frame, textvariable=self.file_text, width=48).grid(row=2, column=1, sticky="w")
        ttk.Button(frame, text="Browse…", command=self.browse).grid(row=2, column=2, sticky="e")
        self.details_text = StringVar(value="Select a raw application .bin file.")
        ttk.Label(frame, textvariable=self.details_text, wraplength=470).grid(row=3, column=0, columnspan=3, sticky="w", pady=(8, 12))
        self.phase_text = StringVar(value="Idle")
        ttk.Label(frame, textvariable=self.phase_text).grid(row=4, column=0, columnspan=3, sticky="w")
        self.progress = ttk.Progressbar(frame, length=470, mode="determinate", maximum=100)
        self.progress.grid(row=5, column=0, columnspan=3, sticky="ew", pady=(4, 2))
        self.bytes_text = StringVar(value="0%")
        ttk.Label(frame, textvariable=self.bytes_text).grid(row=6, column=0, columnspan=3, sticky="e", pady=(0, 12))
        self.cancel_button = ttk.Button(frame, text="Cancel", command=self.cancel, state="disabled")
        self.cancel_button.grid(row=7, column=1, sticky="e")
        self.flash_button = ttk.Button(frame, text="Flash firmware", command=self.start, state="disabled")
        self.flash_button.grid(row=7, column=2, sticky="e")
        self.window.after(50, self.consume_events)

    def browse(self) -> None:
        name = filedialog.askopenfilename(parent=self.window, title="Select firmware", filetypes=[("Binary firmware", "*.bin"), ("All files", "*.*")])
        if not name:
            return
        try:
            self.image = build_image(Path(name))
            self.file_text.set(Path(name).name)
            self.details_text.set(f"Valid: {len(self.image.payload):,} B • CRC32 0x{crc32(self.image.payload):08X} • padded {len(self.image.padded_payload):,} B")
            self.flash_button.configure(state="normal")
        except (OSError, FlashingError) as error:
            self.image = None
            self.flash_button.configure(state="disabled")
            self.details_text.set(f"Invalid firmware: {error}")

    def post(self, kind: str, value: object) -> None:
        self.events.put((kind, value))

    def start(self) -> None:
        if self.image is None or not self.boot_port:
            self.details_text.set("Choose a valid firmware and enter a bootloader CDC port in the main window.")
            return
        self.active = True
        self.cancel_event.clear()
        self.flash_button.configure(state="disabled")
        self.cancel_button.configure(state="normal")
        threading.Thread(target=self.worker, args=(self.image,), daemon=True).start()

    def worker(self, image: Image) -> None:
        port: serial.Serial | None = None
        protocol: BootProtocol | None = None
        try:
            if self.app_port:
                self.post("phase", ("Request update mode", 2, "Waiting for app acknowledgment"))
                request_update_from_app(self.app_port, 3.0)
            self.post("phase", ("Wait for bootloader", 5, f"Waiting for {self.boot_port}"))
            port, protocol = open_bootloader(self.boot_port, 3.0, self.cancel_event)
            board_id, version, capacity, word_size = protocol.get_info()
            if board_id != BOARD_ID or version < BOOT_VERSION or capacity != PAYLOAD_CAPACITY or word_size != FLASH_WORD_SIZE:
                raise FlashingError("Connected bootloader is not compatible with this firmware.")
            self.post("device", f"Device: Board H7B1 • Bootloader v{version >> 16}.{version & 0xFFFF}")
            self.post("phase", ("Erase Secondary", 8, "Beginning update session"))
            protocol.request(CMD_BEGIN_UPDATE, image.header)
            total = len(image.padded_payload)
            for offset in range(0, total, WRITE_DATA_SIZE):
                if self.cancel_event.is_set():
                    protocol.request(CMD_ABORT)
                    raise FlashingCancelled("Update cancelled; incomplete Secondary image was discarded.")
                block = image.padded_payload[offset:offset + WRITE_DATA_SIZE]
                protocol.request(CMD_WRITE_BLOCK, struct.pack("<I", offset) + block)
                done = offset + len(block)
                self.post("phase", ("Write payload", 8 + int(done * 82 / total), f"Writing {done:,} / {total:,} B"))
            self.post("phase", ("Finalize", 92, "Verifying CRC and committing PENDING image"))
            protocol.request(CMD_FINALIZE)
            self.post("phase", ("Reset", 98, "Bootloader will activate test image"))
            protocol.request(CMD_RESET)
            self.post("done", "Firmware committed for TEST boot. It becomes permanent only after the app confirms itself.")
        except FlashingCancelled as error:
            self.post("cancelled", str(error))
        except (OSError, serial.SerialException, FlashingError) as error:
            self.post("error", str(error))
        finally:
            if port is not None:
                port.close()

    def consume_events(self) -> None:
        try:
            while True:
                kind, value = self.events.get_nowait()
                if kind == "phase":
                    phase, percent, text = value  # type: ignore[misc]
                    self.phase_text.set(str(phase)); self.progress["value"] = int(percent); self.bytes_text.set(f"{percent}% • {text}")
                elif kind == "device":
                    self.device_text.set(str(value))
                elif kind in ("done", "error", "cancelled"):
                    self.active = False
                    self.cancel_button.configure(state="disabled")
                    if kind == "done":
                        self.progress["value"] = 100; self.phase_text.set("Test boot started"); self.bytes_text.set("100% • Update committed")
                        messagebox.showinfo("Firmware update", str(value), parent=self.window)
                    else:
                        self.phase_text.set("Update cancelled" if kind == "cancelled" else "Update failed")
                        self.bytes_text.set(str(value)); self.flash_button.configure(state="normal" if self.image else "disabled")
                        messagebox.showwarning("Firmware update", str(value), parent=self.window)
        except queue.Empty:
            pass
        if self.window.winfo_exists():
            self.window.after(50, self.consume_events)

    def cancel(self) -> None:
        if self.active:
            self.cancel_event.set(); self.cancel_button.configure(state="disabled"); self.phase_text.set("Cancelling")
        else:
            self.close()

    def close(self) -> None:
        if self.active:
            self.cancel()
            return
        self.window.grab_release(); self.window.destroy()


class FlashingApp:
    def __init__(self) -> None:
        self.root = Tk()
        self.root.title("STM32H7 Flashing App")
        self.root.resizable(False, False)
        frame = ttk.Frame(self.root, padding=20); frame.grid(sticky="nsew")
        ttk.Label(frame, text="STM32H7 firmware utility", font=("TkDefaultFont", 12, "bold")).grid(row=0, column=0, columnspan=2, sticky="w")
        ttk.Label(frame, text="Running app CDC port (optional):").grid(row=1, column=0, sticky="w", pady=(12, 4))
        self.app_port = StringVar(); ttk.Entry(frame, textvariable=self.app_port, width=18).grid(row=1, column=1, sticky="e", pady=(12, 4))
        ttk.Label(frame, text="Bootloader CDC port:").grid(row=2, column=0, sticky="w", pady=4)
        self.boot_port = StringVar(); ttk.Entry(frame, textvariable=self.boot_port, width=18).grid(row=2, column=1, sticky="e", pady=4)
        ttk.Button(frame, text="Update firmware", command=self.open_update).grid(row=3, column=1, sticky="e", pady=(16, 0))

    def open_update(self) -> None:
        FirmwareUpdateWindow(self, self.app_port.get(), self.boot_port.get())

    def run(self) -> None:
        self.root.mainloop()


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--protocol-self-test":
        try:
            print(json.dumps(protocol_self_test(sys.argv[2]), sort_keys=True))
        except (OSError, serial.SerialException, FlashingError) as error:
            print(json.dumps({"port": sys.argv[2], "passed": False, "error": str(error)}))
            raise SystemExit(1)
    elif len(sys.argv) == 3 and sys.argv[1] == "--request-update":
        try:
            request_update_from_app(sys.argv[2], 3.0)
            print(json.dumps({"passed": True, "port": sys.argv[2]}))
        except (OSError, serial.SerialException, FlashingError) as error:
            print(json.dumps({"passed": False, "port": sys.argv[2], "error": str(error)})); raise SystemExit(1)
    elif len(sys.argv) == 4 and sys.argv[1] in ("--secondary-abort-test", "--secondary-download-test"):
        try:
            action = secondary_abort_test if sys.argv[1] == "--secondary-abort-test" else secondary_download_test
            result = action(sys.argv[2], Path(sys.argv[3])); print(json.dumps(result, sort_keys=True))
            if not result["passed"]: raise SystemExit(1)
        except (OSError, serial.SerialException, FlashingError) as error:
            print(json.dumps({"passed": False, "error": str(error)})); raise SystemExit(1)
    else:
        FlashingApp().run()
