import SwiftUI

struct MainView: View {
    let controlCenter: ServoControlCenter

    var body: some View {
        NavigationStack {
            Group {
                if controlCenter.settingsViewModel.controlTypeIndex == 0 {
                    VehicleTwoAxisView(controlCenter: controlCenter)
                } else {
                    VehicleButtonsView(controlCenter: controlCenter)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("BLE Servo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(viewModel: controlCenter.settingsViewModel)
                            .navigationTitle("Settings")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 18))
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
    }
}
