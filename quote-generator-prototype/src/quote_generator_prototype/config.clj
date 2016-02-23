(ns quote-generator-prototype.config)

(def default-config
  {:google-tokeninfo-url "https://www.googleapis.com/oauth2/v3/tokeninfo"
   :google-signin-client_id "340643924958-ihudkoaue6b2h19j95oui5rs28ebd20l.apps.googleusercontent.com"})

(defn check-email
  [email]
  (or (= email "tomjkidd@gmail.com")
      (.endsWith email "@gmail.com")))

(defn config
  []
  default-config)
