import SwiftUI

/// 局域网设置表单组件
struct LocalSettingsForm: View {
    let onComplete: () -> Void
    
    @StateObject private var viewModel = LocalSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(.green)
                        Text("局域网版本")
                            .font(.headline)
                    }
                    
                    Text("直接连接路由器进行管理，可以查看更详细的设备信息。需要确保手机与路由器在同一网络内。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Section("路由器地址") {
                TextField("http://192.168.1.1:8080", text: $viewModel.baseURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                
                Text("支持格式: http://IP:端口 或 https://IP:端口")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("API Key") {
                SecureField("输入 API Key", text: $viewModel.apiKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                if !viewModel.apiKey.isEmpty {
                    Button("清除") {
                        viewModel.apiKey = ""
                    }
                    .foregroundColor(.red)
                }
            }
            
            Section {
                Button {
                    Task {
                        await viewModel.testConnection()
                    }
                } label: {
                    HStack {
                        Text("测试连接")
                        if viewModel.isTestingConnection {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(viewModel.isTestingConnection || !viewModel.canTest)
                
                if let result = viewModel.testResult {
                    TestResultRow(result: result)
                }
            }
            
            Section {
                Button("保存并进入") {
                    viewModel.save()
                    onComplete()
                }
                .disabled(!viewModel.canSave)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("局域网设置")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
        }
    }
}

// MARK: - 测试结果行

private struct TestResultRow: View {
    let result: TestResult
    
    var body: some View {
        HStack(alignment: .top) {
            switch result {
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("连接成功")
                    .foregroundColor(.green)
            case .successWithVersion(let version):
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                VStack(alignment: .leading, spacing: 4) {
                    Text("连接成功")
                        .foregroundColor(.green)
                    Text("应用版本: \(version)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            case .failure(let message):
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LocalSettingsForm {}
    }
}
