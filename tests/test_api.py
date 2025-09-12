import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, create_engine, SQLModel
from app.api import app
from app.database import get_session


@pytest.fixture
def test_db():
    engine = create_engine("sqlite:///:memory:")
    SQLModel.metadata.create_all(engine)
    
    def get_test_session():
        with Session(engine) as session:
            yield session
    
    app.dependency_overrides[get_session] = get_test_session
    yield
    app.dependency_overrides.clear()


@pytest.fixture
def client(test_db):
    return TestClient(app)


class TestAnalyzeEndpoint:
    def test_analyze_text_success(self, client):
        response = client.post(
            "/analyze",
            json={"text": "This is a positive review about a great product. The customer is very happy with the quality and service."}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert "title" in data
        assert len(data["topics"]) == 3
        assert data["sentiment"] in ["positive", "neutral", "negative"]
        assert len(data["keywords"]) <= 3
        assert 0.0 <= data["confidence_score"] <= 1.0
    
    def test_analyze_empty_text(self, client):
        response = client.post(
            "/analyze",
            json={"text": ""}
        )
        
        assert response.status_code == 422
    
    def test_analyze_whitespace_only_text(self, client):
        response = client.post(
            "/analyze",
            json={"text": "   \n\t   "}
        )
        
        assert response.status_code == 422
    
    def test_health_check(self, client):
        response = client.get("/health")
        
        assert response.status_code == 200
        assert response.json() == {"status": "healthy"}