#lang racket

(require compatibility/defmacro)
(require "../../_lib_links/odysseus_all.rkt")
(require "../../_lib_links/odysseus_tabtree.rkt")
(require "functions.rkt")
(require "globals.rkt")

(provide (all-defined-out))

(define-catch (standard-head-part #:title (title "") #:description (description "") #:keywords (keywords ""))
  (format
    #<<HEAD
<!-- general -->
<meta charset="utf-8">
<!--<meta itemprop="generating-language" content="Lisp/Racket">-->
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="shortcut icon" href="../img/favicon.png">

<!-- styles -->
<link rel="stylesheet" href="../styles/styles.css">
<link rel="stylesheet" href="../styles/news.css">

<!-- scripts -->
<script type="text/javascript" src="../js/functions.js"></script>

<!-- seo -->
<title>~a</title>
<meta name="description" content="~a">
<meta name="keywords" content="~a">
HEAD
    title
    description
    keywords))

(define (print-header)
  (format
    #<<HEADER
<header>
  <div class="title">
    <img class="logo" src="../img/ag_logo.png" alt="Ag" />
    <h1>%(h1 page)%</h1>
  </div>
</header>
HEADER
))

(define (h1 page #:transform-str-function (tfunction string-upcase))
  (let* (
        (page (or page (hash)))
        (h (or
              (hash-ref* page 'h1 #f)
              (get-name page)))
        (h (tfunction h)))
    h))

(define-catch (footer #:statistics (statistics #f))
  (format
    #<<FOOTER
<footer>
  ~a
  <div><b>~a</b> CPUtools</div>
</footer>
FOOTER
    (if-not statistics
      ""
      (format
        "<div>~a</div>"
        (implode
          (map
            (λ (k) (format "~a: <b>~a</b>" k (hash-ref statistics k)))
            (hash-keys statistics))
          ", ")))
      (current-date)
))

(define-catch (make-post-cards
                  posts
                  #:entities entities
                  #:max-symbols (max-symbols MAX_SYMBOLS)
                  #:ad-card (ad-card #f)  ; ad block
                  #:ad-random-max-depth (ad-random-max-depth 10)
                  #:card/date (card/date
                    (λ (p)
                      (let* ((splitted (string-split ($ date p) " "))
                            (adate (first splitted))
                            (atime (second splitted)))
                        (format
                        #<<DATE
                        <div class="date_strip">
                          <span class="date">~a</span> <span class="time">~a</span>
                        </div>
DATE

                        adate
                        atime))))
                  #:card/image (card/image
                    (λ (p) (format
                      #<<IMAGE
                      <div class="image">
                        ~a
                      </div>
IMAGE
                      (let* ((img-urls ($ img-urls p))
                            (video-img-urls ($ video-img-urls p))
                            (img-url (or ($ 3x img-urls) ($ 3x-link img-urls) ($ 4x video-img-urls) ($ 4x_first_frame video-img-urls) ($ doc img-urls)))
                            (img-url (or img-url "../img/ag_stub_1.jpg")))
                        (if img-url
                          (format "<img src=\"~a\" />" img-url)
                        "")))))
                  #:card/title (card/title
                    (λ (p c) (format
                      #<<TITLE
                      <div class="title">
                        <h2>~a</h2>
                      </div>
TITLE
                      (get-source-title p c ""))))
                  #:card/text (card/text
                    (λ (p) (format
                      #<<TEXT
                      <div class="text">
                        ~a
                      </div>
TEXT
                      (let* ((text_to_show (cond
                                            ((not max-symbols) (clean-htmlify ($ text p)))
                                            ((> (string-length ($ text p)) max-symbols)
                                              (str (clean-htmlify (string-ltrim ($ text p) max-symbols)) "..."))
                                            (else
                                              (clean-htmlify ($ text p)))))
                            (text_to_show (string-trim text_to_show))
                            (text_to_show (string-trim text_to_show "<br>" #:repeat? #t #:right? #t))
                            (text_to_show (text-href->a text_to_show))
                            (text_to_show (hashtags->a text_to_show)))
                        text_to_show))))
                  #:card/readpost (card/readpost
                    (λ (p) (format
                      "<div class=\"readnext\"><a href=\"~a\" target=\"_blank\">Перейти к посту</a></div>"
                      ($ url p))))
                  #:card/statistics (card/statistics
                    (λ (p)
                      (format
                        "<div class=\"statistics_line\">~a~a~a</div>"
                        (if ($ likes p)
                          (format "<img class=\"icon\" src=\"../img/likes.png\" /><span class=\"number\">~a</span>" ($ likes p))
                          "")
                        (if ($ comments p)
                          (format "<img class=\"icon\" src=\"../img/comments.png\" /><span class=\"number\">~a</span>" ($ comments p))
                          "")
                        (if ($ reposts p)
                          (format "<img class=\"icon\" src=\"../img/reposts.png\" /><span class=\"number\">~a</span>" ($ reposts p))
                          "")))))
  (let* (
        ; position index for an ad block
        (rnd-number (random ad-random-max-depth)))
    (for/fold
      ((res ""))
      ((p posts) (i (in-naturals)))
      (let* ((c (or
                  (and entities (@id ($ entity-id p) entities))
                  (hash))))
        (str
          res
          (apply
            (curry
              format
                #<<CARD
                <div class="card ~a">
                  <div>
                    <!-- date-place -->
                    ~a
                    <!-- image -->
                    ~a
                    <!-- info block -->
                    <div class="info">
                      <!-- title -->
                      ~a
                      <!-- text -->
                      ~a
                      <!-- post reference -->
                      ~a
                      <!-- statistics strip -->
                      ~a
                    </div>
                  </div>
                </div>
CARD
            )
            (cond
              ((and ad-card (equal? rnd-number i))
                (list
                  "ad"
                  ""
                  (format
                      #<<IMAGE
                      <div class="image">
                        <img src="~a" />
                      </div>
IMAGE
                      ($ img ad-card))
                  (format
                      #<<TITLE
                      <div class="title">
                        <h2>~a</h2>
                      </div>
TITLE
                      ($ title ad-card))
                  ($ text ad-card)
                  ""
                  ""))
              (else
                (list
                  ""
                  (card/date p)
                  (card/image p)
                  (card/title p c)
                  (card/text p)
                  (card/readpost p)
                  (card/statistics p)
                  )))))))))
