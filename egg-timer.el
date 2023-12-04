;;; egg-timer.el --- Commonly used intervals for setting timers while working -*- lexical-binding: t -*-

;; Author: William Carroll <wpcarro@gmail.com>
;; URL: https://github.com/wpcarro/egg-timer.el
;; Version: 0.0.2
;; Package-Requires: ((emacs "25.1"))

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
;; Select common timer intervals and use `notifications-notify' to display a
;; message when the timer completes.  Since this depends on
;; `notifications-notify', ensure that your Emacs is compiled with dbus
;; support.
;;

;; 2023-12-04 https://github.com/twitchy-ears/egg-timer.el
;;
;; I really liked the simplicity of the interface here but I wanted to
;; be able to free form enter text for choosing a timer's time as well
;; as select from a list with completion, also I wanted to make it
;; work on systems where I didn't have access to DBUS notifications
;; (remote terminal machines, windows machines, etc) so I wanted to
;; make the notification system more customisable if I wanted too, and
;; then I wanted the ability to list/modify the timers running... so I
;; sort of took the original incredibly simple and beautiful code and
;; mangled it with complexity.
;;
;; But the users experience of it should remain very simple.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'notifications)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Library
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgroup egg-timer nil
  "Use timers to help focus on a task."
  :group 'emacs)

