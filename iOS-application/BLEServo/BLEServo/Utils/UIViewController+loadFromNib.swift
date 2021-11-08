//
//  UIViewController+loadFromNib.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 08/11/2021.
//

import UIKit

extension UIViewController {
    class func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            let nibName = NSStringFromClass(self).components(separatedBy: ".").last!
            let bundle = Bundle(for: self)
            return T.init(nibName: nibName, bundle: bundle)
        }

        return instantiateFromNib()
    }
}
