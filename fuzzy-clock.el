;;; fuzzy-clock.el --- Display time in a human-friendly, approximate way -*- lexical-binding: t; -*-

;; Copyright (C) 2025

;; Author: Fuzzy Clock Contributors
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.4"))
;; Keywords: calendar, time
;; URL: https://github.com/example/fuzzy-clock

;;; Commentary:

;; This package provides a configurable "fuzzy clock" for Emacs that displays
;; time in a human-friendly, approximate way, similar to the KDE fuzzy clock widget.
;;
;; The clock supports adjustable fuzziness levels from precise to very fuzzy:
;; 1. Every 5 minutes - "Quarter past three", "Twenty to four"
;; 2. Every 15 minutes - "Quarter past three", "Half past three", "Quarter to four"
;; 3. Half hour - "Half past three", "Four o'clock"
;; 4. Hour - "Three o'clock", "Four o'clock"
;; 5. Part of day - "Morning", "Afternoon", "Evening", "Night"
;; 6. Day of week - "Monday", "Tuesday", "Wednesday"
;; 7. Part of month - "Early October", "Middle October", "Late October"
;; 8. Month - "January", "October", "December"
;; 9. Part of season - "Early Fall", "Middle Fall", "Late Fall"
;; 10. Part of year - "Early 2025", "Middle 2025", "Late 2025"
;; 11. Year - "2025", "2026"
;;
;; Usage:
;;
;; Mode-line display (recommended):
;;   M-x fuzzy-clock-mode RET
;;   Enables a global minor mode that displays fuzzy time in the mode-line.
;;   The display updates automatically every minute (configurable).
;;
;; Dedicated buffer display:
;;   M-x fuzzy-clock-display-buffer RET
;;   Opens a dedicated buffer showing the current fuzzy time.
;;
;; Minibuffer display:
;;   M-x fuzzy-clock-show RET
;;   Shows the current fuzzy time in the minibuffer (one-time display).
;;
;; Customization:
;;   M-x customize-group RET fuzzy-clock RET
;;   - fuzzy-clock-fuzziness: Set the fuzziness level (default: 'hour)
;;   - fuzzy-clock-update-interval: Set update interval in seconds (default: 60)

;;; Code:

(defgroup fuzzy-clock nil
  "Display time in a human-friendly, approximate way."
  :group 'calendar
  :prefix "fuzzy-clock-")

(defun fuzzy-clock--hour-to-word (hour)
  "Convert HOUR (0-23) to word form (e.g., 3 -> 'Three')."
  (let ((hour-12 (if (zerop hour) 12
                   (if (<= hour 12) hour (- hour 12)))))
    (cond
     ((= hour-12 1) "One")
     ((= hour-12 2) "Two")
     ((= hour-12 3) "Three")
     ((= hour-12 4) "Four")
     ((= hour-12 5) "Five")
     ((= hour-12 6) "Six")
     ((= hour-12 7) "Seven")
     ((= hour-12 8) "Eight")
     ((= hour-12 9) "Nine")
     ((= hour-12 10) "Ten")
     ((= hour-12 11) "Eleven")
     ((= hour-12 12) "Twelve"))))

(defun fuzzy-clock-format-time (fuzziness hour minute &optional day month year dow dst utcoff)
  "Format time as fuzzy string based on FUZZINESS level.
HOUR is the hour (0-23) and MINUTE is the minute (0-59).
Optional: DAY (1-31), MONTH (1-12), YEAR, DOW (day-of-week: 0=Sun, 6=Sat), DST, UTCOFF.
FUZZINESS can be: five-minutes, fifteen-minutes, half-hour, hour, part-of-day,
day-of-week, part-of-month, month, part-of-season, part-of-year, year."
  (cond
   ;; Level 6: Day of week fuzziness
   ((eq fuzziness 'day-of-week)
    (cond
     ((= dow 0) "Sunday")
     ((= dow 1) "Monday")
     ((= dow 2) "Tuesday")
     ((= dow 3) "Wednesday")
     ((= dow 4) "Thursday")
     ((= dow 5) "Friday")
     ((= dow 6) "Saturday")))

   ;; Level 7: Part of month fuzziness
   ((eq fuzziness 'part-of-month)
    ;; Days 1-10: Early, 11-20: Middle, 21-end: Late
    (let* ((time-value (encode-time 0 minute hour day month year))
           (month-name (format-time-string "%B" time-value))
           (part (cond
                  ((<= day 10) "Early")
                  ((<= day 20) "Middle")
                  (t "Late"))))
      (format "%s %s" part month-name)))

   ;; Level 8: Month fuzziness
   ((eq fuzziness 'month)
    ;; Use format-time-string with %B for full month name
    (let* ((time-value (encode-time 0 minute hour day month year)))
      (format-time-string "%B" time-value)))

   ;; Level 9: Part of season fuzziness
   ((eq fuzziness 'part-of-season)
    ;; First month of season = Early, Second month = Middle, Third month = Late
    (let* ((season-part (cond
                         ;; Winter: Dec=Early, Jan=Middle, Feb=Late
                         ((= month 12) "Early")
                         ((= month 1) "Middle")
                         ((= month 2) "Late")
                         ;; Spring: Mar=Early, Apr=Middle, May=Late
                         ((= month 3) "Early")
                         ((= month 4) "Middle")
                         ((= month 5) "Late")
                         ;; Summer: Jun=Early, Jul=Middle, Aug=Late
                         ((= month 6) "Early")
                         ((= month 7) "Middle")
                         ((= month 8) "Late")
                         ;; Fall: Sep=Early, Oct=Middle, Nov=Late
                         ((= month 9) "Early")
                         ((= month 10) "Middle")
                         ((= month 11) "Late")))
           (season (fuzzy-clock-format-season month)))
      (format "%s %s" season-part season)))

   ;; Level 10: Part of year fuzziness
   ((eq fuzziness 'part-of-year)
    ;; Months 1-4 = Early, 5-8 = Middle, 9-12 = Late
    (let ((part (cond
                 ((<= month 4) "Early")
                 ((<= month 8) "Middle")
                 (t "Late"))))
      (format "%s %d" part year)))

   ;; Level 11: Year fuzziness
   ((eq fuzziness 'year)
    (format "%d" year))

   ;; Original levels below
   ;; Level 1: Five minutes fuzziness
   ((eq fuzziness 'five-minutes)
    ;; Round to nearest 5 minutes with boundaries at ±2 minutes
    ;; 0-2 -> 0, 3-7 -> 5, 8-12 -> 10, 13-17 -> 15, 18-22 -> 20, 23-27 -> 25,
    ;; 28-32 -> 30, 33-37 -> 35, 38-42 -> 40, 43-47 -> 45, 48-52 -> 50, 53-57 -> 55, 58-59 -> 60
    (let* ((rounded-minute (cond
                            ((<= minute 2) 0)
                            ((<= minute 7) 5)
                            ((<= minute 12) 10)
                            ((<= minute 17) 15)
                            ((<= minute 22) 20)
                            ((<= minute 27) 25)
                            ((<= minute 32) 30)
                            ((<= minute 37) 35)
                            ((<= minute 42) 40)
                            ((<= minute 47) 45)
                            ((<= minute 52) 50)
                            ((<= minute 57) 55)
                            (t 60)))
           (adjusted-hour hour)
           (adjusted-minute rounded-minute))
      ;; Handle rounding to 60 minutes
      (when (>= rounded-minute 60)
        (setq adjusted-hour (if (= hour 23) 0 (1+ hour)))
        (setq adjusted-minute 0))
      (cond
       ;; Special cases for midnight and noon
       ((and (= adjusted-hour 0) (= adjusted-minute 0)) "Midnight")
       ((and (= adjusted-hour 12) (= adjusted-minute 0)) "Noon")
       ;; On the hour
       ((= adjusted-minute 0)
        (format "%s o'clock" (fuzzy-clock--hour-to-word adjusted-hour)))
       ;; Minutes past the hour (5, 10, 15, 20, 25, 30)
       ((<= adjusted-minute 30)
        (cond
         ((= adjusted-minute 5) (format "Five past %s" (downcase (fuzzy-clock--hour-to-word adjusted-hour))))
         ((= adjusted-minute 10) (format "Ten past %s" (downcase (fuzzy-clock--hour-to-word adjusted-hour))))
         ((= adjusted-minute 15) (format "Quarter past %s" (downcase (fuzzy-clock--hour-to-word adjusted-hour))))
         ((= adjusted-minute 20) (format "Twenty past %s" (downcase (fuzzy-clock--hour-to-word adjusted-hour))))
         ((= adjusted-minute 25) (format "Twenty five past %s" (downcase (fuzzy-clock--hour-to-word adjusted-hour))))
         ((= adjusted-minute 30) (format "Half past %s" (downcase (fuzzy-clock--hour-to-word adjusted-hour))))))
       ;; Minutes to the next hour (35, 40, 45, 50, 55)
       (t
        (let ((next-hour (if (= adjusted-hour 23) 0 (1+ adjusted-hour))))
          (cond
           ((= adjusted-minute 35) (format "Twenty five to %s" (downcase (fuzzy-clock--hour-to-word next-hour))))
           ((= adjusted-minute 40) (format "Twenty to %s" (downcase (fuzzy-clock--hour-to-word next-hour))))
           ((= adjusted-minute 45) (format "Quarter to %s" (downcase (fuzzy-clock--hour-to-word next-hour))))
           ((= adjusted-minute 50) (format "Ten to %s" (downcase (fuzzy-clock--hour-to-word next-hour))))
           ((= adjusted-minute 55) (format "Five to %s" (downcase (fuzzy-clock--hour-to-word next-hour))))))))))

   ;; Level 2: Fifteen minutes fuzziness
   ((eq fuzziness 'fifteen-minutes)
    ;; Round to nearest 15 minutes with boundaries at 7/22/37/52
    ;; 0-6 -> 0, 7-22 -> 15, 23-37 -> 30, 38-52 -> 45, 53-59 -> next hour
    (let* ((rounded-minute (cond
                            ((<= minute 6) 0)
                            ((<= minute 22) 15)
                            ((<= minute 37) 30)
                            ((<= minute 52) 45)
                            (t 60)))
           (adjusted-hour hour)
           (adjusted-minute rounded-minute))
      ;; Handle rounding to 60 minutes
      (when (>= rounded-minute 60)
        (setq adjusted-hour (if (= hour 23) 0 (1+ hour)))
        (setq adjusted-minute 0))
      (cond
       ;; Special cases for midnight and noon
       ((and (= adjusted-hour 0) (= adjusted-minute 0)) "Midnight")
       ((and (= adjusted-hour 12) (= adjusted-minute 0)) "Noon")
       ;; On the hour
       ((= adjusted-minute 0)
        (format "%s o'clock" (fuzzy-clock--hour-to-word adjusted-hour)))
       ;; Quarter past
       ((= adjusted-minute 15)
        (format "Quarter past %s" (downcase (fuzzy-clock--hour-to-word adjusted-hour))))
       ;; Half past
       ((= adjusted-minute 30)
        (format "Half past %s" (downcase (fuzzy-clock--hour-to-word adjusted-hour))))
       ;; Quarter to next hour
       ((= adjusted-minute 45)
        (let ((next-hour (if (= adjusted-hour 23) 0 (1+ adjusted-hour))))
          (format "Quarter to %s" (downcase (fuzzy-clock--hour-to-word next-hour))))))))

   ;; Level 3: Half hour fuzziness
   ((eq fuzziness 'half-hour)
    ;; Round to nearest half hour
    ;; 0-14 -> 0, 15-44 -> 30, 45-59 -> next hour
    (let* ((rounded-minute (cond
                            ((<= minute 14) 0)
                            ((<= minute 44) 30)
                            (t 60)))
           (adjusted-hour hour)
           (adjusted-minute rounded-minute))
      ;; Handle rounding to 60 minutes
      (when (>= rounded-minute 60)
        (setq adjusted-hour (if (= hour 23) 0 (1+ hour)))
        (setq adjusted-minute 0))
      (cond
       ;; Special cases for midnight and noon
       ((and (= adjusted-hour 0) (= adjusted-minute 0)) "Midnight")
       ((and (= adjusted-hour 12) (= adjusted-minute 0)) "Noon")
       ;; On the hour
       ((= adjusted-minute 0)
        (format "%s o'clock" (fuzzy-clock--hour-to-word adjusted-hour)))
       ;; Half past
       ((= adjusted-minute 30)
        (format "Half past %s" (downcase (fuzzy-clock--hour-to-word adjusted-hour)))))))

   ;; Level 4: Hour fuzziness
   ((eq fuzziness 'hour)
    ;; Round to nearest hour
    ;; 0-29 -> current hour, 30-59 -> next hour
    (let* ((adjusted-hour (if (>= minute 30)
                              (if (= hour 23) 0 (1+ hour))
                            hour)))
      (cond
       ;; Special cases for midnight and noon
       ((= adjusted-hour 0) "Midnight")
       ((= adjusted-hour 12) "Noon")
       ;; On the hour
       (t (format "%s o'clock" (fuzzy-clock--hour-to-word adjusted-hour))))))

   ;; Level 5: Part of day fuzziness
   ((eq fuzziness 'part-of-day)
    (cond
     ((and (>= hour 6) (< hour 12)) "Morning")
     ((and (>= hour 12) (< hour 18)) "Afternoon")
     ((and (>= hour 18) (< hour 22)) "Evening")
     (t "Night")))

   ;; Default fallback
   (t "Three o'clock")))

(defun fuzzy-clock-format-season (month)
  "Format the season based on MONTH (1-12).
Winter: December(12), January(1), February(2)
Spring: March(3), April(4), May(5)
Summer: June(6), July(7), August(8)
Fall: September(9), October(10), November(11)"
  (cond
   ((or (= month 12) (= month 1) (= month 2)) "Winter")
   ((and (>= month 3) (<= month 5)) "Spring")
   ((and (>= month 6) (<= month 8)) "Summer")
   ((and (>= month 9) (<= month 11)) "Fall")))

;;; Mode-line integration

(defcustom fuzzy-clock-fuzziness 'hour
  "The level of fuzziness for the clock display.
Valid values are:
  'five-minutes    - Every 5 minutes
  'fifteen-minutes - Every 15 minutes
  'half-hour       - Half hour
  'hour            - Hour (default)
  'part-of-day     - Part of day
  'day-of-week     - Day of the week
  'part-of-month   - Part of month (early/middle/late)
  'month           - Month name
  'part-of-season  - Part of season (early/middle/late)
  'part-of-year    - Part of year (early/middle/late)
  'year            - Year"
  :type '(choice (const :tag "Every 5 minutes" five-minutes)
                 (const :tag "Every 15 minutes" fifteen-minutes)
                 (const :tag "Half hour" half-hour)
                 (const :tag "Hour" hour)
                 (const :tag "Part of day" part-of-day)
                 (const :tag "Day of week" day-of-week)
                 (const :tag "Part of month" part-of-month)
                 (const :tag "Month" month)
                 (const :tag "Part of season" part-of-season)
                 (const :tag "Part of year" part-of-year)
                 (const :tag "Year" year))
  :group 'fuzzy-clock)

(defcustom fuzzy-clock-update-interval 60
  "The number of seconds between updates of the fuzzy clock.
Default is 60 seconds (1 minute)."
  :type 'integer
  :group 'fuzzy-clock)

(defvar fuzzy-clock-string nil
  "String displayed in the mode-line showing fuzzy time.")

;; Mark as risky so it can be evaluated safely in the mode-line
;; Without this, the mode-line will display "*invalid*" instead of the time
(put 'fuzzy-clock-string 'risky-local-variable t)

(defvar fuzzy-clock-timer nil
  "Timer object for updating the fuzzy clock.")

(defun fuzzy-clock-update ()
  "Update the fuzzy clock string with the current time."
  (let* ((time (decode-time))
         (second (nth 0 time))
         (minute (nth 1 time))
         (hour (nth 2 time))
         (day (nth 3 time))
         (month (nth 4 time))
         (year (nth 5 time))
         (dow (nth 6 time))
         (dst (nth 7 time))
         (utcoff (nth 8 time)))
    (setq fuzzy-clock-string
          (concat " " (fuzzy-clock-format-time fuzzy-clock-fuzziness hour minute day month year dow dst utcoff)))))

(define-minor-mode fuzzy-clock-mode
  "Toggle fuzzy clock display in the mode-line.
When enabled, displays the current time in a human-friendly,
approximate format in the mode-line."
  :global t
  :init-value nil
  (if fuzzy-clock-mode
      ;; Mode is being enabled
      (progn
        (fuzzy-clock-update)
        (unless (member '(:eval fuzzy-clock-string) global-mode-string)
          (add-to-list 'global-mode-string '(:eval fuzzy-clock-string) t))
        (setq fuzzy-clock-timer
              (run-at-time t fuzzy-clock-update-interval #'fuzzy-clock-update)))
    ;; Mode is being disabled
    (when fuzzy-clock-timer
      (cancel-timer fuzzy-clock-timer)
      (setq fuzzy-clock-timer nil))
    (setq global-mode-string
          (delete '(:eval fuzzy-clock-string) global-mode-string))))

;;; Dedicated buffer display

(defun fuzzy-clock-display-buffer ()
  "Display the fuzzy clock in a dedicated buffer."
  (interactive)
  (let ((buffer (get-buffer-create "*Fuzzy Clock*")))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (let* ((time (decode-time))
               (second (nth 0 time))
               (minute (nth 1 time))
               (hour (nth 2 time))
               (day (nth 3 time))
               (month (nth 4 time))
               (year (nth 5 time))
               (dow (nth 6 time))
               (dst (nth 7 time))
               (utcoff (nth 8 time))
               (fuzzy-time (fuzzy-clock-format-time fuzzy-clock-fuzziness hour minute day month year dow dst utcoff)))
          (insert fuzzy-time))))
    (switch-to-buffer buffer)))

;;; Minibuffer display

(defun fuzzy-clock-show ()
  "Display the current fuzzy time in the minibuffer."
  (interactive)
  (let* ((time (decode-time))
         (second (nth 0 time))
         (minute (nth 1 time))
         (hour (nth 2 time))
         (day (nth 3 time))
         (month (nth 4 time))
         (year (nth 5 time))
         (dow (nth 6 time))
         (dst (nth 7 time))
         (utcoff (nth 8 time))
         (fuzzy-time (fuzzy-clock-format-time fuzzy-clock-fuzziness hour minute day month year dow dst utcoff)))
    (message "%s" fuzzy-time)))

(provide 'fuzzy-clock)

;;; fuzzy-clock.el ends here
