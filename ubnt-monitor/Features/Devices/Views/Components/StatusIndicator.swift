import SwiftUI

struct StatusIndicator: View {
    let status: DeviceStatus
    var size: CGFloat = 10
    
    var body: some View {
        Circle()
            .fill(statusColor)
            .frame(width: size, height: size)
    }
    
    private var statusColor: Color {
        switch status.color {
        case .green: return .green
        case .red: return .red
        case .orange: return .orange
        case .gray: return .gray
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        StatusIndicator(status: .connected)
        StatusIndicator(status: .disconnected)
        StatusIndicator(status: .blocked)
        StatusIndicator(status: .adopting)
    }
}
