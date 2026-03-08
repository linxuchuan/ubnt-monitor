import SwiftUI

/// 局域网设备列表页面
struct LocalDeviceListView: View {
    @StateObject private var viewModel = LocalDeviceListViewModel()
    @State private var showingSettings = false
    @State private var selectedDevice: LocalDevice?
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    idleView
                case .loading:
                    loadingView
                case .loaded:
                    deviceListView
                case .error:
                    errorView
                case .noSites:
                    noSitesView
                }
            }
            .navigationTitle("局域网设备")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    sitePickerButton
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
            .sheet(isPresented: $viewModel.showSitePicker) {
                sitePickerSheet
            }
            .alert("连接测试", isPresented: $viewModel.showTestResult) {
                Button("确定") { }
            } message: {
                Text(viewModel.testResultMessage)
            }
        }
        .task {
            #if DEBUG
            print("📱 [Local View] .task triggered, sites count: \(viewModel.sites.count)")
            #endif
            if viewModel.sites.isEmpty {
                await viewModel.loadSites()
            }
        }
        .onAppear {
            #if DEBUG
            print("📱 [Local View] onAppear, state: \(viewModel.state), sites: \(viewModel.sites.count)")
            #endif
            // 如果长时间卡在 loading 状态，强制重置
            if viewModel.state == .loading {
                #if DEBUG
                print("⚠️ [Local View] Stuck in loading state, resetting...")
                #endif
                // 延迟检查，如果 5 秒后还在 loading，则显示错误
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if viewModel.state == .loading {
                        viewModel.errorMessage = "请求超时，请检查网络连接"
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var idleView: some View {
        VStack(spacing: 20) {
            Spacer()
            ContentUnavailableView {
                Label("准备就绪", systemImage: "network")
            } description: {
                Text("点击加载设备或测试连接")
            } actions: {
                VStack(spacing: 12) {
                    Button("加载设备") {
                        Task {
                            await viewModel.loadSites()
                        }
                    }
                    
                    Button("测试连接") {
                        Task {
                            await viewModel.testConnection()
                        }
                    }
                    .buttonStyle(.borderless)
                }
            }
            Spacer()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.5)
            
            Text("正在连接局域网...")
                .font(.headline)
                .foregroundColor(.primary)
            
            // ⚠️ 安全注意：生产环境不要显示 URL 和 Key 状态
            Text(LocalAPIConfig.isConfigured ? "配置已加载" : "配置未加载")
                .font(.caption)
                .foregroundColor(.secondary)
            
            #if DEBUG
            VStack(alignment: .leading, spacing: 4) {
                Text("调试信息")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("State: loading")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("Sites: \(viewModel.sites.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("Devices: \(viewModel.devices.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            #endif
            
            Text("如果长时间无响应，请检查：\n1. 手机和路由器在同一网络\n2. URL 和 API Key 正确\n3. UniFi 控制台已启用 API")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("取消") {
                // 强制重置状态
                viewModel.resetState()
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding()
    }
    
    private var deviceListView: some View {
        List {
            // 站点信息头部
            if let site = viewModel.sites.first(where: { $0.id == viewModel.selectedSiteId }) {
                Section("当前站点") {
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.blue)
                        Text(site.name)
                            .font(.headline)
                        Spacer()
                        Text("\(viewModel.devices.count) 个设备")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // 设备列表
            Section("设备列表") {
                if viewModel.devices.isEmpty {
                    Text("没有找到设备")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(viewModel.devices) { device in
                        LocalDeviceCard(device: device)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedDevice = device
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(item: $selectedDevice) { device in
            LocalDeviceDetailView(device: device, siteId: viewModel.selectedSiteId ?? "")
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("连接错误")
                .font(.headline)
            
            Text(viewModel.errorMessage ?? "未知错误")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            #if DEBUG
            VStack(alignment: .leading, spacing: 8) {
                Text("调试信息 (DEBUG)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                // 安全：不显示实际的 URL 或 Key 状态
                Text("配置状态: \(LocalAPIConfig.isConfigured ? "已配置" : "未配置")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("查看 Xcode 控制台获取详细错误日志")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            #endif
            
            VStack(spacing: 12) {
                Button("重试") {
                    Task {
                        await viewModel.loadSites()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("测试连接") {
                    Task {
                        await viewModel.testConnection()
                    }
                }
                .buttonStyle(.borderless)
                
                #if DEBUG
                Button("重置状态") {
                    viewModel.resetState()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.orange)
                #endif
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var noSitesView: some View {
        ContentUnavailableView {
            Label("无站点", systemImage: "building.2.slash")
        } description: {
            Text("未找到 UniFi 站点")
        } actions: {
            Button("刷新") {
                Task {
                    await viewModel.loadSites()
                }
            }
        }
    }
    
    private var sitePickerButton: some View {
        Button {
            viewModel.showSitePicker = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "building.2")
                if let site = viewModel.sites.first(where: { $0.id == viewModel.selectedSiteId }) {
                    Text(site.name)
                        .lineLimit(1)
                } else {
                    Text("选择站点")
                }
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .foregroundColor(.primary)
        }
        .disabled(viewModel.sites.isEmpty)
    }
    
    private var sitePickerSheet: some View {
        NavigationStack {
            List(viewModel.sites) { site in
                Button {
                    viewModel.selectSite(site)
                    viewModel.showSitePicker = false
                } label: {
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.blue)
                        Text(site.name)
                        Spacer()
                        if site.id == viewModel.selectedSiteId {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("选择站点")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        viewModel.showSitePicker = false
                    }
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
        .disabled(viewModel.isLoadingDevices)
    }
    
    private var settingsButton: some View {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "gear")
        }
    }
}

// MARK: - 设备卡片

struct LocalDeviceCard: View {
    let device: LocalDevice
    
    var body: some View {
        HStack(spacing: 12) {
            // 状态指示器
            statusIndicator
            
            // 设备信息
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name ?? device.model)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(device.model)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let ip = device.ipAddress {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(ip)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let firmware = device.firmwareVersion {
                    HStack(spacing: 4) {
                        Image(systemName: "gear.badge.checkmark")
                            .font(.caption2)
                        Text(firmware)
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 功能标签（使用 interfaceTypes）
            if let interfaceTypes = device.interfaceTypes, !interfaceTypes.isEmpty {
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(interfaceTypes.prefix(2), id: \.self) { type in
                        Text(interfaceTypeLabel(for: type))
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 10, height: 10)
    }
    
    private var statusColor: Color {
        switch device.state {
        case .online: return .green
        case .offline: return .red
        case .pending, .adopting, .provisioning: return .orange
        case .unknown: return .gray
        }
    }
    
    private func interfaceTypeLabel(for type: String) -> String {
        switch type {
        case "ports": return "交换"
        case "radios": return "WiFi"
        default: return type
        }
    }
}

// MARK: - Preview
// ⚠️ 警告：预览仅用于开发，不要包含真实配置

#if DEBUG
#Preview("有设备") {
    // 使用模拟数据，不连接真实服务器
    return LocalDeviceListView()
}

#Preview("无设备") {
    return LocalDeviceListView()
}
#endif
