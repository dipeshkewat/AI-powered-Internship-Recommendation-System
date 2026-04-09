# InterMatch Frontend Redesign - Screen Preview Guide

## Color Palette
```
Primary Blue:      #0926A5  ████████ (Deep Blue)
Secondary Blue:    #435B71  ████████ (Secondary)
Tertiary Green:    #108F03  ████████ (Green)
Neutral Purple:    #75729E  ████████ (Neutral)
Background:        #F8F9FC  ████████ (Light Gray)
Surface:           #FFFFFF  ████████ (White)
Text Primary:      #1A1A1A  ████████ (Dark)
Text Secondary:    #666666  ████████ (Gray)
Border:            #D0D5E0  ████████ (Light Border)
```

---

## Screen 1: Welcome Screen
```
┌─────────────────────────────────┐
│                                 │
│          [LOGO ICON]            │  ← Gradient Blue Box with Icon
│                                 │
│         InterMatch              │  ← App Name (Blue)
│                                 │
│   Find internships              │
│   tailored for you              │  ← Tagline (Gray)
│                                 │
│  Connect with industry leaders  │  ← Description (Light Gray)
│  and innovative startups...     │
│                                 │
│                                 │
│      [████ Login █████]         │  ← Primary Button (Blue)
│                                 │
│    [░░ Register ░░░░░]          │  ← Outline Button
│                                 │
└─────────────────────────────────┘
```

**Design Elements:**
- Large blue gradient logo box (80x80)
- Clean typography hierarchy
- Two prominent CTAs (Login/Register)
- Light background gradient

---

## Screen 2: Auth Screen (Login/Register)

### Login Tab:
```
┌─────────────────────────────────┐
│ ▼  [Back]          InterMatch   │  ← Header
├─────────────────────────────────┤
│                                 │
│  Welcome Back                   │  ← Title
│  Sign in to your account        │  ← Subtitle
│                                 │
│  Email                          │  ← Label
│  [📧 name@company.com        ] │  ← Input Field
│                                 │
│  Password                       │  ← Label
│  [🔒 ••••••••            👁]   │  ← Password Field with Toggle
│                                 │
│         [Forgot Password?]      │  ← Text Link (Blue)
│                                 │
│      [████ Sign In ██████]      │  ← Primary Button
│                                 │
│  ━━━━━ Or continue with ━━━━━   │  ← Divider
│                                 │
│  [Google]    [SSO]              │  ← Social Buttons
│                                 │
│  Don't have account? [Sign Up]  │  ← Toggle Link
│                                 │
└─────────────────────────────────┘
```

**Design Elements:**
- Clean form layout with proper spacing
- Password visibility toggle
- Social login buttons
- Context-aware messaging

---

## Screen 3: Onboarding - Level of Education

```
┌─────────────────────────────────┐
│ [◄]  Step 1 of 8  [————→]       │  ← Progress Header
├─────────────────────────────────┤
│                                 │
│  What is your level of          │
│  education?                     │  ← Title
│                                 │
│  This helps us match you...     │  ← Subtitle (Gray)
│                                 │
│                                 │
│  ┌───────────────────────────┐  │
│  │ [🎓] Graduate           ☉ │  │  ← Option (Unselected)
│  │ I have completed a      │  │
│  │ Master's, PhD...        │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ [🎓] Undergraduate       ✓ │  │  ← Option (Selected - Blue)
│  │ I have completed or am   │  │
│  │ pursuing a Bachelor's    │  │
│  └───────────────────────────┘  │
│                                 │
│                                 │
│  [Back]         [Next ─→]       │  ← Navigation Buttons
│                                 │
└─────────────────────────────────┘
```

**Design Elements:**
- Step indicator with progress bar
- Card options with icon + text
- Selected state: Blue border, blue background tint, checkmark
- Disabled next button when nothing selected

---

## Screen 4: Onboarding - Experience Level

```
┌─────────────────────────────────┐
│ [◄]  Step 2 of 8  [─────→]      │  ← Progress Bar
├─────────────────────────────────┤
│                                 │
│  What is your experience        │
│  level?                         │  ← Title
│                                 │
│  Select the option that best    │
│  describes your professional    │
│  experience                     │  ← Subtitle
│                                 │
│  ┌───────────────────────────┐  │
│  │ [🚀] Fresher             ☉ │  │  ← Option Card
│  │ No prior internship or   │  │
│  │ professional experience  │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ [📈] Intermediate        ✓ │  │  ← Selected (Blue)
│  │ I have completed one or  │  │
│  │ more internships         │  │
│  └───────────────────────────┘  │
│                                 │
│  [Back]         [Next ─→]       │
│                                 │
└─────────────────────────────────┘
```

