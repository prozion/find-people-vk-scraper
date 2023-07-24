#lang racket

(require odysseus)
(require (prefix-in vk: vk))
(require (file "~/.private/APIs.rkt"))
(require "types.rkt")

(provide (all-defined-out))

(define city "novosibirsk")

(define TOPIC1 city)
(define TOPIC2 "red")
(define TOPIC1_TABTREE_PARTS
          (list
            ; (TabtreePart "/home/denis/projects/worlds/cs_world/_local/rostova_cs_vk.tree" 'all)
            ; (TabtreePart "/home/denis/projects/worlds/general-facts/_universities_local/rostova_uni_vk.tree" 'all)
            ; (TabtreePart "/home/denis/projects/taganoskop/knowledge/taganrog_full.tree" 'all)
            ; (TabtreePart "/home/denis/projects/worlds/_world/_local/rostova_vk.tree" 'all)
            ; (TabtreePart "/home/denis/projects/search-people/knowledge/irkutsk.tree" 'all)
            ; (TabtreePart "/home/denis/projects/search-people/knowledge/kingisepp.tree" 'all)
            (TabtreePart (format "/home/denis/projects/search-people/for_rp/~a.tree" TOPIC1) 'all)
            ; (TabtreePart "/home/denis/projects/search-people/knowledge/it.tree" 'all)
            ))
(define TOPIC2_TABTREE_PARTS
          (list
            ; (TabtreePart "/home/denis/projects/worlds/hi_world/hi_vk.tree" 'информационные_технологии.разработка_по.функциональное_программирование.lisp)
            ; (TabtreePart "../knowledge/history_vk.tree" 'all)
            ; (TabtreePart "/home/denis/projects/taganoskop/knowledge/history.tree" 'all)
            ; (TabtreePart "/home/denis/projects/cuba-kb/knowledge/sn.tree" 'vk_группы)
            ; (TabtreePart "/home/denis/projects/various-kgr/astronomy/sn.tree" 'all)
            (TabtreePart "/home/denis/projects/red-kgr/sn.tree" 'all)
            ))
; (define FRIENDS_TABTREE_PARTS
;           (list
;             (TabtreePart "/home/denis/denis_personal/my_knowledge/people.tree" 'all)))

; how frequently to write to the file, when changing persistence
(define FILE_WRITE_FREQUENCY 50)

; cache directory for persistent data:
; (define CACHE_DIR "_cache")
(define CACHE_DIR (format "/var/cache/projects/find-people/~a_~a" TOPIC1 TOPIC2))
(define RESULT_DIR CACHE_DIR)
(define RESULT_FILENAME (format "~a_in_~a_groups" TOPIC1 TOPIC2))

(define MIN_MEMBER_TOPIC1 3)
(define MIN_MEMBER_TOPIC2 3)
(define MAX_MEMBERS_IN_SCANNED_GROUPS 140000)
; (define MAX_MEMBERS_IN_SCANNED_GROUPS #f)

; access tokens for vk.com
(define AT7 ($ access_token vk/nasevere_1))

(vk:set-access-token AT7)
