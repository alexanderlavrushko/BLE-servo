import Foundation

@MainActor
final class ValueAnimator {
    private let timeInterval = TimeInterval(1.0 / 60)
    private var timer: Timer?
    private var currentValue: Float = 0
    private var wantedValue: Float = 0
    private var speed: Float = 0
    private var update: (@MainActor (Float) -> Void)?

    func stopAnimation() {
        timer?.invalidate()
        timer = nil
        update = nil
    }

    func animate(from: Float, to: Float, speed: Float, block: @escaping @MainActor (Float) -> Void) {
        stopAnimation()
        currentValue = from
        wantedValue = to
        self.speed = speed
        update = block
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] timer in
            guard self != nil else {
                timer.invalidate()
                return
            }
            Task { @MainActor [weak self] in self?.advance() }
        }
    }

    private func advance() {
        guard currentValue != wantedValue else {
            stopAnimation()
            return
        }

        let difference = wantedValue - currentValue
        let direction: Float = difference > 0 ? 1 : -1
        let deltaMove = Float(timeInterval) * speed * direction
        currentValue = abs(deltaMove) < abs(difference) ? currentValue + deltaMove : wantedValue
        update?(currentValue)
    }
}
