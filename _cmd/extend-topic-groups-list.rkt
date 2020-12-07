#lang racket

(require "../../_lib_links/odysseus_all.rkt")
(require "../../_lib_links/odysseus_tabtree.rkt")

(require "../_lib/functions.rkt")
(require "../_lib/globals.rkt")

(persistent extended-vk-groups)

(define-catch (extend-topic-groups-list topic-groups-list new-items)
  (let*
    (
      (items-already-extended (filter (λ (x) ($ uids x)) topic-groups-list))
      (ids-already-extended (map (λ (x) ($ id x)) items-already-extended))
      (items new-items)
      (ids (map (λ (x) ($ id x)) items))
      (ids-already-processed (intersect ids ids-already-extended))
      (ids-to-process (minus ids ids-already-processed))
      (items-to-stay (filter (λ (item) (indexof? ids-already-processed ($ id item))) items-already-extended))
      (items-to-process (filter (λ (item) (indexof? ids-to-process ($ id item))) items)))
    (append
      items-to-stay
      (add-uids-to-tabtree
          #:max-users-limit MAX_MEMBERS_IN_SCANNED_GROUPS
          (cond
            ((empty? (extended-vk-groups)) items)
            (else items-to-process))))))

(let* (
      ; (_ (extended-vk-groups (extend-topic-groups-list (extended-vk-groups) "../knowledge/russia_elx.tree"))_
      ; (_ (extended-vk-groups (extend-topic-groups-list (extended-vk-groups) "../../haskell_world/knowledge/social_networks.tree")))
      (current-extended-vk-groups (extended-vk-groups))
      (_ (extended-vk-groups (extend-topic-groups-list current-extended-vk-groups (get-items-with-knowledge-takers TOPIC_AREA_TABTREE))))
      )
  #t)
