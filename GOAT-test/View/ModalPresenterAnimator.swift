//
//  ModalPresenterAnimator.swift
//  GOAT-test
//
//  Created by Andrew Tenno on 3/20/18.
//  Copyright © 2018 Andrew Tenno. All rights reserved.
//

import UIKit

class BaseModalBackgroundAnimator: NSObject {
    final let backgroundViewTag = 42
}

final class ModalPresenterAnimator: BaseModalBackgroundAnimator, UIViewControllerAnimatedTransitioning {
    let duration = 0.5

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)

        let backgroundView = UIView(frame: containerView.frame)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        backgroundView.alpha = 0.0
        backgroundView.tag = backgroundViewTag
        containerView.insertSubview(backgroundView, belowSubview: toView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: transitionContext.viewController(forKey: .to),
                                                          action: .dismissAnimated)
        backgroundView.addGestureRecognizer(tapGestureRecognizer)

        toView.frame = calculateModalFrame(fromContainerFrame: containerView.frame)

        let yTranslation = containerView.frame.maxY - toView.frame.minY
        toView.transform = CGAffineTransform(translationX: 0, y: yTranslation)

        let animations: () -> Void = {
            toView.transform = .identity
            backgroundView.alpha = 1.0
        }

        let completion: (Bool) -> Void = { _ in
            transitionContext.completeTransition(true)
        }

        UIView.animate(withDuration: duration,
                       animations: animations,
                       completion: completion)
    }

    private func calculateModalFrame(fromContainerFrame frame: CGRect) -> CGRect {
        let width = frame.width * 0.8
        let height = frame.height * 0.5
        let originX = frame.midX - width/2
        let originY = frame.midY - height/2

        return .init(x: originX, y: originY, width: width, height: height)
    }
}

private extension Selector {
    static var dismissAnimated: Selector {
        return #selector(UIViewController.dismissAnimated)
    }
}

extension UIViewController {
    @objc func dismissAnimated() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

final class ModalDismissalAnimator: BaseModalBackgroundAnimator, UIViewControllerAnimatedTransitioning {
    let duration = 0.5

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!

        let backgroundView = containerView.subviews.filter({ $0.tag == backgroundViewTag }).first

        let yTranslation = containerView.frame.maxY - fromView.frame.minY
        let transform = CGAffineTransform(translationX: 0, y: yTranslation)

        let animations: () -> Void = {
            fromView.transform = transform
            backgroundView?.alpha = 0.0
        }

        let completion: (Bool) -> Void = { _ in
            transitionContext.completeTransition(true)
        }

        UIView.animate(withDuration: duration,
                       animations: animations,
                       completion: completion)
    }
}
