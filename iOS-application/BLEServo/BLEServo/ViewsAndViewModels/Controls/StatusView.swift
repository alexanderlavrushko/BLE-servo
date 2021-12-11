//
//  StatusView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 01/11/2021.
//

import UIKit

@IBDesignable
class StatusView: UIViewWithNib {
    var content: StatusContentView { contentView as! StatusContentView }
    var viewModel: StatusViewModel? { didSet { connectToViewModel() } }

    override var intrinsicContentSize: CGSize {
        let width = bounds.width
        let height = { () -> CGFloat in
            var height = content.labelTitle.intrinsicContentSize.height + content.constraintTitleToView.constant + content.backgroundView.intrinsicContentSize.height
            if !content.labelError.isHidden {
                height += content.constraintViewToError.constant + content.labelError.intrinsicContentSize.height
            }
            return height
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

        viewModel.onStatusDidChange = { [weak self] in self?.content.labelStatus.text = $0 }
        content.labelStatus.text = viewModel.status

        viewModel.onStatusColorDidChange = { [weak self] in self?.content.labelStatusColor.backgroundColor = $0 }
        content.labelStatusColor.backgroundColor = viewModel.statusColor

        viewModel.onErrorTextDidChange = { [weak self] _ in self?.updateErrorText() }
        updateErrorText()
    }

    private func updateErrorText() {
        if let errorText = viewModel?.errorText {
            content.labelError.text = errorText
            content.labelError.isHidden = false
            content.buttonDismissError.isHidden = false
        } else {
            content.labelError.text = "No error"
            content.labelError.isHidden = true
            content.buttonDismissError.isHidden = true
        }
        invalidateIntrinsicContentSize()
    }
}

class StatusContentView: UIView {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var constraintTitleToView: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelStatusColor: UIView!
    @IBOutlet weak var constraintViewToError: NSLayoutConstraint!
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var buttonDismissError: UIButton!
}
