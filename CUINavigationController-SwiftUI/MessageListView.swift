//
//  MessageListView.swift
//  CUINavigationController-SwiftUI
//
//  Created by Sulaiman Alromaih on 05/02/2026.
//

import SwiftUI

// MARK: -

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
}

// MARK: -

struct MessageListView: View {
    let messages = [
        Message(text: "Hey! How's it going?", isMe: false),
        Message(text: "Hey! I'm doing great, thanks for asking!", isMe: true),
        Message(text: "That's awesome! What are you up to today?", isMe: false),
        Message(text: "Working on a new SwiftUI project", isMe: true)
    ]
    
    @GestureState private var dragTranslation: CGFloat = 0
    @State private var isInteractiveTransitionActive = false
    @State private var transitionStartOffset: CGFloat = 0
    @State private var activeSwipeMessageId: UUID?
    
    var onSwipeBegan: ((Message) -> Void)?
    var onSwipeChanged: ((Message, CGFloat) -> Void)?
    var onSwipeEnded: ((Message, Bool) -> Void)?
    
    private let bubbleMaxOffset: CGFloat = 25
    private let velocityThreshold: CGFloat = 500
    private let distanceThresholdRatio: CGFloat = 0.3
    private let gestureMinDistance: CGFloat = 5
    
    private var bubbleOffset: CGFloat {
        return max(dragTranslation, -bubbleMaxOffset)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Messages")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            ScrollView {
                GeometryReader { geometry in
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubbleView(
                                message: message,
                                bubbleOffset: activeSwipeMessageId == message.id ? bubbleOffset : 0
                            )
                            .gesture(
                                message.isMe ? DragGesture(minimumDistance: gestureMinDistance, coordinateSpace: .global)
                                    .updating($dragTranslation) { value, state, _ in
                                        let translation = value.translation.width
                                        if translation <= 0 {
                                            state = translation
                                        }
                                    }
                                    .onChanged { value in
                                        let translation = value.translation.width
                                        if translation > 0 { return }
                                        
                                        if activeSwipeMessageId == nil {
                                            activeSwipeMessageId = message.id
                                        }
                                        
                                        guard activeSwipeMessageId == message.id else { return }
                                        
                                        // Only start the push transition after bubble reaches its max
                                        if !isInteractiveTransitionActive && abs(translation) > bubbleMaxOffset {
                                            isInteractiveTransitionActive = true
                                            transitionStartOffset = abs(translation)
                                            onSwipeBegan?(message)
                                        }
                                        
                                        if isInteractiveTransitionActive {
                                            let progressSinceStart = max(0, abs(translation) - transitionStartOffset)
                                            let remainingDistance = geometry.size.width - transitionStartOffset
                                            let percentage = min(progressSinceStart / remainingDistance, 1.0)
                                            onSwipeChanged?(message, percentage)
                                        }
                                    }
                                    .onEnded { value in
                                        guard activeSwipeMessageId == message.id else { return }
                                        
                                        let translation = value.translation.width
                                        let velocity = value.predictedEndTranslation.width - translation
                                        let distanceThreshold = geometry.size.width * distanceThresholdRatio
                                        let shouldComplete = isInteractiveTransitionActive &&
                                        ((abs(translation) > distanceThreshold) || (abs(velocity) > velocityThreshold && velocity < 0))
                                        
                                        onSwipeEnded?(message, shouldComplete)
                                        
                                        isInteractiveTransitionActive = false
                                        transitionStartOffset = 0
                                        activeSwipeMessageId = nil
                                    } : nil
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: -

class MessageListHostingController: UIHostingController<MessageListView> {
    var activePushTransition: UIPercentDrivenInteractiveTransition?
    var pendingDetailVC: MessageDetailHostingController?
    
    init() {
        let contentView = MessageListView(
            onSwipeBegan: nil,
            onSwipeChanged: nil,
            onSwipeEnded: nil
        )
        super.init(rootView: contentView)
        
        self.rootView = MessageListView(
            onSwipeBegan: { [weak self] message in
                self?.startInteractivePush(for: message)
            },
            onSwipeChanged: { [weak self] message, percentage in
                self?.updateInteractivePush(percentage: percentage)
            },
            onSwipeEnded: { [weak self] message, shouldComplete in
                self?.finishInteractivePush(shouldComplete: shouldComplete)
            }
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startInteractivePush(for message: Message) {
        let transition = UIPercentDrivenInteractiveTransition()
        transition.wantsInteractiveStart = true
        transition.completionCurve = .easeOut
        
        activePushTransition = transition
        if let customNav = navigationController as? CUINavigationController {
            customNav.activeInteractiveTransition = transition
        }
        
        let detailVC = MessageDetailHostingController(message: message)
        pendingDetailVC = detailVC
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func updateInteractivePush(percentage: CGFloat) {
        activePushTransition?.update(percentage)
    }
    
    private func finishInteractivePush(shouldComplete: Bool) {
        guard let transition = activePushTransition else { return }
        
        shouldComplete ? transition.finish() : transition.cancel()
        
        activePushTransition = nil
        pendingDetailVC = nil
        if let customNav = navigationController as? CUINavigationController {
            customNav.activeInteractiveTransition = nil
        }
    }
}

// MARK: -

#Preview {
    MessageListView()
}
