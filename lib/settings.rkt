#lang racket

(require odysseus)
(require (prefix-in vk: vk))
; (require (file "~/settings/private_settings/APIs.rkt"))
(require (file "../private_settings/APIs.rkt"))
(require "types.rkt")

(provide (all-defined-out))

(define TOPIC1 "belgorod") ; <- Сюда вписывать город
(define TOPIC2 "red") ; Список левых групп

(define TOPIC1_TABTREE_PARTS
          (list
            ; (TabtreePart (format "/home/denis/projects/find_people/knowledge/~a.tree" TOPIC1) 'all)
            (TabtreePart (format "../for_rp/~a.tree" TOPIC1) 'all)
            ))
(define TOPIC2_TABTREE_PARTS
          (list
            (TabtreePart (format "../knowledge/~a.tree" TOPIC2) 'all)
            ))

; сохранение в файл полученных данных через N считанных пабликов
; (чтобы в случае сброса коннекта вконтактом не начинать все заново):
(define PERSISTENCE_PER_GROUP_FREQUENCY 5)

; директория, в которую сохраняются считанные данные:
(define CACHE_DIR (format "cache/~a_~a" TOPIC1 TOPIC2))
(define RESULT_DIR CACHE_DIR)
; имя результирующего csv файла:
(define RESULT_FILENAME (format "~a_in_~a_groups" TOPIC1 TOPIC2))

; минимальное количество пабликов в каждой из групп, в которые должен входить пользоваетль, чтобы попасть в итоговый список:
(define MIN_MEMBER_TOPIC1 3)
(define MIN_MEMBER_TOPIC2 3)

; не считывать данные из пабликов, число членов в которых выше указанного числа:
; (define MAX_MEMBERS_IN_SCANNED_GROUPS 120000)
(define MAX_MEMBERS_IN_SCANNED_GROUPS #f) ; считываем все паблики

; access tokens for vk.com
(define AT ($ access_token vk/rp_1))
; (define AT ($ access_token vk/nasevere_1))

(vk:set-access-token AT)

; создаем директорию с данными и csv, если таковой еще нет:
(make-directory* (str "../" RESULT_DIR))
