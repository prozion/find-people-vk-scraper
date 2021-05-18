#lang racket

(require compatibility/defmacro)
(require odysseus)
(require tabtree)
(require tabtree/utils)
(require odysseus/api/vk)
(require odysseus/api/csv)

(require "settings.rkt")

(require (for-syntax odysseus))

(provide (all-defined-out))

; (: get-item-type (-> Item IdType))
(define-catch (get-item-type item)
  ($* type item))

; (: user? (-> Item Boolean))
(define (user? item)
  (and
    ($ vk item))
    (or ($ f item) (equal? (get-item-type item) "user")))

; (: group? (-> Item Boolean))
(define (group? item)
  (and
    ($ vk item)
    (or ($ u item) ($ p item))))

(define public? group?)

; (: vk-members-number (-> Item Integer))
(define (vk-members-number item)
  (->number (or ($ u item) ($ p item) ($ f item) 0)))

; (: uid->url (-> Gid Url))
(define-catch (uid->url gid)
  (format "vk.com/id~a" gid))

; (: tag? (-> String Item Boolean))
(define (tag? tag item)
  (and item ($ _t item) (re-matches? tag ($ _t item))))

; (: ignore? (-> Item Boolean))
(define-catch (ignore? item)
  (tag? "i" item))

; (: vk? (-> Item Boolean))
(define-catch (vk? item)
  ($ vk item))

; (: sn-group? (-> Item Boolean))
(define-catch (sn-group? item)
  (or
    ($ vk item) ($ vk-old item)
    ($ fb item) ($ insta item) ($ twi item) ($ tg item) ($ yt item) ($ youtube item)
    ))

; (: group-category? (-> Item Boolean))
(define-catch (group-category? item)
  (not (sn-group? item)))

