FROM alpine:3.14
RUN apk add --update --no-cache python3
RUN python3 -m ensurepip

ADD u2.py ./u2.py

ENTRYPOINT python3 u2.py
