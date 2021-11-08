//
//  VehicleTwoAxisViewController.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 01/11/2021.
//

import UIKit

class VehicleTwoAxisViewController: UIViewController {
    @IBOutlet weak var statusView: StatusView!
    @IBOutlet weak var axisViewDriving: AxisView!
    @IBOutlet weak var axisViewSteering: AxisView!

    var viewModel: VehicleTwoAxisViewModel? { didSet { connectToViewModel() } }

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
        super.viewDidLoad()
        connectToViewModel()
    }
}
