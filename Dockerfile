FROM python:3.12-slim as base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VERSION=1.8.3 \
    POETRY_HOME="/opt/poetry" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false \
    PATH="$POETRY_HOME/bin:$PATH"

# Install Poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && curl -sSL https://install.python-poetry.org | python - \
    && apt-get remove -y curl \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

# =================================

FROM base as builder
WORKDIR /app

ENV POETRY_HOME="/opt/poetry" \
    PATH="$POETRY_HOME/bin:$PATH"

COPY pyproject.toml poetry.lock ./

RUN poetry install --no-dev
RUN poetry env info

# =================================

FROM base as final
WORKDIR /app

# Copy installed packages from the builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY . .

CMD ["fastapi", "run", "/app/poetry_demo/main.py", "--port", "8000"]
