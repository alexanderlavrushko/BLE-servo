//
//  ChannelSettingsView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 15/11/2021.
//

import UIKit

class ChannelSettingsView: UIViewWithNib {
    @IBOutlet weak var textFieldMappingNegative: NumericTextField!
    @IBOutlet weak var textFieldMappingCenter: NumericTextField!
    @IBOutlet weak var textFieldMappingPositive: NumericTextField!
    @IBOutlet weak var textFieldChannelIndex: NumericTextField!
    @IBOutlet weak var textFieldAnimationSpeed: NumericTextField!

    var currentTextField: UITextField?
    var viewModel: ChannelSettingsViewModel? { didSet { connectToViewModel() } }

    @IBAction func onTextFieldDidEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }

    @IBAction func onEditingDidBegin(_ sender: UITextField) {
        currentTextField = sender
    }

    @IBAction func onMappingNegativeEditingDidEnd(_ sender: UITextField) {
        commonEditingDidEnd()
        sender.text = viewModel?.updateMappingNegative(wantedValue: sender.text)
    }

    @IBAction func onMappingCenterEditingDidEnd(_ sender: UITextField) {
        commonEditingDidEnd()
        sender.text = viewModel?.updateMappingCenter(wantedValue: sender.text)
    }

    @IBAction func onMappingPositiveEditingDidEnd(_ sender: UITextField) {
        commonEditingDidEnd()
        sender.text = viewModel?.updateMappingPositive(wantedValue: sender.text)
    }

    @IBAction func onChannelIndexEditingDidEnd(_ sender: UITextField) {
        commonEditingDidEnd()
        sender.text = viewModel?.updateChannelIndex(wantedValue: sender.text)
    }

    @IBAction func onAnimationSpeedEditingDidEnd(_ sender: UITextField) {
        commonEditingDidEnd()
        sender.text = viewModel?.updateAnimationSpeed(wantedValue: sender.text)
    }
}

private extension ChannelSettingsView {
    func commonEditingDidEnd() {
        currentTextField = nil
    }

    func connectToViewModel() {
        guard let vm = viewModel else { return }
        textFieldMappingNegative.text = vm.updateMappingNegative(wantedValue: nil)
        textFieldMappingCenter.text = vm.updateMappingCenter(wantedValue: nil)
        textFieldMappingPositive.text = vm.updateMappingPositive(wantedValue: nil)
        textFieldChannelIndex.text = vm.updateChannelIndex(wantedValue: nil)
        textFieldAnimationSpeed.text = vm.updateAnimationSpeed(wantedValue: nil)
    }
}
