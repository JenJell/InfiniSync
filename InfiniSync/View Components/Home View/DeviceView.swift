//
//  DeviceView.swift
//  InfiniSync
//
//  Created by John Stanley on 11/16/21.
//

import SwiftUI

struct DeviceView: View {
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var bleManagerVal = BLEManagerVal.shared
    @ObservedObject var deviceInfo = BLEDeviceInfo.shared
    @ObservedObject var uptimeManager = UptimeManager.shared
    
    @AppStorage("watchNotifications") var watchNotifications: Bool = true
    @AppStorage("batteryNotification") var batteryNotification: Bool = false
    @AppStorage("autoconnectUUID") var autoconnectUUID: String = ""
    @AppStorage("autoconnect") var autoconnect: Bool = false
    @AppStorage("showDisconnectAlert") var showDisconnectConfDialog: Bool = false
    @AppStorage("weatherData") var weatherData: Bool = true
    
    @State var currentUptime: TimeInterval!
    @State var settings: Settings?
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var dateFormatter = DateComponentsFormatter()
    
    var icon: String {
        switch bleManagerVal.weatherInformation.icon {
        case 0:
            return "sun.max.fill"
        case 1:
            return "cloud.sun.fill"
        case 2, 3:
            return "cloud.fill"
        case 4, 5:
            return "cloud.rain.fill"
        case 6:
            return "cloud.bolt.rain.fill"
        case 7:
            return "cloud.snow.fill"
        case 8:
            return "cloud.fog.fill"
        default:
            return "slash.circle"
        }
    }
    
