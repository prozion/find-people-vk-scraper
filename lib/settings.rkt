#lang racket

(require odysseus)
(require (prefix-in vk: odysseus/api/vk))
(require (file "~/.private/APIs.rkt"))
(require "types.rkt")

(provide (all-defined-out))

(define TOPIC "clojure")
(define TOPIC_AREA_TABTREE_PARTS
          (list
            ; (TabtreePart "../../../worlds/cs_world/cs_vk.tree" 'информационные_технологии.разработка_по.операционные_системы)
            ; (TabtreePart "../../../worlds/cs_world/cs_vk.tree" 'информационные_технологии.системное_администрирование)
            ; (TabtreePart "../../../worlds/cs_world/cs_vk.tree" 'информационные_технологии.open_source)
            (TabtreePart "../../../worlds/cs_world/cs_vk.tree" 'all)
            (TabtreePart "../../../worlds/cs_world/cs_vk.tree" 'информационные_технологии.разработка_по.функциональное_программирование.lisp.clojure)
            ))
(define LOCAL_AREA_TABTREE_PARTS
          (list
            (TabtreePart "../../../worlds/cs_world/_local/rostova_cs_vk.tree" 'all)
            (TabtreePart "../../../worlds/_world/_universities_local/rostova_uni_vk.tree" 'all)
            (TabtreePart "../../../worlds/_world/_local/rostova_vk.tree" 'all)))
(define FRIENDS_TABTREE_PARTS
          (list
            (TabtreePart "../../../denis_personal/my_knowledge/people.tree" 'all)))

; how frequently to write to the file, when changing persistence
(define FILE_WRITE_FREQUENCY 500)

; cache directory for persistent data:
; (define CACHE_DIR "_cache")
(define CACHE_DIR (format "/var/cache/projects/find-people/~a" TOPIC))
(define RESULT_DIR CACHE_DIR)
(define RESULT_FILE (format "locals_in_~a_groups.csv" TOPIC))

(define MIN_MEMBER 3)
(define MAX_MEMBERS_IN_SCANNED_GROUPS 300000)

; access tokens for vk.com
(define AT0 ($ access_token vk/odysseus))
(define AT1 ($ access_token vk/postagg1_1))
(define AT2 ($ access_token vk/postagg2_1))
(define AT3 ($ access_token vk/postagg2_2))
(define AT4 ($ access_token vk/postagg2_3))
(define AT5 ($ access_token vk/postagg3_1))
(define AT6 ($ access_token vk/postagg3_2))
(define AT AT2)

(vk:set-access-token AT)
