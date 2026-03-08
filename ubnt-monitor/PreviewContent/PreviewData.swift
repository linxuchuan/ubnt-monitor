import Foundation

enum PreviewData {
    // MARK: - 云端设备预览数据
    
    static let sampleDevice = UbiquitiDevice(
        id: "test-device-id",
        hardwareId: "hardware-123",
        type: "udm",
        ipAddress: "192.168.1.1",
        owner: true,
        isBlocked: false,
        registrationTime: "2024-01-15T10:30:00.000Z",
        lastConnectionStateChange: "2024-03-06T08:00:00.000Z",
        latestBackupTime: nil,
        reportedState: ReportedState(
            name: "Home UDM",
            version: "7.5.187",
            state: "connected",
            mac: "aa:bb:cc:dd:ee:ff",
            hostname: "UDM-Pro",
            ip: "192.168.1.1"
        )
    )
    
    static let sampleDevices = [
        sampleDevice,
        UbiquitiDevice(
            id: "test-device-2",
            hardwareId: "hardware-456",
            type: "usw",
            ipAddress: "192.168.1.2",
            owner: true,
            isBlocked: false,
            registrationTime: "2024-02-01T14:20:00.000Z",
            lastConnectionStateChange: "2024-03-05T12:00:00.000Z",
            latestBackupTime: nil,
            reportedState: ReportedState(
                name: "Office Switch",
                version: "6.5.0",
                state: "connected",
                mac: "11:22:33:44:55:66",
                hostname: "USW-24-PoE",
                ip: "192.168.1.2"
            )
        )
    ]
    
    static let sampleDeviceDetail = DeviceDetail(
        id: "detail-1",
        mac: "aa:bb:cc:dd:ee:ff",
        name: "Living Room AP",
        model: "UniFi 6 Pro",
        shortname: "U6-Pro",
        ip: "192.168.1.50",
        productLine: "unifi",
        status: "online",
        version: "6.5.0",
        firmwareStatus: "upToDate",
        updateAvailable: nil,
        isConsole: false,
        isManaged: true,
        startupTime: "2024-03-01T08:00:00.000Z",
        adoptionTime: "2024-01-15T10:30:00.000Z",
        note: "Main floor access point"
    )
    
    static let sampleHostDevices = HostDevices(
        hostId: "test-device-id",
        hostName: "Home UDM",
        devices: [
            sampleDeviceDetail,
            DeviceDetail(
                id: "detail-2",
                mac: "11:22:33:44:55:66",
                name: nil,
                model: "UniFi Switch 24 PoE",
                shortname: "USW-24-PoE",
                ip: "192.168.1.51",
                productLine: "unifi",
                status: "online",
                version: "6.4.0",
                firmwareStatus: "updateAvailable",
                updateAvailable: "6.5.0",
                isConsole: false,
                isManaged: true,
                startupTime: "2024-02-28T10:00:00.000Z",
                adoptionTime: "2024-01-15T10:35:00.000Z",
                note: nil
            )
        ],
        updatedAt: "2024-03-06T15:00:00.000Z"
    )
    
    // MARK: - 局域网设备预览数据
    
    static let sampleLocalSite = LocalSite(
        id: "site-default",
        internalReference: "default",
        name: "Default Site"
    )
    
    static let sampleLocalSites = [
        sampleLocalSite,
        LocalSite(id: "site-2", internalReference: "office", name: "Office Site")
    ]
    
