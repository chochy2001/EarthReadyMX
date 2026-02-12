# Issues V5 - UI & Navigation Problems

## 1. KitBuilderView: Scroll Conflict with DragGesture
- **Problem**: When trying to scroll the item list, it selects/drags an item instead of scrolling
- **Cause**: DragGesture on each item intercepts the scroll gesture
- **Expected**: Scroll should work normally; items should only be dragged with a deliberate long-press or from a specific drag handle
- **Fix needed**: Use LongPressGesture before DragGesture, or add a dedicated drag handle so scroll isn't intercepted

## 2. KitBuilderView: Drop Zone Not Working
- **Problem**: Cannot drop items into the "Drop Items Here" backpack area
- **Cause**: The drop zone appears to be behind other elements in the Z-stack, making it non-interactive
- **Expected**: Items should be droppable into the backpack area
- **Fix needed**: Review Z-ordering and hit testing of the drop zone, ensure it's above other elements

## 3. Navigation: No Back Button from ChecklistView to ResultView
- **Problem**: After Learn Safety Protocols → Continue → ChecklistView, there's no way to go back to the Results screen
- **Expected**: A back button should allow returning to ResultView where "Build Your Kit", "Learn Safety Protocols", and "Practice Drill" are all accessible
- **Fix needed**: Add back/home button to ChecklistView that returns to .result phase

## 4. Navigation: ChecklistView Missing "Build Your Kit" Button
- **Problem**: ChecklistView only shows "Practice Drill" and "Start Over", but not "Build Your Kit"
- **Expected**: ChecklistView should also have a "Build Your Kit" button, or a back button to return to ResultView which has all options
- **Fix needed**: Add "Build Your Kit" button in ChecklistView OR ensure back navigation to ResultView

## 5. Navigation: After Drill → Checklist, No Access to Other Activities
- **Problem**: After completing the drill, "Continue to Checklist" goes to ChecklistView, but from there user can't access Kit Builder or go back to the hub screen
- **Expected**: User should be able to navigate to all activities from any point after the quiz
- **Fix needed**: Either make ResultView the central hub with back buttons from all activities, or add all activity buttons to each endpoint view

## 6. Navigation Flow Summary
Current problematic flow:
```
Story → Quiz → ResultView (has: Learn, Kit, Drill buttons) ✓
ResultView → Learn → ChecklistView (only: Drill, Start Over) ✗ Missing Kit, no back
ResultView → Drill → ChecklistView (only: Drill, Start Over) ✗ Missing Kit, no back
ResultView → Kit → (broken drop zone) ✗
```

Desired flow:
```
ResultView = Central Hub (always accessible via back buttons)
  → Learn → back to ResultView
  → Kit Builder → back to ResultView
  → Drill → back to ResultView
  → Checklist → back to ResultView
All activities accessible from ResultView at all times
```
