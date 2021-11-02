//
//  UIView+extension.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 19/10/2021.
//

import Foundation
import UIKit

extension UIView {
    func constraintToSuperview() {
        constraintToSuperviewVertically(top: 0, bottom: 0)
        constraintToSuperviewHorizontally(leading: 0, trailing: 0)
    }

    func constraintVertically(toView anotherView: UIView, top: CGFloat, bottom: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: anotherView.topAnchor, constant: top),
            anotherView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom),
        ])
    }

    func constraintToSuperviewVertically(top: CGFloat, bottom: CGFloat) {
        guard let superview = superview else { return }
        constraintVertically(toView: superview, top: top, bottom: bottom)
    }

    func constraintHorizontally(toView anotherView: UIView, leading: CGFloat, trailing: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: anotherView.leadingAnchor, constant: leading),
            anotherView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing)
        ])
    }

    func constraintToSuperviewHorizontally(leading: CGFloat, trailing: CGFloat) {
        guard let superview = superview else { return }
        constraintHorizontally(toView: superview, leading: leading, trailing: trailing)
    }

    func centerVertically(toView anotherView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerYAnchor.constraint(equalTo: anotherView.centerYAnchor)
        ])
    }

    func centerInSuperviewVertically() {
        guard let superview = superview else { return }
        centerVertically(toView: superview)
    }
}
