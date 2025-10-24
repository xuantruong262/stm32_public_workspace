import serial
import struct
import numpy as np
import cv2
import time
import threading
import queue
import easyocr
import difflib
from spellchecker import SpellChecker

HEADER = b'\xAA\x55'

def find_header(ser):
    while True:
        b = ser.read(1)
        if b == b'\xAA':
            nxt = ser.read(1)
            if nxt == b'\x55':
                return True


def serial_reader(ser, frame_queue):
    """Thread đọc ảnh từ STM32 và hiển thị"""
    print("[READER] Bắt đầu đọc dữ liệu từ STM32...")
    while True:
        if not find_header(ser):
            continue

        len_bytes = ser.read(4)
        if len(len_bytes) < 4:
            continue
        frame_len = struct.unpack('<I', len_bytes)[0]

        if not (2048 <= frame_len <= 200 * 1024):
            print(f"[⚠️] Kích thước ảnh bất thường: {frame_len} bytes")
            continue

        jpeg_data = bytearray()
        while len(jpeg_data) < frame_len:
            chunk = ser.read(frame_len - len(jpeg_data))
            if not chunk:
                break
            jpeg_data.extend(chunk)

        if len(jpeg_data) != frame_len:
            continue

        # kiểm tra marker JPEG
        if not jpeg_data[:2] == b'\xFF\xD8':
            continue
        end_marker = jpeg_data.find(b'\xFF\xD9')
        if end_marker == -1:
            continue
        jpeg_data = jpeg_data[:end_marker + 2]

        # giải mã ảnh
        np_data = np.frombuffer(jpeg_data, dtype=np.uint8)
        img = cv2.imdecode(np_data, cv2.IMREAD_COLOR)
        if img is None:
            continue

        # push frame vào hàng đợi (xử lý OCR thread)
        if frame_queue.qsize() < 2:
            frame_queue.put(img)

        # hiển thị video realtime
        cv2.imshow("STM32 USB JPEG Stream", img)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    print("[READER] Kết thúc.")
    ser.close()
    cv2.destroyAllWindows()


def similarity(a, b):
    return difflib.SequenceMatcher(None, a, b).ratio()

def ocr_worker(ser, frame_queue):

    print("[OCR] Bắt đầu OCR thrd...")
    reader = easyocr.Reader(['en'], gpu=True)
    spell = SpellChecker(language='en')
    avg_string = []
    last_text = ""
    stable_text = ""
    stable_score = 0.0
    stable_count = 0

    MIN_CONF = 0.7          
    SIM_THRESHOLD = 0.85    
    STABLE_REQUIRED = 3     

    while True:
        img = frame_queue.get()
        if img is None:
            break

        # OCR
        result = reader.readtext(img)
        if not result:
            continue
        texts = [text for (_, text, conf) in result if conf > 0.6]
        if texts:
            text_result = " ".join(texts)
            words = text_result.split()

            corrected = [spell.correction(w) for w in words]
            corrected = text_result.encode('utf-8')[:128] 
            avg_string.append(corrected)
            if len(avg_string) > 3:
                longest = max(avg_string, key=len)
                #print(longest)  # 👉 "unpredictable"
                packet = f"L:{len(longest)},{longest.decode()}".encode()
                print(packet)
                try:
                    ser.write(packet)
                except serial.SerialException:
                    print("[⚠️] FAILED to send data to STM32.")
                avg_string.clear()


        time.sleep(0.05)

def main():
    port = "COM11"
    baud = 115200

    ser = serial.Serial(port, baud, timeout=2.0)
    frame_queue = queue.Queue(maxsize=3)

    # Tạo 2 thread
    t1 = threading.Thread(target=serial_reader, args=(ser, frame_queue), daemon=True)
    t2 = threading.Thread(target=ocr_worker, args=(ser, frame_queue), daemon=True)

    t1.start()
    t2.start()

    try:
        while t1.is_alive():
            time.sleep(0.1)
    except KeyboardInterrupt:
        print("Stop processing.")
    finally:
        frame_queue.put(None)
        ser.close()
        cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
