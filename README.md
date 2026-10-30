# Combinable

![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2013.0%2B-lightgrey.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
![CocoaPods](https://img.shields.io/badge/CocoaPods-supported-blueviolet.svg)

## Overview

A UIKit extension based on Combine. Publishers live under `cb`, so they do not take method names on `UIView`, `UIControl`, or `UIScrollView`:

- **Gestures** — tap, long press, pan, swipe, pinch, and rotation
- **Controls** — touch and other `UIControl` events
- **Text** — user edits and programmatic updates for `UITextField` and `UITextView`
- **Scrolling** — content offset, and a signal when the content reaches the bottom

## Features

- **Namespace** — call everything through `view.cb` instead of adding methods to UIKit types
- **Gestures on demand** — a recognizer is added when you subscribe and removed when you cancel
- **Text** — user input and code assignments both emit, and consecutive duplicates are dropped
- **Reached bottom** — uses `adjustedContentInset`, including navigation bars and the home indicator
- **Lifetime** — store a subscription on any `NSObject`; it is cancelled when that object is deallocated

## Requirements

- iOS 13.0+
- Swift 5.5+

## Installation

### CocoaPods

```ruby
pod 'Combinable'
```

Then run:

```bash
pod install
```

### Swift Package Manager

In Xcode: **File → Add Packages…** and enter:

```
https://github.com/iLiuChang/Combinable.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iLiuChang/Combinable.git", from: "1.0.0")
]
```

### Manual

1. Download the files in the `Sources` folder
2. Drag them into your Xcode project

## Usage

### Control Events

```swift
import Combinable

button.cb.controlEventPublisher(for: .touchUpInside)
    .sink { [weak self] in
        self?.login()
    }
    .cb.store(in: self)
```

### Gestures

```swift
view.cb.tapPublisher
    .sink { recognizer in
        let point = recognizer.location(in: recognizer.view)
    }
    .cb.store(in: self)
```

Configure a recognizer before it is added. A swipe recognizer defaults to `.right`:

```swift
view.cb.gesturePublisher(for: UISwipeGestureRecognizer.self) { recognizer in
    recognizer.direction = .left
}
.sink { _ in
    // swiped left
}
.cb.store(in: self)
```

Each subscription adds its own recognizer. Cancelling the subscription removes it. A gesture emits its recognizer on every state change.

### Text

```swift
textField.cb.textPublisher
    .sink { text in
        print(text ?? "")
    }
    .cb.store(in: self)
```

`textPublisher` emits the current value on subscription, then on both user edits and assignments such as `textField.text = "Hello"`. The same text is not emitted twice in a row. `UITextView` uses the same property. `UITextField` also has `attributedTextPublisher`.

### Scrolling

```swift
scrollView.cb.contentOffsetPublisher
    .sink { offset in
        print(offset)
    }
    .cb.store(in: self)

tableView.cb.reachedBottomPublisher(offset: 40)
    .sink { [weak self] in
        self?.loadMore()
    }
    .cb.store(in: self)
```

`offset` is the distance from the bottom, in points, at which to emit. The publisher also emits when the content is shorter than the visible area. A `contentSize` height of zero does not emit. It emits again after the scroll position leaves that region and comes back.

### Storing Subscriptions

`store(in:)` keeps the cancellable for the lifetime of an object:

```swift
button.cb.controlEventPublisher(for: .touchUpInside)
    .sink { [weak self] in
        self?.login()
    }
    .cb.store(in: self)
```

This is the same set as `cb.cancellables`:

```swift
.store(in: &self.cb.cancellables)
```

Store the subscription on the object that owns the work, such as a view controller. A subscription that observes a property retains that object until it is cancelled.

## API Reference

### CombinableWrapper

Access it through `cb` on any `NSObject`. `AnyCancellable` also has `cb`, which is used by `store(in:)`.

| Property / Method | Description |
|---|---|
| `base` | The wrapped object. |

### UIView

| Property / Method | Description |
|---|---|
| `tapPublisher` | Tap recognizer. Emits on each state change. |
| `longPressPublisher` | Long-press recognizer. Emits on each state change. |
| `panPublisher` | Pan recognizer. Emits on each state change. |
| `swipePublisher` | Swipe recognizer. Direction defaults to `.right`. |
| `pinchPublisher` | Pinch recognizer. Emits on each state change. |
| `rotationPublisher` | Rotation recognizer. Emits on each state change. |
| `gesturePublisher(`<br>`for:`<br>`configure:)` | Adds a recognizer of the given type. `configure` runs before it is added. |

### UIControl

| Property / Method | Description |
|---|---|
| `controlEventPublisher(for:)` | Emits when any of the given control events occur. |

### UITextField and UITextView

| Property / Method | Description |
|---|---|
| `textPublisher` | Current `text` on subscription, user edits, and programmatic updates. Consecutive duplicates are dropped. |
| `attributedTextPublisher` | Same as `textPublisher`, for `UITextField.attributedText`. |

### UIScrollView

| Property / Method | Description |
|---|---|
| `contentOffsetPublisher` | Content offset changes, including the current value on subscription. |
| `reachedBottomPublisher(offset:)` | Emits within `offset` points of the bottom. `offset` defaults to `0`. Also emits when the content is shorter than the visible area. |

### Lifetime

| Property / Method | Description |
|---|---|
| `cancellables` | Cancellables retained by this object. Cancelled when the object is deallocated. |
| `store(in:)` | Stores this cancellable in the given object's `cancellables` set. Called on `AnyCancellable.cb`. |

### Publishers

These types back the properties above. `UIControlPropertyPublisher` reads a control property when the given events occur, and also sends the current value once.

| Type | Output |
|---|---|
| `UIGesturePublisher` | The gesture recognizer. |
| `UIControlEventPublisher` | `Void` when a control event occurs. |
| `UIControlPropertyPublisher` | The value at the given key path. |

## Architecture

`cb` returns a `CombinableWrapper` around the original object. Extensions on that wrapper add the publishers, so UIKit types stay unchanged. `NSObject` conforms to `CombinableCompatible`; `AnyCancellable` conforms to `CombinableCompatibleValue`.

A gesture subscription creates the recognizer, runs `configure`, and adds it to the view. Cancel removes it. The recognizer retains its target, so cancel also releases that reference.

A control-event subscription calls `addTarget` and removes that target on cancel. `UIControl` does not retain its target.

Text publishers merge an editing signal with key-value observation, then drop consecutive equal values. `UITextField` uses `.allEditingEvents`. `UITextView` uses `textDidChangeNotification`. Key-value observation covers programmatic assignments.

`reachedBottomPublisher(offset:)` watches `contentOffset` and `contentSize`. It compares the scrolled position with the bottom of the content, using `bounds` and `adjustedContentInset`. `offset` moves that line up by the given distance.

`cancellables` is a set stored as an associated object. `AnyCancellable.cb.store(in:)` inserts into that set. Deallocating the object releases the set and cancels every subscription in it.

## License

MIT License. See [LICENSE](LICENSE) for details.
