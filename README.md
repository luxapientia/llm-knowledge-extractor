# LLM Knowledge Extractor

A production-quality prototype system that extracts structured knowledge from unstructured text using OpenAI's function calling API and spaCy for deterministic keyword extraction.

## Features

- **Text Analysis**: Extracts title, topics, sentiment, and keywords from unstructured text
- **AI Integration**: Uses OpenAI GPT-4.1 with function calling for structured data extraction
- **Deterministic Keywords**: spaCy-based noun frequency analysis for consistent keyword extraction
- **PostgreSQL Storage**: Robust data persistence with SQLModel ORM
- **RESTful API**: FastAPI-based endpoints for analysis and search
- **Containerized**: Docker and Docker Compose for easy deployment
- **Testing**: Comprehensive unit and integration tests

## API Endpoints

- `POST /analyze` - Analyze text and return structured results
- `GET /search?topic=xyz` - Search analyses by topic or keyword
- `GET /health` - Health check endpoint

## Quick Start

### Prerequisites

- **For Local Development**: Python 3.8+, PostgreSQL, pip3
- **For Production**: Docker and Docker Compose
- OpenAI API key

### Local Development Setup

1. Clone the repository:
```bash
git clone https://github.com/luxapientia/llm-knowledge-extractor.git
cd llm-knowledge-extractor
```

2. Run the automated setup script:
```bash
./scripts/setup.sh
```

This script will:
- Check system dependencies (Python 3, PostgreSQL)
- Set up environment configuration
- Create PostgreSQL database and user
- Install Python dependencies
- Download spaCy model
- Run database migrations
- Execute test suite

3. Start the development server:
```bash
./scripts/start.sh
```

The API will be available at `http://localhost:8000`

**Interactive API Documentation:**
- **Swagger UI**: `http://localhost:8000/docs` - **Test all endpoints directly in the browser!**
- **ReDoc**: `http://localhost:8000/redoc` - Alternative documentation view

### Production Deployment

1. Copy environment configuration:
```bash
cp env.example .env
```

2. Edit `.env` and add your OpenAI API key:
```
OPENAI_API_KEY=your_openai_api_key_here
```

3. Deploy with Docker:
```bash
./scripts/deploy.sh
```

The API will be available at `http://localhost:8000`

## Development Scripts

The project includes several shell scripts and a Makefile to simplify development:

### Database Management
```bash
./scripts/migrate.sh                    # Apply migrations
./scripts/migrate.sh create "message"   # Create new migration
./scripts/migrate.sh downgrade          # Rollback last migration
./scripts/reset_db.sh                   # Reset database (development only)
```

### Testing
```bash
./scripts/test.sh                       # Run all tests
./scripts/test.sh --coverage            # Run with coverage report
./scripts/test.sh --file test_api.py    # Run specific test file
```

### Development Server
```bash
./scripts/start.sh                      # Start development server with hot reload
```

### Production Deployment
```bash
./scripts/deploy.sh                     # Deploy with Docker Compose
./scripts/deploy.sh --build             # Deploy with rebuild
./scripts/deploy.sh down                # Stop application
./scripts/deploy.sh restart             # Restart application
```

### Using Make (Alternative)
```bash
make setup                              # Set up development environment
make start                              # Start development server
make test                               # Run tests
make test-cov                           # Run tests with coverage
make migrate                            # Apply migrations
make migrate-create MSG="message"       # Create new migration
make deploy                             # Deploy with Docker
make stop                               # Stop application
make help                               # Show all commands
```

## API Usage Examples

### Analyze Text

```bash
curl -X POST "http://localhost:8000/analyze" \
     -H "Content-Type: application/json" \
     -d '{"text": "This is a positive review about our new product. The customer loves the quality and excellent customer service."}'
```

### Search Analyses

```bash
curl "http://localhost:8000/search?topic=product"
```

## Design Choices and Trade-offs

**Architecture**: The system uses a clean service-oriented architecture with separate concerns for OpenAI integration, keyword extraction, and database operations. This modular design enables easy testing and future extensibility.

**Database Choice**: PostgreSQL was selected over SQLite for production readiness, offering better concurrency handling and advanced features. SQLModel provides type safety and automatic schema generation while maintaining SQLAlchemy's power.

**AI Integration**: OpenAI's function calling API ensures structured, reliable output compared to prompt-based approaches. The deterministic spaCy keyword extraction provides consistency and avoids LLM variability for this specific task.

**Error Handling**: Comprehensive error handling distinguishes between client errors (empty input) and service failures (LLM API issues), providing appropriate HTTP status codes and structured error responses.

**Containerization**: Docker Compose simplifies deployment and ensures consistent environments across development and production, with health checks for reliable orchestration.

## Project Structure

```
llm-knowledge-extractor/
├── app/
│   ├── __init__.py
│   ├── api.py              # FastAPI application and endpoints
│   ├── config.py           # Configuration management
│   ├── database.py         # Database connection and session management
│   ├── models.py           # SQLModel database models
│   ├── schemas.py          # Pydantic request/response schemas
│   └── services/
│       ├── __init__.py
│       ├── analysis_service.py    # Main analysis orchestration
│       ├── keyword_extractor.py   # spaCy-based keyword extraction
│       └── openai_service.py      # OpenAI API integration
├── scripts/                # Development and deployment scripts
│   ├── utils.sh            # Shared utility functions
│   ├── setup.sh           # Local development setup
│   ├── start.sh            # Development server starter
│   ├── test.sh             # Test runner
│   ├── migrate.sh          # Database migration helper
│   ├── reset_db.sh         # Database reset (dev only)
│   └── deploy.sh           # Production deployment
├── alembic/                # Database migrations
├── tests/                  # Test suite
├── docker-compose.yml      # Container orchestration
├── Dockerfile             # Application container
├── requirements.txt       # Python dependencies
└── README.md             # This file
```

## Environment Variables

- `DATABASE_URL`: PostgreSQL connection string
- `OPENAI_API_KEY`: OpenAI API key for LLM integration
- `ENVIRONMENT`: Application environment (development/production)

## License

This project is licensed under the MIT License.
