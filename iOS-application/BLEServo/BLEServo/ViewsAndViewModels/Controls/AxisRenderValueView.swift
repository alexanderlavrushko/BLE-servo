import SwiftUI

struct AxisRenderValueView: View {
    let axisValue: Float
    let isVertical: Bool

    var body: some View {
        GeometryReader { geometry in
            let extent = (isVertical ? geometry.size.height : geometry.size.width) * CGFloat(abs(axisValue)) / 2
            RoundedRectangle(cornerRadius: 2)
                .fill(.green)
                .frame(
                    width: isVertical ? geometry.size.width : extent,
                    height: isVertical ? extent : geometry.size.height
                )
                .position(
                    x: isVertical ? geometry.size.width / 2 : geometry.size.width / 2 + CGFloat(axisValue) * geometry.size.width / 4,
                    y: isVertical ? geometry.size.height / 2 - CGFloat(axisValue) * geometry.size.height / 4 : geometry.size.height / 2
                )
        }
        .accessibilityHidden(true)
    }
}
