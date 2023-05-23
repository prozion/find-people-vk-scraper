#lang racket

(require odysseus)
(require odysseus/persistents)
(require tabtree)

(require "../lib/functions.rkt")
(require "../lib/settings.rkt")
(require "../lib/types.rkt")
(require compatibility/defmacro)

; (persistent topic-items)
; (persistent h-topic-items)
(--- (get-items-by-tabtree-parts (list (TabtreePart "/home/denis/projects/cuba-kb/knowledge/sn.tree" 'vk_группы))))
; (persistent local-items)
; (persistent h-local-items)

; (h-topic-items (first (topic-items)))
; (h-local-items (first (local-items)))

; (--- (hash-keys (first (local-items))))
