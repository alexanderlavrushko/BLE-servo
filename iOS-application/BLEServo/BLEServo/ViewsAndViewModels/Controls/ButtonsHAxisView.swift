//
//  ButtonsHAxisView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 03/11/2021.
//

import UIKit

@IBDesignable
class ButtonsHAxisView: UIViewWithNib {
    @IBOutlet weak var stackViewButtons: UIStackView!

    var viewModel: ButtonsAxisViewModel? { didSet { connectToViewModel() } }

    override var intrinsicContentSize: CGSize {
        stackViewButtons.intrinsicContentSize
    }

    @IBAction func onButtonLeftPress(_ sender: Any) {
        viewModel?.negativeButtonDidPress()
    }

    @IBAction func onButtonLeftRelease(_ sender: Any) {
        viewModel?.negativeButtonDidRelease()
    }

    @IBAction func onButtonRightPress(_ sender: Any) {
        viewModel?.positiveButtonDidPress()
    }

    @IBAction func onButtonRightRelease(_ sender: Any) {
        viewModel?.positiveButtonDidRelease()
    }
}

private extension ButtonsHAxisView {
    func connectToViewModel() {
    }
}
