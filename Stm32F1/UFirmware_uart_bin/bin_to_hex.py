import sys
import os

def bin_to_hex(input_file, output_file, bytes_per_line=16):
    try:
        # Kiểm tra file đầu vào tồn tại
        if not os.path.exists(input_file):
            print(f"Error: Input file '{input_file}' does not exist.")
            return
        
        # Mở file .bin ở chế độ binary
        with open(input_file, 'rb') as bin_file:
            # Đọc toàn bộ dữ liệu
            data = bin_file.read()
        
        # Mở file .txt để ghi
        with open(output_file, 'w') as hex_file:
            # Duyệt qua dữ liệu, mỗi lần bytes_per_line byte
            for i in range(0, len(data), bytes_per_line):
                # Lấy đoạn dữ liệu (slice) cho dòng hiện tại
                line_data = data[i:i + bytes_per_line]
                # Chuyển từng byte thành hex (2 chữ số)
                hex_line = ' '.join(f'{byte:02x}' for byte in line_data)
                # Ghi dòng hex vào file, thêm ký tự xuống dòng
                hex_file.write(hex_line + '\n')
        
        print(f"Successfully converted '{input_file}' to '{output_file}'.")
    
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    # Kiểm tra tham số dòng lệnh
    if len(sys.argv) < 3:
        print("Usage: python bin_to_hex.py <input_bin_file> <output_hex_file>")
        sys.exit(1)
    
    input_bin = sys.argv[1]
    output_hex = sys.argv[2]
    bin_to_hex(input_bin, output_hex)