//
//  MainViewController.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 21/08/2021.
//

import UIKit

class MainViewController: UIViewController {

    var contentViewController: UIViewController?
    @IBOutlet weak var labelState: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadContent()
    }

    @IBAction func onTapSettings(_ sender: Any) {
        guard let center = ServoControlCenter.instance else { return }
        let settingsVC = center.makeSettingsViewController { [weak self] in
            self?.reloadContent()
        }
        show(settingsVC, sender: self)
    }
}

private extension MainViewController {
    func reloadContent() {
        removeContentController()
        guard let center = ServoControlCenter.instance else {
            labelState.text = "Error: ServoControlCenter not initialized"
            return
        }
        addContentController(center.takeControl())
    }

    func addContentController(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        vc.view.constraintToSuperview()
        contentViewController = vc
    }

    func removeContentController() {
        guard let vc = contentViewController else { return }
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
}
