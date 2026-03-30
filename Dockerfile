FROM ubuntu:22.04

LABEL name="httpbin"
LABEL version="0.9.2"
LABEL description="A simple HTTP service."
LABEL org.kennethreitz.vendor="Kenneth Reitz"

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update -y && apt-get install --no-install-recommends python3-pip git -y \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir pipenv

COPY Pipfile Pipfile.lock /httpbin/
WORKDIR /httpbin
RUN /bin/bash -c "pip3 install --no-cache-dir -r <(pipenv lock -r)"

COPY . /httpbin
RUN pip3 install --no-cache-dir /httpbin

# Run as non-root user to limit impact of container compromise
RUN groupadd -r httpbin && useradd -r -g httpbin -d /httpbin -s /sbin/nologin httpbin \
    && chown -R httpbin:httpbin /httpbin
USER httpbin

EXPOSE 80

CMD ["gunicorn", "-b", "0.0.0.0:80", "httpbin:app", "-k", "gevent"]
