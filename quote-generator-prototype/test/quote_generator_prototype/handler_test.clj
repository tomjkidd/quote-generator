(ns quote-generator-prototype.handler-test
  (:require [clojure.test :refer :all]
            [ring.mock.request :as mock]
            [quote-generator-prototype.handler :refer :all]))

(deftest test-app
  (testing "main route"
    (let [response (app (mock/request :get "/"))]
      (is (= (:status response) 200))
      (is (= (:body response) "Hello World"))))

  (testing "not-found route"
    (let [response (app (mock/request :get "/invalid"))]
      (is (= (:status response) 404))))

  (testing "locales route"
    (let [response (app (mock/request :get "/locales"))]
      (is (= (:status response) 200))))

  (testing "antiforgery route"
    (let [response (app (mock/request :get "/antiforgerytoken"))]
      (is (= (:status response) 200)))))
