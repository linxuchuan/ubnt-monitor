import SwiftUI

struct DeviceCardView: View {
    let device: UbiquitiDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(device.displayName)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(device.type ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                StatusIndicator(status: device.status)
                Text(device.status.displayName)
                    .foregroundColor(statusColor)
                Spacer()
                Text(device.ipAddress ?? "N/A")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Owner: \(device.owner == true ? "Yes" : "No")")
                    .font(.caption)
                Spacer()
                if let registrationTime = device.registrationTime {
                    Text("Registered: \(registrationTime.formattedDate())")
                        .font(.caption)
                }
            }
            
            if let lastChange = device.lastConnectionStateChange {
                Text("Last Change: \(lastChange.formattedDate())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var statusColor: Color {
        switch device.status.color {
        case .green: return .green
        case .red: return .red
        case .orange: return .orange
        case .gray: return .secondary
        }
    }
}

#Preview {
    DeviceCardView(device: PreviewData.sampleDevice)
        .padding()
}
