//
//  ViewController.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 21/08/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var labelState: UILabel!
    @IBOutlet weak var labelServo1: UILabel!
    @IBOutlet weak var sliderServo1: UISlider!
    @IBOutlet weak var labelServo2: UILabel!
    @IBOutlet weak var sliderServo2: UISlider!
    @IBOutlet weak var switchInvertServo1: UISwitch!
    @IBOutlet weak var switchInvertServo2: UISwitch!

    private var servo: ServoModelProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let factory = ServoFactory.instance else {
            labelState.text = "No ServoFactory"
            return
        }

        servo = factory.createServo()
        subscribeToServoChanges()
        refreshServoValues()
    }

    @IBAction func onChangeSliderServo1(_ sender: Any) {
        servo.positions[0] = servoValue1
        labelServo1.text = "\(servoValue1)"
    }

    @IBAction func onChangeSliderServo2(_ sender: Any) {
        servo.positions[1] = servoValue2
        labelServo2.text = "\(servoValue2)"
    }
}

private extension ViewController {
    func subscribeToServoChanges() {
        servo.onIsConnectedDidChange = { [weak self] (isConnected) in
            guard let self = self else { return }
            self.sliderServo1.isEnabled = isConnected
            self.sliderServo2.isEnabled = isConnected
        }

        servo.onStateStrDidChange = { [weak self] (stateStr) in
            guard let self = self else { return }
            self.labelState.text = stateStr
        }

        servo.onPositionsDidChange = { [weak self] (positions) in
            guard let self = self,
                  positions.count >= 2 else {
                return
            }

            self.servoValue1 = positions[0]
            self.servoValue2 = positions[1]
        }
    }

    func refreshServoValues() {
        servo.onIsConnectedDidChange?(servo.isConnected)
        servo.onStateStrDidChange?(servo.stateStr)
        servo.onPositionsDidChange?(servo.positions)
    }

    var servoValue1: UInt8 {
        get {
            let value = UInt8(sliderServo1.value)
            let invert = switchInvertServo1.isOn
            return invert ? 255 - value : value
        }
        set {
            let invert = switchInvertServo1.isOn
            let value = invert ? 255 - newValue : newValue
            sliderServo1.value = Float(value)
            labelServo1.text = "\(value)"
        }
    }

    var servoValue2: UInt8 {
        get {
            let value = UInt8(sliderServo2.value)
            let invert = switchInvertServo2.isOn
            return invert ? 255 - value : value
        }
        set {
            let invert = switchInvertServo2.isOn
            let value = invert ? 255 - newValue : newValue
            sliderServo2.value = Float(value)
            labelServo2.text = "\(value)"
        }
    }
}
