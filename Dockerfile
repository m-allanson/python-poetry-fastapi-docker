# syntax=docker/dockerfile:1
FROM python:3.12-slim-bookworm AS builder

RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes pipx

ENV PATH="/root/.local/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN pipx install poetry
RUN pipx inject poetry poetry-plugin-bundle

WORKDIR /src

COPY pyproject.toml .
COPY poetry.lock .
COPY README.md .

RUN poetry bundle venv --python=/usr/bin/python3 --only=main /venv

# COPY /venv /venv
COPY . .
ENV PATH="/venv/bin:$PATH"

CMD ["fastapi", "run", "/src/poetry_demo/main.py", "--port", "8000"]

## Now copy in the dependencies and run the app
# FROM python:3.12-slim-bookworm

# COPY --from=builder /venv /venv
# COPY . .
# ENV PATH="/venv/bin:$PATH"

# WORKDIR /src
# CMD ["fastapi", "run", "/src/poetry_demo/main.py", "--port", "8000"]