//
//  AxisView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 30/10/2021.
//

import UIKit

@IBDesignable
class AxisView: UIViewWithNib {
    var content: AxisContentView { contentView as! AxisContentView }
    var viewModel: AxisViewModel? { didSet { connectToViewModel() } }

    override var intrinsicContentSize: CGSize {
        CGSize(width: bounds.width, height: content.backgroundView.bounds.height + content.labelName.bounds.height + content.constraintLabelToView.constant)
    }

    @IBAction func onSliderDidChange(_ sender: Any) {
        viewModel?.value = content.slider.value
    }

    @IBAction func onSliderTouchUp(_ sender: Any) {
        viewModel?.userInteractionDidEnd()
    }
}

// MARK: - Private logic
private extension AxisView {
    private func connectToViewModel() {
        guard let viewModel = viewModel else {
            content.labelValue.text = "disconnected"
            return
        }
        content.labelName.text = viewModel.axisName
        content.labelValue.text = viewModel.displayValue
        viewModel.onDisplayValueDidChange = { [weak self] (displayValue: String) in
            self?.content.labelValue.text = viewModel.displayValue
        }
        content.slider.value = viewModel.value
        viewModel.onValueDidChange = { [weak self] (value: Float) in
            self?.content.slider.value = value
        }
    }
}

class AxisContentView: UIView {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var constraintLabelToView: NSLayoutConstraint!
}
