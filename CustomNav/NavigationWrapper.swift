//
//  NavigationWrapper.swift
//  CustomNav
//
//  Created by Sulaiman Alromaih on 04/02/2026.
//

import SwiftUI
import UIKit

// MARK: - Custom Navigation Controller

class CUINavigationController: UINavigationController {
    weak var activeInteractiveTransition: UIPercentDrivenInteractiveTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension CUINavigationController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return DrawerAnimationController(operation: operation)
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        
        if let customNav = navigationController as? CUINavigationController,
           let transition = customNav.activeInteractiveTransition {
            return transition
        }
        
        return nil
    }
}

// MARK: - SwiftUI Bridge

struct NavigationBridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let listVC = MessageListHostingController()
        let navController = CUINavigationController(rootViewController: listVC)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

#Preview {
    NavigationBridge()
}
