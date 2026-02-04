from fastapi import FastAPI, UploadFile, File
from PIL import Image
import pytesseract
import io
from app.ocr import run_ocr 

app = FastAPI()

@app.get("/")
def health():
    return {"status": "ok"}

@app.post("/ocr")
async def ocr_endpoint(file: UploadFile = File(...)):
    contents = await file.read()
    text = run_ocr(contents)
    return {"extracted_text": text}
