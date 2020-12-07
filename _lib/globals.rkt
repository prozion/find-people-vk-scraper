#lang racket

(require "../../_lib_links/odysseus_all.rkt")
;
(provide (all-defined-out))

;  server settings
(define HOURS_SHIFT 3) ; to correct output time, regarding time of the scraping script on the remote server

; output post criteria
(define MAX_SYMBOLS 800)
(define MIN_SYMBOLS 100)

(define DEFAULT_PLACE #f)
(define CURRENT_LOCATION "rostov_linux")
(define TOPIC_AREA_TABTREE (list
                              (hash 'file "../../../worlds/cs_world/cs_vk.tree" 'take 'информационные_технологии.разработка_по.операционные_системы)
                              (hash 'file "../../../worlds/cs_world/cs_vk.tree" 'take 'информационные_технологии.системное_администрирование)
                              (hash 'file "../../../worlds/cs_world/cs_vk.tree" 'take 'информационные_технологии.open_source)
                              (hash 'file "../../../worlds/cs_world/linux/linux_vk.tree" 'take 'all)))
(define LOCAL_AREA_TABTREES (list
                                (hash 'file "../../../worlds/cs_world/_local/rostova_cs_vk.tree" 'take 'all)
                                (hash 'file "../../../worlds/elx_world/_local/rostova_elx_vk.tree" 'take 'all)
                                (hash 'file "../../../worlds/_world/_universities_local/rostova_uni_vk.tree" 'take 'all)
                                (hash 'file "../../../worlds/_world/_local/rostova_vk.tree" 'take 'университетские_группы_ростовской_агломерации.технические)
                            ))

; how frequently to write to the file, when changing persistence
(define FILE_WRITE_FREQUENCY 500)

; cache directory for persistent data:
; (define CACHE_DIR "_cache")
(define CACHE_DIR (format "_cache/~a" CURRENT_LOCATION))
(define RESULT_DIR "results")

(define MIN_MEMBER 4)
(define MAX_MEMBERS_IN_SCANNED_GROUPS 100000)
