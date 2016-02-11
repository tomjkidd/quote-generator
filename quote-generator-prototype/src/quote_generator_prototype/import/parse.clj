(ns quote-generator-prototype.import.parse
  (:import
   (org.apache.poi.ss.usermodel Workbook Sheet Cell Row)
   (org.apache.poi.ss.util CellReference))
  (:require [dk.ative.docjure.spreadsheet :as docjure]
            [clojure.pprint :refer [pprint]]
            [medley.core :refer [map-vals]]))

(defn load-rows
  [xlsx-filepath xlsx-tab xlsx-parse-map]
  (let [rows (->> (docjure/load-workbook xlsx-filepath)
                  (docjure/select-sheet xlsx-tab)
                  (docjure/select-columns xlsx-parse-map)
                  (drop 1))]
    rows))

(def xlsx-filepath
  "The relative path to the xlsx template"
  "./resources/public/import/quote-generator-template.xlsx")

(def xlsx-product-tab
  "The tab where Products are defined"
  "Products")

(def xlsx-product-parse-map
  "The map to use to parse product data from .xlsx"
  {:A :id
   :B :title
   :C :description
   :D :note
   :E :link-to-sample})

(defn parse-products
  "Parse the products from the xlsx"
  []
  (->> (load-rows xlsx-filepath xlsx-product-tab xlsx-product-parse-map)
       (filter #(not (nil? (:id %))))))

(def xlsx-feature-tab
  "The tab where Features are defined"
  "Features")

(def xlsx-feature-parse-map
  "The map to use to parse feature data from .xlsx"
  {:A :id
   :B :title
   :C :description
   :D :multiplier
   :E :feature-type})

(defn parse-features
  "Parse the features from the xlsx"
  []
  (->> (load-rows xlsx-filepath xlsx-feature-tab xlsx-feature-parse-map)
       (filter #(not (nil? (:id %))))))

(def xlsx-product-feature-tab
  "The tab where Product/Feature mappings are defined"
  "ProductFeatures")

(def xlsx-product-feature-parse-map
  "The map to use to parse product/feature mappings from .xlsx"
  {:A :product-id
   :B :feature-id
   :C :feature-quantity})

(defn parse-product-feature
  []
  (load-rows xlsx-filepath xlsx-product-feature-tab xlsx-product-feature-parse-map))

(def xlsx-base-cost-tab
  "The tab where the base cost is defined"
  "BaseCost")

(def xlsx-base-cost-parse-map
  {:A :base-cost})

(defn parse-base-cost
  []
  (-> (load-rows xlsx-filepath xlsx-base-cost-tab xlsx-base-cost-parse-map)
      (first)
      (:base-cost)))

(def xlsx-translations-tab
  "The tab where translations are defined"
  "Translations")

(def xlsx-translations-parse-map
  {:A :name
   :B :translation})

(defn parse-translations
  []
  (->> (load-rows xlsx-filepath xlsx-translations-tab xlsx-translations-parse-map)
       (filter #(not (nil? (:translation %))))))

(defn- add-quantity-to-features 
  "Use a list of features and the product features to add
quantity to the feature map."
  [product-features features]
  (map (fn [f]
         (let [total-quantity
               (->> product-features
                    (filter #(= (:feature-id %) (:id f)))
                    (map #(:feature-quantity %))
                    (reduce + 0))]
           (assoc f :quantity total-quantity)))
       features))

(defn- add-cost-to-features
  "Adds a :cost key to the feature after calculating what
the unit cost of the feature is."
  [base-cost features]
  (map #(assoc % :cost (* (:multiplier %) base-cost)) features))

(defn- base-feature?
  "Takes a list of feature ids to consider base features.
Returns a function that will determine if the given feature
is a base features."
  [base-feature-ids]
  (fn [feature]
    (some (fn [id] (= id (:id feature))) base-feature-ids)))

(defn- get-features-for-product
  "Handles mapping a product to it's features and adding
necessary extra fields the client uses to the results."
  [base-cost product product-features features]
  (let [pf-mappings (filter #(= (:product-id %) (:id product))
                    product-features)
        base-feature-ids (map #(:feature-id %) pf-mappings)
        base-fs (->> features
                     (filter (base-feature? base-feature-ids))
                     (map #(assoc % :base-feature true))) 
        base-fs-with-qty (add-quantity-to-features pf-mappings base-fs)
        additional-fs (->> features
                           (map #(merge % {:base-feature false :quantity 0})))

        fs (concat base-fs-with-qty additional-fs)
        fs-with-cost (add-cost-to-features base-cost fs)]
    fs-with-cost))

(defn- add-features-to-product
  "Uses the excel information to create a product data
structure."
  [base-cost features product-features product]
  (let [fs (get-features-for-product base-cost product product-features features)]
    (assoc product :features fs)))

(defn combine-products-and-features
  "Use the excel tab parsers to create products.edn, the 
data structure used to source the list of products for the
client."
  []
  (let [products (parse-products)
        features (parse-features)
        product-features (parse-product-feature)
        base-cost (parse-base-cost)
        ]
    (map (partial add-features-to-product base-cost features product-features)
         products)
    ))

(defn parseProductsToFile
  "A convenience function to save results to disk."
  []
  (->> (combine-products-and-features)
       (pr-str)
       (spit "./products.edn")))
