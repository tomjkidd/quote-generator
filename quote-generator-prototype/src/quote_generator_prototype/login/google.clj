(ns quote-generator-prototype.login.google
  (:require [clojure.core :refer :all]
            [clj-http.client :as client]
            [cheshire.core :as json]))

(def tokeninfo-endpoint-url
  "https://www.googleapis.com/oauth2/v3/tokeninfo")

(defn- is-valid?
  [id-token]
  ;; https://developers.google.com/identity/sign-in/web/backend-auth
  ;; There are 2 methods, is-valid-external handles the first.
  ;; TODO: is-valid? should be a Java Interop one that unpacks the JWT.
  
  ;;TODO: Unpack the email
  ;;TODO: Validate the email
  ;;TODO: Return true if login is valid
  false)

(defn check-claims
  [claims]
  (let [email (:email claims)
        client-id (:aud claims)
        email-verified (= "true" (:email_verified claims))
        expire-epoch-str (:exp claims)
        name (:name claims)
        local (:locale claims)]
    (or (= email "tomjkidd@gmail.com")
        (.endsWith email "@crimsonhexagon.com"))))

(defn is-valid-external?
  "Use the google `tokeninfo` endpoint to unpack the token."
  [id-token]
  (try
    (let [response (client/get tokeninfo-endpoint-url {:query-params {"id_token" id-token}})
          success (= 200 (:status response))
          claims (:body response)]
      (if (not success)
        false
        (check-claims (json/parse-string claims true))))
    
    ;; TODO: Provide more info about if error was due call out to google.
    (catch Exception _
      false)))

(defn login
  [id-token]
  (is-valid-external? id-token))