    var body: some View {
        CustomScrollView(settings: $settings) {
            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        NavigationLink(destination: BatteryView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(NSLocalizedString("battery_tilte", comment: ""))
                                        .font(.title3.weight(.semibold))
                                    Text(String(format: "%.0f", bleManager.batteryLevel) + "%")
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body.weight(.medium))
                            }
                            .aspectRatio(1, contentMode: .fill)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                        NavigationLink(destination: DFUView()) {
                            HStack {
                                Text(NSLocalizedString("software_update", comment: ""))
                                    .multilineTextAlignment(.leading)
                                    .font(.title3.weight(.semibold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body.weight(.medium))
                            }
                            .aspectRatio(1, contentMode: .fill)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.primary)
                            .cornerRadius(20)
                        }
                    }
                    HStack(spacing: 8) {
                        NavigationLink(destination: StepView().navigationBarHidden(true)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(NSLocalizedString("step_count", comment: ""))
                                        .font(.title3.weight(.semibold))
                                    Text("\(bleManagerVal.stepCount)")
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body.weight(.medium))
                            }
                            .aspectRatio(1, contentMode: .fill)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                        NavigationLink(destination: HeartView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(NSLocalizedString("heart_rate", comment: ""))
                                        .font(.title3.weight(.semibold))
                                    Text(String(format: "%.0f", bleManagerVal.heartBPM) + " " + NSLocalizedString("bpm", comment: "BPM"))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body.weight(.medium))
                            }
                            .aspectRatio(1, contentMode: .fill)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                    }
                    
                    if weatherData {
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(NSLocalizedString("weather", comment: ""))
                                        .font(.headline)
                                    if bleManagerVal.loadingWeather {
                                        Text(NSLocalizedString("loading", comment: "Loading..."))
                                    } else {
                                        if (UnitTemperature.current == .celsius && deviceData.chosenWeatherMode == "System") || deviceData.chosenWeatherMode == "Metric" {
                                            Text(String(Int(round(bleManagerVal.weatherInformation.temperature))) + "°" + "C")
                                                .font(.title.weight(.semibold))
                                        } else {
                                            Text(String(Int(round(bleManagerVal.weatherInformation.temperature * 1.8 + 32))) + "°" + "F")
                                                .font(.title.weight(.semibold))
                                        }
                                    }
                                }
                                .font(.title.weight(.semibold))
                                Spacer()
                                VStack {
                                    if bleManagerVal.loadingWeather {
                                        Image(systemName: "circle.slash")
                                    } else {
                                        Image(systemName: icon)
                                    }
                                }
                                .font(.title.weight(.medium))
                            }
                        }
                        .padding()
                        .background(LinearGradient(colors: [.blue, .yellow], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        Spacer()
                            .frame(height: 6)
                    }
                }
                if DownloadManager.shared.updateAvailable {
                    NavigationLink(destination: DFUView()) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(NSLocalizedString("software_update_available", comment: "Software Update Available"))
                                    .font(.title3.weight(.semibold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.body.weight(.medium))
                            }
                            Text(DownloadManager.shared.updateVersion)
                                .foregroundColor(.gray)
                                .font(.headline)
                            Spacer()
                                .frame(height: 5)
                            Text(DownloadManager.shared.updateBody)
                                .multilineTextAlignment(.leading)
                                .lineLimit(4)
                        }
                        .foregroundColor(.primary)
                        .modifier(RowModifier(style: .standard))
                    }
                }
                VStack {
                    NavigationLink(destination: RenameView()) {
                        HStack {
                            Text(NSLocalizedString("name", comment: ""))
                            Text(deviceInfo.deviceName)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .modifier(RowModifier(style: .capsule))
                    }
                    .opacity(bleManager.isConnectedToPinetime ? 1.0 : 0.5)
                    .disabled(!bleManager.isConnectedToPinetime)
                    HStack {
                        Text(NSLocalizedString("software_version", comment: ""))
                        Spacer()
                        Text(deviceInfo.firmware)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    }
                    .modifier(RowModifier(style: .capsule))
                    HStack {
                        Text(NSLocalizedString("model_name", comment: ""))
                        Text(deviceInfo.modelNumber)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                    }
                    .modifier(RowModifier(style: .capsule))
                    HStack {
                        Text(NSLocalizedString("last_disconnect", comment: ""))
                        Spacer()
                        if UptimeManager.shared.lastDisconnect != nil {
                            Text(uptimeManager.dateFormatter.string(from: uptimeManager.lastDisconnect))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .modifier(RowModifier(style: .capsule))
                    HStack {
                        Text(NSLocalizedString("uptime", comment: ""))
                        Spacer()
                        if currentUptime != nil {
                            Text((dateFormatter.string(from: currentUptime) ?? ""))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .modifier(RowModifier(style: .capsule))
                    NavigationLink(destination: WatchSettingsView()) {
                        HStack {
                            Text(NSLocalizedString("watch_settings", comment: ""))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .modifier(RowModifier(style: .capsule))
                    }
                    .opacity(bleManager.isConnectedToPinetime ? 1.0 : 0.5)
                    .disabled(!bleManager.isConnectedToPinetime)
                }
                .onReceive(timer, perform: { _ in
                    if uptimeManager.connectTime != nil {
                        currentUptime = -uptimeManager.connectTime.timeIntervalSinceNow
                    }
                })
                Spacer()
                    .frame(height: 6)
                NavigationLink(destination: Settings_Page()) {
                    HStack {
                        Text(NSLocalizedString("settings", comment: ""))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .modifier(RowModifier(style: .capsule))
                }
                Spacer()
                    .frame(height: 6)
                NavigationLink(destination: FileSystemView()) {
                    HStack {
                        Text(NSLocalizedString("file_system", comment: ""))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .modifier(RowModifier(style: .capsule))
                }
                Spacer()
                    .frame(height: 6)
                VStack {
                    if bleManager.isConnectedToPinetime {
                        Toggle(isOn: $bleManager.autoconnectToDevice) {
                            Text(NSLocalizedString("autoconnect_to_this", comment: "") + " \(deviceInfo.modelNumber)")
                        }.onChange(of: bleManager.autoconnectToDevice) { newValue in
                            autoconnect = bleManager.autoconnectToDevice
                            if bleManager.autoconnectToDevice == false {
                                autoconnectUUID = ""
                            } else {
                                autoconnectUUID = bleManager.setAutoconnectUUID
                            }
                        }
                        .modifier(RowModifier(style: .capsule))
                    }
                    Toggle(NSLocalizedString("enable_watch_notifications", comment: ""), isOn: $watchNotifications)
                        .modifier(RowModifier(style: .capsule))
                    Toggle(NSLocalizedString("notify_about_low_battery", comment: ""), isOn: $batteryNotification)
                        .modifier(RowModifier(style: .capsule))
                    Button {
                        SheetManager.shared.sheetSelection = .notification
                        SheetManager.shared.showSheet = true
                    } label: {
                        Text(NSLocalizedString("send_notification_to", comment: "") + " \(deviceInfo.modelNumber)")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                            .modifier(RowModifier(style: .capsule))
                    }
                    .opacity(!watchNotifications || !bleManager.isConnectedToPinetime ? 0.5 : 1.0)
                    .disabled(!watchNotifications || !bleManager.isConnectedToPinetime)
                    Button {
                        BLEWriteManager.init().sendLostNotification()
                    } label: {
                        Text(NSLocalizedString("find_lost_device", comment: "") + " \(deviceInfo.modelNumber)")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                            .modifier(RowModifier(style: .capsule))
                    }
                    .opacity(!watchNotifications || !bleManager.isConnectedToPinetime ? 0.5 : 1.0)
                    .disabled(!watchNotifications || !bleManager.isConnectedToPinetime)
                }
                Spacer()
                    .frame(height: 6)
                VStack {
                    Button {
                        showDisconnectConfDialog = true
                    } label: {
                        Text(NSLocalizedString("disconnect", comment: "") + " \(deviceInfo.modelNumber)")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                            .font(.body.weight(.semibold))
                            .modifier(RowModifier(style: .capsule))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .padding(.bottom)
        }
    }
}

struct CustomScrollView<Content: View>: View {
    let content: Content
    
    init(settings: Binding<Settings?>, @ViewBuilder content: @escaping () -> Content) {
        self._settings = settings
        self.content = content()
    }
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var bleManagerVal = BLEManagerVal.shared
    @ObservedObject var deviceInfo = BLEDeviceInfo.shared
    
    @State private var scrollPosition: CGFloat = 0
    @State private var showDivider: Bool = false
    
    @Binding var settings: Settings?
    @State var clockType: ClockType = .H24
    
    @AppStorage("stepCountGoal") var stepCountGoal = 10000
    
    let watchSpace = 0.28
    let watchScrollSpeed = 0.15
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack() {
                    ZStack() {
                        Rectangle()
                            .foregroundColor(.secondary)
                            .frame(width:  geometry.size.width / 2.65, height:  geometry.size.width / 2.65, alignment: .center)
                            .position(x: geometry.size.width / 2, y: (((geometry.size.height) * watchSpace / 2) + 55 + (self.scrollPosition - (geometry.size.height * watchSpace) * 1.45) * watchScrollSpeed).clamped(to: geometry.size.height*0.25...geometry.size.height*1.0))
                            .blur(radius: 128)
                            .opacity(0.75)
                        GeometryReader { geometry in
                            ZStack {
                                WatchFaceView(watchface: .constant(-1))
                                    .frame(width: geometry.size.width / 2.4, height: geometry.size.width / 2.4, alignment: .center)
                                    .position(x: geometry.size.width / 2, y: (((geometry.size.height) * watchSpace / 2) + 55 + (self.scrollPosition - (geometry.size.height * watchSpace) * 1.45) * watchScrollSpeed))
                            }
                            .clipped(antialiased: true)
                            .frame(width: geometry.size.width, height: (self.scrollPosition - geometry.safeAreaInsets.top).clamped(to: 0...geometry.size.height), alignment: .center)
                        }
                    }
                    VStack {
                        Spacer(minLength: scrollPosition.clamped(to: geometry.size.height*0.2...geometry.size.height))
                        Color.clear
                    }
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            ZStack {
                                Text("Blank")
                                    .opacity(0.0)
                                    .font(.system(size: 30))
                                
                                Text(deviceInfo.deviceName == "" ? "InfiniTime" : deviceInfo.deviceName)
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .center)
                        if showDivider {
                            Divider()
                        }
                        ScrollView(showsIndicators: false) {
                            Spacer(minLength: (geometry.size.height) * watchSpace)
                            VStack() {
                                GeometryReader{ geo in
                                    AnyView(Color.clear
                                        .frame(width: 0, height: 0)
                                        .preference(key: SizePreferenceKey.self, value: geo.frame(in: .global).minY)
                                    )}.onPreferenceChange(SizePreferenceKey.self) { preferences in
                                        self.scrollPosition = preferences
                                        
                                        if scrollPosition - geometry.safeAreaInsets.top <= 64 {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                self.showDivider = true
                                            }
                                        } else {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                self.showDivider = false
                                            }
                                        }
                                    }
                                content
                            }
                        }
                        .onAppear {
                            DownloadManager.shared.updateAvailable = DownloadManager.shared.checkForUpdates(currentVersion: BLEDeviceInfo.shared.firmware)
                        }
                        .onChange(of: deviceInfo.firmware) { firmware in
                            if firmware != "" && bleManager.isConnectedToPinetime{
                                BLEFSHandler.shared.readSettings { settings in
                                    self.settings = settings
                                    self.stepCountGoal = Int(settings.stepsGoal)
                                    self.bleManagerVal.watchFace = Int(settings.watchFace)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


enum RowModifierStyle {
    case capsule
    case standard
}

struct RowModifier: ViewModifier {
    var style: RowModifierStyle
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.gray.opacity(0.15))
            .foregroundColor(.primary)
            .cornerRadius(style == .capsule ? 40 : 15)
    }
}

#Preview {
    NavigationView {
        DeviceView()
            .onAppear {
                BLEManager.shared.isConnectedToPinetime = true
                BLEManagerVal.shared.firmwareVersion = "1.14.0"
            }
    }
}


struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = 0
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
}


public extension Color {
#if os(macOS)
    static let background = Color(NSColor.windowBackgroundColor)
    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
#else
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
#endif
}