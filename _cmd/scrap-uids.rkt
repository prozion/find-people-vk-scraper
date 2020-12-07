#lang racket

(require "../../_lib_links/odysseus_all.rkt")
(require "../../_lib_links/odysseus_scrap.rkt")
(require "../../_lib_links/odysseus_tabtree.rkt")
(require "../../_lib_links/settings.rkt")
(require racket/serialize)
(require (rename-in racket/hash (hash-union hash-union-racket)))

(require "../_lib/functions.rkt")
(require "../_lib/scraping_vk.rkt")
(require "../_lib/globals.rkt")

(define-catch (get-h-id-uids h-id-uids-existed items)
  (persistent h-alias-id)
  (persistent h-id-uids)
        ; находим id для новодобавленных групп:
      (let-values (((h-alias-id-new h-id-uids-new)
                        (for/fold
                          (
                            (res-alias-id (hash))
                            (res-id-uids (hash)))
                          ((item items))
                          (let* ((alias (extract-pure-alias ($ vk item))))
                            (cond
                              ;; already processed aliases also prevent from reading uids from the group/user more than one time:
                              ((hash-ref (h-alias-id) alias #f) (values res-alias-id res-id-uids))
                              (($* i item) (values res-alias-id res-id-uids))
                              ((> (vk-members-number item) MAX_MEMBERS_IN_SCANNED_GROUPS) (values res-alias-id res-id-uids))
                              ((user? item)
                                    (let* ((alias-id (get-user-id alias #:delay 0.1 #:display? (format "~n[get-uid ~a]~n" alias))))
                                      (values
                                        (hash-set res-alias-id alias alias-id)
                                        (hash-set res-id-uids alias-id (get-friends-of-user alias-id #:delay 0.1 #:display? (format " [get-friend-uids ~a] " alias-id))))))
                              ((group? item)
                                    (let* ((alias-id (get-gid alias #:delay 0.1 #:display? (format "~n[get-gid ~a]~n" alias))))
                                      (values
                                        (hash-set res-alias-id alias alias-id)
                                        (hash-set res-id-uids alias-id (get-group-users alias-id #:delay 0.1 #:display? (format " [get-participant-uids ~a] " alias-id))))))
                              (else (values res-alias-id res-id-uids)))))))
        (let* (
              (_ (h-alias-id h-alias-id-new 'append))
              (_ (h-id-uids h-id-uids-new 'append))
              )
    #t)))

(define (get-score h-id-uids)
  (persistent h-alias-id)
  (persistent h-uid-score)
  (let* (
        ; определяем кластеры групп, по которым считать частоту вхождения
        (a-h-alias-id (h-alias-id))

        (gids (hash-keys h-id-uids))

        ; определяем частоту вхождения
        (_ (when
              (not-empty? gids)
              (h-uid-score (for/fold
                              ((res1 (hash)))
                              ((gid gids))
                              (let* ((uids (hash-ref h-id-uids gid empty)))
                                (display "+") (flush-output)
                                (for/fold
                                    ((res2 res1))
                                    ((uid uids))
                                    (hash-set res2 uid (+ 1 (hash-ref res2 uid 0))))))))))
    #t))

(define (get-uids-selected h-uid-score)
  (persistent uids-selected)
  ; берем только тех пользователей, которые входят в MIN_MEMBER и более групп
  (uids-selected
    (opt/uniques
      (select-uids
        h-uid-score
        #:filter (λ (k v)
                    (>= v MIN_MEMBER)))))
  #t)

(persistent h-id-uids)
(persistent h-uid-score)
(persistent h-ualias-uid)

(let* (
      ; (_ (--- "getting user ids in the groups"))
      (h-id-uids-all (h-id-uids))
      )

  ; (--- "Всего уникальных uid:" (length (uniques (flatten (hash-values h-id-uids-all)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; (--- "for each group get its id and a list of user ids")
  (get-h-id-uids
    (h-id-uids)
    (get-items-with-knowledge-takers LOCAL_AREA_TABTREES))
  ;
  (--- "getting a score of users")
  (get-score (h-id-uids))
  ;
  ; (--- "getting user ids for scanning")
  (get-uids-selected (h-uid-score))

  #t)
