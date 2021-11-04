//
//  ButtonsVAxisView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 03/11/2021.
//

import UIKit

@IBDesignable
class ButtonsVAxisView: UIViewWithNib {
    @IBOutlet weak var stackViewButtons: UIStackView!

    var viewModel: ButtonsAxisViewModel? { didSet { connectToViewModel() } }

    override var intrinsicContentSize: CGSize {
        stackViewButtons.intrinsicContentSize
    }

    @IBAction func onButtonUpPress(_ sender: Any) {
        viewModel?.positiveButtonDidPress()
    }

    @IBAction func onButtonUpRelease(_ sender: Any) {
        viewModel?.positiveButtonDidRelease()
    }

    @IBAction func onButtonDownPress(_ sender: Any) {
        viewModel?.negativeButtonDidPress()
    }

    @IBAction func onButtonDownRelease(_ sender: Any) {
        viewModel?.negativeButtonDidRelease()
    }
}

private extension ButtonsVAxisView {
    func connectToViewModel() {
    }
}
