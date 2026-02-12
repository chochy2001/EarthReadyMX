# Issues V7 - Room Scanner Crash + Kit Builder Toast

## Issue 1: Room Scanner - SWIFT TASK CONTINUATION MISUSE (CRITICAL)

### Error
```
Task 414: Fatal error: SWIFT TASK CONTINUATION MISUSE: classifyRoomImage(_:topK:)
tried to resume its continuation more than once, throwing Error Domain=NSOSStatusErrorDomain
Code=-1 "Error encountered during: Loading espresso Network [espresso error: -2]"
```

### Root Cause Analysis
The `classifyRoomImage()` function uses `withCheckedThrowingContinuation` with a
`VNClassifyImageRequest` completion handler. The problem:

1. `VNClassifyImageRequest` completion handler fires with an espresso error
2. Completion handler calls `continuation.resume(throwing: error)`
3. `handler.perform([request])` ALSO throws (because the request failed internally)
4. The catch block calls `continuation.resume(throwing: error)` AGAIN
5. Swift crashes: "tried to resume its continuation more than once"

This is a well-known footgun with Vision + withCheckedThrowingContinuation:
- When `perform()` throws, the completion handler MAY or MAY NOT have already been called
- There's a race between the completion handler error and the perform() throw

### Additional Issue: Espresso Error
The "Loading espresso Network [espresso error: -2]" suggests the Vision classification
neural network failed to load. This can happen:
- On certain devices with limited memory
- When the Neural Engine is busy
- When usesCPUOnly doesn't have sufficient resources

### Fix Strategy
1. **Remove the continuation pattern entirely** - Don't use completion handler
2. Use `VNClassifyImageRequest()` without completion handler
3. Call `handler.perform([request])` synchronously
4. Read `request.results` after perform returns
5. Wrap in `Task.detached` to avoid blocking main thread
6. Handle espresso errors gracefully (show user-friendly error, don't crash)

### Affects
- Camera photo analysis
- Photo library analysis
- Both paths crash identically

---

## Issue 2: Kit Builder - Feedback Toast Too Transparent

### Problem
The FeedbackToast in KitBuilderView is semi-transparent, making text hard to read.
The background behind the toast shows through, mixing with the card text.

### Current Code
```swift
.background(
    RoundedRectangle(cornerRadius: 14)
        .fill((isCorrect ? Color.green : Color.red).opacity(0.15))
)
```

The `opacity(0.15)` makes the background almost invisible. Combined with the overlay
stroke at `opacity(0.3)`, the card content blends with whatever is behind it.

### Fix Strategy
1. Increase background opacity significantly (0.15 → higher)
2. Add a solid dark background layer behind the colored tint
3. Consider adding `.background(.ultraThinMaterial)` or solid Color.black base
4. Ensure text contrast meets WCAG guidelines

---

## Implementation Plan
1. Research Vision framework best practices for Swift concurrency
2. Fix classifyRoomImage to avoid double-resume
3. Add graceful error handling for espresso failures
4. Fix toast background opacity
5. Typecheck and verify
