(ns quote-generator-prototype.handler
  (:require [compojure.core :refer :all]
            [compojure.route :as route]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]
            [cheshire.core :as json]
            [ring.middleware.json :as ring-json]
            [ring.util.response :as rr]
            [ring.middleware.anti-forgery :as af]
            [camel-snake-kebab.core :refer :all]
            [quote-generator-prototype.import.parse :as xlsx]
            [quote-generator-prototype.database.file :as db]
            [quote-generator-prototype.jsend :as jsend]
            [hiccup.core :refer :all]
            [hiccup.form :as form]
            [hiccup.element :refer :all]))

(defroutes app-routes
  "The defroutes macro returns a RING handler based on a list of routes, providing the appropriate handler for each request."
  (GET "/" [] (rr/redirect "/app.html"))

  (GET "/import" []
       (html [:form {:action "/import" :method "post" :enctype "multipart/form-data"}
              [:div "Choose a template file to upload for the Quote Generator."]
              [:input {:name "file" :type "file" :size "20"}]
              [:input {:type "submit" :name "submit" :value "Submit"}]
              (form/hidden-field "__anti-forgery-token"
                                 af/*anti-forgery-token*)]))

  (POST "/import" {params :params}
        (let [store (:file  params)
              file (:tempfile store)]
          (xlsx/import (.getPath file))
          (rr/redirect "/imported")))

  (GET "/imported" []
       (html [:div
              [:div [:p "Import succeeded"]]
              [:div (link-to "/" "Go to Quote Generator")]]))

  ;; Endpoint to request antiforgery token, built into RING
  (GET "/antiforgerytoken" []
       (->> {:csrf-token af/*anti-forgery-token*}
            (jsend/success)
            (rr/response)))

  ;; Endpoint to provide a list of products
  (GET "/products" []
       (->> (db/get-products)
            (jsend/success)
            (rr/response)))
  
  ;; Endpoint to provide a list of locales. 
  (GET "/locales" []
       (->> (db/get-locales)
            (jsend/success)
            (rr/response)))

  (GET "/translations/:id" [id]
       (->> (db/get-translations id)
            (jsend/success)
            (rr/response)))
  
  ;; Endpoint to provide a way to save a submitted quote
  (POST "/quote" {body :body}
        (->> {:uuid (db/save-quote body)}
             (jsend/success)
             (rr/response)))

  ;; This line will serve static requrests out of public directory
  (route/resources "/")

  ;; Not found for all other requests.
  (route/not-found "Not Found"))

(def app
  "app-routes our router
wrap-json-response will convert responses to JSON.
wrap-json-body will convert incoming Content-Type application/json to edn as :body.
wrap-defaults uses app-routes as a handler and site-defaults as a config."
  (-> app-routes
      (ring-json/wrap-json-response {:key-fn ->camelCaseString})
      (ring-json/wrap-json-body {:keywords? true :bigdecimals? true})
      (wrap-defaults site-defaults)))
