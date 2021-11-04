//
//  ButtonsAxisViewModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 03/11/2021.
//

import Foundation

protocol ButtonsAxisViewModel: AnyObject {
    func positiveButtonDidPress()
    func positiveButtonDidRelease()
    func negativeButtonDidPress()
    func negativeButtonDidRelease()
}

class ButtonsAxisViewModelImpl: ButtonsAxisViewModel {
    // MARK: - ButtonsAxisViewModel implementation
    func positiveButtonDidPress() {
        if value < 0 {
            value = 0 // if direction is changed, react quickly
        }
        animateValue(to: 1)
    }

    func positiveButtonDidRelease() {
        animateValue(to: 0)
    }

    func negativeButtonDidPress() {
        if value > 0 {
            value = 0 // if direction is changed, react quickly
        }
        animateValue(to: -1)
    }

    func negativeButtonDidRelease() {
        animateValue(to: 0)
    }

    // MARK: - Internal logic
    private let model: ServoChannelModel
    private let converter: AxisConverter
    private let animator = ValueAnimator()
    private let animationSpeed = Float(2)

    private var value: Float {
        didSet {
            guard value != oldValue else { return }
            model.position = converter.axisToServo(value)
        }
    }

    init(model: ServoChannelModel, config: AxisOutputConfig) {
        self.model = model
        converter = AxisConverter(config)
        value = converter.servoToAxis(model.position)
        animateValue(to: 0)
    }
}

private extension ButtonsAxisViewModelImpl {
    func animateValue(to wantedValue: Float) {
        animator.animate(from: value, to: wantedValue, speed: animationSpeed) { [weak self] (currentValue) in
            self?.value = currentValue
        }
    }
}
