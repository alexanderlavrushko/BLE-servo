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
        let newValue = UInt8(sliderServo1.value)
        servo.positions[0] = newValue
        labelServo1.text = "\(newValue)"
    }

    @IBAction func onChangeSliderServo2(_ sender: Any) {
        let newValue = UInt8(sliderServo2.value)
        servo.positions[1] = newValue
        labelServo2.text = "\(newValue)"
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

            self.sliderServo1.value = Float(positions[0])
            self.labelServo1.text = "\(positions[0])"

            self.sliderServo2.value = Float(positions[1])
            self.labelServo2.text = "\(positions[1])"
        }
    }

    func refreshServoValues() {
        servo.onIsConnectedDidChange?(servo.isConnected)
        servo.onStateStrDidChange?(servo.stateStr)
        servo.onPositionsDidChange?(servo.positions)
    }
}
