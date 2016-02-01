# Question: How do I POST data to the web server with an anti-forgery token?

In order to do a POST, I had to figure out how to deal with an anti forgery token.

Between these, I was able to coble together a solution:

http://stackoverflow.com/questions/20430281/set-ring-anti-forgery-csrf-header-token

http://stackoverflow.com/questions/30172569/how-can-i-use-ring-anti-forgery-csrf-token-with-latest-version-ring-compojure

### On the server
* Include `ring.middleware.anti-forgery`
    (:require [ring.middleware.anti-forgery :as af])
* Create a handler to expose `*anti-forgery-token*`
    (GET "/antiforgerytoken" [] (rr/response {:csrf-token af/*anti-forgery-token*})

### On the client
* Use the exposed handler to get the anti-forgery-token
* Locate `Cookie` header to get `ring-session` cookie
* Create `X-CSRF-Token` using the anti-forgery-token
* Perform POST with `Cookie` and `X-CSRF-Token` headers

# Question: How does `lein ring server` actually serve my app?

The [ring-server](https://github.com/weavejester/ring-server/blob/master/src/ring/server/standalone.clj) project makes the call to `run-jetty` with the handler specified in project.clj at `:ring {:handler quote-generator-prototype.handler/app}`.

This handler uses Compojure to route requests to their appropriate handlers.

I found `ring-server` while investigating the [lein-ring](https://github.com/weavejester/lein-ring/blob/master/src/leiningen/ring/server.clj) plugin, because it was a dependency.

This all started because I read through the [ring](https://github.com/ring-clojure/ring) source code, which includes `ring-jetty-adapter`.

The Ring [SPEC](https://github.com/ring-clojure/ring/blob/master/SPEC) was very helpful to understand all of the pieces involved in the http request/response cycle.

## Request/Response cycle

### Request

    Client    Adapter          Handler
       _         _                _
      |_|------>|_|------------->|_|
          http      request map
         request


### Response

    Client    Adapter          Handler
       _         _                _
      |_|<------|_|<-------------|_|
          http      response map
        response

### RING Notes
* The `Client` sends an http request to the server
* The http request reaches the `Adapter` and is converted into a `request map`
* The `request map` is passed to a `Handler`, which is composed of `middleware` functions (also called handlers). Through these middleware calls, a `response map` is created.
* The `response map` is passed to the `Adapter`, where it is turned into an http response.
* The http response is returned to the `Client`.

### Implementation Notes
* [Jetty](http://www.eclipse.org/jetty/) is used to create an `Adapter` in [ring-server](https://github.com/weavejester/ring-server) which will handle incoming and outgoing http requests and responses.
* Using the compojure template for lein, a `Handler` is created to allow the developer to take `request maps` and turn them into `response maps`
* This is useful because we can use simple Clojure structures to describe the data and manipulations we want to perform, and the `Adapter` will handle the details.
* The Ring implementation provides a [Servlet](https://tomcat.apache.org/tomcat-5.5-doc/servletapi/javax/servlet/http/package-summary.html), which is used to define provide hooks into Clojure for the Jetty Adapter. The Servlet code is used "for turning a ring handler into a Java servlet".
* The Jetty Adapter takes an http request and uses the Servlet to build the `request map`(build-request-map), pass the `request map` to the Compojure `Handler` to get a `response map`, and then use the `response map` to upate the Servlet response (update-servlet-response). After this, a response is considered handled.
* The Jetty Adapter implements [handle](http://download.eclipse.org/jetty/9.3.6.v20151106/apidocs/org/eclipse/jetty/server/Handler.html#handle-java.lang.String-org.eclipse.jetty.server.Request-javax.servlet.http.HttpServletRequest-javax.servlet.http.HttpServletResponse-), allowing Clojure to define how to do this work, and then .setHandled is called. I think this could be loosely based on [Jetty's hello world](https://wiki.eclipse.org/Jetty/Tutorial/Jetty_HelloWorld). [Another example](https://wiki.eclipse.org/Jetty/Tutorial/Embedding_Jetty)
