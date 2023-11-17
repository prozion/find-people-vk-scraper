#lang racket

(require odysseus)
(require odysseus/math)
(require tabtree)

(--- (->> "../knowledge/ds.tree"
          parse-tabtree
          hash-values
          (map (λ (item) ($ vk item)))
          make-frequency-hash
          (hash-filter (λ (k v) (> v 1)))
          hash-keys))
