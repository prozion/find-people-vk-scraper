#lang typed/racket

(require typed/racket)

(provide (all-defined-out))

(struct TabtreePart ((filepath : String) (treepath : Symbol)))
(define-type Gid String)
(define-type GidName String)
(define-type Uid String)
(define-type Id (U Gid Uid))
(define-type IdType (U "group" "user"))
(define-type Count Integer)
(define-type IdAlias (HashTable Gid GidName))
(define-type Key Symbol)
(define-type Url String)
(define-type Item (HashTable Key Any))
(define-type GroupItem Item)
(define-type UserItem Item)
(struct Limits ((limit1 : Integer) (limit2 : Integer)))
(define-type GroupItemWithUsers (HashTable Key (U String Integer (Listof Uid))))
(define-type UserItemWithGroups (HashTable Key (U String Integer (Listof Gid))))
(define-type ExtendedGroups (HashTable Gid GroupItemWithUsers))
(define-type ExtendedUsers (HashTable Uid UserItemWithGroups))

(define empty-extended-users (ann (make-hash empty) ExtendedUsers))
