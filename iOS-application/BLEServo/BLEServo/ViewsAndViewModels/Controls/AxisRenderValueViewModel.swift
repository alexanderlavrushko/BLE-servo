//
//  AxisRenderValueViewModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 05/11/2021.
//

import UIKit

class AxisRenderValueViewModel {
    func computeRect(axisValue: Float, parentRect: CGRect) -> CGRect {
        guard axisValue != 0 else { return .zero }
        if parentRect.isVertical {
            return computeVertical(axisValue: axisValue, parentRect: parentRect)
        } else {
            return computeHorizontal(axisValue: axisValue, parentRect: parentRect)
        }
    }
}

private extension AxisRenderValueViewModel {
    func computeVertical(axisValue: Float, parentRect: CGRect) -> CGRect {
        let center = parentRect.origin.y + parentRect.size.height / 2
        let amplitude = parentRect.size.height / 2
        let height = amplitude * Double(abs(axisValue))
        let y = { () -> CGFloat in
            if axisValue < 0 {
                return center
            } else {
                return center - height
            }
        }()
        return CGRect(x: parentRect.origin.x, y: y, width: parentRect.width, height: height)
    }

    func computeHorizontal(axisValue: Float, parentRect: CGRect) -> CGRect {
        let center = parentRect.origin.x + parentRect.size.width / 2
        let amplitude = parentRect.size.width / 2
        let width = amplitude * Double(abs(axisValue))
        let x = { () -> CGFloat in
            if axisValue < 0 {
                return center - width
            } else {
                return center
            }
        }()
        return CGRect(x: x, y: parentRect.origin.y, width: width, height: parentRect.height)
    }
}

private extension CGRect {
    var isVertical: Bool {
        size.width < size.height
    }
}
