//
//  ButtonsHAxisView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 03/11/2021.
//

import UIKit

@IBDesignable
class ButtonsHAxisView: UIViewWithNib {
    var content: ButtonsHAxisContentView { contentView as! ButtonsHAxisContentView }
    var viewModel: ButtonsAxisViewModel? { didSet { connectToViewModel() } }

    override var intrinsicContentSize: CGSize {
        content.stackViewButtons.intrinsicContentSize
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
        guard let viewModel = viewModel else {
            content.axisValueView.axisValue = 0
            return
        }
        viewModel.onValueDidChange = { [weak self] (newValue) in
            self?.content.axisValueView.axisValue = newValue
        }
        content.axisValueView.axisValue = viewModel.value
    }
}

class ButtonsHAxisContentView: UIView {
    @IBOutlet weak var stackViewButtons: UIStackView!
    @IBOutlet weak var axisValueView: AxisRenderValueView!
}
