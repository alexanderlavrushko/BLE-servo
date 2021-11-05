//
//  AxisRenderValueView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 05/11/2021.
//

import UIKit

class AxisRenderValueView: UIView {
    var axisValue = Float(0) {
        didSet {
            setNeedsDisplay()
        }
    }
    var color = UIColor.systemGreen
    var cornerRedius = CGFloat(2)

    private let viewModel = AxisRenderValueViewModel()

    override func draw(_ rect: CGRect) {
        let displayRect = viewModel.computeRect(axisValue: axisValue, parentRect: rect)
        color.setFill()
        let roundedRect = UIBezierPath(roundedRect: displayRect, cornerRadius: cornerRedius)
        roundedRect.fill()
    }
}
