#lang racket

(require odysseus)
(require odysseus/report/csv)
(require tabtree)
(require "../lib/functions.rkt")
(require "../lib/settings.rkt")

(persistent h-uid-friends)
(persistent h-gid-topic-groups)

(define (find-friends)
  (let* (
        (uid-friends-ext (get-extended-users
                                (get-items-by-tabtree-parts FRIENDS_TABTREE_PARTS)
                                #:extract-gids? #f
                                #:existed-extended-users (h-uid-friends)))
        (_ (h-uid-friends uid-friends-ext))
        (friend-uids (uniques (no-empty (hash-keys uid-friends-ext))))
        (gid-groups (get-extended-groups
                                (get-items-by-tabtree-parts TOPIC_AREA_TABTREE_PARTS)
                                #:existed-extended-groups (h-gid-topic-groups)))
        (_ (h-gid-topic-groups gid-groups))
        (group-uids (uniques (no-empty (flatten (filter-map (λ (item) ($ uids item)) (hash-values gid-groups))))))
        (uids-matched (intersect friend-uids group-uids))
        (matched-friends (for/fold
                            ((res empty))
                            ((uid uids-matched))
                            (let ((gnames (in-what-groups-is-this-uid gid-groups uid #:pick-group-name? #t)))
                              (pushr
                                res
                                (hash 'user-url (uid->url uid)
                                      'group-names (implode gnames ", ")
                                      'count (length gnames))))))
        (output-filename (format "friends_in_~a_groups.csv" TOPIC))
        )
    (write-csv-file #:delimeter "\t"
                    '(user-url group-names count)
                    matched-friends
                    (str "../" RESULT_DIR "/" output-filename))
    (--- (length matched-friends))))

(find-friends)
