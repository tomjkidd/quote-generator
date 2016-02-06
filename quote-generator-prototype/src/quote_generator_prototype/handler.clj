(ns quote-generator-prototype.handler
  (:require [compojure.core :refer :all]
            [compojure.route :as route]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]
            [cheshire.core :as json]
            [ring.middleware.json :as ring-json]
            [ring.util.response :as rr]
            [ring.middleware.anti-forgery :as af]
            [clojure.java.io :as io]
            [clj-time.core :as t]
            [clj-time.format :as f]))

(defroutes app-routes
  "The defroutes macro returns a RING handler based on a list of routes, providing the appropriate handler for each request."
  (GET "/" [] "Hello World")

  ;; Endpoint to request antiforgery token, built into RING
  (GET "/antiforgerytoken" [] (rr/response {:csrf-token af/*anti-forgery-token*}))

  ;; Endpoint to provide a list of products
  (GET "/products" []
       (rr/response {:data "TODO: Actually implement this!"}))

  ;; This line will serve static requrests out of public directory
  (route/resources "/")

  ;; Not found for all other requests.
  (route/not-found "Not Found"))

(def app
  "app-routes our router
wrap-json-response will convert responses to JSON.
wrap-defaults uses app-routes as a handler and site-defaults as a config."
  (-> app-routes
      (ring-json/wrap-json-response)
      (wrap-defaults site-defaults)))

(defn backup-then-spit
  "Used to create or replace a file, but will back the file up first, if it exists.

For formatter:
http://www.joda.org/joda-time/key_format.html"
  [filepath contents]
  (let [file (io/as-file filepath)
        file-exists (.exists file)
        now (t/now)
        backup-formatter (f/formatter "yyyyMMdd-HHmmss-z.")
        filename (.getName file)
        new-filename (str "./backup/" (f/unparse backup-formatter now) filename)]

    (when file-exists
      (spit new-filename (slurp filepath)))
    (spit filename contents)))

(defn load-products
  "Load a new set of products. This replaces the current one.

This function will create a backup."
  [products]
  (->> products
       (pr-str)
       (backup-then-spit "products.edn")))
