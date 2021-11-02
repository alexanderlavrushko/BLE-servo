//
//  UIViewWithNib.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 02/11/2021.
//

import UIKit

class UIViewWithNib: UIView {
    /// nibName can be overriden in subclass (if nibName is identical to class name, no need to override)
    class var nibName: String {
        NSStringFromClass(self).components(separatedBy: ".").last!
    }
    private(set) var contentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        guard let view = loadFromNib() else {
            print("Error: Failed to load UIView from nib: \(type(of: self).nibName)")
            return
        }
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])

        contentView = view
        backgroundColor = .clear
    }

    private func loadFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: type(of: self).nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
