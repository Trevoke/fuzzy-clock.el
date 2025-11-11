# Time Perspectives Design Document

## Vision

Time is a human-made, earth-bound construct that different cultures, contexts, and individuals conceptualize differently. This design creates an extensible system for representing these diverse "time perspectives" - ways humans actually think about and experience time.

## Core Concept: Time Perspectives

A **time perspective** is a coherent way of mapping clock time to human-meaningful descriptions. Each perspective reflects a cultural, practical, or philosophical approach to understanding time.

## Architecture

### 1. Time Perspective Protocol

Each time perspective is a function that:
- **Input**: Time components (hour, minute, day, month, year, day-of-week, etc.)
- **Output**: Human-readable time description string
- **Optional**: Perspective-specific configuration variables

### 2. Registry System

```elisp
;; Registry of available time perspectives
(defvar fuzzy-clock-time-perspectives
  '((default . fuzzy-clock-perspective-default)
    (solar . fuzzy-clock-perspective-solar)
    (meal-centric . fuzzy-clock-perspective-meal-centric)
    (work-life . fuzzy-clock-perspective-work-life)
    (monastic . fuzzy-clock-perspective-monastic)
    (energy-based . fuzzy-clock-perspective-energy)
    (british-tea . fuzzy-clock-perspective-british-tea)
    (proverbs . fuzzy-clock-perspective-proverbs))
  "Registry of available time perspective functions.")
```

### 3. Configuration

```elisp
(defcustom fuzzy-clock-perspective 'default
  "The time perspective to use for fuzzy time display."
  :type '(choice (const :tag "Default (fuzziness-based)" default)
                 (const :tag "Solar/Natural cycles" solar)
                 (const :tag "Meal-centric" meal-centric)
                 (const :tag "Work/Life balance" work-life)
                 (const :tag "Monastic hours" monastic)
                 (const :tag "Energy-based" energy-based)
                 (const :tag "British tea time" british-tea)
                 (const :tag "Folk proverbs" proverbs))
  :group 'fuzzy-clock)
```

## Time Perspectives Catalog

### 1. Default (Current behavior)
Uses the existing fuzziness-based system with configurable granularity levels.

**Configuration**: `fuzzy-clock-fuzziness`, `fuzzy-clock-hemisphere`, `fuzzy-clock-season-word-preference`

### 2. Solar/Natural
Time based on the sun's position and natural cycles.

**Examples**:
- 5:00-6:00 AM: "Dawn", "First light"
- 6:00-9:00 AM: "Early morning"
- 9:00-11:00 AM: "Late morning"
- 11:00-13:00: "Midday", "High noon"
- 13:00-16:00: "Afternoon"
- 16:00-18:00: "Late afternoon"
- 18:00-19:00: "Dusk", "Twilight"
- 19:00-22:00: "Evening"
- 22:00-5:00: "Night", "Deep night", "Before dawn"

**Configuration**: Could include actual sunrise/sunset times for location

### 3. Meal-Centric
Life organized around eating times.

**Examples**:
- 6:00-8:00 AM: "Breakfast time"
- 8:00-10:00 AM: "Post-breakfast", "Mid-morning"
- 10:00-11:00 AM: "Almost lunch"
- 12:00-13:00: "Lunch time"
- 13:00-15:00: "Post-lunch"
- 15:00-16:00: "Afternoon snack time"
- 18:00-20:00: "Dinner time"
- 20:00-22:00: "After dinner"
- 22:00-24:00: "Late night snack time"

**Configuration**: Customizable meal times for different cultures/schedules

### 4. Work/Life Balance
Based on typical work schedules and life structure.

**Examples**:
- 6:00-8:00 AM: "Pre-work routine", "Morning prep"
- 8:00-9:00 AM: "Morning commute"
- 9:00-12:00: "Morning work block"
- 12:00-13:00: "Lunch break"
- 13:00-17:00: "Afternoon grind"
- 17:00-18:00: "Evening commute"
- 18:00-22:00: "Personal time", "Family time"
- 22:00-6:00: "Sleep time", "Rest hours"

**Configuration**: `fuzzy-clock-work-start`, `fuzzy-clock-work-end`, weekday vs weekend

### 5. Monastic Hours (Liturgy of the Hours)
Traditional Christian monastic time divisions.

