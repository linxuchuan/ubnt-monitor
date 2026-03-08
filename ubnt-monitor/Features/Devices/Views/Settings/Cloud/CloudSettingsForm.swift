import SwiftUI

/// 云端设置表单组件
struct CloudSettingsForm: View {
    let onComplete: () -> Void
    
    @StateObject private var viewModel = CloudSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "cloud.fill")
                            .foregroundColor(.blue)
                        Text("互联网版本")
                            .font(.headline)
                    }
                    
                    Text("通过 Ubiquiti 官方云端 API 访问您的设备，适合远程管理。需要先在 Ubiquiti 官网申请 API Key。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
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
                .disabled(viewModel.isTestingConnection || viewModel.apiKey.isEmpty)
                
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
        .navigationTitle("云端 API 设置")
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
        CloudSettingsForm {}
    }
}
