from python:3.12-slim-bookworm AS builder

RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes pipx
ENV PATH="/root/.local/bin:${PATH}"

RUN pipx install poetry
RUN pipx inject poetry poetry-plugin-bundle

WORKDIR /src
COPY . .

RUN poetry bundle venv --python=/usr/bin/python3 --only=main /venv
# ENTRYPOINT ["/venv/bin/poetry_demo"]

CMD ["/venv/bin/fastapi", "run", "/src/poetry_demo/main.py", "--port", "8000"]