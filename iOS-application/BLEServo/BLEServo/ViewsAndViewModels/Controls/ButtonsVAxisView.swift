//
//  ButtonsVAxisView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 03/11/2021.
//

import UIKit

@IBDesignable
class ButtonsVAxisView: UIViewWithNib {
    var content: ButtonsVAxisContentView { contentView as! ButtonsVAxisContentView }
    var viewModel: ButtonsAxisViewModel? { didSet { connectToViewModel() } }

    override var intrinsicContentSize: CGSize {
        content.stackViewButtons.intrinsicContentSize
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

class ButtonsVAxisContentView: UIView {
    @IBOutlet weak var stackViewButtons: UIStackView!
    @IBOutlet weak var axisValueView: AxisRenderValueView!
}
