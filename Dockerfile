FROM node:18.12.0-alpine3.16 AS web

WORKDIR /opt/vue-fastapi-admin
COPY /web ./web
RUN cd /opt/vue-fastapi-admin/web && npm i --registry=https://registry.npmmirror.com && npm run build

FROM python:3.11-slim-bullseye

RUN sed -i "s@http://.*.debian.org@http://mirrors.ustc.edu.cn@g" /etc/apt/sources.list \
    && echo "Asia/Shanghai" > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update -o Acquire::Check-Valid-Until=false \
    && apt-get install -y --no-install-recommends gcc python3-dev nginx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/vue-fastapi-admin
COPY requirements.txt .
RUN pip install --user -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple \
    && python -m pip cache purge

COPY . .
COPY --from=web /opt/vue-fastapi-admin/web/dist ./web/dist
COPY /deploy/web.conf /etc/nginx/sites-available/web.conf

RUN ln -sf /etc/nginx/sites-available/web.conf /etc/nginx/sites-enabled/ \
    && rm -f /etc/nginx/sites-enabled/default

ENV LANG=zh_CN.UTF-8
EXPOSE 80
ENTRYPOINT [ "sh", "entrypoint.sh" ]