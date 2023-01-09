FROM alpine:3.14
RUN apk add --update --no-cache python2 iptables build-base linux-headers python2-dev libnetfilter_queue-dev
RUN python2 -m ensurepip

ADD ./pywall ./pywall
WORKDIR ./pywall

RUN pwd

RUN pip install -r requirements.txt
ADD ./f1-rules.json .
RUN python2 main.py ./f1-rules.json
