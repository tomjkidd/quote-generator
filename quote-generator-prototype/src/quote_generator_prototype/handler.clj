(ns quote-generator-prototype.handler
  (:require [compojure.core :refer :all]
            [compojure.route :as route]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]
            [cheshire.core :as json]
            [ring.middleware.json :as ring-json]
            [ring.util.response :as rr]
            [ring.middleware.anti-forgery :as af]
            [quote-generator-prototype.database.file :as db]
            [quote-generator-prototype.jsend :as jsend]))

(defroutes app-routes
  "The defroutes macro returns a RING handler based on a list of routes, providing the appropriate handler for each request."
  (GET "/" [] "Hello World")

  ;; Endpoint to request antiforgery token, built into RING
  (GET "/antiforgerytoken" [] (rr/response {:csrf-token af/*anti-forgery-token*}))

  ;; Endpoint to provide a list of products
  (GET "/products" []
       (->> (db/get-products)
            (jsend/success)
            (rr/response)))

  ;; Endpoint to provide a way to save a submitted quote
  (POST "/quote" [quote]
        (->> {:uuid (db/save-quote quote)}
             (jsend/success)
             (rr/response)))

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
