FROM python:3.12-slim
RUN pip install --no-cache-dir sympy==1.13.3 && useradd -u 10001 -m sbx
USER 10001
WORKDIR /w
