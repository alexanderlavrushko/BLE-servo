import SwiftUI

struct ButtonsVAxisView: View {
    @Bindable var viewModel: ButtonsAxisViewModelImpl

    var body: some View {
        HStack(spacing: 8) {
            VStack(spacing: 0) {
                DirectionButton(symbol: "arrow.up.circle") {
                    viewModel.positiveButtonDidPress()
                } release: {
                    viewModel.positiveButtonDidRelease()
                }
                DirectionButton(symbol: "arrow.down.circle") {
                    viewModel.negativeButtonDidPress()
                } release: {
                    viewModel.negativeButtonDidRelease()
                }
            }
            .aspectRatio(0.5, contentMode: .fit)

            AxisRenderValueView(axisValue: viewModel.value, isVertical: true)
                .frame(width: 8)
        }
        .aspectRatio(0.5, contentMode: .fit)
    }
}
