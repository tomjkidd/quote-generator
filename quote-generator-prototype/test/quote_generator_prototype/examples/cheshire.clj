(ns quote-generator-prototype.examples.cheshire
  (:require [cheshire.core :as json]))

(def toJsonExample
  "(require ['cheshire.core :as 'json]) in the repl to use this"
  (json/generate-string {:name "Cheshire Cat" :state :grinning}))

(def fromJsonExample
  (json/parse-string toJsonExample))

(def fromJsonWithKeywordsAsKeys
  (json/parse-string toJsonExample true))
