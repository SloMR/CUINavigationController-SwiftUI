//
//  MessageBubbleView.swift
//  CUINavigationController-SwiftUI
//
//  Created by Sulaiman Alromaih on 05/02/2026.
//

import SwiftUI

// MARK: -

struct MessageBubbleView: View {
    let message: Message
    let screenWidth: CGFloat
    var onSwipeBegan: (() -> Void)?
    var onSwipeChanged: ((CGFloat) -> Void)?
    var onSwipeEnded: ((Bool) -> Void)?
    
    @State private var offset: CGFloat = 0
    @State private var hasStartedInteractiveTransition = false
    @State private var transitionStartOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            if message.isMe { Spacer() }
            
            Text(message.text)
                .padding()
                .background(message.isMe ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(20)
                .offset(x: offset)
                .gesture(
                    message.isMe ? DragGesture()
                        .onChanged { value in
                            let translation = value.translation.width
                            
                            if translation > 0 { return }
                            
                            offset = translation
                            
                            if !hasStartedInteractiveTransition && abs(translation) > 1 {
                                hasStartedInteractiveTransition = true
                                transitionStartOffset = abs(translation)
                                onSwipeBegan?()
                            }
                            
                            if hasStartedInteractiveTransition {
                                let progressSinceStart = max(0, abs(translation) - transitionStartOffset)
                                let remainingDistance = screenWidth - transitionStartOffset
                                let percentage = min(progressSinceStart / remainingDistance, 1.0)
                                onSwipeChanged?(percentage)
                            }
                        }
                        .onEnded { value in
                            if hasStartedInteractiveTransition {
                                let translation = value.translation.width
                                let velocity = value.predictedEndTranslation.width - translation
                                let distanceThreshold: CGFloat = screenWidth * 0.3
                                let velocityThreshold: CGFloat = 500
                                let shouldComplete = (abs(translation) > distanceThreshold) || (abs(velocity) > velocityThreshold && velocity < 0)
                                
                                onSwipeEnded?(shouldComplete)
                                hasStartedInteractiveTransition = false
                                transitionStartOffset = 0
                                
                                if shouldComplete {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        offset = -1000
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        offset = 0
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        offset = 0
                                    }
                                }
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    offset = 0
                                }
                            }
                        } : nil
                )
            
            if !message.isMe { Spacer() }
        }
    }
}

// MARK: -

#Preview {
    GeometryReader { geometry in
        MessageBubbleView(message: Message(text: "Preview message example", isMe: false), screenWidth: 12)
    }
}
