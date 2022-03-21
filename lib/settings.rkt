#lang racket

(require odysseus)
(require (prefix-in vk: odysseus/api/vk))
(require (file "~/.private/APIs.rkt"))
(require "types.rkt")

(provide (all-defined-out))

(define TOPIC "history")
(define TOPIC_AREA_TABTREE_PARTS
          (list
            ; (TabtreePart "/home/denis/projects/worlds/hi_world/hi_vk.tree" 'информационные_технологии.разработка_по.функциональное_программирование.lisp)
            (TabtreePart "/home/denis/projects/worlds/history-facts/hi_vk.tree" 'all)
            (TabtreePart "/home/denis/projects/taganoskop/knowledge/history.tree" 'all)
            ))
(define LOCAL_AREA_TABTREE_PARTS
          (list
            ; (TabtreePart "/home/denis/projects/worlds/cs_world/_local/rostova_cs_vk.tree" 'all)
            (TabtreePart "/home/denis/projects/worlds/general-facts/_universities_local/rostova_uni_vk.tree" 'all)
            (TabtreePart "/home/denis/projects/taganoskop/knowledge/taganrog.tree" 'all)
            ; (TabtreePart "/home/denis/projects/worlds/_world/_local/rostova_vk.tree" 'all)
            ))
(define FRIENDS_TABTREE_PARTS
          (list
            (TabtreePart "/home/denis/denis_personal/my_knowledge/people.tree" 'all)))

; how frequently to write to the file, when changing persistence
(define FILE_WRITE_FREQUENCY 50)

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
