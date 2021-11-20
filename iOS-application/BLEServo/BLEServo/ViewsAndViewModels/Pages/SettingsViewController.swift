//
//  SettingsViewController.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 08/11/2021.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedControlControlType: UISegmentedControl!
    @IBOutlet weak var channelSettingsViewDriving: ChannelSettingsView!
    @IBOutlet weak var channelSettingsViewSteering: ChannelSettingsView!
    
    var viewModel: SettingsViewModel? { didSet { connectToViewModel() } }
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        connectToViewModel()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        if parent == nil {
            onDismiss?()
            onDismiss = nil
        }
    }

    @IBAction func onChangeControlType(_ sender: UISegmentedControl) {
        viewModel?.controlTypeIndex = sender.selectedSegmentIndex
    }

    @IBAction func onTapRestorePresetMyCar(_ sender: Any) {
        viewModel?.restorePresetMyCar()
    }

    @IBAction func onTapResetToDefaults(_ sender: Any) {
        viewModel?.resetToDefaults()
    }

    @objc
    func keyboardWillShow(_ notification: Notification) {
        guard let kbFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let kbHeight = kbFrameValue.cgRectValue.height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbHeight, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset

        let currentTextField = { () -> UITextField? in
            channelSettingsViewDriving.currentTextField ?? channelSettingsViewSteering.currentTextField
        }()
        if let currentTextField = currentTextField {
            scrollView.scrollRectToVisible(currentTextField.frame, animated: true)
        }
    }

    @objc
    func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

private extension SettingsViewController {
    func connectToViewModel() {
        reloadValues()
        viewModel?.onNeedToReloadValues = { [weak self] () -> Void in
            self?.reloadValues()
        }
    }

    func reloadValues() {
        guard let segmentedControlControlType = segmentedControlControlType else { return }

        channelSettingsViewDriving.viewModel = viewModel?.drivingViewModel
        channelSettingsViewSteering.viewModel = viewModel?.steeringViewModel

        if let viewModel = viewModel {
            segmentedControlControlType.removeAllSegments()
            let allImages = viewModel.allControlTypeImages
            for i in 0..<allImages.count {
                segmentedControlControlType.insertSegment(with: allImages[i], at: i, animated: false)
            }
            segmentedControlControlType.selectedSegmentIndex = viewModel.controlTypeIndex
        }
    }
}
