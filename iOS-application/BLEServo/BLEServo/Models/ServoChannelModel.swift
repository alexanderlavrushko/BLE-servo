//
//  ServoChannelModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 31/10/2021.
//

import Foundation

class ServoChannelModelImpl: ServoChannelModel {
    // MARK: - ServoChannelModel implementation
    var position: UInt8 {
        get { positionInternal }
        set {
            positionInternal = newValue
            DispatchQueue.main.async {
                self.onUserDidChangePosition(self.position)
            }
        }
    }

    // MARK: - Internal logic
    private var positionInternal: UInt8
    private var onUserDidChangePosition: ((_ position: UInt8) -> Void)

    init(position: UInt8, updateHandler: @escaping (_ position: UInt8) -> Void) {
        positionInternal = position
        onUserDidChangePosition = updateHandler
    }
}

class ServoChannelModelStub: ServoChannelModel {
    // MARK: - ServoChannelModel implementation
    var position = UInt8(127)
}
