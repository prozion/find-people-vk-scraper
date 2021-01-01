#lang racket

(require odysseus)
(require racket/serialize)
(require "settings.rkt")

(provide (all-defined-out))

(persistent h-ext-users-1)
(persistent h-ext-users-2)
(persistent h-ext-groups-1)
(persistent h-ext-groups-2)

(define-catch (val-or-empty val)
  (if (and (list? val) (empty? val))
    (hash)
    val))

(define-catch (get-saved-users-1) (val-or-empty (h-ext-users-1)))
(define-catch (get-saved-users-2) (val-or-empty (h-ext-users-2)))
(define-catch (save-users-1 h-ext-users) (h-ext-users-1 h-ext-users) (void))
(define-catch (save-users-2 h-ext-users) (h-ext-users-2 h-ext-users) (void))

(define-catch (get-saved-groups-1) (val-or-empty (h-ext-groups-1)))
(define-catch (get-saved-groups-2) (val-or-empty (h-ext-groups-2)))
(define-catch (save-groups-1 h-ext-groups) (h-ext-groups-1 h-ext-groups) (void))
(define-catch (save-groups-2 h-ext-groups) (h-ext-groups-2 h-ext-groups) (void))
