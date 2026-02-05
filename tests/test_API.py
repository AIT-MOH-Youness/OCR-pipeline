from fastapi.testclient import TestClient
from app.main import app
from io import BytesIO
from PIL import Image

client = TestClient(app)

def test_health():
    response = client.get("/")
    assert response.status_code == 200


def test_health_response_content():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "okey"}


def test_ocr_endpoint_with_valid_image():
    # Create a simple test image
    img = Image.new('RGB', (200, 100), color='white')
    img_bytes = BytesIO()
    img.save(img_bytes, format='PNG')
    img_bytes.seek(0)
    
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
    
    response = client.post(
        "/ocr",
        files={"file": ("test.png", img_bytes, "image/png")}
    )
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, dict)
    assert "extracted_text" in data
    assert isinstance(data["extracted_text"], str)

