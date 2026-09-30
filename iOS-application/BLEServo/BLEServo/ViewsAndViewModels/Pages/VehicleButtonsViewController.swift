import SwiftUI

struct VehicleButtonsView: View {
    let controlCenter: ServoControlCenter
    @State private var viewModel: VehicleButtonsViewModelImpl

    init(controlCenter: ServoControlCenter) {
        self.controlCenter = controlCenter
        _viewModel = State(initialValue: controlCenter.makeButtonsViewModel())
    }

    var body: some View {
        GeometryReader { geometry in
            let controlSize = min(geometry.size.width * 0.4, min(geometry.size.height * 0.45, 220))
            VStack {
                StatusView(viewModel: viewModel.statusViewModel)
                Spacer(minLength: 10)
                HStack(alignment: .bottom) {
                    ButtonsVAxisView(viewModel: viewModel.drivingViewModel)
                        .frame(width: controlSize / 2, height: controlSize)
                    Spacer(minLength: 0)
                    ButtonsHAxisView(viewModel: viewModel.steeringViewModel)
                        .frame(width: controlSize, height: controlSize / 2)
                }
                Spacer(minLength: 0)
            }
            .padding(20)
        }
        .onChange(of: controlCenter.ble.channelsRevision) { _, _ in
            viewModel.channelsDidChange()
        }
    }
}
