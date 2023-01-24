FROM alpine:3.14
RUN apk add --update --no-cache python3
RUN python3 -m ensurepip

ADD u1.py ./u1.py

ENTRYPOINT python3 u1.py
