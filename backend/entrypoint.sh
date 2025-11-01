#!/bin/bash
set -e

echo "Starting Quran Memorizer Backend..."

# Wait for database to be ready (if using PostgreSQL)
if [[ "${DATABASE_URL}" == postgresql* ]]; then
    echo "Waiting for PostgreSQL to be ready..."
    if command -v pg_isready &> /dev/null; then
        while ! pg_isready -h postgres -p 5432 -U ${POSTGRES_USER:-quran_user} > /dev/null 2>&1; do
            sleep 1
        done
        echo "PostgreSQL is ready!"
    else
        echo "Waiting 5 seconds for PostgreSQL..."
        sleep 5
    fi
fi

# Create database tables
echo "Creating database tables..."
python -c "from database.database import create_tables; create_tables()" || echo "Database tables creation completed"

# Run the application
echo "Starting FastAPI application..."
exec python -m uvicorn api.main:app --host ${API_HOST:-0.0.0.0} --port ${API_PORT:-8000}
