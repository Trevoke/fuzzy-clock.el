;;; fuzzy-clock.el --- Display time in a human-friendly, approximate way -*- lexical-binding: t; -*-
;; SPDX-License-Identifier: GPL-3.0-or-later

;; Copyright (C) 2025

;; Author: Fuzzy Clock Contributors
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: calendar, time
;; URL: https://github.com/trevoke/fuzzy-clock.el

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
;;
;; Time Perspectives:
;;   Choose how you conceptualize time with `fuzzy-clock-perspective':
;;   - default: Traditional fuzziness levels (respects `fuzzy-clock-fuzziness`)
;;   - solar: Natural light cycles (dawn, morning, midday, dusk, etc.)
;;   - meal-centric: Organized around meal times
;;   - work-life: Based on work schedule (weekday vs weekend aware)
;;   - british-tea: Everything relative to tea time (4:00 PM)
;;   - energy: Human circadian rhythms and energy patterns
;;   - monastic: Traditional Christian liturgical hours
;;
;; Configuration Options:
;;   - fuzzy-clock-perspective: Choose your time perspective (default: 'default)
;;   - fuzzy-clock-fuzziness: Granularity for 'default perspective (default: 'hour)
;;   - fuzzy-clock-hemisphere: Northern or southern hemisphere (default: northern)
;;   - fuzzy-clock-season-word-preference: "Fall" or "Autumn" (default: fall)
;;   - fuzzy-clock-update-interval: Update frequency in seconds (default: 60)
;;   - fuzzy-clock-tea-time: Hour for tea time (default: 16)
;;   - fuzzy-clock-work-start: Work start hour (default: 9)
;;   - fuzzy-clock-work-end: Work end hour (default: 17)
;;   - fuzzy-clock-meal-times: Meal hours alist (default: breakfast 7, lunch 12, dinner 19)
;;
;; Creating Custom Perspectives:
;;   Define your own perspective function and register it:
;;
;;   (defun my-perspective (fuzziness hour minute &optional day month year dow dst utcoff)
;;     "My personal time philosophy."
;;     (cond
;;      ((and (>= hour 7) (< hour 9)) "Coffee time!")
;;      ((and (>= hour 9) (< hour 17)) "Creating and building")
;;      ((and (>= hour 17) (< hour 22)) "Living and connecting")
;;      (t "Resting and dreaming")))
;;
;;   (add-to-list 'fuzzy-clock-time-perspectives
;;                '(my-custom . my-perspective))
;;   (setq fuzzy-clock-perspective 'my-custom)
;;
;; See DESIGN-time-perspectives.md for full documentation.

;;; Code:

(defgroup fuzzy-clock nil
  "Display time in a human-friendly, approximate way."
  :group 'calendar
  :prefix "fuzzy-clock-")

;;; Configuration for display preferences

(defcustom fuzzy-clock-hemisphere 'northern
  "Hemisphere to use for season calculations.
In the southern hemisphere, seasons are opposite to the northern hemisphere:
  - Northern Winter (Dec-Feb) = Southern Summer
  - Northern Spring (Mar-May) = Southern Autumn/Fall
  - Northern Summer (Jun-Aug) = Southern Winter
  - Northern Fall (Sep-Nov) = Southern Spring"
  :type '(choice (const :tag "Northern Hemisphere" northern)
                 (const :tag "Southern Hemisphere" southern))
  :group 'fuzzy-clock)

(defcustom fuzzy-clock-season-word-preference 'fall
  "Preferred word for the autumn season.
Choose between 'fall' (American English) and 'autumn' (British English)."
  :type '(choice (const :tag "Fall (American)" fall)
                 (const :tag "Autumn (British)" autumn))
  :group 'fuzzy-clock)

;;; Time Perspectives System
;;
;; Time is a human-made, earth-bound construct that different cultures,
;; contexts, and individuals conceptualize differently. This system
;; allows users to choose from various "time perspectives" - coherent
;; ways of thinking about and describing time.
;;
;; Each perspective is a function that maps clock time to human-meaningful
;; descriptions reflecting cultural, practical, or philosophical approaches.
;;
;; See DESIGN-time-perspectives.md for full documentation.

(defvar fuzzy-clock-time-perspectives nil
  "Registry of available time perspective functions.
Each entry is (SYMBOL . FUNCTION) where FUNCTION takes time
parameters and returns a human-readable description.

Users can add custom perspectives:
  (add-to-list 'fuzzy-clock-time-perspectives
               '(my-perspective . my-perspective-function))")

(defcustom fuzzy-clock-perspective 'default
  "The time perspective to use for fuzzy time display.

A time perspective is a way of conceptualizing and describing time
that reflects cultural, practical, or philosophical approaches.

Available perspectives:
  - default: Traditional fuzziness-based display (respects fuzzy-clock-fuzziness)
  - solar: Based on sun position (dawn, morning, midday, dusk, etc.)
  - meal-centric: Organized around meal times
  - work-life: Based on typical work schedule and life structure
  - british-tea: Everything relative to tea time (traditionally 4 PM)
  - energy: Based on human circadian rhythms and energy levels
  - monastic: Traditional Christian liturgical hours

Users can define and register custom perspectives."
  :type '(choice (const :tag "Default (fuzziness-based)" default)
                 (const :tag "Solar/Natural cycles" solar)
                 (const :tag "Meal-centric" meal-centric)
                 (const :tag "Work/Life balance" work-life)
                 (const :tag "British tea time" british-tea)
                 (const :tag "Energy-based" energy)
                 (const :tag "Monastic hours" monastic))
  :group 'fuzzy-clock)

;; Perspective-specific configuration variables

(defcustom fuzzy-clock-tea-time 16
  "Hour for tea time in British tea time perspective (0-23).
Default is 16 (4:00 PM)."
  :type 'integer
  :group 'fuzzy-clock)

(defcustom fuzzy-clock-work-start 9
  "Hour when work starts for work-life perspective (0-23).
Default is 9 (9:00 AM)."
  :type 'integer
  :group 'fuzzy-clock)

(defcustom fuzzy-clock-work-end 17
  "Hour when work ends for work-life perspective (0-23).
Default is 17 (5:00 PM)."
  :type 'integer
  :group 'fuzzy-clock)

(defcustom fuzzy-clock-meal-times '((breakfast . 7)
                                     (lunch . 12)
                                     (dinner . 19))
  "Meal times for meal-centric perspective.
Alist of (MEAL . HOUR) where HOUR is 0-23."
  :type '(alist :key-type symbol :value-type integer)
  :group 'fuzzy-clock)

(defun fuzzy-clock--hour-to-word (hour)
  "Convert HOUR (0-23) to word form (e.g., 3 -> `Three')."
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

