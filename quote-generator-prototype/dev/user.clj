;; Inspired by http://stackoverflow.com/questions/28371102/how-to-clear-the-repl-in-cider-mode
(ns user
  (:require [clojure.tools.namespace.repl :refer [refresh]]
            [clojure.repl :refer [doc source]]
            [clojure.pprint :refer [pprint pp]]
            [midje.repl :as midje]
            [clojure.stacktrace :as st]))
