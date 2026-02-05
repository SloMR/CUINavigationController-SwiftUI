//
//  MessageDetailView.swift
//  CustomNav
//
//  Created by Sulaiman Alromaih on 04/02/2026.
//

import SwiftUI

// MARK: -

struct MessageDetailView: View {
    let message: Message
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Message Details")
                .font(.title)
                .bold()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("From:")
                        .font(.headline)
                    Text(message.isMe ? "Me" : "Friend")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Message:")
                        .font(.headline)
                    Spacer()
                }
                
                Text(message.text)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
            }
            .padding()
            .background(Color(UIColor.systemGray5))
            .cornerRadius(15)
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: -
class MessageDetailHostingController: UIHostingController<MessageDetailView> {
    var currentSwipeTransition: UIPercentDrivenInteractiveTransition?
    
    init(message: Message) {
        super.init(rootView: MessageDetailView(message: message))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        var xOffset = gesture.translation(in: view).x
        var xVelocity = gesture.velocity(in: view).x
        
        if UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .rightToLeft {
            xOffset = -xOffset
            xVelocity = -xVelocity
        }
        
        if xOffset < 0 { xOffset = 0 }
        
        let percentage = xOffset / view.bounds.width
        
        switch gesture.state {
        case .began:
            let transition = UIPercentDrivenInteractiveTransition()
            transition.completionCurve = .easeOut
            transition.wantsInteractiveStart = true
            
            currentSwipeTransition = transition
            if let customNav = navigationController as? CUINavigationController {
                customNav.activeInteractiveTransition = transition
            }
            
            navigationController?.popViewController(animated: true)
            
        case .changed:
            currentSwipeTransition?.update(percentage)
            
        case .ended:
            let swipedFarEnough = percentage >= 0.5
            let swipedFastEnough = xVelocity >= 500
            let shouldComplete = (swipedFarEnough && xVelocity >= 0) || swipedFastEnough
            
            shouldComplete ? currentSwipeTransition?.finish() : currentSwipeTransition?.cancel()
            
            currentSwipeTransition = nil
            if let customNav = navigationController as? CUINavigationController {
                customNav.activeInteractiveTransition = nil
            }
            
        case .cancelled, .failed:
            currentSwipeTransition?.cancel()
            currentSwipeTransition = nil
            if let customNav = navigationController as? CUINavigationController {
                customNav.activeInteractiveTransition = nil
            }
            
        default:
            break
        }
    }
}

// MARK: -

extension MessageDetailHostingController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = pan.translation(in: view)
            return translation.x > 0 && abs(translation.x) > abs(translation.y)
        }
        return true
    }
}

// MARK: -

#Preview {
    NavigationStack {
        MessageDetailView(message: Message(
            text: "This is a preview message!",
            isMe: true
        ))
    }
}
