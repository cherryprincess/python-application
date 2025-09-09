# Use specific Python version instead of latest
FROM python:3.11.9-slim-bullseye

# Set metadata
LABEL maintainer="github-copilot" \
      description="Secure Python Flask Application" \
      version="1.0.0"

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /bin/bash appuser

# Set working directory
WORKDIR /app

# Install system dependencies and security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy requirements first for better caching
COPY requirements.txt .

# Upgrade pip and install Python dependencies with security fixes
RUN pip install --no-cache-dir --upgrade pip==24.0 && \
    pip install --no-cache-dir --upgrade setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir --upgrade urllib3==2.0.7 certifi==2023.11.17

# Copy application code
COPY app.py .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# Use gunicorn for production deployment with security settings
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "4", "--timeout", "30", "--keep-alive", "5", "--max-requests", "1000", "--max-requests-jitter", "100", "app:app"]
