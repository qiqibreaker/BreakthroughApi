FROM python:3.11-slim-bullseye

RUN echo "Asia/Shanghai" > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update -o Acquire::Check-Valid-Until=false \
    && apt-get install -y --no-install-recommends gcc python3-dev nginx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /breakthroughapi
COPY . .
RUN pip install --user -r requirements.txt \
    && python -m pip cache purge

ENV LANG=zh_CN.UTF-8
ENTRYPOINT [ "sh", "entrypoint.sh" ]