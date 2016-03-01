####
# Dockerfile to build image for quote-generator-prototype
# Based on Ubuntu
####

FROM ubuntu

MAINTAINER tomjkidd@gmail.com

# This doesn't seem to work right now.
ENV LEIN_ROOT 1

RUN apt-get update

RUN apt-get install -y default-jre
RUN apt-get install -y git

RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN apt-get install -y nodejs-legacy npm
RUN apt-get install -y build-essential

RUN sudo npm install -g elm

RUN apt-get update

COPY ./backup ./backup
COPY ./data ./data
COPY ./quotes ./quotes
COPY ./resources ./resources
COPY ./src ./src
COPY ./build-elm.sh ./build-elm.sh
COPY ./elm-package.json ./elm-package.json
COPY ./project.clj ./project.clj

RUN elm-package install -y

#ENV LANG en_US.UTF-8

ENV ELM_HOME /usr/local/lib/node_modules/elm/share

RUN apt-get install -y locales

#RUN sudo dpkg-reconfigure locales && \
#         locale-gen C.UTF-8 && \
#         update-locale LANG=C.UTF-8

ENV LC_ALL C.UTF-8

RUN elm-make --warn ./src/Elm/App.elm --output ./resources/public/src/App.js

RUN apt-get install -y wget
#RUN cd ~; sudo mkdir bin; cd bin; wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein; chmod 755 lein; ./lein; cd ~

#RUN cd ~;  wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein; chmod 755 lein; ./lein;

RUN wget -q -O /usr/bin/lein \
    https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
    && chmod +x /usr/bin/lein

RUN lein

EXPOSE 80

CMD ["sudo",  "lein", "ring", "server-headless", "80"]

# CMD sudo lein ring server-headless 80

# Build the image
# sudo docker build -t tomjkidd/quote-generator-prototype .

# Run the image
# docker run -p 3000:80 -d tomjkidd/quote-generator-prototype
