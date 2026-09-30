import SwiftUI

struct ChannelSettingsView: View {
    @Bindable var viewModel: ChannelSettingsViewModelImpl
    @FocusState private var focusedField: Field?
    @State private var negativeValue: String
    @State private var centerValue: String
    @State private var positiveValue: String
    @State private var channelIndex: String
    @State private var animationSpeed: String

    private enum Field: Hashable {
        case negative, center, positive, channelIndex, animationSpeed
    }

    init(viewModel: ChannelSettingsViewModelImpl) {
        self.viewModel = viewModel
        _negativeValue = State(initialValue: viewModel.updateMappingNegative(wantedValue: nil))
        _centerValue = State(initialValue: viewModel.updateMappingCenter(wantedValue: nil))
        _positiveValue = State(initialValue: viewModel.updateMappingPositive(wantedValue: nil))
        _channelIndex = State(initialValue: viewModel.updateChannelIndex(wantedValue: nil))
        _animationSpeed = State(initialValue: viewModel.updateAnimationSpeed(wantedValue: nil))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Axis mapping")
                .font(.system(size: 17))

            HStack(spacing: 2) {
                mappingField("-1", value: $negativeValue, field: .negative)
                mappingField("0", value: $centerValue, field: .center)
                mappingField("1", value: $positiveValue, field: .positive)
            }

            Text("Input range [-1;1] - output [0;255]")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            settingField("Channel index", value: $channelIndex, field: .channelIndex)
            settingField("Animation speed", value: $animationSpeed, field: .animationSpeed)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .onChange(of: focusedField) { oldField, _ in
            if let oldField { commit(oldField) }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    if let focusedField { commit(focusedField) }
                    focusedField = nil
                }
            }
        }
    }

    private func mappingField(_ label: String, value: Binding<String>, field: Field) -> some View {
        VStack(spacing: 0) {
            TextField("", text: value)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: field)
                .onSubmit { commit(field) }
            Text(label)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func settingField(_ label: String, value: Binding<String>, field: Field) -> some View {
        HStack {
            Text(label)
            TextField("", text: value)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: field)
                .onSubmit { commit(field) }
                .frame(width: 108)
        }
    }

    private func commit(_ field: Field) {
        switch field {
        case .negative: negativeValue = viewModel.updateMappingNegative(wantedValue: negativeValue)
        case .center: centerValue = viewModel.updateMappingCenter(wantedValue: centerValue)
        case .positive: positiveValue = viewModel.updateMappingPositive(wantedValue: positiveValue)
        case .channelIndex: channelIndex = viewModel.updateChannelIndex(wantedValue: channelIndex)
        case .animationSpeed: animationSpeed = viewModel.updateAnimationSpeed(wantedValue: animationSpeed)
        }
    }
}
