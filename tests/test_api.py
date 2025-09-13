import pytest
from unittest.mock import Mock, patch
from fastapi.testclient import TestClient
from app.api import app
from app.database import get_session
from app.models import Sentiment


@pytest.fixture
def mock_analysis_service():
    """Mock analysis service for testing"""
    with patch('app.api.analysis_service') as mock:
        mock.analyze_text.return_value = {
            "title": "Test Analysis",
            "topics": ["topic1", "topic2", "topic3"],
            "sentiment": Sentiment.POSITIVE,
            "keywords": ["keyword1", "keyword2"],
            "confidence_score": 0.8,
            "raw_text": "Test text"
        }
        yield mock


@pytest.fixture
def mock_session():
    """Mock database session"""
    session = Mock()
    session.add.return_value = None
    session.commit.return_value = None
    session.refresh.side_effect = lambda obj: setattr(obj, 'id', 1)
    return session


@pytest.fixture
def client(mock_analysis_service, mock_session):
    """Test client with mocked dependencies"""
    def mock_get_session():
        yield mock_session

    app.dependency_overrides[get_session] = mock_get_session

    yield TestClient(app)

    app.dependency_overrides.clear()


class TestAPI:
    def test_analyze_text_success(self, client):
        """Test successful text analysis"""
        response = client.post(
            "/analyze",
            json={"text": "This is a positive review about a great product."}
        )

        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert "title" in data
        assert len(data["topics"]) == 3
        assert data["sentiment"] in ["positive", "neutral", "negative"]
        assert len(data["keywords"]) <= 3
        assert 0.0 <= data["confidence_score"] <= 1.0

    def test_analyze_missing_text(self, client):
        """Test analysis with missing text field"""
        response = client.post(
            "/analyze",
            json={}
        )

        assert response.status_code == 422

    def test_search_endpoint(self, client):
        """Test search functionality"""
        with patch('app.api.select') as mock_select:
            mock_select.return_value = Mock()

            # Mock session.exec to return empty results for simplicity
            def mock_get_session():
                session = Mock()
                session.exec.return_value.all.return_value = []
                yield session

            app.dependency_overrides[get_session] = mock_get_session

            response = client.get("/search?topic=test")

            assert response.status_code == 200
            assert response.json() == []

            app.dependency_overrides.clear()

    def test_health_check(self, client):
        """Test health endpoint"""
        response = client.get("/health")

        assert response.status_code == 200
        assert response.json() == {"status": "healthy"}