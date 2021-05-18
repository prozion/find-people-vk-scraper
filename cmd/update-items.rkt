#lang racket

(require odysseus)
(require tabtree)

(require "../lib/functions.rkt")
(require "../lib/settings.rkt")
(require compatibility/defmacro)

(define-catch (add-items old-items new-items)
  (let*
    (
      (old-items (filter (λ (x) ($ uids x)) old-items))
      (old-ids (map (λ (x) ($ id x)) old-items))
      (new-ids (map (λ (x) ($ id x)) new-items))
      (done-new-ids (intersect new-ids old-ids))
      (not-done-new-ids (minus new-ids old-ids))
      (items-to-stay (filter (λ (item) (indexof? done-new-ids ($ id item))) old-items))
      (items-to-add (filter (λ (item) (indexof? not-done-new-ids ($ id item))) new-items)))
    (append
      items-to-stay
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

(add-extended-items-to-persistent topic-items TOPIC_AREA_TABTREE_PARTS)
(add-extended-items-to-persistent local-items LOCAL_AREA_TABTREE_PARTS)
