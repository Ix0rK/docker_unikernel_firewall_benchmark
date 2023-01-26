FROM alpine:3.14
RUN apk add --update --no-cache python3
RUN python3 -m ensurepip

ADD ./U3/u3.py ./u3.py

ENTRYPOINT python3 u3.py

