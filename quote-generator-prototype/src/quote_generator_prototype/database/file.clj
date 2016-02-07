(ns quote-generator-prototype.database.file
  (:require [clojure.java.io :as io]
            [clj-time.core :as t]
            [clj-time.format :as f]
            [clj-uuid :as uuid]
            [cheshire.core :as json]))

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

(defn get-products
  "Get the products (and nested features) for the system."
  []
  (->> "products.edn"
       (slurp)
       (read-string)))

(defn get-quote
  "TODO: Implement this function to retrieve a quote by uuid"
  []
  nil)

(defn save-quote
  "Save a quote, identified by Uuid"
  [json-quote]
  (let [uuid (uuid/v4)
        edn-quote (json/parse-string json-quote true)]
    ;; TODO: Quote comes in as JSON, switch to edn.
    (spit (str "./quotes/" uuid ".edn") (pr-str edn-quote))
    uuid))

