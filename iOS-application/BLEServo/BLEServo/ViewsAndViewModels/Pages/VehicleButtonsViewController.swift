//
//  VehicleButtonsViewController.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 03/11/2021.
//

import UIKit

class VehicleButtonsViewController: UIViewController {
    // MARK: - Load from nib
    class private var nibName: String {
        NSStringFromClass(self).components(separatedBy: ".").last!
    }

    class func loadFromNib() -> VehicleButtonsViewController {
        VehicleButtonsViewController(nibName: nibName, bundle: Bundle(for: self))
    }

    // MARK: - Internal logic
    @IBOutlet weak var statusView: StatusView!
    @IBOutlet weak var axisViewDriving: ButtonsVAxisView!
    @IBOutlet weak var axisViewSteering: ButtonsHAxisView!

    var viewModel: VehicleButtonsViewModel? { didSet { connectToViewModel() } }

    func connectToViewModel() {
        statusView?.viewModel = viewModel?.statusViewModel

        axisViewDriving?.viewModel = viewModel?.drivingViewModel
        viewModel?.onDrivingViewModelDidChange = { [weak self] (driving) in
            self?.axisViewDriving?.viewModel = driving
        }

        axisViewSteering?.viewModel = viewModel?.steeringViewModel
        viewModel?.onSteeringViewModelDidChange = { [weak self] (steering) in
            self?.axisViewSteering?.viewModel = steering
        }
    }

    override func viewDidLoad() {
        connectToViewModel()
    }
}
