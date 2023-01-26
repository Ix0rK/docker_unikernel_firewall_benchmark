FROM alpine:3.14
RUN apk add --update --no-cache python3
RUN python3 -m ensurepip

ADD ./U1/u1.py ./u1.py
RUN mkdir logs
ENTRYPOINT python3 u1.py
