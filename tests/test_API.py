from fastapi.testclient import TestClient
from app.main import app
from io import BytesIO
from PIL import Image
from unittest.mock import patch

client = TestClient(app)

def test_health():
    response = client.get("/")
    assert response.status_code == 200


def test_health_response_content():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "okey"}


def test_doc_endpoint():
    response = client.get("/doc")
    assert response.status_code == 200


def test_doc_response_structure():
    response = client.get("/doc")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, dict)
    assert "app_name" in data
    assert "description" in data
    assert "endpoints" in data
    assert "supported_formats" in data
    assert "usage" in data


def test_doc_response_content():
    response = client.get("/doc")
    data = response.json()
    assert data["app_name"] == "OCR API"
    assert isinstance(data["endpoints"], dict)
    assert "/" in data["endpoints"]
    assert "/doc" in data["endpoints"]
    assert "/ocr" in data["endpoints"]
    assert isinstance(data["supported_formats"], list)
    assert len(data["supported_formats"]) > 0


def test_ocr_endpoint_with_valid_image():
    # Create a simple test image
    img = Image.new('RGB', (200, 100), color='white')
    img_bytes = BytesIO()
    img.save(img_bytes, format='PNG')
    img_bytes.seek(0)
    
    # Mock the OCR function to avoid Tesseract dependency
    with patch('app.main.run_ocr', return_value="Sample extracted text"):
        response = client.post(
            "/ocr",
            files={"file": ("test.png", img_bytes, "image/png")}
        )
        assert response.status_code == 200
        assert "extracted_text" in response.json()


def test_ocr_endpoint_missing_file():
    response = client.post("/ocr")
    assert response.status_code == 422  # Unprocessable Entity


def test_ocr_endpoint_with_invalid_file():
    # Send non-image data
    invalid_data = BytesIO(b"not an image")
    response = client.post(
        "/ocr",
        files={"file": ("test.txt", invalid_data, "text/plain")}
    )
    # Should return 400 for invalid image
    assert response.status_code == 400
    assert "Invalid image file" in response.json()["detail"]


def test_ocr_endpoint_with_jpg_image():
    img = Image.new('RGB', (200, 100), color='white')
    img_bytes = BytesIO()
    img.save(img_bytes, format='JPEG')
    img_bytes.seek(0)
    
    # Mock the OCR function to avoid Tesseract dependency
    with patch('app.main.run_ocr', return_value="Sample extracted text from JPEG"):
        response = client.post(
            "/ocr",
            files={"file": ("test.jpg", img_bytes, "image/jpeg")}
        )
        assert response.status_code == 200
        assert "extracted_text" in response.json()


def test_ocr_endpoint_response_structure():
    img = Image.new('RGB', (200, 100), color='white')
    img_bytes = BytesIO()
    img.save(img_bytes, format='PNG')
    img_bytes.seek(0)
    
    # Mock the OCR function to avoid Tesseract dependency
    with patch('app.main.run_ocr', return_value="Mocked text"):
        response = client.post(
            "/ocr",
            files={"file": ("test.png", img_bytes, "image/png")}
        )
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, dict)
        assert "extracted_text" in data
        assert isinstance(data["extracted_text"], str)

