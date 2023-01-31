FROM alpine:3.14
RUN apk add --update --no-cache python3 net-tools
RUN python3 -m ensurepip

ADD ./F1/f1.py ./f1.py
RUN mkdir logs
ENTRYPOINT python3 f1.py
HEALTHCHECK CMD netstat -an | grep 2433 > /dev/null; if [ 0 != $? ]; then exit 1; fi;
HEALTHCHECK CMD netstat -an | grep 2434 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

