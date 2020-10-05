#lang racket

(require web-server/servlet
         web-server/servlet-env)
(require web-server/templates)
(require xml)
(require racket/runtime-path)

(define-runtime-path cwd "..") ;; need this to find the real root

(define title "HEGP CHALLENGE")
(define subtitle
  '(a ((href "https://doi.org/10.1534/genetics.120.303153"))
      "Genetics June 1, 2020 vol. 215 no. 2 359-372"))

(define subsubtitle
  "Homomorphic Encryption of Genotypes and Phenotypes (HEGP)")

(define animation-caption
  "Animation of HEGP encrypting using step-wise linear orthogonal
transformation:")

(define CC-BY-NC
  '(a ((href "https://creativecommons.org/licenses/by-nc/4.0/")) "CC-BY-NC"))

(define code-repo-url
  '(a ((href "https://github.com/encryption4genetics"))
      "code"))
(define point-right-image
  '(img ((src "/pointing-finger-right.png"))))
(define point-left-image
  '(img ((src "/pointing-finger-left.png"))))

(define (edit-button uri)
  `(div ((class "editbutton")) (a ((href ,uri)) "Edit text!")))

(define footer
  `(footer
    (hr)
    (div ((class "copyright")) "Source " ,code-repo-url
         " by the HEGP team (AGPLv3) - text published under " ,CC-BY-NC)))

(define (get-doc-path fn)
  (begin
    (path->string (build-path cwd "doc" fn))))

(define (read-file fn)
  (let ([htmlfn (get-doc-path fn)])
  (with-input-from-file htmlfn
    (lambda () (read-bytes (file-size htmlfn))))))

(define (strip-body fn)
  (string->xexpr
   (first
    (string-split
     (second
      (string-split
       (bytes->string/utf-8
        (read-file fn))
       "<body>"))
     "<div id=\"postamble\" class=\"status\">"))))

(define (challenge request)
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
                 (div ((class "subtitle")) ,subtitle)
                 (div ((class "subsubtitle")) ,subsubtitle))
            (div ((class "header"))
                 ,point-left-image)
           ,(edit-button "https://github.com/encryption4genetics/HEGP-website/blob/master/doc/call.org")
           (section
            ((class "call"))
            ,(strip-body "call.html")))
           ,footer
           ))))

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
                 (div ((class "subtitle")) ,subtitle)
                 (div ((class "subsubtitle")) ,subsubtitle))
            (div ((class "header"))
                 ,point-left-image))

           ,(edit-button "https://github.com/encryption4genetics/HEGP-website/blob/master/doc/intro.org")
           (section
            ((class "intro"))
            ,(strip-body "intro.html"))
           (div ((class "caption")) ,animation-caption)
           ,(include-template/xml "./static/app.html")
           ,(edit-button "https://github.com/encryption4genetics/HEGP-website/blob/master/doc/challenge.org")
           (section
            ((class "main-text"))
            ,(strip-body "challenge.html"))
           ,footer
           ))))

(define (error-handler request)
  (response/xexpr
   `(html
     (body
      (h1 "ERROR")))))

(define-values (dispatch generate-url)
  (dispatch-rules
    [("start") start]
    [("challenge") challenge]
    [("") start]
    ; [else (error "There is no procedure to handle the url.")]))
    ))

(define (request-handler request)
  (dispatch request))

(serve/servlet request-handler
               #:port 8096
               #:launch-browser? #f
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
