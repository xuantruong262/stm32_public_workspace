#!/usr/bin/env python3
"""
usb_jpeg_viewer.py
Đọc ảnh JPEG được STM32 gửi qua USB CDC và hiển thị realtime.
Giao thức: [0xAA 0x55][4 byte length][JPEG data...]
"""

import serial
import struct
import numpy as np
import cv2
import time
import argparse

HEADER = b'\xAA\x55'

def find_header(ser):
    """Tìm header 0xAA55 trong luồng serial"""
    while True:
        b = ser.read(1)
        if b == b'\xAA':
            nxt = ser.read(1)
            if nxt == b'\x55':
                return True

def main():
    parser = argparse.ArgumentParser(description="STM32 USB JPEG Viewer")
    parser.add_argument("--port", "-p", required=True, help="Serial port (e.g. COM3 or /dev/ttyACM0)")
    parser.add_argument("--baud", "-b", type=int, default=115200, help="Baud rate (not important for USB CDC)")
    parser.add_argument("--timeout", type=float, default=2.0, help="Read timeout (s)")
    parser.add_argument("--show-fps", action="store_true", help="Display FPS in window title")
    args = parser.parse_args()

    print(f"Opening port {args.port} ...")
    ser = serial.Serial(args.port, args.baud, timeout=args.timeout)
    cv2.namedWindow("STM32 USB JPEG Stream", cv2.WINDOW_NORMAL)
    frame_count = 0
    t0 = time.time()

    print("Waiting for JPEG frames... Press 'q' to quit.")

    try:
        while True:
            # 1️⃣ Tìm header 0xAA55
            if not find_header(ser):
                continue

            # 2️⃣ Đọc độ dài ảnh (4 byte little endian)
            len_bytes = ser.read(4)
            if len(len_bytes) < 4:
                continue
            frame_len = struct.unpack('<I', len_bytes)[0]

            # Giới hạn kích thước ảnh hợp lệ (ví dụ 2KB–200KB)
            if not (2048 <= frame_len <= 200 * 1024):
                print(f"⚠️ Kích thước ảnh bất thường: {frame_len} bytes")
                continue

            # 3️⃣ Đọc dữ liệu JPEG
            jpeg_data = bytearray()
            while len(jpeg_data) < frame_len:
                chunk = ser.read(frame_len - len(jpeg_data))
                if not chunk:
                    break
                jpeg_data.extend(chunk)

            # Đảm bảo đọc đủ byte
            if len(jpeg_data) != frame_len:
                print(f"⚠️ Chưa đủ dữ liệu: {len(jpeg_data)} / {frame_len} bytes")
                continue

            # 4️⃣ Kiểm tra marker đầu/cuối
            if not (jpeg_data[:2] == b'\xFF\xD8'):
                print("⚠️ Thiếu marker đầu JPEG (FFD8)")
                continue

            # Tìm marker kết thúc FFD9
            end_marker = jpeg_data.find(b'\xFF\xD9')
            if end_marker != -1:
                jpeg_data = jpeg_data[:end_marker + 2]
            else:
                print("⚠️ Thiếu marker kết thúc JPEG (FFD9) → có thể bị cắt thiếu")
                continue

            # 5️⃣ Giải mã JPEG
            np_data = np.frombuffer(jpeg_data, dtype=np.uint8)
            img = cv2.imdecode(np_data, cv2.IMREAD_COLOR)
            if img is None:
                print("❌ Giải mã JPEG thất bại")
                continue

            # 6️⃣ Hiển thị ảnh
            frame_count += 1
            elapsed = time.time() - t0
            if elapsed >= 1.0:
                fps = frame_count / elapsed
                frame_count = 0
                t0 = time.time()
                if args.show_fps:
                    cv2.setWindowTitle("STM32 USB JPEG Stream", f"STM32 USB JPEG Stream - {fps:.1f} FPS")

            cv2.imshow("STM32 USB JPEG Stream", img)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
    except KeyboardInterrupt:
        print("Stopped by user.")
    finally:
        ser.close()
        cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
