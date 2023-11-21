#lang racket

(require odysseus)
(require odysseus/csv)
(require odysseus/math)
(require odysseus/persistents)
(require vk)
(require tabtree)
(require tabtree/utils)

(require "../lib/functions.rkt")
(require "../lib/settings.rkt")
(require compatibility/defmacro)

(persistent h-topic1-items)
(persistent h-topic2-items)
(persistent h-topic1-uid-score)
(persistent h-topic2-uid-score)

; (define-catch (get-score items)
;   (--- (length items))
;   (if (empty? items)
;     (hash)
;     (for/fold
;       ((res1 (hash)))
;       ((item items))
;       (let* ((uids ($ uids item)))
;         (display "+") (flush-output)
;         (if-not uids
;           res1
;           (for/fold
;               ((res2 res1))
;               ((uid uids))
;               (hash-set res2 uid (+ 1 (hash-ref res2 uid 0)))))))))

(define-catch (in-what-groups-is-this-uid h-gid-item uid #:pick-group-name? (pick-group-name? #f))
  (for/fold
    ((res empty))
    (((gid item) h-gid-item))
    (let* (
          (item-id ($ __id item))
          (uids ($ uids item)))
      (cond
        ((not uids) res)
        ((index-of? uids uid)
          (cond
            (pick-group-name?
                (pushr res (or ($ name item) item-id)))
            (else
                (pushr res gid))))
        (else res)))))

(define-catch (search-users-by-intersection
                  #:local-vk-groups local-vk-groups
                  #:local-scored-uids local-scored-uids
                  #:topic-vk-groups topic-vk-groups
                  #:topic-scored-uids topic-scored-uids
                  #:result-csv-name (result-csv-name "result")
                )
  (let* (
        (locals-uids (hash-keys local-scored-uids))
        (_ (--- (format "Total filtered local uids: ~a" (length locals-uids))))
        (topic-uids (hash-keys topic-scored-uids))
        (_ (--- (format "Total filtered topic uids: ~a" (length topic-uids))))
        ; (locals-in-topic2-groups (benchmark (d "find locals uids in topical groups")
        ;                             (for/fold
        ;                                 ((res empty))
        ;                                 (((gid item) topic-vk-groups))
        ;                                   (append res (intersect ($ uids item) locals-uids)))))
        (locals-in-topic2-groups (benchmark (d "find locals uids in topical groups")
                                  (intersect topic-uids locals-uids)))
        ; (locals-in-topic2-groups-scored (benchmark (d "find uids distribution by topical groups")
        ;                                   (make-frequency-hash locals-in-topic2-groups)))
        (locals-in-topic2-groups (benchmark (d "make locals in topic groups table")
                                  (for/hash
                                    ((uid locals-in-topic2-groups))
                                    (let* ((local-groups (in-what-groups-is-this-uid local-vk-groups uid #:pick-group-name? #t))
                                            (local-groups (map deidify local-groups))
                                            (topic-groups (in-what-groups-is-this-uid topic-vk-groups uid #:pick-group-name? #t))
                                            (topic-groups (map deidify topic-groups)))
                                        (values
                                          uid
                                          (hash
                                                'url (uid->url uid)
                                                'local_groups (implode local-groups ", ")
                                                'topic_groups (implode topic-groups ", ")
                                                'local_count (length local-groups)
                                                'topic_count (length topic-groups)))))))
        (_ (--- (format "Detected intersected uids: ~a" (length (hash-keys locals-in-topic2-groups)))))
        )
    (write-csv-file #:delimeter "\t" '(url local_groups topic_groups local_count topic_count) locals-in-topic2-groups (str "../" RESULT_DIR "/" result-csv-name ".csv"))
    #t
    ))

    (search-users-by-intersection
        #:local-vk-groups (h-topic1-items)
        #:local-scored-uids (hash-filter (λ (k v) (>= v MIN_MEMBER_TOPIC1)) (h-topic1-uid-score))
        #:topic-vk-groups (h-topic2-items)
        #:topic-scored-uids (hash-filter (λ (k v) (>= v MIN_MEMBER_TOPIC2)) (h-topic2-uid-score))
        #:result-csv-name RESULT_FILENAME)
