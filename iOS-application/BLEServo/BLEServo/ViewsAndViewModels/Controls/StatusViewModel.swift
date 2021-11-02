//
//  StatusViewModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 01/11/2021.
//

import UIKit

protocol StatusViewModel: AnyObject {
    var status: String { get }
    var onStatusDidChange: ((String) -> Void)? { get set }

    var statusColor: UIColor { get }
    var onStatusColorDidChange: ((UIColor) -> Void)? { get set }

    var errorText: String? { get }
    var onErrorTextDidChange: ((String?) -> Void)? { get set }

    func dismissError()
}

class StatusViewModelImpl: StatusViewModel {
    // MARK: - StatusViewModel implementation
    var status: String = "" { didSet { onStatusDidChange?(status) } }
    var onStatusDidChange: ((String) -> Void)?

    var statusColor: UIColor = .systemYellow { didSet { onStatusColorDidChange?(statusColor) } }
    var onStatusColorDidChange: ((UIColor) -> Void)?

    var errorText: String? { didSet { onErrorTextDidChange?(errorText) } }
    var onErrorTextDidChange: ((String?) -> Void)?

    func dismissError() {
        errorText = nil
        reloadStatusColor()
    }

    // MARK: - Internal logic
    private let model: StatusModel

    init(model: StatusModel) {
        self.model = model
        connectToModel()
    }
}

private extension StatusViewModelImpl {
    func connectToModel() {
        model.onIsConnectedDidChange = { [weak self] (_) in
            self?.reloadStatusColor()
        }
        model.onStatusStrDidChange = { [weak self] (_) in
            self?.reloadStatus()
        }
        model.onError = { [weak self] (errorText) in
            self?.errorText = errorText
            self?.reloadStatusColor()
        }
        errorText = nil
        reloadStatus()
        reloadStatusColor()
    }

    func reloadStatus() {
        let statusStr = model.statusStr
        status = statusStr.prefix(1).uppercased() + statusStr.dropFirst()
    }

    func reloadStatusColor() {
        statusColor = { () -> UIColor in
            if errorText != nil {
                return .systemRed
            } else if model.isConnected {
                return .systemGreen
            }
            return .systemYellow
        }()
    }
}
