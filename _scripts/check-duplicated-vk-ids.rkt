#!/usr/bin/env racket

#lang racket

(require odysseus)
(require odysseus/math)
(require tabtree)
(require tabtree/utils)

; (define city "volgograd")
(define city "novosibirsk")

(define (find-dup-vks tabtree)
  (define vks (->> tabtree hash-values (map (λ (item) ($ vk item))) flatten))
  (->> vks make-frequency-hash (hash-filter (λ (k v) (> v 1)))))

(--- "Dup vks sn.tree:")
(---- (find-dup-vks (parse-tabtree "/home/denis/projects/red-kgr/sn.tree")))

(define city-tabtree (parse-tabtree (format "../for_rp/~a.tree" city) #:parse-info #t))

(--- (format "Dup ids ~a:" city))
(---- ($ duplicated-ids city-tabtree))

(--- (format "Dup vks ~a:" city))
(---- (find-dup-vks (parse-tabtree (format "../for_rp/~a.tree" city))))
