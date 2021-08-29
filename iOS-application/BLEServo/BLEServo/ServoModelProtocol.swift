//
//  ServoProtocols.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 22/08/2021.
//

import Foundation

protocol ServoModelProtocol: AnyObject {
    var isConnected: Bool { get }
    var onIsConnectedDidChange: ((Bool) -> Void)? { get set }

    var stateStr: String { get }
    var onStateStrDidChange: ((String) -> Void)? { get set }

    var channelCount: Int { get }
    var onChannelCountDidChange: ((Int) -> Void)? { get set }

    var positions: [UInt8] { get set }
    var onPositionsDidChange: (([UInt8]) -> Void)? { get set }

    var onError: ((String) -> Void)? { get set }
}
