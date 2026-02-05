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
    let bubbleOffset: CGFloat
    
    var body: some View {
        HStack {
            if message.isMe { Spacer() }
            
            Text(message.text)
                .padding()
                .background(message.isMe ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(20)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .offset(x: message.isMe ? bubbleOffset : 0)
            
            if !message.isMe { Spacer() }
        }
    }
}

// MARK: -

#Preview {
    GeometryReader { geometry in
        MessageBubbleView(message: Message(text: "Preview message example", isMe: false), bubbleOffset: 0)
    }
}
