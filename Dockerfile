FROM mcr.microsoft.com/oryx/python:3.7-20190712.5
LABEL maintainer="appsvc-images@microsoft.com"

# Web Site Home
ENV HOME_SITE "/home/site/wwwroot"

#Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        openssh-server \
        vim \
        curl \
        wget \
        tcptraceroute \
    && pip install --upgrade pip \
    && pip install subprocess32 \
    && pip install gunicorn \ 
    && pip install virtualenv \
    && pip install flask 

RUN apt-get install -y redis-server

WORKDIR ${HOME_SITE}

EXPOSE 8000
ENV PORT 8000
ENV SSH_PORT 2222

# setup SSH
RUN mkdir -p /home/LogFiles \
     && echo "root:Docker!" | chpasswd \
     && echo "cd /home" >> /etc/bash.bashrc 

COPY sshd_config /etc/ssh/
RUN mkdir -p /opt/startup
COPY init_container.sh /opt/startup/init_container.sh

# setup default site
RUN mkdir /opt/defaultsite
COPY hostingstart.html /opt/defaultsite
COPY application.py /opt/defaultsite

# configure startup
RUN chmod -R 777 /opt/startup
COPY entrypoint.py /usr/local/bin

COPY requirements.txt /usr/local/bin
RUN pip install -r /usr/local/bin/requirements.txt

RUN mkdir -p /etc/redis
COPY 6379.conf /etc/redis

ENTRYPOINT ["/opt/startup/init_container.sh"]