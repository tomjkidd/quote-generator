(ns quote-generator-prototype.examples.cheshire
  (:require [cheshire.core :as json])
  (:use [clojure.test]))

(def toJsonExample
  "{\"name\":\"Cheshire Cat\",\"state\":\"grinning\"}")

(def fromJsonExample
  "A hashmap that represents the expected result for parse-string"
  {"name" "Cheshire Cat" "state" "grinning"})

(def fromJsonWithKeywordsAsKeys
  "A hashmap that represents the expected result for parse-string using keyword argument."
  {:name "Cheshire Cat" :state "grinning"})

(deftest toJson
  "(require ['cheshire.core :as 'json]) in the repl to use this"
  (is (= toJsonExample
         (json/generate-string {:name "Cheshire Cat" :state :grinning}))))

(deftest fromJson
  (is (= fromJsonExample (json/parse-string toJsonExample)))
  (is (= fromJsonWithKeywordsAsKeys (json/parse-string toJsonExample true))))
