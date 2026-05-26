# Responsive & Refactor Plan

## 1. Add Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_screenutil: ^5.9.0
  gap: ^3.0.1
```
Then run `flutter pub get`.

---

## 2. Setup in `main.dart`

Wrap `MaterialApp` with `ScreenUtilInit`:
```dart
ScreenUtilInit(
  designSize: const Size(390, 866),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) => MaterialApp.router(
    // ... existing setup
  ),
)
```

---

## 3. Refactoring Rules

### 3a. SizedBox → Gap
| Old | New |
|-----|-----|
| `SizedBox(height: 4)` | `Gap(4.h)` |
| `SizedBox(height: 8)` | `Gap(8.h)` |
| `SizedBox(width: 10)` | `Gap(10.w)` |
| `SizedBox.shrink()` | `Gap.zero` |
| `SizedBox(height: 50)` | `Gap(50.h)` |

Import: `import 'package:gap/gap.dart';`

### 3b. Sizes → ScreenUtil
| Usage | Pattern |
|-------|---------|
| Container width/height | `.w` / `.h` |
| Padding/Margin | `EdgeInsets.all(16.w)` |
| Border radius | `BorderRadius.circular(24.r)` |
| Font size | `TextStyle(fontSize: 16.sp)` |
| Icon size | `Icon(size: 24.sp)` |
| Blur sigma | keep as-is |
| Border width | keep as `1` |

Import: `import 'package:flutter_screenutil/flutter_screenutil.dart';`

### 3c. Fraction sizes
| Old | New |
|-----|-----|
| `MediaQuery.of(context).size.width * 0.7` | `0.7.sw` |
| `MediaQuery.of(context).size.height * 0.7` | `0.7.sh` |

---

## 4. Refactoring Order

### Phase 1: Core Widgets
1. `custom_glass_container.dart`
2. `custom_glass_drawer.dart`
3. `custom_bottom_nav_bar.dart`
4. `custom_floating_action_button.dart`
5. `custom_section_button.dart`

### Phase 2: Scanner Views (most sizes)
6. `scanner_view.dart` (32x SizedBox, 19+ heights, 32+ widths)
7. `camera_scanner_view.dart`
8. `details_view.dart` + `scan_log_details_view.dart`

### Phase 3: Chat
9. `chat_view.dart`
10. `chat_bubble.dart`
11. `chat_input_field.dart`

### Phase 4: Auth & Profile
12. `auth_bottom_sheet.dart`
13. `auth_view.dart`
14. `edit_profile_view.dart`
15. `profile_view.dart`
16. `settings_view.dart`

### Phase 5: Discover & Home
17. `custom_scan_button.dart`
18. `custom_home_slider.dart`
19. `custom_era_time_line_card.dart`
20. `custom_section_card.dart`
21. `mythology_view.dart`
22. `god_details_view.dart`
23. `egyptian_history_view.dart`
24. `onboarding_view.dart`
25. `glass_card.dart`

---

## 5. Code Cleanup

### 5a. Dedup `details_view.dart` ↔ `scan_log_details_view.dart`
~90% identical. Extract shared sections into `ArtifactDetailsBody`.

### 5b. Remove FeaturesCubit duplicate
Two files exist. Consolidate into `cubit/` and fix imports.

### 5c. Extract magic numbers
Examples: `_glassBorderRadius = 24`, `_chatMaxWidth = 282`, `_inputHeight = 45`.

### 5d. Remove unused imports in every touched file.

---

## 6. Effort

| Phase | Files | Time |
|-------|-------|------|
| Setup | 2 | 15m |
| Core widgets | 5 | 30m |
| Scanner views | 4 | 2h |
| Chat views | 3 | 1h |
| Auth & Profile | 5 | 1.5h |
| Discover & Home | 10 | 2h |
| Cleanup | all | 1h |
| **Total** | **~30** | **~8-9h** |
