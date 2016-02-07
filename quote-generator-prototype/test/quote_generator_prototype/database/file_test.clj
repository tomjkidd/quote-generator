(ns quote-generator-prototype.database.file-test
  (:require [clojure.test :refer :all]
            [cheshire.core :as json]
            [quote-generator-prototype.database.file :refer :all]
            [clojure.java.io :as io]))

(deftest save-qoute
  (testing "save-quote"
    (is
     (let [uuid (save-quote (json/generate-string {:products []
                                              :client "Unknown"
                                              :preparer "tomjkidd@gmail.com"
                                              :approved false
                                              :id nil}))
           filepath (str "./quotes/" uuid ".edn")
           exists (.exists (io/file filepath))]
       (io/delete-file filepath true)
       (and exists (not (nil? uuid)))))))
