#lang racket

(require odysseus)
(require odysseus/persistents)
(require tabtree)

(require "../lib/functions.rkt")
(require "../lib/settings.rkt")
(require compatibility/defmacro)

(define-catch (add-items h-old-items new-items)
  (let*
    (
      ; (old-items (hash-filter (λ (k v) ($ uids v)) old-items))
      (old-ids (map (λ (item) (id item)) (hash-values h-old-items)))
      (new-items (hash-values new-items))
      (new-ids (map (λ (item) (id item)) new-items))
      (done-new-ids (intersect new-ids old-ids))
      (not-done-new-ids (minus new-ids old-ids))
      (h-items-to-stay (hash-filter (λ (uid item) (index-of? done-new-ids (id item))) h-old-items))
      (items-to-add (filter (λ (item) (index-of? not-done-new-ids (id item))) new-items)))
    (hash-union
      h-items-to-stay
      (get-extended-groups
          #:max-users-limit MAX_MEMBERS_IN_SCANNED_GROUPS
          items-to-add))))

(define (_ids items)
  (map (curryr hash-ref 'id) items))

(define-macro (add-extended-items-to-persistent persistent-name tabtree-parts)
  `(begin
    (persistent ,persistent-name)
    (let* ((current-extended-items (,persistent-name)))
      (,persistent-name (add-items current-extended-items (get-items-by-tabtree-parts ,tabtree-parts)))
      (void))))

(add-extended-items-to-persistent h-topic-items TOPIC2_TABTREE_PARTS)
(add-extended-items-to-persistent h-local-items TOPIC1_TABTREE_PARTS)
