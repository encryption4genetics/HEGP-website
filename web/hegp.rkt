#lang racket

;; (require "./execute.rkt")

(require web-server/servlet
         web-server/servlet-env)
(require web-server/templates)

(define title "HEGP CHALLENGE")
(define subtitle
  ; https://doi.org/10.1534/genetics.120.303153"))
  "Genetics June 1, 2020 vol. 215 no. 2 359-372")

(define code-repo-url
  '(a ((href "https://github.com/encryption4genetics"))
      "code"))
(define point-right-image
  '(img ((src "/pointing-finger-right.png"))))
(define point-left-image
  '(img ((src "/pointing-finger-left.png"))))

(define (start request)
  (response/xexpr
   `(html ((lang "en"))
          (head (title ,title)
                (link ((rel "stylesheet")
                       (href "/style.css")
                       (type "text/css")))
                (link ((rel "stylesheet")
                       (href "/hegp.css")
                       (type "text/css"))))
          (body
           (header
            (div ((class "header"))
                 ,point-right-image)
            (div ((class "header"))
                 (h1 ,title)
                 (div ((class "subtitle")) ,subtitle))

            (div ((class "header"))
                 ,point-left-image))
           (footer
            (hr)
            (div ((class "copyright")) "Source " ,code-repo-url
                 " by the HEGP team"))
           ))))

(define (error-handler request)
  (response/xexpr
   `(html
     (body
      (h1 "ERROR")))))

(define-values (dispatch generate-url)
  (dispatch-rules
    [("start") start]
    [("") start]
    ; [else (error "There is no procedure to handle the url.")]))
    ))

(define (request-handler request)
  (dispatch request))

(serve/servlet request-handler
               #:port 8080
               #:launch-browser? #t
               #:stateless? #t
               #:servlet-path "/"
               #:servlets-root "/"
               #:servlet-regexp	#rx"start|\\s*"
               #:server-root-path (current-directory)
               #:file-not-found-responder error-handler
               #:extra-files-paths
               (list
                (build-path (current-directory) "web/static"))
               )