(defun fuzzy-clock-perspective-default (fuzziness hour minute &optional day month year dow _dst _utcoff)
  "Default time perspective using traditional fuzziness-based display.
FUZZINESS determines granularity level.
HOUR is the hour (0-23) and MINUTE is the minute (0-59).
Optional: DAY (1-31), MONTH (1-12), YEAR, DOW (day-of-week: 0=Sun,
6=Sat), DST, UTCOFF.
FUZZINESS can be: five-minutes, fifteen-minutes, half-hour, hour,
part-of-day, day-of-week, part-of-month, month, part-of-season,
part-of-year, year."
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
Uses `fuzzy-clock-hemisphere' and `fuzzy-clock-season-word-preference'.

Northern Hemisphere:
  Winter: December(12), January(1), February(2)
  Spring: March(3), April(4), May(5)
  Summer: June(6), July(7), August(8)
  Fall/Autumn: September(9), October(10), November(11)

Southern Hemisphere (opposite):
  Summer: December(12), January(1), February(2)
  Fall/Autumn: March(3), April(4), May(5)
  Winter: June(6), July(7), August(8)
  Spring: September(9), October(10), November(11)"
  (let* ((northern-season
          (cond
           ((or (= month 12) (= month 1) (= month 2)) 'winter)
           ((and (>= month 3) (<= month 5)) 'spring)
           ((and (>= month 6) (<= month 8)) 'summer)
           ((and (>= month 9) (<= month 11)) 'fall)))
         ;; Convert to southern hemisphere if needed (opposite seasons)
         (season (if (eq fuzzy-clock-hemisphere 'southern)
                     (cond
                      ((eq northern-season 'winter) 'summer)
                      ((eq northern-season 'spring) 'fall)
                      ((eq northern-season 'summer) 'winter)
                      ((eq northern-season 'fall) 'spring))
                   northern-season))
         ;; Apply word preference for fall/autumn
         (season-word (cond
                       ((eq season 'winter) "Winter")
                       ((eq season 'spring) "Spring")
                       ((eq season 'summer) "Summer")
                       ((eq season 'fall)
                        (if (eq fuzzy-clock-season-word-preference 'autumn)
                            "Autumn"
                          "Fall")))))
    season-word))

;;; Time Perspective Implementations

(defun fuzzy-clock-perspective-solar (_fuzziness hour _minute &optional _day _month _year _dow _dst _utcoff)
  "Solar/natural cycles perspective based on sun position.
Describes time relative to natural light cycles."
  (cond
   ((and (>= hour 5) (< hour 6)) "Dawn")
   ((and (>= hour 6) (< hour 7)) "Sunrise")
   ((and (>= hour 7) (< hour 9)) "Early morning")
   ((and (>= hour 9) (< hour 11)) "Late morning")
   ((and (>= hour 11) (< hour 13)) "Midday")
   ((= hour 12) "High noon")
   ((and (>= hour 13) (< hour 16)) "Afternoon")
   ((and (>= hour 16) (< hour 18)) "Late afternoon")
   ((and (>= hour 18) (< hour 19)) "Dusk")
   ((= hour 19) "Twilight")
   ((and (>= hour 19) (< hour 22)) "Evening")
   ((and (>= hour 22) (< hour 24)) "Night")
   ((and (>= hour 0) (< hour 3)) "Deep night")
   ((and (>= hour 3) (< hour 5)) "Before dawn")
   (t "Night")))

(defun fuzzy-clock-perspective-meal-centric (_fuzziness hour _minute &optional _day _month _year _dow _dst _utcoff)
  "Meal-centric perspective organized around eating times.
Uses `fuzzy-clock-meal-times' for customization."
  (let ((breakfast-hour (alist-get 'breakfast fuzzy-clock-meal-times 7))
        (lunch-hour (alist-get 'lunch fuzzy-clock-meal-times 12))
        (dinner-hour (alist-get 'dinner fuzzy-clock-meal-times 19)))
    (cond
     ((and (>= hour (- breakfast-hour 1)) (< hour breakfast-hour))
      "Time for breakfast soon")
     ((and (>= hour breakfast-hour) (< hour (1+ breakfast-hour)))
      "Breakfast time")
     ((and (>= hour (1+ breakfast-hour)) (< hour (- lunch-hour 2)))
      "Mid-morning")
     ((and (>= hour (- lunch-hour 2)) (< hour (- lunch-hour 1)))
      "Almost lunch")
     ((and (>= hour (- lunch-hour 1)) (< hour lunch-hour))
      "Lunch time approaches")
     ((and (>= hour lunch-hour) (< hour (1+ lunch-hour)))
      "Lunch time")
     ((and (>= hour (1+ lunch-hour)) (< hour 15))
      "Post-lunch")
     ((and (>= hour 15) (< hour 16))
      "Afternoon snack time")
     ((and (>= hour 16) (< hour (- dinner-hour 1)))
      "Between meals")
     ((and (>= hour (- dinner-hour 1)) (< hour dinner-hour))
      "Dinner time soon")
     ((and (>= hour dinner-hour) (< hour (+ dinner-hour 2)))
      "Dinner time")
     ((and (>= hour (+ dinner-hour 2)) (< hour 22))
      "After dinner")
     ((and (>= hour 22) (< hour 24))
      "Late night snack time")
     ((and (>= hour 0) (< hour (- breakfast-hour 1)))
      "The wee hours")
     (t "Between meals"))))

(defun fuzzy-clock-perspective-work-life (_fuzziness hour _minute &optional _day _month _year dow _dst _utcoff)
  "Work/life balance perspective based on typical work schedule.
Uses `fuzzy-clock-work-start' and `fuzzy-clock-work-end'.
Distinguishes between weekdays and weekends using DOW."
  (let ((is-weekend (or (= dow 0) (= dow 6))))  ; 0=Sunday, 6=Saturday
    (if is-weekend
        ;; Weekend time descriptions
        (cond
         ((and (>= hour 7) (< hour 10)) "Lazy weekend morning")
         ((and (>= hour 10) (< hour 12)) "Weekend brunch time")
         ((and (>= hour 12) (< hour 17)) "Weekend afternoon")
         ((and (>= hour 17) (< hour 20)) "Weekend evening")
         ((and (>= hour 20) (< hour 23)) "Weekend night")
         ((or (< hour 7) (>= hour 23)) "Weekend rest time")
         (t "Weekend"))
      ;; Weekday time descriptions
      (cond
       ((and (>= hour 6) (< hour (- fuzzy-clock-work-start 1)))
        "Pre-work routine")
       ((and (>= hour (- fuzzy-clock-work-start 1)) (< hour fuzzy-clock-work-start))
        "Morning commute")
       ((and (>= hour fuzzy-clock-work-start) (< hour 12))
        "Morning work block")
       ((and (>= hour 12) (< hour 13))
        "Lunch break")
       ((and (>= hour 13) (< hour fuzzy-clock-work-end))
        "Afternoon work")
       ((and (>= hour fuzzy-clock-work-end) (< hour (1+ fuzzy-clock-work-end)))
        "Wrapping up")
       ((and (>= hour (1+ fuzzy-clock-work-end)) (< hour (+ fuzzy-clock-work-end 2)))
        "Evening commute")
       ((and (>= hour (+ fuzzy-clock-work-end 2)) (< hour 22))
        "Personal time")
       ((or (>= hour 22) (< hour 6))
        "Rest time")
       (t "Work day")))))

(defun fuzzy-clock-perspective-british-tea (_fuzziness hour minute &optional _day _month _year _dow _dst _utcoff)
  "British tea time perspective - everything relative to tea time.
Uses `fuzzy-clock-tea-time' (default 16:00 / 4 PM)."
  (let* ((tea-hour fuzzy-clock-tea-time)
         (current-decimal (+ hour (/ minute 60.0)))
         (tea-decimal (float tea-hour))
         (hours-diff (- current-decimal tea-decimal)))
    (cond
     ((< hours-diff -4) "Long before tea")
     ((< hours-diff -3) "Well before tea")
     ((< hours-diff -2) (format "%d hours until tea" (ceiling (abs hours-diff))))
     ((< hours-diff -1) (format "%d hour until tea" (ceiling (abs hours-diff))))
     ((< hours-diff -0.5) "Less than an hour to tea!")
     ((< hours-diff -0.25) "Almost tea time")
     ((< hours-diff -0.08) "Tea time approaches!")
     ((and (>= hours-diff -0.08) (< hours-diff 0.08)) "Tea time!")
     ((< hours-diff 0.5) "Just after tea")
     ((< hours-diff 1) "Shortly after tea")
     ((< hours-diff 2) (format "%d hour past tea" (floor hours-diff)))
     ((< hours-diff 3) (format "%d hours past tea" (floor hours-diff)))
     (t "Well past tea"))))

(defun fuzzy-clock-perspective-energy (_fuzziness hour _minute &optional _day _month _year _dow _dst _utcoff)
  "Energy-based perspective following human circadian rhythms.
Describes time based on typical energy patterns throughout the day."
  (cond
   ((and (>= hour 6) (< hour 9)) "Morning energy surge")
   ((and (>= hour 9) (< hour 11)) "Peak productivity window")
   ((and (>= hour 11) (< hour 12)) "Pre-lunch dip")
   ((and (>= hour 12) (< hour 14)) "Post-lunch slump")
   ((and (>= hour 14) (< hour 16)) "Afternoon recovery")
   ((and (>= hour 16) (< hour 18)) "Second wind")
   ((and (>= hour 18) (< hour 21)) "Wind down time")
   ((and (>= hour 21) (< hour 22)) "Prepare for rest")
   ((and (>= hour 22) (< hour 24)) "Deep rest begins")
   ((and (>= hour 0) (< hour 3)) "Deep sleep cycle")
   ((and (>= hour 3) (< hour 6)) "Final sleep phase")
   (t "Rest time")))

(defun fuzzy-clock-perspective-monastic (_fuzziness hour _minute &optional _day _month _year _dow _dst _utcoff)
  "Monastic hours perspective based on Christian liturgical hours.
Traditional times of prayer and contemplation."
  (cond
   ((and (>= hour 3) (< hour 4)) "Matins (Night vigils)")
   ((and (>= hour 4) (< hour 6)) "Between matins and lauds")
   ((and (>= hour 6) (< hour 7)) "Lauds (Dawn prayer)")
   ((and (>= hour 7) (< hour 9)) "Prime (First hour)")
   ((and (>= hour 9) (< hour 10)) "Terce (Third hour)")
   ((and (>= hour 10) (< hour 12)) "Between terce and sext")
   ((and (>= hour 12) (< hour 13)) "Sext (Sixth hour)")
   ((and (>= hour 13) (< hour 15)) "Between sext and none")
   ((and (>= hour 15) (< hour 16)) "None (Ninth hour)")
   ((and (>= hour 16) (< hour 18)) "Between none and vespers")
   ((and (>= hour 18) (< hour 19)) "Vespers (Evening prayer)")
   ((and (>= hour 19) (< hour 21)) "Between vespers and compline")
   ((and (>= hour 21) (< hour 22)) "Compline (Night prayer)")
   ((or (>= hour 22) (< hour 3)) "Great Silence")
   (t "Prayer time")))

;;; Perspective dispatch system

(defun fuzzy-clock-format-time (fuzziness hour minute &optional day month year dow dst utcoff)
  "Format time according to selected time perspective.
Dispatches to perspective function based on `fuzzy-clock-perspective'.

For backward compatibility, when using 'default perspective,
FUZZINESS is respected. Other perspectives may ignore FUZZINESS.

HOUR is the hour (0-23) and MINUTE is the minute (0-59).
Optional: DAY (1-31), MONTH (1-12), YEAR, DOW (day-of-week: 0=Sun,
6=Sat), DST, UTCOFF."
  (let* ((perspective fuzzy-clock-perspective)
         (perspective-fn
          (cond
           ((eq perspective 'default)
            'fuzzy-clock-perspective-default)
           ((eq perspective 'solar)
            'fuzzy-clock-perspective-solar)
           ((eq perspective 'meal-centric)
            'fuzzy-clock-perspective-meal-centric)
           ((eq perspective 'work-life)
            'fuzzy-clock-perspective-work-life)
           ((eq perspective 'british-tea)
            'fuzzy-clock-perspective-british-tea)
           ((eq perspective 'energy)
            'fuzzy-clock-perspective-energy)
           ((eq perspective 'monastic)
            'fuzzy-clock-perspective-monastic)
           ;; Check custom perspectives in registry
           ((assq perspective fuzzy-clock-time-perspectives)
            (cdr (assq perspective fuzzy-clock-time-perspectives)))
           ;; Fallback to default
           (t 'fuzzy-clock-perspective-default))))
    (funcall perspective-fn fuzziness hour minute day month year dow dst utcoff)))

;;; Mode-line integration

(defcustom fuzzy-clock-fuzziness 'hour
  "The level of fuzziness for the clock display.
Valid values are:
  `five-minutes'    - Every 5 minutes
  `fifteen-minutes' - Every 15 minutes
  `half-hour'       - Half hour
  `hour'            - Hour (default)
  `part-of-day'     - Part of day
  `day-of-week'     - Day of the week
  `part-of-month'   - Part of month (early/middle/late)
  `month'           - Month name
  `part-of-season'  - Part of season (early/middle/late)
  `part-of-year'    - Part of year (early/middle/late)
  `year'            - Year"
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
         (_second (nth 0 time))
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

;;;###autoload
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
               (_second (nth 0 time))
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
         (_second (nth 0 time))
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
