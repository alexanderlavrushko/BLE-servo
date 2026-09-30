import SwiftUI

struct AxisView: View {
    @Bindable var viewModel: AxisViewModelImpl

    var body: some View {
        VStack(spacing: 4) {
            Text(viewModel.axisName)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 15)

            VStack(spacing: 8) {
                Text(viewModel.displayValue)
                    .font(.system(size: 17))
                Slider(
                    value: Binding(
                        get: { viewModel.value },
                        set: { viewModel.value = $0 }
                    ),
                    in: -1...1,
                    onEditingChanged: { isEditing in
                        if !isEditing { viewModel.userInteractionDidEnd() }
                    }
                )
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
            .padding(.top, 12)
            .frame(height: 94)
            .frame(maxWidth: .infinity)
            .background(.secondarySystemGroupedBackground, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
