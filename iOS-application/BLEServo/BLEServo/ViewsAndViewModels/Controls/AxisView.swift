//
//  AxisView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 30/10/2021.
//

import UIKit

@IBDesignable
class AxisView: UIViewWithNib {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var constraintLabelToView: NSLayoutConstraint!

    var viewModel: AxisViewModel? { didSet { connectToViewModel() } }

    override var intrinsicContentSize: CGSize {
        CGSize(width: bounds.width, height: backgroundView.bounds.height + labelName.bounds.height + constraintLabelToView.constant)
    }

    @IBAction func onSliderDidChange(_ sender: Any) {
        viewModel?.value = slider.value
    }

    @IBAction func onSliderTouchUp(_ sender: Any) {
        viewModel?.userInteractionDidEnd()
    }
}

// MARK: - Private logic
private extension AxisView {
    private func connectToViewModel() {
        guard let viewModel = viewModel else {
            labelValue.text = "disconnected"
            return
        }
        labelName.text = viewModel.axisName
        labelValue.text = viewModel.displayValue
        viewModel.onDisplayValueDidChange = { [weak self] (displayValue: String) in
            self?.labelValue.text = viewModel.displayValue
        }
        slider.value = viewModel.value
        viewModel.onValueDidChange = { [weak self] (value: Float) in
            self?.slider.value = value
        }
    }
}
