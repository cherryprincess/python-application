# Use specific Python version with slim variant for smaller image size
FROM python:3.12.7-slim-bookworm AS base

# Add metadata labels
LABEL maintainer="DevSecOps Team"
LABEL description="Secure Python Flask Application"
LABEL version="1.0.0"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PORT=8080

# Create non-root user with specific UID/GID
RUN groupadd -r appuser -g 1001 && \
    useradd -r -g appuser -u 1001 -m -s /sbin/nologin appuser

# Install security updates and minimal dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && rm -rf /var/cache/apt/archives/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY --chown=appuser:appuser requirements.txt .

# Install Python dependencies as root, then switch to non-root
RUN pip install --no-cache-dir --upgrade pip==24.2 && \
    pip install --no-cache-dir -r requirements.txt && \
    pip check

# Copy application code
COPY --chown=appuser:appuser app.py .
COPY --chown=appuser:appuser config.yaml .

# Create necessary directories with proper permissions
RUN mkdir -p /app/logs && \
    chown -R appuser:appuser /app && \
    chmod -R 755 /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Use gunicorn for production with security settings
CMD ["gunicorn", \
     "--bind", "0.0.0.0:8080", \
     "--workers", "4", \
     "--threads", "2", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "--log-level", "info", \
     "--worker-class", "sync", \
     "--worker-tmp-dir", "/dev/shm", \
     "app:app"]