(defcustom egg-timer-intervals
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
  :group 'egg-timer)

(cl-defstruct egg-timer-event
  "An egg timer event that is stored in the list of events"
  id
  timer-item
  label)

(defvar egg-timer-notification-method 'notify
  "Backup notification method if 'notifications-notify' isn't
 available, can be one of:
 * 'notify (use notifications-notify if possible)
 * 'buffer (pop up a buffer with a message in)
 * 'message (just use the message function)
 * #'your-function in which case it'll run the function and
   pass it the label

It will default to message.")

(defvar egg-timer-running-timers nil "Stores the running timers for egg-timer.el")

(defun egg-timer-p ()
  "Return nil if an egg timer isn't running, t if one is."
  (interactive)
  (if (and (not (equal egg-timer-running-timers nil))
           (listp egg-timer-running-timers)
           (not (seq-empty-p egg-timer-running-timers)))

      ;; Yes timers
      (progn 
        (if (called-interactively-p 'any)
            (message "egg-timer-p: t"))
        t)

    ;; No timers
    (progn
      (if (called-interactively-p 'any)
          (message "egg-timer-p: nil"))
      nil)))

(defun egg-timer-list ()
  "Returns a list of all currently running egg-timer-events if
called interactively messages this list formatted with
'<label> (ID: <id>)' when called programatically returns an
alist of events each of (label id)."
  (interactive)
  (when (egg-timer-p)
    (if (called-interactively-p 'any)
        (let ((tlist (mapcar (lambda (x)
                               (format "%s (ID: %s)"
                                       (egg-timer-event-label x)
                                       (egg-timer-event-id x)))
                             egg-timer-running-timers)))
          (message "%s" tlist))

      (mapcar (lambda (x)
                (cons (egg-timer-event-label x)
                      (egg-timer-event-id x)))
              egg-timer-running-timers))))

(defun egg-timer-cancel (&optional timer-choice)
  "Offers the user a choice of egg-timer-event to cancel, if called programmatically requires an ID"
  (interactive)
  (when (egg-timer-p)

    ;; If we don't get passed one then ask for one
    (if (and (not timer-choice)
             (called-interactively-p 'any))
        (let* ((choices (mapcar
                         (lambda (x)
                           (concat 
                            (format "%s" (egg-timer-event-label x))
                            ;; Lets us have an ID after the label but not
                            ;; clutter the view in the completing-read
                            (propertize (format " (%s)" (egg-timer-event-id x))
                                        'invisible t)))
                         egg-timer-running-timers)))
          (setq timer-choice (completing-read "Cancel: " choices))))

    ;; If we get one:
    (when timer-choice
      
      ;; Select the ID which is listed in the brackets after the label
      (string-match "(\\([[:graph:]]+\\))$"
                    timer-choice)
      
      (let ((timerid (match-string 1 timer-choice)))
        
        ;; if we get a timerid then search for it
        (when timerid
          (let ((tstruct (seq-find
                          (lambda (x)
                            (equal (egg-timer-event-id x)
                                   timerid))
                          egg-timer-running-timers)))
            
            ;; If we found an egg-timer-event struct then cancel its
            ;; timer and remove it from the list by ID.
            (when tstruct
              (cancel-timer (egg-timer-event-timer-item tstruct))
              (setq egg-timer-running-timers
                    (seq-remove (lambda (x)
                                  (equal (egg-timer-event-id x)
                                         timerid))
                                egg-timer-running-timers)))))))))
    
(cl-defun egg-timer--timedesc-checker (timedesc)
  "Accepts a string in the format of \"<unit> <measure>\" where the unit
should be an integer and the measure should be from 'timer-duration-words', it will also accept these words pluralised with an s on the end and remove it.

Returns a cons cell of (<unit> . <measure>) or nil in the event
of bad formatting"
  (cond

   ;; Just get an int? Assume minutes
   ((if (integerp timedesc)
        (cl-return-from egg-timer--timedesc-checker (cons timedesc "minute"))))

   ;; Get a string we can parse?  Parse and return, this will attempt
   ;; to drop s from the end of strings because none of the
   ;; timer-duration-words has it by default.  This is a dangerous
   ;; assumption based on English named units.
   ((if (string-match "^\\([[:digit:]]+\\)[[:space:]]+\\([[:graph:]]+?\\)s??$"
                      timedesc)
        (let* ((unit (string-to-number (match-string 1 timedesc)))
               (measure (match-string 2 timedesc))
               (exists (assoc measure timer-duration-words)))
          (format "got '%s' '%s'" unit measure)
          (if (and (not (equal unit nil))
                   (not (equal exists nil)))
              (cons unit measure)))))
    
   ;; Otherwise try and extract a number from whatever we get and assume its
   ;; minutes
   ((stringp timedesc)
    (progn
      ;; (message "Guessing based on a string and doing string-to-number")
      (let ((num (string-to-number timedesc)))
        (if num
            (cl-return-from egg-timer--timedesc-checker
              (cons num "minute"))))))

   ;; Unsure?  Return nil
   t nil))

(cl-defun egg-timer--display-message (id)
  "Takes an 'id' argument that must match one of the :id elements of an
egg-timer-event stored in 'egg-timer-running-timers'.

Attempts to display the message of that event using the method
 specified in the 'egg-timer-notification-method' variable.

Then attempts to remove the egg-timer-event from the list of
running timers regardless of if it thinks it notifed or not, the
moment has passed."
  (unless (egg-timer-p)
    ;; (message "egg-timer--display-message: egg-timer-p says nil so failing early")
    (cl-return-from egg-timer--display-message nil))

  ;; Retrieve our egg-timer
  (let ((tstruct (seq-find (lambda (x)
                             (equal (egg-timer-event-id x)
                                    id))
                           egg-timer-running-timers)))
    (when tstruct
      (let ((label (egg-timer-event-label tstruct)))
        (cond
         
         ;; If the user has bound 
         ((functionp egg-timer-notification-method)
          (funcall egg-timer-notification-method label))
         
         ;; w32 notification, need IDs storing and all sorts of faff.
         ;; ((string-equal system-type "windows-nt")
         ;; ;; (message "Attempting a w32 notification")
         ;; (w32-notification-notify :title "egg timer complete" label))
         
         ((equal egg-timer-notification-method 'buffer)
          (let ((eggwin (with-temp-buffer-window
                            "*egg-timer*"
                            nil
                            (lambda (win bodyres)
                              win)
                          (princ label))))
            (shrink-window-if-larger-than-buffer eggwin)))
         
         ((equal egg-timer-notification-method 'message)
          (message "EGG-TIMER: %s" label))
         
         ;; Have dbus?  Lets go, this should be default for
         ;; *nix GUI emacs
         ((and (equal egg-timer-notification-method 'notify)
               (not (equal (notifications-get-capabilities) nil)))
          
          (notifications-notify
           :title "egg-timer.el"
           :body (format "%s timer complete." label)))
         
         ;; Fallback
         (t (message "EGG-TIMER: %s" label)))
        
        ;; Cleanup
        (setq egg-timer-running-timers
              (seq-remove (lambda (x)
                            (equal (egg-timer-event-id x)
                                   id))
                          egg-timer-running-timers))))))

(defun egg-timer-do-schedule (timedesc &optional label)
  "Schedule a timer to go off in TIMEDESC.  This should be a string in the
format of units and a measure featured in 'timer-duration-words', can be
given as an integer which is presumed to be minutes.
Provide LABEL to change the notifications, which defaults to \"TIMEDESC\"
with the correct amount of units on the end."
  ;; (interactive)
  (let ((timer-details (egg-timer--timedesc-checker timedesc)))
    (when (not (equal timer-details nil))
      (let* ((units (car timer-details))
             (measure (cdr timer-details))
             (actual-label (if (not (equal label nil))
                               label
                             (format "%i %s" units measure))))

        ;; Set the timer creating an egg-timer-event struct and
        ;; pushing it onto the egg-timer-running-timers list.
        (let* ((timer-id (md5
                          (format "%s-%s"
                                  (format-time-string "%s" (current-time))
                                  (recent-keys))))
               (event (run-at-time
                       actual-label ;; When do we run
                       nil          ;; No repeat

                       ;; Pass the ID so it can find the label and remove it
                       `(lambda () (egg-timer--display-message ,timer-id))))

               ;; construct the structure.
               (tstruct (make-egg-timer-event
                         :id timer-id
                         :timer-item event
                         :label actual-label)))
          (push tstruct egg-timer-running-timers))

        ;; Tell the user we did it
        (message "%s timer scheduled." actual-label)))))

(defun egg-timer-schedule ()
  "Select and schedule a timer for a given set of time intervals."
  (interactive)
  (let* ((key (completing-read "Set timer for: " egg-timer-intervals))
         (val (alist-get key egg-timer-intervals nil nil #'string=)))
    (if val
        (egg-timer-do-schedule val key)
      (egg-timer-do-schedule key))))

(provide 'egg-timer)
;;; egg-timer.el ends here
