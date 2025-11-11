;;; fuzzy-clock-test.el --- Tests for fuzzy-clock -*- lexical-binding: t; -*-

;;; Commentary:
;; Acceptance and unit tests for fuzzy-clock package

;;; Code:

(require 'buttercup)
(require 'fuzzy-clock)

;;; Acceptance Tests
;; These tests define the complete expected behavior of the fuzzy clock

(describe "Fuzzy Clock Acceptance Tests"

  (describe "Level 1: Every 5 minutes fuzziness"
    ;; At this level, time is rounded to the nearest 5-minute interval
    ;; and expressed in natural language

    (it "should say 'Three o'clock' at 3:00"
      (expect (fuzzy-clock-format-time 'five-minutes 3 0)
              :to-equal "Three o'clock"))

    (it "should say 'Five past three' at 3:05"
      (expect (fuzzy-clock-format-time 'five-minutes 3 5)
              :to-equal "Five past three"))

    (it "should say 'Ten past three' at 3:10"
      (expect (fuzzy-clock-format-time 'five-minutes 3 10)
              :to-equal "Ten past three"))

    (it "should say 'Quarter past three' at 3:15"
      (expect (fuzzy-clock-format-time 'five-minutes 3 15)
              :to-equal "Quarter past three"))

    (it "should say 'Twenty past three' at 3:20"
      (expect (fuzzy-clock-format-time 'five-minutes 3 20)
              :to-equal "Twenty past three"))

    (it "should say 'Twenty five past three' at 3:25"
      (expect (fuzzy-clock-format-time 'five-minutes 3 25)
              :to-equal "Twenty five past three"))

    (it "should say 'Half past three' at 3:30"
      (expect (fuzzy-clock-format-time 'five-minutes 3 30)
              :to-equal "Half past three"))

    (it "should say 'Twenty five to four' at 3:35"
      (expect (fuzzy-clock-format-time 'five-minutes 3 35)
              :to-equal "Twenty five to four"))

    (it "should say 'Twenty to four' at 3:40"
      (expect (fuzzy-clock-format-time 'five-minutes 3 40)
              :to-equal "Twenty to four"))

    (it "should say 'Quarter to four' at 3:45"
      (expect (fuzzy-clock-format-time 'five-minutes 3 45)
              :to-equal "Quarter to four"))

    (it "should say 'Ten to four' at 3:50"
      (expect (fuzzy-clock-format-time 'five-minutes 3 50)
              :to-equal "Ten to four"))

    (it "should say 'Five to four' at 3:55"
      (expect (fuzzy-clock-format-time 'five-minutes 3 55)
              :to-equal "Five to four"))

    (it "should handle midnight correctly"
      (expect (fuzzy-clock-format-time 'five-minutes 0 0)
              :to-equal "Midnight"))

    (it "should handle noon correctly"
      (expect (fuzzy-clock-format-time 'five-minutes 12 0)
              :to-equal "Noon"))

    ;; Rounding tests for non-exact 5-minute intervals
    (it "should round 3:03 to 'Five past three'"
      (expect (fuzzy-clock-format-time 'five-minutes 3 3)
              :to-equal "Five past three"))

    (it "should round 3:07 to 'Five past three'"
      (expect (fuzzy-clock-format-time 'five-minutes 3 7)
              :to-equal "Five past three"))

    (it "should round 3:13 to 'Quarter past three'"
      (expect (fuzzy-clock-format-time 'five-minutes 3 13)
              :to-equal "Quarter past three"))

    (it "should round 3:23 to 'Twenty five past three'"
      (expect (fuzzy-clock-format-time 'five-minutes 3 23)
              :to-equal "Twenty five past three"))

    (it "should round 3:38 to 'Twenty to four'"
      (expect (fuzzy-clock-format-time 'five-minutes 3 38)
              :to-equal "Twenty to four"))

    (it "should round 3:47 to 'Quarter to four'"
      (expect (fuzzy-clock-format-time 'five-minutes 3 47)
              :to-equal "Quarter to four"))

    (it "should round 3:52 to 'Ten to four'"
      (expect (fuzzy-clock-format-time 'five-minutes 3 52)
              :to-equal "Ten to four"))

    (it "should round 3:58 to 'Four o'clock'"
      (expect (fuzzy-clock-format-time 'five-minutes 3 58)
              :to-equal "Four o'clock")))

  (describe "Level 2: Every 15 minutes fuzziness"
    ;; At this level, time is rounded to the nearest 15-minute interval

    (it "should say 'Three o'clock' at 3:00"
      (expect (fuzzy-clock-format-time 'fifteen-minutes 3 0)
              :to-equal "Three o'clock"))

    (it "should say 'Quarter past three' at 3:15"
      (expect (fuzzy-clock-format-time 'fifteen-minutes 3 15)
              :to-equal "Quarter past three"))

    (it "should say 'Half past three' at 3:30"
      (expect (fuzzy-clock-format-time 'fifteen-minutes 3 30)
              :to-equal "Half past three"))

    (it "should say 'Quarter to four' at 3:45"
      (expect (fuzzy-clock-format-time 'fifteen-minutes 3 45)
              :to-equal "Quarter to four"))

    (it "should round 3:07 to 'Quarter past three'"
      (expect (fuzzy-clock-format-time 'fifteen-minutes 3 7)
              :to-equal "Quarter past three"))

    (it "should round 3:37 to 'Half past three'"
      (expect (fuzzy-clock-format-time 'fifteen-minutes 3 37)
              :to-equal "Half past three"))

    (it "should handle midnight correctly"
      (expect (fuzzy-clock-format-time 'fifteen-minutes 0 0)
              :to-equal "Midnight"))

    (it "should handle noon correctly"
      (expect (fuzzy-clock-format-time 'fifteen-minutes 12 0)
              :to-equal "Noon")))

  (describe "Level 3: Half hour fuzziness"
    ;; At this level, time is rounded to the nearest half hour

    (it "should say 'Three o'clock' at 3:00"
      (expect (fuzzy-clock-format-time 'half-hour 3 0)
              :to-equal "Three o'clock"))

    (it "should say 'Half past three' at 3:30"
      (expect (fuzzy-clock-format-time 'half-hour 3 30)
              :to-equal "Half past three"))

    (it "should round 3:14 to 'Three o'clock'"
      (expect (fuzzy-clock-format-time 'half-hour 3 14)
              :to-equal "Three o'clock"))

    (it "should round 3:15 to 'Half past three'"
      (expect (fuzzy-clock-format-time 'half-hour 3 15)
              :to-equal "Half past three"))

    (it "should round 3:44 to 'Half past three'"
      (expect (fuzzy-clock-format-time 'half-hour 3 44)
              :to-equal "Half past three"))

    (it "should round 3:45 to 'Four o'clock'"
      (expect (fuzzy-clock-format-time 'half-hour 3 45)
              :to-equal "Four o'clock"))

    (it "should handle midnight correctly"
      (expect (fuzzy-clock-format-time 'half-hour 0 0)
              :to-equal "Midnight"))

    (it "should handle noon correctly"
      (expect (fuzzy-clock-format-time 'half-hour 12 0)
              :to-equal "Noon")))

  (describe "Level 4: Hour fuzziness"
    ;; At this level, time is rounded to the nearest hour

    (it "should say 'Three o'clock' at 3:00"
      (expect (fuzzy-clock-format-time 'hour 3 0)
              :to-equal "Three o'clock"))

    (it "should say 'Three o'clock' at 3:29"
      (expect (fuzzy-clock-format-time 'hour 3 29)
              :to-equal "Three o'clock"))

    (it "should say 'Four o'clock' at 3:30"
      (expect (fuzzy-clock-format-time 'hour 3 30)
              :to-equal "Four o'clock"))

    (it "should say 'Four o'clock' at 3:45"
      (expect (fuzzy-clock-format-time 'hour 3 45)
              :to-equal "Four o'clock"))

    (it "should handle midnight correctly"
      (expect (fuzzy-clock-format-time 'hour 0 0)
              :to-equal "Midnight"))

    (it "should handle noon correctly"
      (expect (fuzzy-clock-format-time 'hour 12 0)
              :to-equal "Noon"))

    (it "should handle transition to midnight"
      (expect (fuzzy-clock-format-time 'hour 23 45)
              :to-equal "Midnight")))

  (describe "Level 5: Part of day fuzziness"
    ;; At this level, time is expressed as part of the day

    (it "should say 'Night' at 0:00"
      (expect (fuzzy-clock-format-time 'part-of-day 0 0)
              :to-equal "Night"))

    (it "should say 'Night' at 4:00"
      (expect (fuzzy-clock-format-time 'part-of-day 4 0)
              :to-equal "Night"))

    (it "should say 'Morning' at 6:00"
      (expect (fuzzy-clock-format-time 'part-of-day 6 0)
              :to-equal "Morning"))

    (it "should say 'Morning' at 11:00"
      (expect (fuzzy-clock-format-time 'part-of-day 11 0)
              :to-equal "Morning"))

    (it "should say 'Afternoon' at 12:00"
      (expect (fuzzy-clock-format-time 'part-of-day 12 0)
              :to-equal "Afternoon"))

    (it "should say 'Afternoon' at 17:00"
      (expect (fuzzy-clock-format-time 'part-of-day 17 0)
              :to-equal "Afternoon"))

    (it "should say 'Evening' at 18:00"
      (expect (fuzzy-clock-format-time 'part-of-day 18 0)
              :to-equal "Evening"))

    (it "should say 'Evening' at 21:00"
      (expect (fuzzy-clock-format-time 'part-of-day 21 0)
              :to-equal "Evening"))

    (it "should say 'Night' at 22:00"
      (expect (fuzzy-clock-format-time 'part-of-day 22 0)
              :to-equal "Night"))

    (it "should say 'Night' at 23:59"
      (expect (fuzzy-clock-format-time 'part-of-day 23 59)
              :to-equal "Night")))

  (describe "Level 6: Day of week fuzziness"
    ;; At this level, time is expressed as the day of the week
    ;; Function signature: (fuzziness hour minute &optional day month year dow dst utcoff)
    ;; DOW: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday

    (it "should say 'Sunday' for Sunday"
      ;; hour=12, minute=0, day=27, month=10, year=2024, dow=0 (Sunday)
      (expect (fuzzy-clock-format-time 'day-of-week 12 0 27 10 2024 0 nil -25200)
              :to-equal "Sunday"))

    (it "should say 'Monday' for Monday"
      ;; hour=12, minute=0, day=28, month=10, year=2024, dow=1 (Monday)
      (expect (fuzzy-clock-format-time 'day-of-week 12 0 28 10 2024 1 nil -25200)
              :to-equal "Monday"))

    (it "should say 'Tuesday' for Tuesday"
      (expect (fuzzy-clock-format-time 'day-of-week 12 0 29 10 2024 2 nil -25200)
              :to-equal "Tuesday"))

    (it "should say 'Wednesday' for Wednesday"
      (expect (fuzzy-clock-format-time 'day-of-week 12 0 30 10 2024 3 nil -25200)
              :to-equal "Wednesday"))

    (it "should say 'Thursday' for Thursday"
      (expect (fuzzy-clock-format-time 'day-of-week 12 0 31 10 2024 4 nil -25200)
              :to-equal "Thursday"))

    (it "should say 'Friday' for Friday"
      (expect (fuzzy-clock-format-time 'day-of-week 12 0 1 11 2024 5 nil -25200)
              :to-equal "Friday"))

    (it "should say 'Saturday' for Saturday"
      (expect (fuzzy-clock-format-time 'day-of-week 12 0 2 11 2024 6 nil -25200)
              :to-equal "Saturday")))

  (describe "Level 7: Part of month fuzziness"
    ;; At this level, time is expressed as part of the month
    ;; Early (days 1-10), Middle (days 11-20), Late (days 21-end)

    (it "should say 'Early January' for January 1st"
      (expect (fuzzy-clock-format-time 'part-of-month 12 0 1 1 2024 1 nil -25200)
              :to-equal "Early January"))

    (it "should say 'Early October' for October 5th"
      (expect (fuzzy-clock-format-time 'part-of-month 12 0 5 10 2024 6 nil -25200)
              :to-equal "Early October"))

    (it "should say 'Early December' for December 10th"
      (expect (fuzzy-clock-format-time 'part-of-month 12 0 10 12 2024 2 nil -25200)
              :to-equal "Early December"))

    (it "should say 'Middle February' for February 11th"
      (expect (fuzzy-clock-format-time 'part-of-month 12 0 11 2 2024 0 nil -25200)
              :to-equal "Middle February"))

    (it "should say 'Middle June' for June 15th"
      (expect (fuzzy-clock-format-time 'part-of-month 12 0 15 6 2024 6 nil -25200)
              :to-equal "Middle June"))

    (it "should say 'Middle September' for September 20th"
      (expect (fuzzy-clock-format-time 'part-of-month 12 0 20 9 2024 5 nil -25200)
              :to-equal "Middle September"))

    (it "should say 'Late March' for March 21st"
      (expect (fuzzy-clock-format-time 'part-of-month 12 0 21 3 2024 4 nil -25200)
              :to-equal "Late March"))

    (it "should say 'Late October' for October 25th"
      (expect (fuzzy-clock-format-time 'part-of-month 12 0 25 10 2024 5 nil -25200)
              :to-equal "Late October"))

    (it "should say 'Late December' for December 31st"
      (expect (fuzzy-clock-format-time 'part-of-month 12 0 31 12 2024 2 nil -25200)
              :to-equal "Late December")))

  (describe "Level 8: Month fuzziness"
    ;; At this level, time is expressed as the month name
    ;; Test all 12 months

    (it "should say 'January' for month 1"
      (expect (fuzzy-clock-format-time 'month 12 0 15 1 2024 1 nil -25200)
              :to-equal "January"))

    (it "should say 'February' for month 2"
      (expect (fuzzy-clock-format-time 'month 12 0 15 2 2024 4 nil -25200)
              :to-equal "February"))

    (it "should say 'March' for month 3"
      (expect (fuzzy-clock-format-time 'month 12 0 15 3 2024 5 nil -25200)
              :to-equal "March"))

    (it "should say 'April' for month 4"
      (expect (fuzzy-clock-format-time 'month 12 0 15 4 2024 1 nil -25200)
              :to-equal "April"))

    (it "should say 'May' for month 5"
      (expect (fuzzy-clock-format-time 'month 12 0 15 5 2024 3 nil -25200)
              :to-equal "May"))

    (it "should say 'June' for month 6"
      (expect (fuzzy-clock-format-time 'month 12 0 15 6 2024 6 nil -25200)
              :to-equal "June"))

    (it "should say 'July' for month 7"
      (expect (fuzzy-clock-format-time 'month 12 0 15 7 2024 1 nil -25200)
              :to-equal "July"))

    (it "should say 'August' for month 8"
      (expect (fuzzy-clock-format-time 'month 12 0 15 8 2024 4 nil -25200)
              :to-equal "August"))

    (it "should say 'September' for month 9"
      (expect (fuzzy-clock-format-time 'month 12 0 15 9 2024 0 nil -25200)
              :to-equal "September"))

    (it "should say 'October' for month 10"
      (expect (fuzzy-clock-format-time 'month 12 0 15 10 2024 2 nil -25200)
              :to-equal "October"))

    (it "should say 'November' for month 11"
      (expect (fuzzy-clock-format-time 'month 12 0 15 11 2024 5 nil -25200)
              :to-equal "November"))

    (it "should say 'December' for month 12"
      (expect (fuzzy-clock-format-time 'month 12 0 15 12 2024 0 nil -25200)
              :to-equal "December")))

  (describe "Level 9: Part of season fuzziness"
    ;; At this level, time is expressed as part of the current season
    ;; Seasons are: Winter (12,1,2), Spring (3,4,5), Summer (6,7,8), Fall (9,10,11)
    ;; First month = Early, Second month = Middle, Third month = Late

    (it "should say 'Early Winter' in December"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 12 2024 0 nil -25200)
              :to-equal "Early Winter"))

    (it "should say 'Middle Winter' in January"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 1 2025 3 nil -25200)
              :to-equal "Middle Winter"))

    (it "should say 'Late Winter' in February"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 2 2025 6 nil -25200)
              :to-equal "Late Winter"))

    (it "should say 'Early Spring' in March"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 3 2025 6 nil -25200)
              :to-equal "Early Spring"))

    (it "should say 'Middle Spring' in April"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 4 2025 2 nil -25200)
              :to-equal "Middle Spring"))

    (it "should say 'Late Spring' in May"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 5 2025 4 nil -25200)
              :to-equal "Late Spring"))

    (it "should say 'Early Summer' in June"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 6 2025 0 nil -25200)
              :to-equal "Early Summer"))

    (it "should say 'Middle Summer' in July"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 7 2025 2 nil -25200)
              :to-equal "Middle Summer"))

    (it "should say 'Late Summer' in August"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 8 2025 5 nil -25200)
              :to-equal "Late Summer"))

    (it "should say 'Early Fall' in September"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 9 2025 1 nil -25200)
              :to-equal "Early Fall"))

    (it "should say 'Middle Fall' in October"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 30 10 2025 4 nil -25200)
              :to-equal "Middle Fall"))

    (it "should say 'Late Fall' in November"
      (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 11 2025 6 nil -25200)
              :to-equal "Late Fall")))

  (describe "Level 10: Part of year fuzziness"
    ;; At this level, time is expressed as part of the year
    ;; Months 1-4 = Early, Months 5-8 = Middle, Months 9-12 = Late

    (it "should say 'Early 2024' in January"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 1 2024 1 nil -25200)
              :to-equal "Early 2024"))

    (it "should say 'Early 2025' in February"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 2 2025 6 nil -25200)
              :to-equal "Early 2025"))

    (it "should say 'Early 2024' in March"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 3 2024 5 nil -25200)
              :to-equal "Early 2024"))

    (it "should say 'Early 2025' in April"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 4 2025 2 nil -25200)
              :to-equal "Early 2025"))

    (it "should say 'Middle 2024' in May"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 5 2024 3 nil -25200)
              :to-equal "Middle 2024"))

    (it "should say 'Middle 2025' in June"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 6 2025 0 nil -25200)
              :to-equal "Middle 2025"))

    (it "should say 'Middle 2024' in July"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 7 2024 1 nil -25200)
              :to-equal "Middle 2024"))

    (it "should say 'Middle 2025' in August"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 8 2025 5 nil -25200)
              :to-equal "Middle 2025"))

    (it "should say 'Late 2024' in September"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 9 2024 0 nil -25200)
              :to-equal "Late 2024"))

    (it "should say 'Late 2025' in October"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 10 2025 3 nil -25200)
              :to-equal "Late 2025"))

    (it "should say 'Late 2024' in November"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 11 2024 5 nil -25200)
              :to-equal "Late 2024"))

    (it "should say 'Late 2025' in December"
      (expect (fuzzy-clock-format-time 'part-of-year 12 0 15 12 2025 1 nil -25200)
              :to-equal "Late 2025")))

  (describe "Level 11: Year fuzziness"
    ;; At this level, time is expressed as just the year

    (it "should say '2024' for any date in 2024"
      (expect (fuzzy-clock-format-time 'year 12 0 15 6 2024 6 nil -25200)
              :to-equal "2024"))

    (it "should say '2025' for any date in 2025"
      (expect (fuzzy-clock-format-time 'year 12 0 15 1 2025 3 nil -25200)
              :to-equal "2025"))

    (it "should say '2026' for any date in 2026"
      (expect (fuzzy-clock-format-time 'year 12 0 30 10 2026 4 nil -25200)
              :to-equal "2026")))

  (describe "Season helper function (fuzzy-clock-format-season)"
    ;; Tests for the standalone season formatting function

    (it "should say 'Winter' in December"
      (expect (fuzzy-clock-format-season 12)
              :to-equal "Winter"))

    (it "should say 'Winter' in January"
      (expect (fuzzy-clock-format-season 1)
              :to-equal "Winter"))

    (it "should say 'Winter' in February"
      (expect (fuzzy-clock-format-season 2)
              :to-equal "Winter"))

    (it "should say 'Spring' in March"
      (expect (fuzzy-clock-format-season 3)
              :to-equal "Spring"))

    (it "should say 'Spring' in April"
      (expect (fuzzy-clock-format-season 4)
              :to-equal "Spring"))

    (it "should say 'Spring' in May"
      (expect (fuzzy-clock-format-season 5)
              :to-equal "Spring"))

    (it "should say 'Summer' in June"
      (expect (fuzzy-clock-format-season 6)
              :to-equal "Summer"))

    (it "should say 'Summer' in July"
      (expect (fuzzy-clock-format-season 7)
              :to-equal "Summer"))

    (it "should say 'Summer' in August"
      (expect (fuzzy-clock-format-season 8)
              :to-equal "Summer"))

    (it "should say 'Fall' in September"
      (expect (fuzzy-clock-format-season 9)
              :to-equal "Fall"))

    (it "should say 'Fall' in October"
      (expect (fuzzy-clock-format-season 10)
              :to-equal "Fall"))

    (it "should say 'Fall' in November"
      (expect (fuzzy-clock-format-season 11)
              :to-equal "Fall")))

  (describe "Season configuration: Autumn vs Fall preference"
    ;; Tests for fuzzy-clock-season-word-preference configuration

    (it "should say 'Fall' by default in September"
      (let ((fuzzy-clock-season-word-preference 'fall))
        (expect (fuzzy-clock-format-season 9)
                :to-equal "Fall")))

    (it "should say 'Autumn' when preference is set to 'autumn in September"
      (let ((fuzzy-clock-season-word-preference 'autumn))
        (expect (fuzzy-clock-format-season 9)
                :to-equal "Autumn")))

    (it "should say 'Fall' by default in October"
      (let ((fuzzy-clock-season-word-preference 'fall))
        (expect (fuzzy-clock-format-season 10)
                :to-equal "Fall")))

    (it "should say 'Autumn' when preference is set to 'autumn in October"
      (let ((fuzzy-clock-season-word-preference 'autumn))
        (expect (fuzzy-clock-format-season 10)
                :to-equal "Autumn")))

    (it "should say 'Fall' by default in November"
      (let ((fuzzy-clock-season-word-preference 'fall))
        (expect (fuzzy-clock-format-season 11)
                :to-equal "Fall")))

    (it "should say 'Autumn' when preference is set to 'autumn in November"
      (let ((fuzzy-clock-season-word-preference 'autumn))
        (expect (fuzzy-clock-format-season 11)
                :to-equal "Autumn")))

    (it "should not affect other seasons"
      (let ((fuzzy-clock-season-word-preference 'autumn))
        (expect (fuzzy-clock-format-season 12) :to-equal "Winter")
        (expect (fuzzy-clock-format-season 3) :to-equal "Spring")
        (expect (fuzzy-clock-format-season 6) :to-equal "Summer"))))

  (describe "Hemisphere configuration: Southern vs Northern hemisphere"
    ;; Tests for fuzzy-clock-hemisphere configuration

    (it "should display northern hemisphere seasons by default"
      (let ((fuzzy-clock-hemisphere 'northern))
        (expect (fuzzy-clock-format-season 12) :to-equal "Winter")
        (expect (fuzzy-clock-format-season 3) :to-equal "Spring")
        (expect (fuzzy-clock-format-season 6) :to-equal "Summer")
        (expect (fuzzy-clock-format-season 9) :to-equal "Fall")))

    (it "should display opposite seasons for southern hemisphere - Winter becomes Summer"
      (let ((fuzzy-clock-hemisphere 'southern))
        (expect (fuzzy-clock-format-season 12) :to-equal "Summer")
        (expect (fuzzy-clock-format-season 1) :to-equal "Summer")
        (expect (fuzzy-clock-format-season 2) :to-equal "Summer")))

    (it "should display opposite seasons for southern hemisphere - Spring becomes Fall"
      (let ((fuzzy-clock-hemisphere 'southern)
            (fuzzy-clock-season-word-preference 'fall))
        (expect (fuzzy-clock-format-season 3) :to-equal "Fall")
        (expect (fuzzy-clock-format-season 4) :to-equal "Fall")
        (expect (fuzzy-clock-format-season 5) :to-equal "Fall")))

    (it "should display opposite seasons for southern hemisphere - Summer becomes Winter"
      (let ((fuzzy-clock-hemisphere 'southern))
        (expect (fuzzy-clock-format-season 6) :to-equal "Winter")
        (expect (fuzzy-clock-format-season 7) :to-equal "Winter")
        (expect (fuzzy-clock-format-season 8) :to-equal "Winter")))

    (it "should display opposite seasons for southern hemisphere - Fall becomes Spring"
      (let ((fuzzy-clock-hemisphere 'southern))
        (expect (fuzzy-clock-format-season 9) :to-equal "Spring")
        (expect (fuzzy-clock-format-season 10) :to-equal "Spring")
        (expect (fuzzy-clock-format-season 11) :to-equal "Spring")))

    (it "should combine southern hemisphere with autumn preference"
      (let ((fuzzy-clock-hemisphere 'southern)
            (fuzzy-clock-season-word-preference 'autumn))
        ;; In southern hemisphere, March-May (northern spring) becomes fall/autumn
        (expect (fuzzy-clock-format-season 3) :to-equal "Autumn")
        (expect (fuzzy-clock-format-season 4) :to-equal "Autumn")
        (expect (fuzzy-clock-format-season 5) :to-equal "Autumn"))))

  (describe "Part of season with configuration"
    ;; Tests that part-of-season fuzziness respects the configuration

    (it "should use 'Autumn' preference in part-of-season display"
      (let ((fuzzy-clock-season-word-preference 'autumn))
        (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 9 2025 1 nil -25200)
                :to-equal "Early Autumn")
        (expect (fuzzy-clock-format-time 'part-of-season 12 0 30 10 2025 4 nil -25200)
                :to-equal "Middle Autumn")
        (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 11 2025 6 nil -25200)
                :to-equal "Late Autumn")))

    (it "should use southern hemisphere in part-of-season display"
      (let ((fuzzy-clock-hemisphere 'southern))
        ;; December is summer in southern hemisphere
        (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 12 2024 0 nil -25200)
                :to-equal "Early Summer")
        ;; March is fall in southern hemisphere
        (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 3 2025 6 nil -25200)
                :to-equal "Early Fall")
        ;; June is winter in southern hemisphere
        (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 6 2025 0 nil -25200)
                :to-equal "Early Winter")
        ;; September is spring in southern hemisphere
        (expect (fuzzy-clock-format-time 'part-of-season 12 0 15 9 2025 1 nil -25200)
                :to-equal "Early Spring")))))

(describe "Fuzzy Clock Mode-line Integration"
  ;; Acceptance tests for mode-line integration
  ;; The mode should be a global minor mode that displays fuzzy time

  (describe "fuzzy-clock-mode global minor mode"
    (it "should be defined as a command"
      (expect (fboundp 'fuzzy-clock-mode) :to-be-truthy))

    (it "should have a mode variable that starts as nil"
      (expect (boundp 'fuzzy-clock-mode) :to-be-truthy)
      (expect fuzzy-clock-mode :to-be nil))

    (it "should enable the mode when called"
      (fuzzy-clock-mode 1)
      (expect fuzzy-clock-mode :to-be-truthy))

    (it "should disable the mode when called with -1"
      (fuzzy-clock-mode 1)  ; Enable first
      (fuzzy-clock-mode -1) ; Then disable
      (expect fuzzy-clock-mode :to-be nil)))

  (describe "mode-line display"
    (it "should mark fuzzy-clock-string as risky-local-variable for mode-line display"
      ;; Mode-line variables must be marked as risky to be evaluated safely in the mode-line
      ;; This prevents the "*invalid*" error when the variable is displayed
      (expect (get 'fuzzy-clock-string 'risky-local-variable) :to-be t))

    (it "should add fuzzy time string to global-mode-string when enabled"
      (fuzzy-clock-mode -1) ; Ensure it's disabled first
      (expect (member '(:eval fuzzy-clock-string) global-mode-string) :to-be nil)
      (fuzzy-clock-mode 1)
      (expect (member '(:eval fuzzy-clock-string) global-mode-string) :not :to-be nil))

    (it "should remove fuzzy time string from global-mode-string when disabled"
      (fuzzy-clock-mode 1)  ; Enable first
      (expect (member '(:eval fuzzy-clock-string) global-mode-string) :not :to-be nil)
      (fuzzy-clock-mode -1) ; Disable
      (expect (member '(:eval fuzzy-clock-string) global-mode-string) :to-be nil))

    (it "should populate fuzzy-clock-string with current time when enabled"
      (fuzzy-clock-mode 1)
      (expect fuzzy-clock-string :not :to-be nil)
      (expect (stringp fuzzy-clock-string) :to-be-truthy))

    (it "should format fuzzy-clock-string with leading space for mode-line display"
      (fuzzy-clock-mode 1)
      (expect fuzzy-clock-string :not :to-be nil)
      (expect (string-prefix-p " " fuzzy-clock-string) :to-be-truthy)
      (expect (stringp fuzzy-clock-string) :to-be-truthy))

    (it "should use :eval construct for mode-line display"
      ;; ACCEPTANCE TEST: This verifies we're using the correct mode-line construct.
      ;; Mode-lines require (:eval VARIABLE) not just 'VARIABLE for proper display.
      ;; The bare symbol 'fuzzy-clock-string doesn't evaluate in mode-line context.
      (fuzzy-clock-mode 1)
      ;; Find the fuzzy-clock entry in global-mode-string
      (let ((found-entry (seq-find
                          (lambda (entry)
                            (and (listp entry)
                                 (eq (car entry) :eval)
                                 (eq (cadr entry) 'fuzzy-clock-string)))
                          global-mode-string)))
        (expect found-entry :not :to-be nil)
        (expect (car found-entry) :to-equal :eval)
        (expect (cadr found-entry) :to-equal 'fuzzy-clock-string))))

  (describe "fuzziness configuration"
    (it "should have a customizable fuzziness level variable"
      (expect (boundp 'fuzzy-clock-fuzziness) :to-be-truthy)))

  (describe "auto-update functionality"
    (it "should have a customizable update interval"
      (expect (boundp 'fuzzy-clock-update-interval) :to-be-truthy))

    (it "should create a timer when mode is enabled"
      (fuzzy-clock-mode -1) ; Ensure disabled
      (fuzzy-clock-mode 1)  ; Enable
      (expect (boundp 'fuzzy-clock-timer) :to-be-truthy)
      (expect fuzzy-clock-timer :not :to-be nil))

    (it "should cancel the timer when mode is disabled"
      (fuzzy-clock-mode 1)   ; Enable
      (expect fuzzy-clock-timer :not :to-be nil)
      (fuzzy-clock-mode -1)  ; Disable
      (expect fuzzy-clock-timer :to-be nil))))

(describe "Fuzzy Clock Buffer Display"
  ;; Tests for dedicated buffer display

  (describe "fuzzy-clock-display-buffer command"
    (it "should be defined as a command"
      (expect (fboundp 'fuzzy-clock-display-buffer) :to-be-truthy))

    (it "should create or switch to a buffer named *Fuzzy Clock*"
      (when (get-buffer "*Fuzzy Clock*")
        (kill-buffer "*Fuzzy Clock*"))
      (fuzzy-clock-display-buffer)
      (expect (get-buffer "*Fuzzy Clock*") :not :to-be nil)
      (expect (buffer-name (current-buffer)) :to-equal "*Fuzzy Clock*"))

    (it "should display the current fuzzy time in the buffer"
      (when (get-buffer "*Fuzzy Clock*")
        (kill-buffer "*Fuzzy Clock*"))
      (fuzzy-clock-display-buffer)
      (with-current-buffer "*Fuzzy Clock*"
        (let ((content (buffer-string)))
          (expect (> (length content) 0) :to-be-truthy))))))

(describe "Fuzzy Clock Minibuffer Display"
  ;; Tests for minibuffer display command

  (describe "fuzzy-clock-show command"
    (it "should be defined as a command"
      (expect (fboundp 'fuzzy-clock-show) :to-be-truthy))))

(describe "Time Perspectives System"
  ;; Tests for the new time perspectives system

  (describe "Perspective dispatch"
    (it "should use default perspective when fuzzy-clock-perspective is 'default"
      (let ((fuzzy-clock-perspective 'default))
        (expect (fuzzy-clock-format-time 'hour 15 0)
                :to-equal "Three o'clock")))

    (it "should switch to solar perspective"
      (let ((fuzzy-clock-perspective 'solar))
        (expect (fuzzy-clock-format-time 'hour 6 0) :to-equal "Sunrise")
        (expect (fuzzy-clock-format-time 'hour 12 0) :to-equal "High noon")
        (expect (fuzzy-clock-format-time 'hour 18 0) :to-equal "Dusk")))

    (it "should switch to meal-centric perspective"
      (let ((fuzzy-clock-perspective 'meal-centric)
            (fuzzy-clock-meal-times '((breakfast . 7) (lunch . 12) (dinner . 19))))
        (expect (fuzzy-clock-format-time 'hour 7 0) :to-equal "Breakfast time")
        (expect (fuzzy-clock-format-time 'hour 12 0) :to-equal "Lunch time")
        (expect (fuzzy-clock-format-time 'hour 19 0) :to-equal "Dinner time")))

    (it "should switch to british-tea perspective"
      (let ((fuzzy-clock-perspective 'british-tea)
            (fuzzy-clock-tea-time 16))
        (expect (fuzzy-clock-format-time 'hour 16 0) :to-equal "Tea time!")
        (expect (fuzzy-clock-format-time 'hour 15 0) :to-match "until tea")
        (expect (fuzzy-clock-format-time 'hour 17 0) :to-match "past tea"))))

  (describe "Solar perspective"
    (it "should describe dawn and sunrise"
      (let ((fuzzy-clock-perspective 'solar))
        (expect (fuzzy-clock-format-time 'hour 5 30) :to-equal "Dawn")
        (expect (fuzzy-clock-format-time 'hour 6 30) :to-equal "Sunrise")))

    (it "should describe daytime hours"
      (let ((fuzzy-clock-perspective 'solar))
        (expect (fuzzy-clock-format-time 'hour 8 0) :to-equal "Early morning")
        (expect (fuzzy-clock-format-time 'hour 10 0) :to-equal "Late morning")
        (expect (fuzzy-clock-format-time 'hour 12 0) :to-equal "High noon")
        (expect (fuzzy-clock-format-time 'hour 14 0) :to-equal "Afternoon")))

    (it "should describe evening and night"
      (let ((fuzzy-clock-perspective 'solar))
        (expect (fuzzy-clock-format-time 'hour 18 30) :to-equal "Dusk")
        (expect (fuzzy-clock-format-time 'hour 19 0) :to-equal "Twilight")
        (expect (fuzzy-clock-format-time 'hour 20 0) :to-equal "Evening")
        (expect (fuzzy-clock-format-time 'hour 23 0) :to-equal "Night"))))

  (describe "Work-life perspective"
    (it "should distinguish weekday from weekend"
      (let ((fuzzy-clock-perspective 'work-life)
            (fuzzy-clock-work-start 9)
            (fuzzy-clock-work-end 17))
        ;; Monday (dow=1) - weekday
        (expect (fuzzy-clock-format-time 'hour 10 0 nil nil nil 1) :to-equal "Morning work block")
        ;; Saturday (dow=6) - weekend
        (expect (fuzzy-clock-format-time 'hour 10 0 nil nil nil 6) :to-equal "Weekend brunch time")
        ;; Sunday (dow=0) - weekend
        (expect (fuzzy-clock-format-time 'hour 14 0 nil nil nil 0) :to-equal "Weekend afternoon")))

    (it "should show work-related times on weekdays"
      (let ((fuzzy-clock-perspective 'work-life)
            (fuzzy-clock-work-start 9)
            (fuzzy-clock-work-end 17))
        (expect (fuzzy-clock-format-time 'hour 8 0 nil nil nil 2) :to-equal "Morning commute")
        (expect (fuzzy-clock-format-time 'hour 12 0 nil nil nil 3) :to-equal "Lunch break")
        (expect (fuzzy-clock-format-time 'hour 17 0 nil nil nil 4) :to-equal "Wrapping up"))))

  (describe "Monastic perspective"
    (it "should show traditional prayer hours"
      (let ((fuzzy-clock-perspective 'monastic))
        (expect (fuzzy-clock-format-time 'hour 6 30) :to-equal "Lauds (Dawn prayer)")
        (expect (fuzzy-clock-format-time 'hour 9 30) :to-equal "Terce (Third hour)")
        (expect (fuzzy-clock-format-time 'hour 12 30) :to-equal "Sext (Sixth hour)")
        (expect (fuzzy-clock-format-time 'hour 15 30) :to-equal "None (Ninth hour)")
        (expect (fuzzy-clock-format-time 'hour 18 30) :to-equal "Vespers (Evening prayer)")
        (expect (fuzzy-clock-format-time 'hour 21 30) :to-equal "Compline (Night prayer)"))))

  (describe "Energy perspective"
    (it "should describe energy patterns throughout the day"
      (let ((fuzzy-clock-perspective 'energy))
        (expect (fuzzy-clock-format-time 'hour 7 0) :to-equal "Morning energy surge")
        (expect (fuzzy-clock-format-time 'hour 10 0) :to-equal "Peak productivity window")
        (expect (fuzzy-clock-format-time 'hour 13 0) :to-equal "Post-lunch slump")
        (expect (fuzzy-clock-format-time 'hour 17 0) :to-equal "Second wind")
        (expect (fuzzy-clock-format-time 'hour 20 0) :to-equal "Wind down time"))))

  (describe "Custom perspective extensibility"
    (it "should allow users to register custom perspectives"
      (let ((custom-called nil)
            (fuzzy-clock-time-perspectives
             (cons '(test-custom . (lambda (&rest _) (setq custom-called t) "Custom time"))
                   fuzzy-clock-time-perspectives))
            (fuzzy-clock-perspective 'test-custom))
        (expect (fuzzy-clock-format-time 'hour 12 0) :to-equal "Custom time")
        (expect custom-called :to-be-truthy)))))

(provide 'fuzzy-clock-test)

;;; fuzzy-clock-test.el ends here
