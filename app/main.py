from fastapi import FastAPI, UploadFile, File, HTTPException
from PIL import Image, UnidentifiedImageError
import pytesseract
import io
from app.ocr import run_ocr 

app = FastAPI()

@app.get("/")
def health():
    return {"status": "okey"}

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
