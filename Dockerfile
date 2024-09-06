FROM python:3

ARG COMMAND
VOLUME /workdir
WORKDIR /workdir

ADD . /workdir

RUN apt-get update && apt-get install -y software-properties-common wget gnupg

RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && apt install -y terraform

RUN git config --global --add safe.directory /workdir

ENTRYPOINT ["/workdir/scripts/tooling.py"]
