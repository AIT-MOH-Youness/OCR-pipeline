from fastapi import FastAPI, UploadFile, File, HTTPException
from PIL import Image, UnidentifiedImageError
import pytesseract
import io
from app.ocr import run_ocr 

app = FastAPI()

@app.get("/")
def health():
    return {"status": "okey"}

@app.get("/doc")
def documentation():
    return {
        "app_name": "OCR API",
        "description": "This application provides Optical Character Recognition (OCR) functionality through a REST API. Upload an image file and extract text content from it using Tesseract OCR engine.",
        "endpoints": {
            "/": "Health check endpoint - returns API status",
            "/doc": "API documentation - describes the application and available endpoints",
            "/ocr": "OCR endpoint - accepts image file upload (POST) and returns extracted text"
        },
        "supported_formats": ["PNG", "JPEG", "JPG", "BMP", "GIF", "TIFF"],
        "usage": "Send a POST request to /ocr with an image file in the 'file' field to extract text from the image"
    }

@app.post("/ocr")
async def ocr_endpoint(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        text = run_ocr(contents)
        return {"extracted_text": text}
    except UnidentifiedImageError:
        raise HTTPException(status_code=400, detail="Invalid image file")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")
