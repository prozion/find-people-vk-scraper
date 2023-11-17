#lang racket

(require odysseus)
(require (prefix-in vk: vk))
; (require (file "~/settings/private_settings/APIs.rkt"))
(require (file "../private_settings/APIs.rkt"))
(require "types.rkt")

(provide (all-defined-out))

(define TOPIC1 "belgorod")
(define TOPIC2 "red")
(define TOPIC1_TABTREE_PARTS
          (list
            ; (TabtreePart (format "/home/denis/projects/find_people/knowledge/~a.tree" TOPIC1) 'all)
            (TabtreePart (format "/home/denis/projects/find_people/for_rp/~a.tree" TOPIC1) 'all)
            ))
(define TOPIC2_TABTREE_PARTS
          (list
            ; (TabtreePart "/home/denis/projects/worlds/hi_world/hi_vk.tree" 'информационные_технологии.разработка_по.функциональное_программирование.lisp)
            (TabtreePart "/home/denis/projects/find_people/knowledge/red.tree" 'all)
            ))
; (define FRIENDS_TABTREE_PARTS
;           (list
;             (TabtreePart "/home/denis/denis_personal/my_knowledge/people.tree" 'all)))

; how frequently to write to the file, when changing persistence
; (define FILE_WRITE_FREQUENCY 50)

(define PERSISTENCE_PER_GROUP_FREQUENCY 5)

; cache directory for persistent data:
; (define CACHE_DIR "_cache")
; (define CACHE_DIR (format "/home/denis/cache/find_people/~a_~a" TOPIC1 TOPIC2))
(define CACHE_DIR (format "cache/~a_~a" TOPIC1 TOPIC2))
(define RESULT_DIR CACHE_DIR)
(define RESULT_FILENAME (format "~a_in_~a_groups" TOPIC1 TOPIC2))

(define MIN_MEMBER_TOPIC1 3)
(define MIN_MEMBER_TOPIC2 3)
; (define MAX_MEMBERS_IN_SCANNED_GROUPS 120000)
(define MAX_MEMBERS_IN_SCANNED_GROUPS #f)

; access tokens for vk.com
(define AT7 ($ access_token vk/rp_1))
; (define AT7 ($ access_token vk/nasevere_1))
; (define AT7 ($ access_token vk/postagg3_2))

(vk:set-access-token AT7)
