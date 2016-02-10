# Purpose

This file is around to keep track of the build/release information that was used to create the project so that it:

* can serve as a starting point for another project
* could be automated if necessary

# Setup
## Create Compojure Project

        lein new compojure quote-generator-prototype

The server will use Clojure to respond to HTTP requests, and this command creates artifacts that support creating the server.

## Clojure Dependencies

        [cheshire "5.5.0"]
        [ring/ring-json "0.4.0"]

These libraries provide functionality that the server will utilize and were added to the `project.clj` file. The default Compojure template includes `org.clojure/clojure`, `compojure`, `ring/ring-defaults`.

## Install Elm

        npm install -g elm

To build and run Elm, it can be installed through npm. Note, this means node.js is a prerequisite.

## Get Elm Dependencies
        elm-package install elm-lang/core
        elm-package install evancz/elm-effects
        elm-package install evancz/elm-html
        elm-package install evancz/elm-http
        elm-package install evancz/start-app

## Build Elm code

        elm-make --warn ./src/Elm/App.elm --output ./resources/public/src/App.js

The client will use Elm to create the UI, and this command creates the JavaScript code that is necessary to run the application in the browser. For now this is the only file, and should completely define the application.

NOTE: *App.js* is *NOT* in git because it gets generated through this Elm build step, and is subject to change frequently while in development.

## Run Web Server

        lein ring server

This command will set up a process that manages the server.

## Deploy to EC2 (Ubuntu Instance)

### Shell Commands
Get hostname (needed for lein ring server)

        $HOSTNAME

Edit hosts file to include hostname

        cd /etc
        sudo nano hosts

Install Java and Git

        sudo apt-get install default-jre
        sudo apt-get install git

Install Node

        curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
        sudo apt-get install -y nodejs
        sudo apt-get install -y build-essential

Install Elm

        sudo npm install -g elm

Install Leiningen

        cd /home/ubuntu
        sudo mkdir bin
        cd bin
        wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
        chmod 755 lein
        ./lein
        cd ~

Install Quote Generator
        git clone https://github.com/tomjkidd/quote-generator.git
        cd /quote-generator/qoute-generator-prototype
        elm-make --warn ./src/Elm/App.elm --output ./resources/public/src/App.js
        lein install

Start Server with No Hang Up

        sudo nohup lein ring server-headless 80 &

Verify Server still running

        clear
        ps aux | grep nohup

Emacs, if you want

        sudo apt-get install emacs


### Reference
[Use Putty for login to EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html)

[Install Nodejs through package manager](https://nodejs.org/en/download/package-manager/)

A [Stack Overflow answer](http://stackoverflow.com/questions/14238665/can-a-public-ip-address-be-used-as-google-oauth-redirect-uri) was used to figure out how to configure the Authorized Javascript origins from the Google Developers Console. NOTE: IP address was not sufficient, it needed a proper hostname.

Find hostname of EC2 for Google login

        wget http://www.displaymyhostname.com

[SCP to EC2](http://stackoverflow.com/questions/11388014/using-scp-to-copy-a-file-to-amazon-ec2-instance)

history | grep <keyword>

[Elm Blog post](http://www.gizra.com/content/thinking-choosing-elm/) and [Elm Example App](https://github.com/Gizra/elm-hedley)

[No Hang Up](http://stackoverflow.com/questions/12075642/how-to-start-process-via-ssh-so-it-keeps-running)

[Non-interactie apt-get](https://snowulf.com/2008/12/04/truly-non-interactive-unattended-apt-get-install/)
