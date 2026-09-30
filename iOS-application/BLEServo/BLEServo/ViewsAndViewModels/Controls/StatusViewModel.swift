import Observation
import SwiftUI

@MainActor
@Observable
final class StatusViewModelImpl {
    private let model: BLEServoAdapter

    var status: String {
        model.statusStr.prefix(1).uppercased() + model.statusStr.dropFirst()
    }

    var statusColor: Color {
        if errorText != nil {
            return .red
        }
        return model.isConnected ? .green : .yellow
    }

    var errorText: String? {
        model.errorText
    }

    init(model: BLEServoAdapter) {
        self.model = model
    }

    func dismissError() {
        model.errorText = nil
    }
}
