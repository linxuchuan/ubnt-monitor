import SwiftUI

struct DeviceDetailView: View {
    let device: UbiquitiDevice
    @StateObject private var viewModel: DeviceDetailViewModel
    
    init(device: UbiquitiDevice) {
        self.device = device
        _viewModel = StateObject(wrappedValue: DeviceDetailViewModel(hostId: device.id))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeaderView(device: device, deviceCount: viewModel.deviceCount)
                
                Group {
                    switch viewModel.state {
                    case .idle, .loaded:
                        deviceDetailsList
                    case .loading:
                        LoadingView()
                    case .error:
                        ErrorView(message: viewModel.errorMessage ?? "Unknown error") {
                            Task {
                                await viewModel.loadDeviceDetails()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Device Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDeviceDetails()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - Subviews
    
    private var deviceDetailsList: some View {
        Group {
            if viewModel.deviceDetails.isEmpty {
                EmptyStateView()
            } else {
                ForEach(viewModel.deviceDetails) { detail in
                    DeviceDetailCard(device: detail)
                }
            }
        }
    }
}

// MARK: - Header View

private struct HeaderView: View {
    let device: UbiquitiDevice
    let deviceCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(device.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                StatusIndicator(status: device.status, size: 12)
            }
            
            HStack(spacing: 12) {
                Label(device.type ?? "Unknown", systemImage: "network")
                Text("•")
                Text("\(deviceCount) devices")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Device Detail Card

private struct DeviceDetailCard: View {
    let device: DeviceDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(device.displayName)
                        .font(.headline)
                    
                    Text(device.model)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusIndicator(status: device.deviceStatus, size: 12)
            }
            
            Divider()
            
            // Basic Info
            InfoGrid(items: [
                ("MAC Address", device.mac),
                ("IP Address", device.ip),
                ("Version", device.version),
                ("Product Line", device.productLine.capitalized)
            ])
            
            // Status Info
            InfoGrid(items: [
                ("Status", device.status.capitalized),
                ("Firmware", device.firmwareStatus),
                ("Managed", device.isManaged ? "Yes" : "No"),
                ("Console", device.isConsole ? "Yes" : "No")
            ])
            
            // Dates
            if let adoptionTime = device.adoptionTime,
               let startupTime = device.startupTime {
                InfoGrid(items: [
                    ("Adopted", adoptionTime.formattedDate()),
                    ("Started", startupTime.formattedDate())
                ])
            }
            
            // Update available
            if device.hasUpdate, let updateVersion = device.updateAvailable {
                UpdateAvailableView(version: updateVersion)
            }
            
            // Note
            if let note = device.note, !note.isEmpty {
                NoteView(text: note)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Supporting Views

private struct UpdateAvailableView: View {
    let version: String
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundColor(.orange)
            Text("Update available: \(version)")
                .font(.caption)
                .foregroundColor(.orange)
        }
    }
}

private struct NoteView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Notes")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(6)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "desktopcomputer")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No devices found")
                .font(.headline)
            
            Text("This host doesn't have any managed devices")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        DeviceDetailView(device: PreviewData.sampleDevice)
    }
}
