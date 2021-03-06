; Matrix.scm

#lang racket/base

(require racket/contract)

(define size 30)

(define (1+ x) (+ x 1))

(define nat? natural-number/c)
(define natmatrix? (vectorof (vectorof nat?)))

(define/contract (mkmatrix rows cols)
  (-> nat? nat? natmatrix?)
  (let ((mx (make-vector rows 0))
        (count 1))
      (define/contract (do1 i)
        (-> nat? void?)
        (let ([row (make-vector cols 0)])
          (do ([j 0 (1+ j)])
              ([= j cols])
              (do2 row j))
          (vector-set! mx i row)
              ))
      (define/contract (do2 row j)
        (-> (vectorof nat?) nat? void?)
          (vector-set! row j count)
          (set! count (+ count 1)))
    (do ((i 0 (1+ i)))
        ((= i rows))
        (do1 i))
    mx))

(define/contract (num-cols mx)
  (->  natmatrix? nat?)
  (let ((row (vector-ref mx 0)))
    (vector-length row)))

(define/contract (num-rows mx)
  (-> natmatrix? nat?)
  (vector-length mx))

(define/contract (mmult rows cols m1 m2)
  (-> nat? nat? natmatrix? natmatrix? (vectorof nat?))
  (let ((m3 (make-vector rows 0)))
    (define/contract (do1 i)
      (-> nat? void?)
      (let ([m1i (vector-ref m1 i)]
            [row (make-vector cols 0)])
        (do ([j 0 (1+ j)])
            ([= j cols])
            (do2 m1i row j))))
    (define/contract (do2 m1i row j)
      (-> (vectorof nat?) (vectorof nat?) nat? void?)
      (let ([val 0])
        (do ([k 0 (1+ k)])
            ([= k cols])
            (do3 m1i row val j k))
            (vector-set! row j val)))
    (define/contract (do3 m1i row val j k)
      (-> (vectorof nat?) (vectorof nat?) nat? nat? nat? void?)
              (set! val (+ val (* (vector-ref m1i k)
                                  (vector-ref (vector-ref m2 k) j)))))
    (do ((i 0 (1+ i)))
        ((= i rows))
        (do1 i)) m3))
;;       (let ((m1i (vector-ref m1 i))
;;             (row (make-vector cols 0)))
;;         (do ((j 0 (1+ j)))
;;             ((= j cols))
;;           (let ((val 0))
;;             (do ((k 0 (1+ k)))
;;                 ((= k cols))
;;               (set! val (+ val (* (vector-ref m1i k)
;;                                   (vector-ref (vector-ref m2 k) j)))))
;;             (vector-set! row j val)))
;;         (vector-set! m3 i row)))
;;     m3))

;; (define/contract (matrix-print m)
;;   (do ((i 0 (1+ i)))
;;       ((= i (num-rows m)))
;;     (let ((row (vector-ref m i)))
;;       (do ((j 0 (1+ j)))
;;           ((= j (num-cols m)))
;;         (display (vector-ref row j))
;;         (if (< j (num-cols m))
;;             (display " ")
;;             #t))
;;       (newline))))
;; (define (print-list . items) (for-each display items) (newline))

(define/contract (main args)
  (-> (vectorof string?) void?)
  (let ((n (or (and (= (vector-length args) 1) (string->number (vector-ref
                                                                args 0)))
               1)))
    (let ((mm 0)
          (m1 (mkmatrix size size))
          (m2 (mkmatrix size size)))
      (define/contract (loop iter)
        (-> nat? void?)
        (cond ((> iter 0)
               (set! mm (mmult size size m1 m2))
               (loop (- iter 1)))))
      (loop n)))) ;; 2014-12-04 ben: TODO mm is not a vector, for some reason
      ;; (let ((r0 (vector-ref mm 0))
      ;;       (r2 (vector-ref mm 2))
      ;;       (r3 (vector-ref mm 3))
      ;;       (r4 (vector-ref mm 4)))
      ;;   (format "~a ~a ~a ~a" (vector-ref r0 0) (vector-ref r2 3)
      ;;               (vector-ref r3 2) (vector-ref r4 4))))))

(time (begin (main (vector "12000")) (void)))
