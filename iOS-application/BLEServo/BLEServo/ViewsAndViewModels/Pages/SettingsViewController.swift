import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModelImpl

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                sectionLabel("Control type")
                Picker(
                    "Control type",
                    selection: Binding(
                        get: { viewModel.controlTypeIndex },
                        set: { viewModel.updateControlType($0) }
                    )
                ) {
                    Image("CarSliders").resizable().scaledToFit().tag(0)
                    Image("CarButtons").resizable().scaledToFit().tag(1)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(height: 56)

                sectionLabel("Driving")
                ChannelSettingsView(viewModel: viewModel.drivingViewModel)
                sectionLabel("Steering")
                ChannelSettingsView(viewModel: viewModel.steeringViewModel)
                sectionLabel("Configurations")

                VStack(alignment: .leading, spacing: 16) {
                    Button("Restore preset - my RC car") {
                        viewModel.restorePresetMyCar()
                    }
                    Button("Reset to defaults") {
                        viewModel.resetToDefaults()
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 100, alignment: .center)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .id(viewModel.revision)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15))
            .foregroundStyle(.secondary)
            .padding(.leading, 10)
    }
}
