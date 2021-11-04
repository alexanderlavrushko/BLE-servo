//
//  ValueAnimator.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 04/11/2021.
//

import Foundation

class ValueAnimator {
    private let timeInterval = TimeInterval(1.0 / 60)
    private var timer: Timer?

    func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }

    func animate(from: Float, to: Float, speed: Float, block: @escaping ((Float) -> Void)) {
        var currentValue = from
        let wantedValue = to

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { (timer) in
            guard currentValue != wantedValue else {
                timer.invalidate()
                return
            }
            let difference = wantedValue - currentValue
            let direction = Double(difference > 0 ? 1 : -1)
            let deltaMove = Float(direction * timer.timeInterval * Double(speed))

            let newValue = { () -> Float in
                if abs(deltaMove) < abs(difference) {
                    return currentValue + deltaMove
                } else {
                    return wantedValue
                }
            }()
            currentValue = newValue
            block(currentValue)
        }
    }
}
