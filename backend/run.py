"""
Run the FastAPI application
"""

import uvicorn
from api.main import app
from database.database import create_tables
import os

if __name__ == "__main__":
    # Create database tables
    create_tables()
    
    # Run the application
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        reload=True,  # Enable auto-reload in development
        log_level="info"
    )
