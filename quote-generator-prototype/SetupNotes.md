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

## Build Elm code

        elm-make --warn ./src/Elm/App.elm --output ./resources/public/src/App.js

The client will use Elm to create the UI, and this command creates the JavaScript code that is necessary to run the application in the browser.

### Might be useful
[blog](http://www.gizra.com/content/thinking-choosing-elm/) and [source](https://github.com/Gizra/elm-hedley)

### TODO:
* Get Clojure Dependencies
* Get Elm dependencies
* Create app.html
* Get JS dependencies (maybe with bower?)
* Create JS/Elm boilerplate code