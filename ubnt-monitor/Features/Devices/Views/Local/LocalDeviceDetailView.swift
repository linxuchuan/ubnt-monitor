import SwiftUI

/// 局域网设备详情页面
struct LocalDeviceDetailView: View {
    @StateObject private var viewModel: LocalDeviceDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(device: LocalDevice, siteId: String) {
        _viewModel = StateObject(wrappedValue: LocalDeviceDetailViewModel(device: device, siteId: siteId))
    }
    
    var body: some View {
        NavigationStack {
            List {
                // 基本信息
                basicInfoSection
                
                // 状态信息
                statusSection
                
                // 统计信息
                if viewModel.statistics != nil {
                    statisticsSection
                }
                
                // 端口信息
                if let ports = viewModel.device.interfaces?.ports, !ports.isEmpty {
                    portsSection(ports: ports)
                }
                
                // 射频信息
                if let radios = viewModel.device.interfaces?.radios, !radios.isEmpty {
                    radiosSection(radios: radios)
                }
                
                // 操作按钮
                actionsSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle(viewModel.device.name ?? viewModel.device.model)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .refreshable {
                await viewModel.loadDeviceDetail()
                await viewModel.loadStatistics()
            }
            .task {
                await viewModel.loadDeviceDetail()
                await viewModel.loadStatistics()
            }
            .alert("确认重启", isPresented: $viewModel.showRestartConfirmation) {
                Button("取消", role: .cancel) { }
                Button("重启", role: .destructive) {
                    Task {
                        await viewModel.restartDevice()
                    }
                }
            } message: {
                Text("确定要重启设备 \(viewModel.device.name ?? viewModel.device.model) 吗？")
            }
            .alert("重启成功", isPresented: $viewModel.showRestartSuccess) {
                Button("确定") { }
            } message: {
                Text("设备重启命令已发送")
            }
            .alert("重启失败", isPresented: $viewModel.showRestartError) {
                Button("确定") { }
            } message: {
                Text(viewModel.errorMessage ?? "未知错误")
            }
        }
    }
    
    // MARK: - Sections
    
    private var basicInfoSection: some View {
        Section("基本信息") {
            LocalInfoRow(title: "型号", value: viewModel.device.model)
            LocalInfoRow(title: "MAC 地址", value: viewModel.device.macAddress)
            if let ip = viewModel.device.ipAddress {
                LocalInfoRow(title: "IP 地址", value: ip)
            }
            if let configId = viewModel.device.configurationId {
                LocalInfoRow(title: "配置 ID", value: configId)
            }
        }
    }
    
    private var statusSection: some View {
        Section("状态") {
            HStack {
                Text("设备状态")
                Spacer()
                StatusBadge(state: viewModel.device.state)
            }
            
            if let firmware = viewModel.device.firmwareVersion {
                HStack {
                    Text("固件版本")
                    Spacer()
                    Text(firmware)
                        .foregroundColor(.secondary)
                }
            }
            
            if let updatable = viewModel.device.firmwareUpdatable {
                HStack {
                    Text("固件更新")
                    Spacer()
                    Text(updatable ? "可用" : "已是最新")
                        .foregroundColor(updatable ? .orange : .green)
                }
            }
            
            if let adoptedAt = viewModel.device.adoptedAt {
                LocalInfoRow(title: "Adoption 时间", value: formatDate(adoptedAt))
            }
        }
    }
    
    private var statisticsSection: some View {
        Section("实时统计") {
            if let stats = viewModel.statistics {
                if let cpu = stats.cpuUtilizationPct {
                    HStack {
                        Text("CPU 使用率")
                        Spacer()
                        Text(String(format: "%.1f%%", cpu))
                            .foregroundColor(cpuColor(cpu))
                    }
                }
                
                if let mem = stats.memoryUtilizationPct {
                    HStack {
                        Text("内存使用率")
                        Spacer()
                        Text(String(format: "%.1f%%", mem))
                            .foregroundColor(cpuColor(mem))
                    }
                }
                
                if let uptime = stats.uptimeSec {
                    LocalInfoRow(title: "运行时间", value: formatUptime(uptime))
                }
                
                if let uplink = stats.uplink {
                    if let tx = uplink.txRateBps {
                        LocalInfoRow(title: "上行速率", value: formatSpeed(tx))
                    }
                    if let rx = uplink.rxRateBps {
                        LocalInfoRow(title: "下行速率", value: formatSpeed(rx))
                    }
                }
            } else if viewModel.isLoadingStats {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
    }
    
    private func portsSection(ports: [LocalDevicePort]) -> some View {
        Section("端口 (\(ports.count)个)") {
            ForEach(ports) { port in
                PortRow(port: port)
            }
        }
    }
    
    private func radiosSection(radios: [LocalDeviceRadio]) -> some View {
        Section("射频 (\(radios.count)个)") {
            ForEach(radios) { radio in
                RadioRow(radio: radio)
            }
        }
    }
    
    private var actionsSection: some View {
        Section("操作") {
            Button {
                viewModel.showRestartConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
                    Text("重启设备")
                        .foregroundColor(.orange)
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ dateString: String) -> String {
        // 简化日期格式化
        return dateString
    }
    
    private func formatUptime(_ seconds: Int) -> String {
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        
        if days > 0 {
            return "\(days)天 \(hours)小时"
        } else if hours > 0 {
            return "\(hours)小时 \(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
    
    private func formatSpeed(_ bps: Int64) -> String {
        if bps >= 1_000_000_000 {
            return String(format: "%.2f Gbps", Double(bps) / 1_000_000_000)
        } else if bps >= 1_000_000 {
            return String(format: "%.2f Mbps", Double(bps) / 1_000_000)
        } else if bps >= 1_000 {
            return String(format: "%.2f Kbps", Double(bps) / 1_000)
        } else {
            return "\(bps) bps"
        }
    }
    
    private func cpuColor(_ percentage: Double) -> Color {
        if percentage < 50 { return .green }
        if percentage < 80 { return .orange }
        return .red
    }
}

// MARK: - 状态徽章

struct StatusBadge: View {
    let state: DeviceState
    
    var body: some View {
        Text(state.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch state {
        case .online: return Color.green.opacity(0.2)
        case .offline: return Color.red.opacity(0.2)
        case .pending, .adopting, .provisioning: return Color.orange.opacity(0.2)
        case .unknown: return Color.gray.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        switch state {
        case .online: return .green
        case .offline: return .red
        case .pending, .adopting, .provisioning: return .orange
        case .unknown: return .gray
        }
    }
}

// MARK: - 端口行

struct PortRow: View {
    let port: LocalDevicePort
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("端口 \(port.idx)")
                    .font(.headline)
                
                if let connector = port.connector {
                    Text(connector)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // 状态
                HStack(spacing: 4) {
                    Circle()
                        .fill(port.state == "UP" ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(port.state ?? "Unknown")
                        .font(.caption)
                }
                
                // 速度
                if let speed = port.speedMbps {
                    Text("\(speed) Mbps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // PoE 状态
                if let poe = port.poe, poe.enabled == true {
                    HStack(spacing: 2) {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                        Text(poe.standard ?? "PoE")
                            .font(.caption2)
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 射频行

struct RadioRow: View {
    let radio: LocalDeviceRadio
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let standard = radio.wlanStandard {
                    Text(standard)
                        .font(.headline)
                }
                
                if let freq = radio.frequencyGHz {
                    Text(String(format: "%.1f GHz", freq))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let channel = radio.channel {
                Text("信道 \(channel)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 信息行

struct LocalInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Preview

#Preview {
    LocalDeviceDetailView(device: PreviewData.sampleLocalDevice, siteId: "test-site")
}
