(ns quote-generator-prototype.jsend
  (:require [compojure.core :refer :all]
            [compojure.route :as route]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]
            [cheshire.core :as json]
            [ring.middleware.json :as ring-json]
            [ring.util.response :as rr]
            [ring.middleware.anti-forgery :as af]
            [quote-generator-prototype.database.file :as db]))

;; Simple interface to provide jsend messages
;; https://labs.omniti.com/labs/jsend

(defn success
  "Create a JSend success message.
Meant for when an API method is called successfully."
  [data]
  {:status :success
   :data data})

(defn fail
  "Create a JSend fail message.
Meant for when an API method is rejected due to invalid data or call conditions."
  [data]
  {:status :fail
   :data data})

(defn error
  "Create a JSend error message.
Meant for when an API call fails due to an error on the server."
  [msg data]
  {:status :error
   :message msg
   :data data})
