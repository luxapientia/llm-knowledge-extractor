from fastapi import FastAPI, Depends, HTTPException
from sqlmodel import Session, select, or_, text
from typing import List
from app.database import get_session, create_db_and_tables
from app.models import AnalysisResult
from app.schemas import AnalysisRequest, AnalysisResponse, ErrorResponse
from app.services.analysis_service import analysis_service


app = FastAPI(title="LLM Knowledge Extractor", version="1.0.0")


@app.on_event("startup")
def on_startup():
    create_db_and_tables()


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


@app.post("/analyze", response_model=AnalysisResponse)
async def analyze_text(
    request: AnalysisRequest,
    session: Session = Depends(get_session)
):
    try:
        analysis_data = analysis_service.analyze_text(request.text)
        
        analysis_result = AnalysisResult(**analysis_data)
        session.add(analysis_result)
        session.commit()
        session.refresh(analysis_result)
        
        return AnalysisResponse(
            id=analysis_result.id,
            title=analysis_result.title,
            topics=analysis_result.topics,
            sentiment=analysis_result.sentiment,
            keywords=analysis_result.keywords,
            confidence_score=analysis_result.confidence_score,
            created_at=analysis_result.created_at.isoformat()
        )
    
    except ValueError:
        raise HTTPException(status_code=422, detail="Empty input")
    except Exception as e:
        if "LLM request failed" in str(e):
            raise HTTPException(status_code=500, detail="LLM request failed")
        raise HTTPException(status_code=500, detail="Internal server error")


@app.get("/search", response_model=List[AnalysisResponse])
async def search_analyses(
    topic: str,
    session: Session = Depends(get_session)
):
    # Simple search implementation - get all records and filter in Python
    statement = select(AnalysisResult)
    all_results = session.exec(statement).all()
    
    # Filter results that contain the topic in topics or keywords
    results = []
    for result in all_results:
        if (topic.lower() in [t.lower() for t in result.topics] or 
            topic.lower() in [k.lower() for k in result.keywords]):
            results.append(result)
    
    return [
        AnalysisResponse(
            id=result.id,
            title=result.title,
            topics=result.topics,
            sentiment=result.sentiment,
            keywords=result.keywords,
            confidence_score=result.confidence_score,
            created_at=result.created_at.isoformat()
        )
        for result in results
    ]