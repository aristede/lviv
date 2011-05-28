;
;Copyright (c) 2011 Riad S. Wahby <rsw@jfet.org>
;
;Permission is hereby granted, free of charge, to any person obtaining a copy
;of this software and associated documentation files (the "Software"), to deal
;in the Software without restriction, including without limitation the rights
;to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;copies of the Software, and to permit persons to whom the Software is
;furnished to do so, subject to the following conditions:
;
;The above copyright notice and this permission notice shall be included in
;all copies or substantial portions of the Software.
;
;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;THE SOFTWARE.
;

; #################
; #### PRELUDE ####
; #################
; eventually, most of this will be defined in lviv directly
; rather than via lviv wrapped in scheme calls (but of course
; file reading will have to be implemented first!)

(define lvivState (mkEmptyState))

(define (lviv-define-prim x arity . name)
  (if (null? name)
    ((applyMap lvivState) (quasiquote (,arity ,x primitive ,x define)))
    (let ((cName (car name)))
      ((applyMap lvivState) (quasiquote (,arity ,x primitive ,cName define))))))
(define (lviv-define-val x val)
  ((applyMap lvivState) (quasiquote (,val ,x define))))

(lviv-define-val 'pi 3.141592653589793238462643)
(lviv-define-val 'nil '())

(lviv-define-prim '+ 2)
(lviv-define-prim '- 2)
(lviv-define-prim '/ 2)
(lviv-define-prim '* 2)

(define (inv x) (/ 1 x)) (lviv-define-prim 'inv 1)
(lviv-define-prim 'modulo 2 'mod)

(define (chs x) (* -1 x))
(lviv-define-prim 'chs 1 'neg)
(lviv-define-prim 'chs 1)
(lviv-define-prim 'abs 1)

(lviv-define-prim 'ceiling 1 'ceil)
(lviv-define-prim 'floor 1)
(lviv-define-prim 'number->int 1 'int)

(define (frac x) (- x (number->int x)))
(lviv-define-prim 'frac 1)

(define (pct y x) (* (/ y 100) x))
(lviv-define-prim 'pct 2 '%)

(define (pctOf y x) (* 100 (/ x y)))
(lviv-define-prim 'pctOf 2 '%t)

(define (pctCh y x) (* 100 (/ (- x y) y)))
(lviv-define-prim 'pctCh 2 '%ch)

(lviv-define-prim 'eq? 2)
(lviv-define-prim '< 2)
(lviv-define-prim '> 2)
(lviv-define-prim '<= 2)
(lviv-define-prim '>= 2)

(lviv-define-prim 'expt 2 '^)
(lviv-define-prim 'sqrt 1)

(lviv-define-prim 'append 2)
(lviv-define-prim 'cons 2)

(define (add-cxrs state n)
  (letrec ((nums (take n '(1 2 4 8 16)))
           (bitAD
             (lambda (cnt)
               (apply string-append
                 (map (lambda (x)
                        (if (= (modulo (quotient cnt x) 2) 0) "a" "d"))
                      nums))))
           (acHlp
             (lambda (cnt) 
               (if (= (expt 2 n) cnt) #t
                 (let ((nxName (string->symbol (string-append "c" (bitAD cnt) "r"))))
                   (stEnvUpdateBinding state
                                       (cons nxName
                                             (mkPrimBinding nxName 1)))
                   (acHlp (+ cnt 1)))))))
    (acHlp 0)))

;(add-cxrs lvivState 5)
;only defined up to 4 levels, not 5 as I'd previously believed
(add-cxrs lvivState 4)
(add-cxrs lvivState 3)
(add-cxrs lvivState 2)
(add-cxrs lvivState 1)
