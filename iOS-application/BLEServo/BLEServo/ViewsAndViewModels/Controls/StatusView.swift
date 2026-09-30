import SwiftUI

struct StatusView: View {
    @Bindable var viewModel: StatusViewModelImpl

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Connectivity status")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .padding(.leading, 15)

            HStack(spacing: 10) {
                Circle()
                    .fill(viewModel.statusColor)
                    .frame(width: 20, height: 20)
                Text(viewModel.status)
                    .font(.system(size: 17))
            }
            .frame(maxWidth: .infinity, minHeight: 41)
            .background(.secondarySystemGroupedBackground, in: RoundedRectangle(cornerRadius: 12))

            if let error = viewModel.errorText {
                HStack(alignment: .center) {
                    Text(error)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("Dismiss") { viewModel.dismissError() }
                }
                .padding(.horizontal, 15)
                .padding(.top, 4)
            }
        }
    }
}
