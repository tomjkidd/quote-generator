(ns quote-generator-prototype.config)

(def default-config
  {:google-tokeninfo-url "https://www.googleapis.com/oauth2/v3/tokeninfo"})

(defn check-email
  [email]
  (or (= email "tomjkidd@gmail.com")
      (.endsWith email "@gmail.com")))

(defn config
  []
  default-config)
