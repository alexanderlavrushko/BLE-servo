//
//  ServoFactory.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 22/08/2021.
//

import Foundation

class ServoFactory {
    static var instance: ServoFactory?

    private init() {}

    static func create() {
        guard instance == nil else { return }
        instance = ServoFactory()
    }

    static func destroy() {
        instance = nil
    }

    func createServo() -> ServoModelProtocol {
        BLEServo()
    }
}