---

## Screen 5: Onboarding - Internship History

```
┌─────────────────────────────────┐
│ [◄]  Step 3 of 8  [──────→]     │
├─────────────────────────────────┤
│                                 │
│  Have you done any              │
│  internship?                    │  ← Title
│                                 │
│  Tell us about your             │
│  experience                     │  ← Subtitle
│                                 │
│  [Yes ✓]   [No ☐]              │  ← Buttons
│                                 │
│  Describe your internship       │  (showing if Yes selected)
│  experience                     │
│                                 │
│  [Tell us about your role,    ]│
│  [responsibilities, and       ] │  ← Text Area
│  [key learnings...            ]│
│                                 │
│  [Back]         [Next ─→]       │
│                                 │
└─────────────────────────────────┘
```

---

## Screen 6: Onboarding - Basic Information

```
┌─────────────────────────────────┐
│ [◄]  Step 4 of 8  [───────→]    │
├─────────────────────────────────┤
│                                 │
│  Basic Information              │  ← Title
│  Help us know you better        │  ← Subtitle
│                                 │
│  Full Name                      │
│  [👤 e.g. Alexander Pierce   ]│  ← Input
│                                 │
│  Phone Number                   │
│  [📱 +1 555-012-3456          ]│  ← Input
│                                 │
│                                 │
│  [Back]         [Next ─→]       │
│                                 │
└─────────────────────────────────┘
```

---

## Screen 7: Onboarding - Academic Details

```
┌─────────────────────────────────┐
│ [◄]  Step 5 of 8  [────────→]   │
├─────────────────────────────────┤
│                                 │
│  Academic Details               │  ← Title
│  Help us understand your        │
│  academic background            │
│                                 │
│  Degree                         │
│  [▼ Select your degree      ]│  ← Dropdown
│                                 │
│  Current Year                   │
│  [▼ Select year               ]│  ← Dropdown
│                                 │
│  CGPA                           │
│  [📊 e.g. 8.5                 ]│  ← Input (Number)
│                                 │
│  [Back]         [Next ─→]       │
│                                 │
└─────────────────────────────────┘
```

---

## Screen 8: Onboarding - Skills

```
┌─────────────────────────────────┐
│ [◄]  Step 6 of 8  [─────────→]  │
├─────────────────────────────────┤
│                                 │
│  Build your profile             │  ← Title
│  What are the core skills       │
│  you maintain?                  │
│                                 │
│  COMMON SKILLS                  │  ← Section Label
│                                 │
│  [Flutter] [Java]    [Python] │  ← Chips (Unselected)
│  [React]   [JavaScript] [C++]  │
│  [SQL]     [Node.js]           │
│                                 │
│  [Flutter ✓] [Java ✓]          │  ← Selected Skills (Blue)
│  [Python ✓]                    │
│                                 │
│  ADD CUSTOM SKILL               │
│  [Enter skill...            +] │  ← Custom Skill Input
│                                 │
│  TOOLS                          │  ← Section Label
│  [Git] [Docker] [AWS]          │
│  [Linux]                        │
│                                 │
│  [Back]         [Next ─→]       │
│                                 │
└─────────────────────────────────┘
```

---

## Screen 9: Onboarding - Interests

```
┌─────────────────────────────────┐
│ [◄]  Step 7 of 8  [──────────→] │
├─────────────────────────────────┤
│                                 │
│  What interests you?            │  ← Title
│  Select areas that excite you   │
│  professionally                 │
│                                 │
│  [Web Dev ✓]                   │  ← Selected (Blue)
│  [App Dev ✓]                   │
│  [Data Science]                │
│  [AI/ML ✓]                     │
│  [Cybersecurity]               │
│                                 │
│  [Back]         [Next ─→]       │
│                                 │
└─────────────────────────────────┘
```

---

## Screen 10: Onboarding - Preferences