; (: get-extended-groups (-> (Listof GroupItem) (#:ignore-i? Boolean) (#:max-users-limit Boolean) (#:existed-extended-groups ExtendedGroups) ExtendedGroups)))
(define-catch (get-extended-groups
                    group-items
                    #:existed-extended-groups (existed-extended-groups (hash))
                    #:ignore-i? (ignore-i? #t)
                    #:max-users-limit (max-users-limit #f))
  (let ((h-alias-gid (map-hash
                        (λ (gid item) (values ($ vk item) gid))
                        existed-extended-groups)))
      (for/fold
        ((res (hash)))
        ((item group-items))
          (let* ((alias ($ vk item))
                (is-group (group? item))
                (is-user (user? item))
                (vk-id (and alias (hash-ref h-alias-gid alias #f)))
                (vk-id (cond
                      ((and alias is-group (not vk-id))
                        (get-gid alias #:delay 0.1 #:display? (format "~n[get-gid ~a]~n" alias)))
                      ((and alias is-user (not vk-id))
                        (get-uid alias #:delay 0.1 #:display? (format "~n[get-uid ~a]~n" alias)))
                      (else
                        vk-id))))
            (cond
              ; skip if no vk url in item
              ((not vk-id)
                res)
              (($ uids item)
                (hash-set res vk-id item))
              ; skip if i:<t>
              ((and ignore-i? ($* i item))
                res)
              ; skip if number of users is more than max-users-limit
              ((and max-users-limit (> (vk-members-number item) max-users-limit))
                res)
              ((hash-ref existed-extended-groups vk-id #f)
                (hash-set res vk-id (hash-ref existed-extended-groups vk-id)))
              (is-group
                (hash-set res vk-id (hash-union item (hash 'uids (get-group-users vk-id #:delay 0.1 #:display? (format " [get-gid-uids ~a] " vk-id))))))
              (is-user
                (hash-set res vk-id (hash-union item (hash 'uids (get-friends-of-user vk-id #:delay 0.1 #:display? (format " [get-uid-uids ~a] " vk-id))))))
              ; if something different, also skip
              (else res))))))

(define-catch (get-extended-users
                    user-items
                    #:existed-extended-users (existed-extended-users (hash))
                    #:extract-gids? (extract-gids? #t)
                    #:ignore-i? (ignore-i? #t))
  (let ((h-alias-uid (map-hash
                        (λ (uid item) (values ($ vk item) uid))
                        existed-extended-users)))
      (for/fold
        ((res (hash)))
        ((item user-items))
          (let* ((alias ($ vk item))
                (vk-id (and alias (hash-ref h-alias-uid alias #f)))
                (vk-id (cond
                          ((and alias (not vk-id))
                            (get-uid alias #:delay 0.1 #:display? (format "[get-uid ~a]~n" alias)))
                          (else
                            vk-id))))
            (cond
              ; skip if no vk url in item
              ((not vk-id)
                res)
              ; (($ gids item)
              ;   (hash-set res vk-id item))
              ((and ignore-i? ($* i item))
                res)
              ((hash-ref existed-extended-users vk-id #f)
                (hash-set res vk-id (hash-ref existed-extended-users vk-id)))
              (extract-gids?
                (hash-set
                  res
                  vk-id
                  (hash
                    'id ($ id item)
                    'vk ($ vk item)
                    'gids (get-groups-of-user vk-id #:delay 0.1 #:display? (format " [get-uid-gids ~a] " vk-id)))))
              (else
                (hash-set
                  res
                  vk-id
                  (hash
                    'id ($ id item)
                    'vk ($ vk item)
                  ))))))))

(define-catch (add-count ext-users cnt)
  (map-hash (λ (k v) (values k (hash-union (hash 'count cnt) v)))
            ext-users))

; knowledge-takers format: (list (hash 'file <path-to-tabtre> 'take '<path-to-section-extracted>) ...)
(define-catch (get-items-by-tabtree-parts tabtree-parts)
  (for/fold
    ((res empty))
    ((tabtree-part tabtree-parts))
    (let* ((base-tabtree-filepath (TabtreePart-filepath tabtree-part))
          (all-tree (parse-tab-tree base-tabtree-filepath))
          (knowledge-path (TabtreePart-treepath tabtree-part))
          (knowledge-path-lst (string-split (symbol->string knowledge-path) ".")))
      (cond
        ((equal? knowledge-path 'all)
          (append res (get-leaves all-tree)))
        (else
          (append res (get-leaves (get-$4 knowledge-path-lst all-tree))))))))

; (: ext-groups->ext-users (-> ExtendedGroups (#:display-process Boolean) ExtendedUsers)))
(define-catch (ext-groups->ext-users extended-groups #:display-process (display-process #t))
  (let* ((gids (hash-keys extended-groups)))
    (cond
      ((empty? gids) (hash))
      (else
        (for/fold
          ((res1 (hash)))
          ((gid gids))
          (let* ((uids (hash-ref
                          (hash-ref extended-groups gid empty)
                          'uids empty)))
            (for/fold
                ((res2 res1))
                ((uid uids))
                (let ((gids ($ uid.gids res2)))
                  (--- (length (hash-keys res1)) (length (hash-keys res2)))
                  (hash-set
                    res2
                    uid
                    (hash
                      'count (+ 1 (or ($ uid.count res2) 0))
                      'gids (if gids (pushr gids gid) (list gid))
                  ))))))))))

; (: count-gids (-> UserItemWithGroups Integer))
(define (count-gids item)
  (cond
    (($ gids item)
      (length (uniques ($ gids item))))
    (else 0)))

; (: intersect-users (-> ExtendedUsers ExtendedUsers Limits ExtendedUsers))
(define-catch (intersect-users extusr1 extusr2 limits)
    (match-let* (((Limits limit1 limit2) limits)
                  (filtered-extusr1 (hash-filter (λ (k v) (>= (count-gids v) limit1)) extusr1))
                  (filtered-extusr2 (hash-filter (λ (k v) (>= (count-gids v) limit2)) extusr2))
                  (filtered-ids1 (hash-keys filtered-extusr1))
                  (filtered-ids2 (hash-keys filtered-extusr2))
                  (intersected-ids (intersect filtered-ids1 filtered-ids2))
                  (result (for/hash
                            ((id intersected-ids))
                            (values id (hash-ref extusr1 id) (hash-ref extusr2 id)))))
      result))

; (: in-what-groups-is-this-uid (-> ExtendedGroups Uid (#:pick-group-name? Boolean) (Listof GidName)))
(define-catch (in-what-groups-is-this-uid ext-groups uid #:pick-group-name? (pick-group-name? #f))
  (for/fold
    ((res empty))
    (((gid item) ext-groups))
    (let* ((gname ($ id item))
          (uids ($ uids item)))
      (cond
        ((not uids) res)
        ((indexof? uids uid)
          (cond
            (pick-group-name?
                (pushr res gname))
            (else
                (pushr res gid))))
        (else res)))))
