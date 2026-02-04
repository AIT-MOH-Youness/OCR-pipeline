from PIL import Image
import pytesseract
import io

def run_ocr(image_bytes):
    image = Image.open(io.BytesIO(image_bytes))
    text = pytesseract.image_to_string(image)
    return text
