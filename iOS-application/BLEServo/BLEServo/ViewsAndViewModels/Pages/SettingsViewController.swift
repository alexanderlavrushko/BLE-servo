//
//  SettingsViewController.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 08/11/2021.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var segmentedControlControlType: UISegmentedControl!

    var viewModel: SettingsViewModel? { didSet { connectToViewModel() } }
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        connectToViewModel()
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
}

private extension SettingsViewController {
    func connectToViewModel() {
        guard let viewModel = viewModel else { return }
        guard let segmentedControlControlType = segmentedControlControlType else { return }
        segmentedControlControlType.removeAllSegments()
        let allImages = viewModel.allControlTypeImages
        for i in 0..<allImages.count {
            segmentedControlControlType.insertSegment(with: allImages[i], at: i, animated: false)
        }
        segmentedControlControlType.selectedSegmentIndex = viewModel.controlTypeIndex
    }
}
