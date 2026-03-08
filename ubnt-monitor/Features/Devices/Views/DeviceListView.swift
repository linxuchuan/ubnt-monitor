import SwiftUI

/// 云端设备列表页面
/// 仅用于互联网模式（云端 API）
struct DeviceListView: View {
    @StateObject private var viewModel = DeviceListViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loaded:
                    deviceList
                case .loading:
                    loadingView
                case .error:
                    errorView
                }
            }
            .navigationTitle("云端设备")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    modeBadge
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        refreshButton
                        settingsButton
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onAppear {
                if viewModel.devices.isEmpty && viewModel.state != .loading {
                    Task {
                        await viewModel.loadDevices()
                    }
                }
            }
        }
    }
    
    private var modeBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "cloud.fill")
            Text("云端")
                .font(.caption)
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.15))
        )
    }
    
    private var settingsButton: some View {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "gear")
        }
    }
    
    // MARK: - Subviews
    
    private var deviceList: some View {
        Group {
            if viewModel.devices.isEmpty {
                ContentUnavailableView(
                    "No Devices",
                    systemImage: "network",
                    description: Text("No UBNT devices found in your account")
                )
            } else {
                List(viewModel.devices) { device in
                    NavigationLink(value: device) {
                        DeviceCardView(device: device)
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: UbiquitiDevice.self) { device in
                    DeviceDetailView(device: device)
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading devices...")
                .foregroundColor(.secondary)
        }
    }
    
    private var errorView: some View {
        ContentUnavailableView {
            Label("Connection Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.loadDevices()
                }
            }
        }
    }
    
    private var refreshButton: some View {
        Button {
            Task {
                await viewModel.refresh()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
        .disabled(viewModel.isLoading)
    }
}

#Preview {
    DeviceListView()
}