```
┌─────────────────────────────────┐
│ [◄]  Step 8 of 8  [────────────→]│
├─────────────────────────────────┤
│                                 │
│  Internship Preference          │  ← Title
│  Tell us what you're looking    │
│  for so we can find the         │
│  perfect match                  │
│                                 │
│  Preferred Location             │
│  [Remote ✓]  [On-site]         │  ← Options
│                                 │
│  Internship Type                │
│  [Full-time ✓]  [Part-time]    │  ← Options
│                                 │
│  Duration                       │
│  [1 month]  [3 months ✓]       │  ← Options
│  [6 months]                    │
│                                 │
│         [███████████████████]  │
│         Find Internship         │  ← Action Button
│                                 │
└─────────────────────────────────┘
```

---

## Screen 11: Dashboard - Recommended Opportunities

```
┌─────────────────────────────────┐
│  Recommended for you      [👤]  │  ← Header
│  Based on your skills and       │
│  preferences                    │
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────────┐│
│  │ [💼] Frontend Developer  [♡]││  ← Card Header
│  │ Acme Software Inc            ││
│  │                              ││
│  │ [📍 New York] [⏱ 3 months] ││  ← Details
│  │ [💼 Full-time] [$500-1000]  ││
│  │                              ││
│  │ [React] [JavaScript] [CSS]   ││  ← Skills
│  │                              ││
│  │      [████ Apply ████]       ││  ← CTA
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ [💼] Data Science Intern [♡]││
│  │ Analytics Corp               ││
│  │                              ││
│  │ [🌍 Remote] [⏱ 6 months]   ││
│  │ [💼 Full-time] [$700-1200]  ││
│  │                              ││
│  │ [Python] [SQL] [Data Sci.]  ││
│  │                              ││
│  │      [████ Apply ████]       ││
│  └─────────────────────────────┘│
│                                 │
│      [████ Find Internship ████]│  ← CTA
│                                 │
├─────────────────────────────────┤
│ [🏠 Dashboard] [🔍 Search]      │  ← Bottom Nav
│ [📌 Saved]    [👤 Profile]      │
│                                 │
└─────────────────────────────────┘
```

**Dashboard Features:**
- Cards with company logo/icon
- Location, duration, type, pay info
- Skill tags (blue background)
- Apply button
- Bookmark/Save functionality
- Bottom navigation bar

---

## Design System Highlights

### Typography
- **Display Large**: 32px (App name, main titles)
- **Display Medium**: 26px (Screen titles)
- **Head Line Large**: 22px (Section headers)
- **Body Large**: 16px (Main content)
- **Body Small**: 12px (Supporting text)
- **Label Large**: 14px (Buttons, labels)

### Spacing
- **Extra Large**: 32px (Section spacing)
- **Large**: 24px (Page padding)
- **Medium**: 16px (Component spacing)
- **Small**: 8px (Internal spacing)

### Components
- **Buttons**: 56px height, 12px border radius
- **Inputs**: 48px height, 12px border radius
- **Cards**: 16px border radius, 1px border
- **Chips**: 8px border radius, 12px horizontal padding

### Effects
- **Shadows**: Light box shadow on cards
- **Focus States**: 2px blue border
- **Active States**: Blue background with 10% opacity
- **Transitions**: 300-400ms smooth animations

---

## Color Usage Guide

| Element | Color | Hex |
|---------|-------|-----|
| Primary Buttons | Primary Blue | #0926A5 |
| Link Text | Primary Blue | #0926A5 |
| Active Selection | Primary Blue | #0926A5 |
| Background | Light Gray | #F8F9FC |
| Card Background | White | #FFFFFF |
| Border | Light Border | #D0D5E0 |
| Main Text | Text Primary | #1A1A1A |
| Secondary Text | Text Secondary | #666666 |
| Disabled Text | Text Muted | #999999 |
| Success | Green | #108F03 |
| Skill Tags | Primary + 10% opacity | #0926A5 |
| Chip Background | Surface Elevated | #F0F2F7 |

---

## To Run the App and See Preview

```bash
# Navigate to the project
cd "c:\Users\dipes\OneDrive\Desktop\collage mini project\internmatch"

# Run the app (ensure you have an emulator running or device connected)
flutter run

# Or run on a specific device
flutter run -d "device-id"
```

The app will start with the Welcome Screen and flow through the login/signup → onboarding → dashboard experience.

---

**Design Complete! ✅**
All screens implemented with modern, minimalistic design using the InterMatch brand colors.
