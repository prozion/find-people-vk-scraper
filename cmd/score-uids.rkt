#lang racket

(require odysseus)
(require tabtree/tabtree1)
(require racket/serialize)
(require (rename-in racket/hash (hash-union hash-union-racket)))

(require "../lib/functions.rkt")
(require "../lib/settings.rkt")

(persistent h-local-items)
(persistent h-local-uid-score)
(persistent uids-selected)

(define (get-score h-items)
  (if (hash-empty? h-items)
        (hash)
        (for/fold
          ((res1 (hash)))
          (((gid item) h-items))
          (let* ((uids (hash-ref* item 'uids empty)))
            (display "+") (flush-output)
            (for/fold
                ((res2 res1))
                ((uid uids))
                (hash-set res2 uid (+ 1 (hash-ref res2 uid 0))))))))

(define-catch (score-uids)
  (--- "getting a score of users")
  (let* ((uid-score (get-score (h-local-items))))
    (h-local-uid-score uid-score)
    #t))

(score-uids)