**Examples**:
- 3:00 AM: "Matins", "Vigils"
- 6:00 AM: "Lauds", "Dawn prayer"
- 9:00 AM: "Terce", "Third hour"
- 12:00 PM: "Sext", "Sixth hour"
- 3:00 PM: "None", "Ninth hour"
- 6:00 PM: "Vespers", "Evening prayer"
- 9:00 PM: "Compline", "Night prayer"

**Note**: Could also implement Islamic prayer times, Buddhist time markers, etc.

### 6. Energy-Based
Based on human circadian rhythms and typical energy patterns.

**Examples**:
- 6:00-9:00 AM: "Morning surge", "Peak alertness"
- 9:00-11:00 AM: "High productivity window"
- 11:00-12:00: "Pre-lunch dip"
- 12:00-14:00: "Post-lunch slump"
- 14:00-16:00: "Afternoon recovery"
- 16:00-18:00: "Second wind"
- 18:00-21:00: "Wind down time"
- 21:00-22:00: "Prepare for rest"
- 22:00-6:00: "Deep sleep cycle"

### 7. British Tea Time
Everything relative to tea time (traditionally 4:00 PM).

**Examples**:
- 2:00 PM: "Two hours until tea"
- 3:00 PM: "Almost tea time"
- 4:00 PM: "Tea time!"
- 5:00 PM: "Just after tea"
- 6:00 PM: "Well past tea"

**Configuration**: `fuzzy-clock-tea-time` (default 16:00)

### 8. Folk Proverbs/Sayings
Traditional wisdom about different times of day.

**Examples**:
- Early morning: "The early bird catches the worm"
- Mid-morning: "A stitch in time saves nine"
- Noon: "The devil finds work for idle hands"
- Afternoon: "Make hay while the sun shines"
- Evening: "All's well that ends well"
- Night: "The darkest hour is just before dawn"

## Implementation Strategy

### Phase 1: Infrastructure
1. Create perspective registry system
2. Add perspective selection configuration
3. Modify main formatting function to dispatch to perspectives
4. Ensure backward compatibility with existing behavior

### Phase 2: Core Perspectives
1. Implement 3-4 most useful perspectives:
   - Solar/Natural
   - Meal-centric
   - Work/Life
   - British Tea

### Phase 3: Documentation & Extensibility
1. Document how to create custom perspectives
2. Provide templates for user-defined perspectives
3. Add examples of perspective customization

### Phase 4: Advanced Features
1. Location-aware perspectives (actual sunrise/sunset)
2. Calendar-aware perspectives (work vs weekend, holidays)
3. Perspective combinations/layers

## Extensibility for Users

Users can define custom perspectives:

```elisp
(defun my-custom-perspective (hour minute &optional day month year dow dst utcoff)
  "My personal way of thinking about time."
  (cond
   ((and (>= hour 7) (< hour 9)) "Coffee time!")
   ((and (>= hour 9) (< hour 12)) "Deep work hours")
   ((and (>= hour 12) (< hour 13)) "Lunch and walk")
   ((and (>= hour 13) (< hour 17)) "Meetings and collaboration")
   ((and (>= hour 17) (< hour 19)) "Exercise and unwind")
   ((and (>= hour 19) (< hour 22)) "Family time")
   (t "Rest and recharge")))

;; Register it
(add-to-list 'fuzzy-clock-time-perspectives
             '(my-custom . my-custom-perspective))

;; Use it
(setq fuzzy-clock-perspective 'my-custom)
```

## Benefits

1. **Cultural sensitivity**: Respects different ways of conceptualizing time
2. **Personal relevance**: Users can choose perspectives that match their lifestyle
3. **Educational**: Exposes users to diverse time concepts
4. **Extensible**: Easy to add new perspectives without modifying core code
5. **Fun**: Makes time display more engaging and meaningful
6. **Practical**: Can actually help people think about their day differently

## Future Possibilities

- **Hybrid perspectives**: Combine multiple perspectives (e.g., work-life + meal-centric)
- **Context-aware**: Switch perspectives based on day of week, location, calendar events
- **AI/Learning**: Learn user's actual patterns and create personalized perspectives
- **Seasonal variations**: Perspectives that change with seasons
- **Cultural calendar**: Integrate cultural/religious calendars
- **Poetic/Literary**: Time descriptions from literature and poetry
