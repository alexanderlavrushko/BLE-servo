//
//  StatusView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 01/11/2021.
//

import UIKit

@IBDesignable
class StatusView: UIViewWithNib {
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelStatusColor: UIView!
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var buttonDismissError: UIButton!

    var viewModel: StatusViewModel? { didSet { connectToViewModel() } }

    override var intrinsicContentSize: CGSize {
        let width = bounds.width
        let height = { () -> CGFloat in
            if labelError.isHidden {
                return labelError.frame.origin.y
            } else {
                return labelError.frame.origin.y + labelError.frame.height
            }
        }()
        return CGSize(width: width, height: height)
    }

    @IBAction func onTapDismissError(_ sender: Any) {
        viewModel?.dismissError()
    }
}

// MARK: - Private logic
private extension StatusView {
    private func connectToViewModel() {
        guard let viewModel = viewModel else {
            updateErrorText()
            return
        }

        viewModel.onStatusDidChange = { [weak self] in self?.labelStatus.text = $0 }
        labelStatus.text = viewModel.status

        viewModel.onStatusColorDidChange = { [weak self] in self?.labelStatusColor.backgroundColor = $0 }
        labelStatusColor.backgroundColor = viewModel.statusColor

        viewModel.onErrorTextDidChange = { [weak self] _ in self?.updateErrorText() }
        updateErrorText()
    }

    private func updateErrorText() {
        if let errorText = viewModel?.errorText {
            labelError.text = errorText
            labelError.isHidden = false
            buttonDismissError.isHidden = false
        } else {
            labelError.text = "No error"
            labelError.isHidden = true
            buttonDismissError.isHidden = true
        }
        invalidateIntrinsicContentSize()
    }
}
