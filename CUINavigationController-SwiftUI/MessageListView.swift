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
    
    var onSwipeBegan: ((Message) -> Void)?
    var onSwipeChanged: ((Message, CGFloat) -> Void)?
    var onSwipeEnded: ((Message, Bool) -> Void)?
    
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
                                screenWidth: geometry.size.width,
                                onSwipeBegan: {
                                    onSwipeBegan?(message)
                                },
                                onSwipeChanged: { percentage in
                                    onSwipeChanged?(message, percentage)
                                },
                                onSwipeEnded: { shouldComplete in
                                    onSwipeEnded?(message, shouldComplete)
                                }
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
