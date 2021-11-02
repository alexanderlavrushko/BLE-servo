//
//  ServoModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 22/08/2021.
//

import Foundation

/// This protocol defines how ViewModel communicates with Model. Just to make the dependency clear.
protocol ServoModel: AnyObject {
    var statusModel: StatusModel { get }

    var channels: [ServoChannelModel] { get }
    var onChannelsDidChange: (([ServoChannelModel]) -> Void)? { get set }
}

/// This protocol defines how ViewModel communicates with Model. Just to make the dependency clear.
protocol StatusModel: AnyObject {
    var isConnected: Bool { get }
    var onIsConnectedDidChange: ((Bool) -> Void)? { get set }

    var statusStr: String { get }
    var onStatusStrDidChange: ((String) -> Void)? { get set }

    var onError: ((String) -> Void)? { get set }
}

/// This protocol defines how ViewModel communicates with Model. Just to make the dependency clear.
protocol ServoChannelModel: AnyObject {
    var position: UInt8 { get set }
}
