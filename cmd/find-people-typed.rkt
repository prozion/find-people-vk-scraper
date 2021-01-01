#lang typed/racket

(require typed/racket)
(require "../lib/types.rkt")

(require/typed
  "../lib/functions.rkt"
  (get-items-by-tabtree-parts (-> (Listof TabtreePart) (Listof GroupItem)))
  (get-extended-groups (-> (Listof GroupItem) (#:ignore-i? Boolean) (#:max-users-limit Boolean) (#:existed-extended-groups ExtendedGroups) ExtendedGroups))
  (get-extended-users (-> (Listof UserItem) (#:ignore-i? Boolean) (#:extract-gids? Boolean) (#:existed-extended-users ExtendedUsers) ExtendedUsers))
  (ext-groups->ext-users (-> ExtendedGroups (#:display-process Boolean) ExtendedUsers))
  (add-count (-> ExtendedUsers Integer ExtendedUsers))
  (find-users-in-groups (-> ExtendedUsers ExtendedGroups ExtendedUsers))
  (intersect-users (-> ExtendedUsers ExtendedUsers Limits ExtendedUsers))
  (make-side-by-side-count-table (-> ExtendedUsers ExtendedGroups (#:output (U String Boolean)) Boolean))
)
(require/typed
  "../lib/settings.rkt"
  (TOPIC_AREA_TABTREE_PARTS (Listof TabtreePart))
  (FRIENDS_TABTREE_PARTS (Listof TabtreePart))
  (TOPIC String)
  (CACHE_DIR String)
)
(require/typed
  "../lib/persistences.rkt"
  (get-saved-users-1 (-> ExtendedUsers))
  (get-saved-users-2 (-> ExtendedUsers))
  (save-users-1 (-> ExtendedUsers Void))
  (save-users-2 (-> ExtendedUsers Void))
  (get-saved-groups-1 (-> ExtendedGroups))
  (get-saved-groups-2 (-> ExtendedGroups))
  (save-groups-1 (-> ExtendedGroups Void))
  (save-groups-2 (-> ExtendedGroups Void))
  ; (get-id-alias (-> IdAlias))
  ; (set-id-alias (-> ExtendedGroups Boolean))
)

; (-> (Listof TabtreePart) (Listof Item))
; (-> (Listof Item) ExtendedGroups)
; (-> ExtendedGroups ExtendedUsers)
; (-> ExtendedUsers ExtendedUsers Limits ExtendedUsers)
; (-> ExtendedUsers IO ())

; (-> (Listof TabtreePart) (Listof Item))
(define items1 (get-items-by-tabtree-parts TOPIC_AREA_TABTREE_PARTS))

; (-> (Listof Item) ExtendedGroups)
(define ext-groups-1 (get-extended-groups items1 #:existed-extended-groups (get-saved-groups-1)))
(save-groups-1 ext-groups-1)

; (-> ExtendedGroups ExtendedUsers)
; (define ext-users-1 (ext-groups->ext-users ext-groups-1))
; (save-users-1 ext-users-1)
(define ext-users-2 (add-count
                      (get-extended-users
                        (get-items-by-tabtree-parts FRIENDS_TABTREE_PARTS)
                        #:extract-gids? #f
                        #:existed-extended-users (get-saved-users-2))
                      1))
(save-users-2 ext-users-2)

(define intersected-users (find-users-in-groups ext-users-2 ext-groups-1))

; (-> ExtendedUsers ExtendedUsers Limits ExtendedUsers)
; (define intersected-users
;         (intersect-users ext-users-1 ext-users-2 (Limits 1 1)))

; (set-id-alias ext-groups-1)
; (define id-alias (get-id-alias))

; (-> ExtendedUsers IO ())
(make-side-by-side-count-table
    intersected-users
    ext-groups-1
    #:output (format "friends_in_~a_groups.csv" TOPIC))
