import SwiftUI

struct ButtonsHAxisView: View {
    @Bindable var viewModel: ButtonsAxisViewModelImpl

    var body: some View {
        VStack(spacing: 8) {
            AxisRenderValueView(axisValue: viewModel.value, isVertical: false)
                .frame(height: 8)

            HStack(spacing: 0) {
                DirectionButton(symbol: "arrow.left.circle") {
                    viewModel.negativeButtonDidPress()
                } release: {
                    viewModel.negativeButtonDidRelease()
                }
                DirectionButton(symbol: "arrow.right.circle") {
                    viewModel.positiveButtonDidPress()
                } release: {
                    viewModel.positiveButtonDidRelease()
                }
            }
        }
        .aspectRatio(2, contentMode: .fit)
    }
}

struct DirectionButton: View {
    let symbol: String
    let press: () -> Void
    let release: () -> Void
    @State private var isPressed = false

    var body: some View {
        Image(systemName: symbol)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.tint)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0, maximumDistance: 50, pressing: { pressing in
                guard pressing != isPressed else { return }
                isPressed = pressing
                if pressing { press() } else { release() }
            }, perform: {})
            .accessibilityLabel(accessibilityName)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                press()
                release()
            }
    }

    private var accessibilityName: String {
        switch symbol {
        case "arrow.left.circle": return "Left"
        case "arrow.right.circle": return "Right"
        case "arrow.up.circle": return "Up"
        case "arrow.down.circle": return "Down"
        default: return "Direction"
        }
    }
}
