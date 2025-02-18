# KeyboardAlignedViews ⌨️

[![Quintschaf_Badge]](https://fivesheep.co)
[![LICENSE_BADGE]][LICENSE_URL]

KeyboardAlignedViews is a Swift Package that alignes SwiftUI Views with the iOS keyboard, both during animation and when the user drags the keyboard.

## Description

In standard SwiftUI, the animation of the safe area insets and the keyboard is not properly aligned. Also, when the `.scrollDismissesKeyboard(.interactively)` interaction never adjusts the safe area, leaving users with strange unfilled areas of their screens.

KeyboardAlignedViews solves both problems, providing proper user interaction and animation tracking.

## Example Code

### Chat-style view with footer that contains a resizable text field
```Swift
KAScrollViewWithTextViewFooter(placeholder: "placeholder", text: $message) {
    // scroll view content
} footer: { textView in
    textView
        .padding(8)
        .background(Color.gray)
}
```

## TODO

- [x] Chat-style view where a footer below the main scroll view contains a resizable text field.
- [ ] More generic usage possibility, where the developer can use a custom text view.

<!-- References -->

[Quintschaf_Badge]: https://badgen.net/badge/Built%20and%20maintained%20by/Quintschaf/cyan?icon=https://quintschaf.com/assets/logo.svg
[LICENSE_BADGE]: https://badgen.net/github/license/FiveSheepCo/KeyboardAlignedViews
[LICENSE_URL]: https://github.com/FiveSheepCo/KeyboardAlignedViews/blob/main/LICENSE
