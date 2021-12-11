//
//  ChannelSettingsView.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 15/11/2021.
//

import UIKit

@IBDesignable
class ChannelSettingsView: UIViewWithNib {
    var content: ChannelSettingsContentView { contentView as! ChannelSettingsContentView }
    var viewModel: ChannelSettingsViewModel? { didSet { connectToViewModel() } }
    var currentTextField: UITextField?

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
        content.textFieldMappingNegative.text = vm.updateMappingNegative(wantedValue: nil)
        content.textFieldMappingCenter.text = vm.updateMappingCenter(wantedValue: nil)
        content.textFieldMappingPositive.text = vm.updateMappingPositive(wantedValue: nil)
        content.textFieldChannelIndex.text = vm.updateChannelIndex(wantedValue: nil)
        content.textFieldAnimationSpeed.text = vm.updateAnimationSpeed(wantedValue: nil)
    }
}

class ChannelSettingsContentView: UIView {
    @IBOutlet weak var textFieldMappingNegative: NumericTextField!
    @IBOutlet weak var textFieldMappingCenter: NumericTextField!
    @IBOutlet weak var textFieldMappingPositive: NumericTextField!
    @IBOutlet weak var textFieldChannelIndex: NumericTextField!
    @IBOutlet weak var textFieldAnimationSpeed: NumericTextField!
}
