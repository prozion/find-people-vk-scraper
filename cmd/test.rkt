#lang racket

(require odysseus)
(require tabtree)

(require "../lib/functions.rkt")
(require "../lib/settings.rkt")
(require compatibility/defmacro)

; (persistent topic-items)
; (persistent h-topic-items)
(persistent local-items)
; (persistent h-local-items)

; (h-topic-items (first (topic-items)))
; (h-local-items (first (local-items)))

(--- (hash-keys (first (local-items))))
