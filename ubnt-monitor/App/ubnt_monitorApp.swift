import SwiftUI

@main
struct ubnt_monitorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// 应用委托
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 应用启动配置
        return true
    }
}

/// 内容视图 - 根据模式选择状态决定显示哪个页面
struct ContentView: View {
    @State private var hasSelectedMode = ConnectionModeConfig.hasSelectedMode
    @State private var currentMode: ConnectionMode? = ConnectionModeConfig.currentMode
    
    var body: some View {
        Group {
            if !hasSelectedMode {
                // 未选择模式，显示模式选择页面
                ModeSelectionView()
            } else if let mode = currentMode {
                // 已选择模式，根据模式显示不同页面
                switch mode {
                case .cloud:
                    DeviceListView()
                case .local:
                    LocalDeviceListView()
                }
            } else {
                // 异常情况，重新选择模式
                ModeSelectionView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .modeDidChange)) { _ in
            hasSelectedMode = ConnectionModeConfig.hasSelectedMode
            currentMode = ConnectionModeConfig.currentMode
        }
        // 监听应用从后台返回，刷新状态
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            hasSelectedMode = ConnectionModeConfig.hasSelectedMode
            currentMode = ConnectionModeConfig.currentMode
        }
    }
}

// MARK: - 通知扩展

extension Notification.Name {
    static let modeDidChange = Notification.Name("com.ubnt.monitor.modeDidChange")
}
