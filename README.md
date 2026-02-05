# CUINavigationController-SwiftUI

A SwiftUI + UIKit implementation of interactive navigation transitions.

## Features

- **Interactive Push**
- **Interactive Pop**
- **Cancellable Transitions**
- **Parallax Effect**

## How It Works

The app uses UIKit's `UINavigationController` for navigation control while keeping the UI in SwiftUI. This enables custom interactive transitions that aren't possible with pure SwiftUI.

```
SwiftUI Views → UIHostingController → UINavigationController
```

Key components:
- `UIPercentDrivenInteractiveTransition` - Drives animation with gesture percentage
- `UIViewPropertyAnimator` - Allows pausing and scrubbing animations
- `DragGesture` / `UIPanGestureRecognizer` - Captures user input

## Project Structure

```
CUINavigationController-SwiftUI/
├── CustomNavApp.swift              
├── NavigationWrapper.swift         
├── DrawerAnimationController.swift 
├── MessageListView.swift           
├── MessageBubbleView.swift         
└── MessageDetailView.swift         
```