from PIL import Image
import struct

img = Image.open("rsz_1image_3.bmp").convert("RGB")
width, height = img.size
pixels = img.load()

with open("rsz_image1_scaledown_RGB565.bmp", "wb") as f:
    # BMP header (54 bytes)
    file_size = 54 + width * height * 2
    f.write(b'BM')
    f.write(struct.pack('<IHHI', file_size, 0, 0, 54))
    f.write(struct.pack('<IIIHHIIIIII',
                        40, width, height, 1, 16,
                        3, width * height * 2,
                        2835, 2835, 0, 0))
    # Color masks (565 format)
    f.write(struct.pack('<III', 0xF800, 0x07E0, 0x001F))

    # Pixel data
    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, height-1-y]  # BMP lưu bottom-up
            rgb565 = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)
            f.write(struct.pack('<H', rgb565))
