//
//  MainViewController.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 21/08/2021.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var labelState: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let center = ServoControlCenter.instance else {
            labelState.text = "Error: ServoControlCenter not initialized"
            return
        }

        let childVC = center.takeControlWithViewController()
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
        childVC.view.constraintToSuperview()
    }
}
