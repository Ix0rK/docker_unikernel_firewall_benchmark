FROM alpine:3.14
RUN apk add --update --no-cache python3
RUN python3 -m ensurepip

ADD f1.py ./f1.py

ENTRYPOINT python3 f1.py

