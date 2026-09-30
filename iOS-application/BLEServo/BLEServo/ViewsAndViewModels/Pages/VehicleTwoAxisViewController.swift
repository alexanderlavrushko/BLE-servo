import SwiftUI

struct VehicleTwoAxisView: View {
    let controlCenter: ServoControlCenter
    @State private var viewModel: VehicleTwoAxisViewModelImpl

    init(controlCenter: ServoControlCenter) {
        self.controlCenter = controlCenter
        _viewModel = State(initialValue: controlCenter.makeTwoAxisViewModel())
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                StatusView(viewModel: viewModel.statusViewModel)
                Spacer(minLength: 20)
                AxisView(viewModel: viewModel.drivingViewModel)
                    .frame(width: min(geometry.size.width * 0.5, 250), height: 112)
                AxisView(viewModel: viewModel.steeringViewModel)
                    .frame(width: min(geometry.size.width * 0.5, 250), height: 112)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .onChange(of: controlCenter.ble.channelsRevision) { _, _ in
            viewModel.channelsDidChange()
        }
    }
}
