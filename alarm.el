;;; alarm.el --- Commonly used intervals for setting alarms while working -*- lexical-binding: t -*-

;; Author: William Carroll <wpcarro@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.1") (ivy "0.13.0"))

;; This file is NOT part of GNU Emacs.

;; The MIT License (MIT)
;;
;; Copyright (c) 2016 Al Scott
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:
;; Select common timer intervals with ivy and use `notifications-notify' to
;; display a message when the timer completes.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'ivy)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Library
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgroup alarm nil
  "Schedule alarms to focus on a task."
  :group 'emacs)

(defcustom alarm-intervals
  '(("1 minute" . 1)
    ("2 minutes" . 2)
    ("3 minutes" . 3)
    ("4 minutes" . 4)
    ("5 minutes" . 5)
    ("10 minutes" . 10)
    ("15 minutes" . 15)
    ("20 minutes" . 20)
    ("30 minutes" . 30)
    ("45 minutes" . 45)
    ("1 hour" . 60)
    ("2 hours" . 120))
  "Commonly used intervals for timer amounts in minutes."
  :type '(alist :key-type string :value-type integer)
  :group 'alarm)

(defun alarm-ivy-schedule ()
  "Use ivy to select and schedule an alarm for a given set of time intervals."
  (interactive)
  (let ((ivy-sort-functions-alist nil))
    (ivy-read "Set timer for: "
              alarm-intervals
              :action (lambda (cell)
                        (run-at-time
                         (format "%s minutes" (cdr cell))
                         nil
                         (lambda ()
                           (notifications-notify
                            :title "productivity.el"
                            :body (format "%s timer complete." (car cell)))))
                        (message (format "%s timer scheduled." (car cell)))))))

(provide 'alarm)
;;; alarm.el ends here
