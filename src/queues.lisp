;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10; indent-tabs-mode: nil -*-
;;;;
;;;; Copyright © 2009 Josh Marchan
;;;;
;;;; Simple Queues
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :chanl)

(eval-when (:compile-toplevel)
  (defvar queue-sentinel (make-symbol "EMPTY")))

(define-speedy-function make-queue (length)
    ((integer 1 #.(- array-total-size-limit 2)) length)
  "Creates a new queue of maximum size LENGTH"
  (let ((queue (the simple-vector
                 (make-array (the (integer 3 #.array-total-size-limit)
                               (+ 2 length))
                             :initial-element 2))))
    (setf (svref queue 2) '#.queue-sentinel)
    queue))

(define-speedy-function queue-peek (queue)
    (simple-vector queue)
  "Dereference QUEUE's head pointer"
  (svref queue (the (integer 2 #.(1- array-total-size-limit))
                 (svref queue 0))))

(define-speedy-function queue-zero-p (queue)
    (simple-vector queue)
  "Checks whether QUEUE's theoretical length is zero"
  (= (the (integer 2 #.(1- array-total-size-limit))
       (svref queue 0))
     (the (integer 2 #.(1- array-total-size-limit))
       (svref queue 1))))

(define-speedy-function queue-empty-p (queue)
    (type simple-vector queue)
  "Checks whether QUEUE's effective length is zero"
  (and (queue-zero-p queue)
       (eq (queue-peek queue) '#.queue-sentinel)))

(define-speedy-function queue-full-p (queue)
    (type simple-vector queue)
  "Checks whether QUEUE is effectively full"
  (and (queue-zero-p queue)
       (not (eq (queue-peek queue) '#.queue-sentinel))))

(define-speedy-function queue-count (queue)
    (simple-vector queue)
  "Returns QUEUE's effective length"
  (let ((length (mod (- (svref queue 1)
                        (svref queue 0))
                     (- (length queue) 2))))
    (if (zerop length)
        (if (eq (queue-peek queue) '#.queue-sentinel) 0
            (- (length queue) 2))
        length)))

(define-speedy-function queue-max-size (queue)
    (simple-vector queue)
  "Returns QUEUE's maximum length"
  (the fixnum (- (length queue) 2)))

(define-speedy-function enqueue (object queue)
    (simple-vector queue)
  "Sets QUEUE's head to OBJECT and increments QUEUE's head pointer"
  (setf (svref queue (the (integer 2 #.(1- array-total-size-limit))
                       (svref queue 1)))
        object
        (svref queue 1)
        (+ 2 (mod (1- (svref queue 1))
                  (- (length queue) 2))))
  object)

(define-speedy-function dequeue (queue)
    (simple-vector queue)
  "Sets QUEUE's tail to QUEUE, increments QUEUE's tail pointer, and returns the previous tail ref"
  (prog1 (svref queue (svref queue 0))
    (setf (svref queue 0) (+ 2 (mod (1- (svref queue 0)) (- (length queue) 2))))
    (when (queue-zero-p queue) (setf (svref queue (svref queue 0)) '#.queue-sentinel))))
