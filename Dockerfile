# Dockerfile # Plots2
# https://github.com/publiclab/plots2

FROM ruby:2.6.6-buster

LABEL description="This image deploys Plots2."

# Set correct environment variables.
ENV HOME /root

RUN echo \
   'deb http://ftp.ca.debian.org/debian/ buster main\n \
    deb http://ftp.ca.debian.org/debian/ buster-updates main\n \
    deb http://security.debian.org buster/updates main\n \
    deb http://deb.nodesource.com/node_8.x buster main\n' \
    > /etc/apt/sources.list

# Install dependencies
ADD nodesource.gpg.key /tmp/nodesource.gpg.key
RUN apt-key add /tmp/nodesource.gpg.key && apt-get update -qq \
    && apt-get install --no-install-recommends -y build-essential libmariadbclient-dev \
                wget curl procps cron make nodejs unzip \
                apt-transport-https libfreeimage3 yarnpkg npm

#RUN apt-get install -y fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 \
#                       libatspi2.0-0 libgtk-3-0 libnspr4 libnss3 libx11-xcb1 libxss1 \
#                       libxtst6 xdg-utils phantomjs lsb-release
#RUN wget https://github.com/webnicer/chrome-downloads/raw/master/x64.deb/google-chrome-stable_75.0.3770.142-1_amd64.deb \
#          -O google-chrome.deb && \
#    dpkg -i google-chrome.deb && \
#    apt-get -fy install && \
#    wget https://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_linux64.zip && \
#    unzip chromedriver_linux64.zip && \
#    mv chromedriver /usr/local/bin/chromedriver && \
#    chmod +x /usr/local/bin/chromedriver

ENV BUNDLER_VERSION=2.1.4
WORKDIR /tmp
ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN gem install --default bundler && \
    gem update --system && \
    bundle install --jobs=4

WORKDIR /app
COPY . /app
#COPY Gemfile /app/Gemfile
#COPY Gemfile.lock /app/Gemfile.lock
#COPY start.sh /app/start.sh
COPY ./db/schema.rb.example /app/db/schema.rb
COPY ./config/database.yml.example /app/config/database.yml
RUN yarnpkg

CMD [ "bash", "-l", "start.sh" ]