    static let sampleLocalDevice = LocalDevice(
        id: "device-1",
        macAddress: "94:2a:6f:26:c6:ca",
        ipAddress: "192.168.1.55",
        name: "Living Room AP",
        model: "U6-Pro",
        state: .online,
        supported: true,
        firmwareVersion: "6.6.55",
        firmwareUpdatable: true,
        features: ["accessPoint"],
        interfaceTypes: ["radios"],
        interfaces: LocalDeviceInterfaces(
            ports: [
                LocalDevicePort(
                    idx: 1,
                    state: "UP",
                    connector: "RJ45",
                    maxSpeedMbps: 1000,
                    speedMbps: 1000,
                    poe: LocalDevicePoE(
                        standard: "802.3at",
                        type: 2,
                        enabled: true,
                        state: "UP"
                    )
                )
            ],
            radios: [
                LocalDeviceRadio(
                    wlanStandard: "802.11ax",
                    frequencyGHz: 5.0,
                    channelWidthMHz: 80,
                    channel: 36
                ),
                LocalDeviceRadio(
                    wlanStandard: "802.11ax",
                    frequencyGHz: 2.4,
                    channelWidthMHz: 40,
                    channel: 6
                )
            ]
        ),
        adoptedAt: "2024-01-15T10:30:00Z",
        provisionedAt: "2024-01-15T10:35:00Z",
        configurationId: "abc123",
        uplink: nil
    )
    
    static let sampleLocalDevices = [
        sampleLocalDevice,
        LocalDevice(
            id: "device-2",
            macAddress: "94:2a:6f:26:c6:cb",
            ipAddress: "192.168.1.56",
            name: "Switch 24 PoE",
            model: "USW-24-PoE",
            state: .online,
            supported: true,
            firmwareVersion: "6.5.0",
            firmwareUpdatable: false,
            features: ["switching"],
            interfaceTypes: ["ports"],
            interfaces: LocalDeviceInterfaces(
                ports: (1...24).map { idx in
                    LocalDevicePort(
                        idx: idx,
                        state: idx <= 8 ? "UP" : "DOWN",
                        connector: "RJ45",
                        maxSpeedMbps: 1000,
                        speedMbps: idx <= 8 ? 1000 : nil,
                        poe: idx <= 8 ? LocalDevicePoE(
                            standard: "802.3at",
                            type: 2,
                            enabled: true,
                            state: "UP"
                        ) : nil
                    )
                },
                radios: nil
            ),
            adoptedAt: "2024-01-15T10:30:00Z",
            provisionedAt: "2024-01-15T10:35:00Z",
            configurationId: "def456",
            uplink: LocalDeviceUplink(deviceId: "device-1")
        ),
        LocalDevice(
            id: "device-3",
            macAddress: "94:2a:6f:26:c6:cc",
            ipAddress: nil,
            name: "Bedroom AP",
            model: "U6-Lite",
            state: .offline,
            supported: true,
            firmwareVersion: "6.6.50",
            firmwareUpdatable: true,
            features: ["accessPoint"],
            interfaceTypes: ["radios"],
            adoptedAt: "2024-02-01T08:00:00Z",
            provisionedAt: nil,
            configurationId: nil,
            uplink: nil
        )
    ]
    
    static let sampleLocalStatistics = LocalDeviceStatistics(
        uptimeSec: 86400 * 30, // 30 days
        lastHeartbeatAt: "2024-03-06T15:00:00Z",
        nextHeartbeatAt: "2024-03-06T15:01:00Z",
        loadAverage1Min: 0.25,
        loadAverage5Min: 0.30,
        loadAverage15Min: 0.28,
        cpuUtilizationPct: 15.5,
        memoryUtilizationPct: 42.0,
        uplink: LocalStatisticsUplink(
            txRateBps: 125000000, // 1 Gbps
            rxRateBps: 125000000
        ),
        interfaces: LocalStatisticsInterfaces(
            radios: [
                LocalRadioStatistics(
                    frequencyGHz: 5.0,
                    txRetriesPct: 2.5
                ),
                LocalRadioStatistics(
                    frequencyGHz: 2.4,
                    txRetriesPct: 5.0
                )
            ]
        )
    )
    
    static let sampleLocalClient = LocalClient(
        id: "client-1",
        macAddress: "aa:bb:cc:dd:ee:01",
        ipAddress: "192.168.1.100",
        name: "iPhone",
        hostname: "iPhone-User",
        networkId: "network-1",
        deviceId: "device-1",
        connectionType: "wireless",
        signalStrength: -45,
        rxRateBps: 50000000,
        txRateBps: 30000000
    )
}
