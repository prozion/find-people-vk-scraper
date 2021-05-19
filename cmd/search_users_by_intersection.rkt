#lang racket

(require odysseus)
(require tabtree)

(require "../lib/functions.rkt")
(require "../lib/settings.rkt")
(require compatibility/defmacro)

(persistent local-items)
(persistent topic-items)
(persistent h-uid-local-score)

(define-catch (in-what-groups-is-this-uid items uid #:pick-group-name? (pick-group-name? #f))
  (for/fold
    ((res empty))
    ((item items))
    (let* ((vk-alias (extract-pure-alias ($ vk item)))
          (vk-id ($ vk-id item))
          (item-id ($ id item))
          (uids ($ uids item)))
      (cond
        ((not vk-alias) res)
        ((not vk-id) res)
        ((not uids) res)
        ((indexof? uids uid)
          (cond
            (pick-group-name?
                (pushr res item-id))
            (else
                (pushr res vk-id))))
        (else res)))))

(define (search-users-by-intersection
          #:local-vk-groups local-vk-groups
          #:topic-vk-groups topic-vk-groups
          #:local-min-membership (local-min-membership 3)
          #:result-csv-name (result-csv-name "result")
        )
  (let* (
        (groups-with-uids (filter
                            (λ (x) ($ uids x))
                            (extended-vk-groups)))
        ; (_ (--- (length groups-with-uids)))
        ; (_ (--- (format "Total local uids: ~a" (length (hash-keys (h-uid-score))))))
        (locals-uids (hash-keys (hash-filter (λ (k v) (>= v local-min-membership)) (h-uid-score))))
        (_ (--- (format "Total filtered local uids: ~a" (length locals-uids))))
        (locals-in-topic-groups (for/fold
                                        ((res empty))
                                        ((item groups-with-uids))
                                        (append res (intersect ($ uids item) locals-uids))))
        (locals-in-topic-groups-score (frequency-hash locals-in-topic-groups))
        (uid-score (h-uid-score))
        (locals-in-topic-groups-score (hash-map
                                        (λ (k v)
                                          (values
                                            k
                                            (hash 'url (gid->url k)
                                                  'gids (implode
                                                          (in-what-groups-is-this-uid groups-with-uids k #:pick-group-name? #t)
                                                          ", ")
                                                  'local_count (hash-ref uid-score k 0)
                                                  'topic_count v)))
                                        locals-in-topic-groups-score))
        )
    (write-csv-file #:delimeter "\t" '(url gids local_count elx_count) locals-in-topic-groups-score (str "../" RESULT_DIR "/" result-csv-name ".csv"))
    #t
    ))

    (search-users-by-intersection
        #:local-vk-groups (local-items)
        #:topic-vk-groups (topic-items)
        #:local-min-membership 3
        #:result-csv-name "locals_in_clojure_groups")
