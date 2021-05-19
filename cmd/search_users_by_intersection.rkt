#lang racket

(require odysseus)
(require odysseus/api/vk)
(require odysseus/api/csv)
(require tabtree)

(require "../lib/functions.rkt")
(require "../lib/settings.rkt")
(require compatibility/defmacro)

(persistent local-items)
(persistent topic-items)
(persistent h-local-uid-score)

(define-catch (get-score items)
  (--- (length items))
  (if (empty? items)
    (hash)
    (for/fold
      ((res1 (hash)))
      ((item items))
      (let* ((uids ($ uids item)))
        (display "+") (flush-output)
        (if-not uids
          res1
          (for/fold
              ((res2 res1))
              ((uid uids))
              (hash-set res2 uid (+ 1 (hash-ref res2 uid 0)))))))))

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

(define-catch (search-users-by-intersection
                  #:local-scored-uids local-scored-uids
                  #:local-vk-groups local-vk-groups
                  #:topic-vk-groups topic-vk-groups
                  #:result-csv-name (result-csv-name "result")
                )
  (let* (
        (locals-uids (hash-keys (local-scored-uids)))
        (_ (--- (format "Total filtered local uids: ~a" (length locals-uids))))
        (locals-in-topic-groups (for/fold
                                        ((res empty))
                                        ((item topic-vk-groups))
                                        (append res (intersect ($ uids item) locals-uids))))
        (locals-in-topic-groups-scored (frequency-hash locals-in-topic-groups))
        (locals-in-topic-groups (hash-map
                                  (λ (uid score)
                                    (let* ((local-groups (in-what-groups-is-this-uid local-vk-groups uid #:pick-group-name? #t))
                                          (topic-groups (in-what-groups-is-this-uid topic-vk-groups uid #:pick-group-name? #t)))
                                      (values
                                        uid
                                        (hash 'url (gid->url uid)
                                              'local_groups (implode local-groups ", ")
                                              'topic_groups (implode topic-groups ", ")
                                              'local_count score
                                              'topic_count (length topic-groups)))))
                                  locals-in-topic-groups-scored))
        )
    (write-csv-file #:delimeter "\t" '(url local_groups topic_groups local_count topic_count) locals-in-topic-groups (str "../" RESULT_DIR "/" result-csv-name ".csv"))
    #t
    ))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (h-local-uid-score (get-score (local-items)))
    (exit)

    (search-users-by-intersection
        #:local-scored-uids (hash-filter (λ (k v) (>= v MIN_MEMBER)) (h-local-uid-score))
        #:local-vk-groups (local-items)
        #:topic-vk-groups (topic-items)
        #:local-min-membership 3
        #:result-csv-name "locals_in_clojure_groups")
