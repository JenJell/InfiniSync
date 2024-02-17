//
//  DeviceView.swift
//  InfiniLink
//
//  Created by John Stanley on 11/16/21.
//

import SwiftUI
import SpriteKit

struct TitleView: View {
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var bleManagerVal = BLEManagerVal.shared
    @ObservedObject var deviceInfo = BLEDeviceInfo.shared
    
    @Binding var offset: CGFloat
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(deviceInfo.deviceName == "" ? "InfiniTime" : deviceInfo.deviceName)
                .font(.system(size: 26).weight(.semibold))
            HStack {
                Text("InfiniTime \(deviceInfo.firmware)")
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                if DownloadManager.shared.updateAvailable {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                        .font(.body.weight(.regular))
                }
            }
            .padding(.top, -4)
            .opacity(1 - getTitleOpacity())
            WatchFaceView(watchface: .constant(-1))
                .compositingGroup()
                .frame(width: 145, height: 150, alignment: .center)
                .padding(.top, -18)
                .opacity(getTitleOpacity())
            Text("Version")
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .opacity(getTitleOpacity())
            Text("InfiniTime \(deviceInfo.firmware)")
                .foregroundStyle(.primary)
                .fontWeight(.semibold)
                .opacity(getTitleOpacity())
        }
        //.offset(y: -offset)
        .offset(y: offset > 0 ? (offset / UIScreen.main.bounds.width) * 100 : 0)
        .offset(y: getTitleOffset())
        .padding(.bottom, 30)
    }
    
    func getTitleOpacity() -> CGFloat {
        let titleOffset = -getTitleOffset()
        
        let progress = titleOffset / 20
        
        let opacity = 1 - progress
        
        return opacity
    }
    
    func getTitleOffset() -> CGFloat{
        if offset < 0 {
            let progress = -offset / 180
            let newOffset = (progress <= 1.0 ? progress : 1) * 20
            return -newOffset
        }
        return 0
    }
}

struct ScrollContentView: View {
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var bleManagerVal = BLEManagerVal.shared
    @ObservedObject var deviceInfo = BLEDeviceInfo.shared
    
    @AppStorage("watchNotifications") var watchNotifications: Bool = true
    @AppStorage("batteryNotification") var batteryNotification: Bool = false
    @AppStorage("autoconnectUUID") var autoconnectUUID: String = ""
    @AppStorage("autoconnect") var autoconnect: Bool = false
    @AppStorage("showDisconnectAlert") var showDisconnectConfDialog: Bool = false
    
    var topEdge: CGFloat
    
    var body: some View {
        // MARK: Update Available
        if DownloadManager.shared.updateAvailable {
            NavigationLink(destination: DFUView()) {
                CustomStackView(topEdge) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .font(.body.weight(.regular))
                        Text(NSLocalizedString("software_update_available", comment: ""))
                            .foregroundColor(.orange)
                            .font(.headline.weight(.semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.body.weight(.regular))
                    }
                } contentView: {
                    
                    VStack(alignment: .leading) {
                        Text(DownloadManager.shared.updateVersion)
                            .foregroundColor(.gray)
                            .font(.headline)
                        Spacer()
                            .frame(height: 5)
                        Text(DownloadManager.shared.updateBody)
                            .multilineTextAlignment(.leading)
                            .lineLimit(4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .foregroundColor(.primary)
                }
            }
            Spacer()
            .frame(height: 24)
        }
        // MARK: Device View Content
        VStack(spacing: 8) {
            StepNavigationLink(topEdge: topEdge)
            HeartNavigationLink(topEdge: topEdge)
            BatteryNavigationLink(topEdge: topEdge)
            // MARK: More Content
            Spacer()
                .frame(height: 6)
            NavigationLink(destination: DFUView()) {
                CustomButtonView(topEdge) {
                    HStack {
                        Text(NSLocalizedString("software_update", comment: ""))
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.body.weight(.regular))
                    }
                }
            }
            Spacer()
                .frame(height: 6)
            NavigationLink(destination: FileSystemView()) {
                CustomButtonView(topEdge) {
                    HStack {
                        Text(NSLocalizedString("file_system", comment: ""))
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.body.weight(.regular))
                    }
                }
            }
            Spacer()
                .frame(height: 6)
            Button {
                SheetManager.shared.sheetSelection = .notification
                SheetManager.shared.showSheet = true
            } label: {
                CustomButtonView(topEdge) {
                    Text(NSLocalizedString("send_notification_to", comment: "") + " \(deviceInfo.modelNumber)")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                }
            }
            .opacity(!watchNotifications || !bleManager.isConnectedToPinetime ? 0.5 : 1.0)
            .disabled(!watchNotifications || !bleManager.isConnectedToPinetime)
            Button {
                BLEWriteManager.init().sendLostNotification()
            } label: {
                CustomButtonView(topEdge) {
                    Text(NSLocalizedString("find_lost_device", comment: "") + " \(deviceInfo.modelNumber)")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                }
            }
            .opacity(!watchNotifications || !bleManager.isConnectedToPinetime ? 0.5 : 1.0)
            .disabled(!watchNotifications || !bleManager.isConnectedToPinetime)
            Spacer()
            .frame(height: 6)
            Button {
                showDisconnectConfDialog = true
            } label: {
                CustomButtonView(topEdge) {
                    Text(NSLocalizedString("disconnect", comment: "") + " \(deviceInfo.modelNumber)")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                        .font(.headline.weight(.semibold))
                }
            }
        }
    }
}


struct DeviceView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var bleManagerVal = BLEManagerVal.shared
    @ObservedObject var deviceInfo = BLEDeviceInfo.shared
    @ObservedObject var deviceDataForSettings: DeviceData = deviceData
    
    @State private var offset: CGFloat = .zero
    @State var settings: Settings?
    
    var topEdge: CGFloat
    
    @State private var scrollPosition: CGFloat = 0
    @State private var showDivider: Bool = false
    
    @State var clockType: ClockType = .H24
    
    @AppStorage("stepCountGoal") var stepCountGoal = 10000
    
    let watchSpace = 0.26
    let watchScrollSpeed = 0.15
    
    @State var debugView = false
    @State var debugClick : Int = 0
    @State var lastDebugClick : Date = Date()
    
    var body: some View {
        NavigationStack{
            ZStack {
                VStack {
                    TitleView(offset: $scrollPosition)
                    Spacer()
                }
                .padding(.top,25)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 305)
                        ScrollContentView(topEdge: topEdge)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top,topEdge)
                    .padding([.horizontal,.bottom])
                    .overlay(
                        GeometryReader{ geo in
                            AnyView(Color.clear
                                .frame(width: 0, height: 0)
                                .preference(key: SizePreferenceKey.self, value: geo.frame(in: .global).minY)
                            )}.onPreferenceChange(SizePreferenceKey.self) { preferences in
                                self.scrollPosition = preferences
                            }
                    )
                }
                .ignoresSafeArea(.all, edges: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                DownloadManager.shared.updateAvailable = DownloadManager.shared.checkForUpdates(currentVersion: BLEDeviceInfo.shared.firmware)
            }
            .onChange(of: deviceInfo.firmware) { firmware in
                if firmware != "" && bleManager.isConnectedToPinetime{
                    BLEFSHandler.shared.readSettings { settings in
                        DispatchQueue.main.async {
                            self.settings = settings
                            self.stepCountGoal = Int(settings.stepsGoal)
                            self.bleManagerVal.watchFace = Int(settings.watchFace)
                            self.bleManagerVal.pineTimeStyleData = settings.pineTimeStyle
                            self.bleManagerVal.timeFormat = settings.clockType
                            switch settings.weatherFormat {
                            case .Metric:
                                self.deviceDataForSettings.chosenWeatherMode = "Metric"
                            case .Imperial:
                                self.deviceDataForSettings.chosenWeatherMode = "Imperial"
                            }
                        }
                    }
                }
            }
            .background(Color("AppBackgroundColor"))
        }
    }
}

// MARK: Step Navigation Link
struct StepNavigationLink: View {
    @ObservedObject var bleManagerVal = BLEManagerVal.shared
    var topEdge: CGFloat
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \StepCounts.timestamp, ascending: true)])
    private var existingStepCounts: FetchedResults<StepCounts>
    let dateFormatter : DateFormatter = DateFormatter()
    
    func getStepHistoryAsString(date: Date) -> String {
        for stepCount in existingStepCounts {
            if Calendar.current.isDate(stepCount.timestamp!, inSameDayAs: date) {
                let formattedSteps = NumberFormatter.localizedString(from: NSNumber(value: stepCount.steps), number: .decimal)
                return formattedSteps
            }
        }
        return "0"
    }
    
    func getLatestDate() -> Date? {
        return existingStepCounts.last?.timestamp
    }
    
    func formatDate(date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()

        if calendar.isDateInToday(date) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            return dateFormatter.string(from: date)
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            dateFormatter.dateFormat = "MMM dd"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter.string(from: date)
        }
    }
    
    var body: some View {
        NavigationLink(destination: StepView().navigationBarHidden(true)) {
            CustomStackView(topEdge) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.blue)
                        .font(.body.weight(.regular))
                    Text(NSLocalizedString("steps_title", comment: ""))
                        .foregroundColor(.blue)
                        .font(.headline.weight(.semibold))
                    Spacer()
                    if let lastUpdate = getLatestDate() {
                        Text("\(formatDate(date: lastUpdate))")
                            .foregroundColor(.gray)
                            .font(.subheadline.weight(.regular))
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.body.weight(.regular))
                }
            } contentView: {
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        Text(getStepHistoryAsString(date: Date()))
                            .foregroundColor(.primary)
                            .font(.system(size: 32, weight: .semibold))
                            .padding(.vertical, -(32/6))
                        Text("steps")
                            .foregroundColor(.gray)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(-(14/10))
                        Spacer()
                    }
                }
                .frame(minHeight: 80)
                
            }
        }
    }
}

// MARK: Heart Navigation Link
struct HeartNavigationLink: View {
    @ObservedObject var bleManagerVal = BLEManagerVal.shared
    var topEdge: CGFloat
    
    let chartManager = ChartManager.shared    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ChartDataPoint.timestamp, ascending: true)], predicate: NSPredicate(format: "chart == 0"))
    private var chartPoints: FetchedResults<ChartDataPoint>
    
    func getLatestDate() -> Date? {
        return chartPoints.last?.timestamp
    }
    
    func formatDate(date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()

        if calendar.isDateInToday(date) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            return dateFormatter.string(from: date)
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            dateFormatter.dateFormat = "MMM dd"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter.string(from: date)
        }
    }
    
    var body: some View {
        let dataPoints = ChartManager.shared.convert(results: chartPoints)
        
        NavigationLink(destination: HeartView()) {
            CustomStackView(topEdge) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.body.weight(.regular))
                    Text(NSLocalizedString("heart_rate", comment: ""))
                        .foregroundColor(.red)
                        .font(.headline.weight(.semibold))
                    Spacer()
                    if let lastUpdate = getLatestDate() {
                        Text("\(formatDate(date: lastUpdate))")
                            .foregroundColor(.gray)
                            .font(.subheadline.weight(.regular))
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.body.weight(.regular))
                }
            } contentView: {
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text("Latest")
                                .foregroundColor(.gray)
                                .font(.system(size: 14, weight: .semibold))
                                .padding((14/10))
                            HStack(alignment: .bottom) {
                                Text(dataPoints.count < 2 ? "--" : String(format: "%.0f", chartPoints.last!.value))
                                    .foregroundColor(.primary)
                                    .font(.system(size: 32, weight: .semibold))
                                    .padding(.vertical, -(32/6))
                                Text("BPM")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(-(14/10))
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
                .frame(minHeight: 80)
            }
        }
    }
}

// MARK: Battery Navigation Link
struct BatteryNavigationLink: View {
    @ObservedObject var bleManager = BLEManager.shared
    var topEdge: CGFloat
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ChartDataPoint.timestamp, ascending: true)], predicate: NSPredicate(format: "chart == 1"))
    private var chartPoints: FetchedResults<ChartDataPoint>
    
    func getLatestDate() -> Date? {
        return chartPoints.last?.timestamp
    }
    
    func formatDate(date: Date) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()

        if calendar.isDateInToday(date) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            return dateFormatter.string(from: date)
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            dateFormatter.dateFormat = "MMM dd"
            return dateFormatter.string(from: date)
        } else {
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter.string(from: date)
        }
    }
    
    var body: some View {
        NavigationLink(destination: BatteryView()) {
            CustomStackView(topEdge) {
                HStack {
                    Image(systemName: "battery.75percent")
                        .foregroundColor(.green)
                        .font(.body.weight(.regular))
                    Text(NSLocalizedString("battery_tilte", comment: ""))
                        .foregroundColor(.green)
                        .font(.headline.weight(.semibold))
                    Spacer()
                    if let lastUpdate = getLatestDate() {
                        Text("\(formatDate(date: lastUpdate))")
                            .foregroundColor(.gray)
                            .font(.subheadline.weight(.regular))
                    }
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.body.weight(.regular))
                }
            } contentView: {
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                            Text("Latest")
                                .foregroundColor(.gray)
                                .font(.system(size: 14, weight: .semibold))
                                .padding((14/10))
                            HStack(alignment: .bottom) {
                                Text(String(format: "%.0f", bleManager.batteryLevel))
                                    .foregroundColor(.primary)
                                    .font(.system(size: 32, weight: .semibold))
                                    .padding(.vertical, -(32/6))
                                Text("percent")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(-(14/10))
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
                .frame(minHeight: 80)
            }
        }
    }
}


//                GeometryReader { geometry in
//                    ZStack() {
//                        GeometryReader{_ in
//                            SpriteView(scene: Background(), options: [.allowsTransparency])
//                        }
//                        .blur(radius: 64)
//                        .opacity(0.35)
//                        .ignoresSafeArea()
//                        ZStack() {
//                            Rectangle()
//                                .foregroundColor(.secondary)
//                                .frame(width:  geometry.size.width / 2.65, height:  geometry.size.width / 2.65, alignment: .center)
//                                .position(x: geometry.size.width / 2, y: (((geometry.size.height) * watchSpace / 2) + 55 + (self.scrollPosition - (geometry.size.height * watchSpace) * 1.45) * watchScrollSpeed).clamped(to: geometry.size.height*0.25...geometry.size.height*1.0))
//                                .blur(radius: 128)
//                                .opacity(0.75)
//                            GeometryReader { geometry in
//                                ZStack {
//                                    WatchFaceView(watchface: .constant(-1))
//                                        .frame(width: geometry.size.width / 2.4, height: geometry.size.width / 2.4, alignment: .center)
//                                        .position(x: geometry.size.width / 2, y: (((geometry.size.height) * watchSpace / 2) + 55 + (self.scrollPosition - (geometry.size.height * watchSpace) * 1.45) * watchScrollSpeed))
//                                }
//                                .clipped(antialiased: true)
//                                .frame(width: geometry.size.width, height: (self.scrollPosition - geometry.safeAreaInsets.top).clamped(to: 0...geometry.size.height), alignment: .center)
//                            }
//                        }
//                        VStack {
//                            Spacer(minLength: scrollPosition.clamped(to: geometry.size.height*0.2...geometry.size.height))
//                            Color.clear
//                        }
//                        VStack(spacing: 0) {
//                            HStack(spacing: 12) {
//                                ZStack {
//                                    Text("Blank")
//                                        .opacity(0.0)
//                                        .font(.system(size: 30))
//                                    
//                                    Text(deviceInfo.deviceName == "" ? "InfiniTime" : deviceInfo.deviceName)
//                                        .font(.title2.weight(.semibold))
//                                        .foregroundColor(colorScheme == .dark ? .white : .black)
//                                }
//                            }
//                            .padding(18)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                            if showDivider {
//                                Divider()
//                            }
//                            ScrollView(showsIndicators: false) {
//                                Spacer(minLength: (geometry.size.height) * watchSpace)
//                                Text(NSLocalizedString("Stats", comment: ""))
//                                    .font(.title2.weight(.semibold))
//                                    .foregroundColor(.gray)
//                                    .padding(.bottom, -15)
//                                    .padding(.horizontal)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                VStack() {
//                                    GeometryReader{ geo in
//                                        AnyView(Color.clear
//                                            .frame(width: 0, height: 0)
//                                            .preference(key: SizePreferenceKey.self, value: geo.frame(in: .global).minY)
//                                        )}.onPreferenceChange(SizePreferenceKey.self) { preferences in
//                                            self.scrollPosition = preferences
//                                            
//                                            if scrollPosition - geometry.safeAreaInsets.top <= 64 {
//                                                withAnimation(.easeInOut(duration: 0.1)) {
//                                                    self.showDivider = true
//                                                }
//                                            } else {
//                                                withAnimation(.easeInOut(duration: 0.1)) {
//                                                    self.showDivider = false
//                                                }
//                                            }
//                                        }
//                                    content
//                                }
//                            }
                            
//                        }
//                        VStack {
//                            Button {
//                                if Date().timeIntervalSince(lastDebugClick) > 1.0 {
//                                    debugClick = 0
//                                }
//                                lastDebugClick = Date()
//                                debugClick += 1
//                                if debugClick >= 5 {
//                                    debugClick = 0
//                                    debugView = true
//                                }
//                            } label: {
//                                VStack {
//                                    Spacer()
//                                }
//                                .frame(maxWidth: .infinity, maxHeight: (self.scrollPosition - geometry.safeAreaInsets.top).clamped(to: 0...geometry.size.height))
//                                
//                            }
//                            .navigationDestination(isPresented: $debugView){
//                                DebugMenu()
//                            }
//                            Spacer()
//                        }
//                    }
//                }
//            }
//            .background(Color("AppBackgroundColor"))
//        }
//    }
//}


//struct DeviceView: View {
//    @ObservedObject var bleManager = BLEManager.shared
//    @ObservedObject var bleManagerVal = BLEManagerVal.shared
//    @ObservedObject var deviceInfo = BLEDeviceInfo.shared
//    @ObservedObject var uptimeManager = UptimeManager.shared
//    
//    @AppStorage("watchNotifications") var watchNotifications: Bool = true
//    @AppStorage("batteryNotification") var batteryNotification: Bool = false
//    @AppStorage("autoconnectUUID") var autoconnectUUID: String = ""
//    @AppStorage("autoconnect") var autoconnect: Bool = false
//    @AppStorage("showDisconnectAlert") var showDisconnectConfDialog: Bool = false
//    @AppStorage("weatherData") var weatherData: Bool = true
//    
//    @State var currentUptime: TimeInterval!
//    @State var settings: Settings?
//    
//    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    
//    private var dateFormatter = DateComponentsFormatter()
//    
//    var icon: String {
//        switch bleManagerVal.weatherInformation.icon {
//        case 0:
//            return "sun.max.fill"
//        case 1:
//            return "cloud.sun.fill"
//        case 2, 3:
//            return "cloud.fill"
//        case 4, 5:
//            return "cloud.rain.fill"
//        case 6:
//            return "cloud.bolt.rain.fill"
//        case 7:
//            return "cloud.snow.fill"
//        case 8:
//            return "cloud.fog.fill"
//        default:
//            return "slash.circle"
//        }
//    }
//    
//    var body: some View {
//        CustomScrollView(settings: $settings) {
//            VStack(spacing: 10) {
//                VStack(alignment: .leading, spacing: 8) {
//                    StepButtonView()
//                    HeartButtonView()
//                    BatteryButtonView()
//                    if weatherData {
//                        VStack {
//                            HStack {
//                                VStack(alignment: .leading) {
//                                    Text(NSLocalizedString("weather", comment: ""))
//                                        .font(.headline)
//                                    if bleManagerVal.loadingWeather {
//                                        Text(NSLocalizedString("loading", comment: "Loading..."))
//                                    } else {
//                                        if (UnitTemperature.current == .celsius && deviceData.chosenWeatherMode == "System") || deviceData.chosenWeatherMode == "Metric" {
//                                            Text(String(Int(round(bleManagerVal.weatherInformation.temperature))) + "°" + "C")
//                                                .font(.title.weight(.semibold))
//                                        } else {
//                                            Text(String(Int(round(bleManagerVal.weatherInformation.temperature * 1.8 + 32))) + "°" + "F")
//                                                .font(.title.weight(.semibold))
//                                        }
//                                    }
//                                }
//                                .font(.title.weight(.semibold))
//                                Spacer()
//                                VStack {
//                                    if bleManagerVal.loadingWeather {
//                                        Image(systemName: "circle.slash")
//                                    } else {
//                                        Image(systemName: icon)
//                                    }
//                                }
//                                .font(.title.weight(.medium))
//                            }
//                        }
//                        .padding()
//                        .background(Color.gray.opacity(0.15))
//                        .foregroundColor(.primary)
//                        .cornerRadius(15)
//                    }
//                    NavigationLink(destination: DFUView()) {
//                        HStack {
//                            Text(NSLocalizedString("software_update", comment: ""))
//                                .multilineTextAlignment(.leading)
//                                .font(.title3.weight(.semibold))
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .font(.body.weight(.medium))
//                        }
//                        .aspectRatio(1, contentMode: .fill)
//                        .padding()
//                        .background(Color.gray.opacity(0.15))
//                        .foregroundColor(.primary)
//                        .cornerRadius(20)
//                    }
//                    Spacer()
//                        .frame(height: 6)
//                }
//                if DownloadManager.shared.updateAvailable {
//                    NavigationLink(destination: DFUView()) {
//                        VStack(alignment: .leading, spacing: 6) {
//                            HStack {
//                                Text(NSLocalizedString("software_update_available", comment: "Software Update Available"))
//                                    .font(.title3.weight(.semibold))
//                                Spacer()
//                                Image(systemName: "chevron.right")
//                                    .font(.body.weight(.medium))
//                            }
//                            Text(DownloadManager.shared.updateVersion)
//                                .foregroundColor(.gray)
//                                .font(.headline)
//                            Spacer()
//                                .frame(height: 5)
//                            Text(DownloadManager.shared.updateBody)
//                                .multilineTextAlignment(.leading)
//                                .lineLimit(4)
//                        }
//                        .foregroundColor(.primary)
//                        .modifier(RowModifier(style: .standard))
//                    }
//                }
//                VStack {
//                    NavigationLink(destination: RenameView()) {
//                        HStack {
//                            Text(NSLocalizedString("name", comment: ""))
//                            Text(deviceInfo.deviceName)
//                                .foregroundColor(.gray)
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(.gray)
//                        }
//                        .modifier(RowModifier(style: .capsule))
//                    }
//                    .opacity(bleManager.isConnectedToPinetime ? 1.0 : 0.5)
//                    .disabled(!bleManager.isConnectedToPinetime)
//                    HStack {
//                        Text(NSLocalizedString("software_version", comment: ""))
//                        Spacer()
//                        Text(deviceInfo.firmware)
//                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                        
//                    }
//                    .modifier(RowModifier(style: .capsule))
//                    HStack {
//                        Text(NSLocalizedString("model_name", comment: ""))
//                        Text(deviceInfo.modelNumber)
//                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                        
//                    }
//                    .modifier(RowModifier(style: .capsule))
//                    HStack {
//                        Text(NSLocalizedString("last_disconnect", comment: ""))
//                        Spacer()
//                        if UptimeManager.shared.lastDisconnect != nil {
//                            Text(uptimeManager.dateFormatter.string(from: uptimeManager.lastDisconnect))
//                                .foregroundColor(.gray)
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                        }
//                    }
//                    .modifier(RowModifier(style: .capsule))
//                    HStack {
//                        Text(NSLocalizedString("uptime", comment: ""))
//                        Spacer()
//                        if currentUptime != nil {
//                            Text((dateFormatter.string(from: currentUptime) ?? ""))
//                                .foregroundColor(.gray)
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                        }
//                    }
//                    .modifier(RowModifier(style: .capsule))
//                    NavigationLink(destination: WatchSettingsView()) {
//                        HStack {
//                            Text(NSLocalizedString("watch_settings", comment: ""))
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(.gray)
//                        }
//                        .modifier(RowModifier(style: .capsule))
//                    }
//                    .opacity(bleManager.isConnectedToPinetime ? 1.0 : 0.5)
//                    .disabled(!bleManager.isConnectedToPinetime)
//                }
//                .onReceive(timer, perform: { _ in
//                    if uptimeManager.connectTime != nil {
//                        currentUptime = -uptimeManager.connectTime.timeIntervalSinceNow
//                    }
//                })
//                Spacer()
//                    .frame(height: 6)
//                NavigationLink(destination: FileSystemView()) {
//                    HStack {
//                        Text(NSLocalizedString("file_system", comment: ""))
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
//                    }
//                    .modifier(RowModifier(style: .capsule))
//                }
//                Spacer()
//                    .frame(height: 6)
//                VStack {
//                    if bleManager.isConnectedToPinetime {
//                        Toggle(isOn: $bleManager.autoconnectToDevice) {
//                            Text(NSLocalizedString("autoconnect_to_this", comment: "") + " \(deviceInfo.modelNumber)")
//                        }.onChange(of: bleManager.autoconnectToDevice) { newValue in
//                            autoconnect = bleManager.autoconnectToDevice
//                            if bleManager.autoconnectToDevice == false {
//                                autoconnectUUID = ""
//                            } else {
//                                autoconnectUUID = bleManager.setAutoconnectUUID
//                            }
//                        }
//                        .modifier(RowModifier(style: .capsule))
//                    }
//                    Toggle(NSLocalizedString("enable_watch_notifications", comment: ""), isOn: $watchNotifications)
//                        .modifier(RowModifier(style: .capsule))
//                    Toggle(NSLocalizedString("notify_about_low_battery", comment: ""), isOn: $batteryNotification)
//                        .modifier(RowModifier(style: .capsule))
//                    Button {
//                        SheetManager.shared.sheetSelection = .notification
//                        SheetManager.shared.showSheet = true
//                    } label: {
//                        Text(NSLocalizedString("send_notification_to", comment: "") + " \(deviceInfo.modelNumber)")
//                            .frame(maxWidth: .infinity)
//                            .foregroundColor(.blue)
//                            .modifier(RowModifier(style: .capsule))
//                    }
//                    .opacity(!watchNotifications || !bleManager.isConnectedToPinetime ? 0.5 : 1.0)
//                    .disabled(!watchNotifications || !bleManager.isConnectedToPinetime)
//                    Button {
//                        BLEWriteManager.init().sendLostNotification()
//                    } label: {
//                        Text(NSLocalizedString("find_lost_device", comment: "") + " \(deviceInfo.modelNumber)")
//                            .frame(maxWidth: .infinity)
//                            .foregroundColor(.blue)
//                            .modifier(RowModifier(style: .capsule))
//                    }
//                    .opacity(!watchNotifications || !bleManager.isConnectedToPinetime ? 0.5 : 1.0)
//                    .disabled(!watchNotifications || !bleManager.isConnectedToPinetime)
//                }
//                Spacer()
//                    .frame(height: 6)
//                VStack {
//                    Button {
//                        showDisconnectConfDialog = true
//                    } label: {
//                        Text(NSLocalizedString("disconnect", comment: "") + " \(deviceInfo.modelNumber)")
//                            .frame(maxWidth: .infinity)
//                            .foregroundColor(.red)
//                            .font(.body.weight(.semibold))
//                            .modifier(RowModifier(style: .capsule))
//                    }
//                }
//            }
//            .padding(.horizontal)
//            .padding(.bottom)
//            .padding(.bottom)
//        }
//    }
//}


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
        GeometryReader { geometry in
            let topEdge = geometry.safeAreaInsets.top
            DeviceView(topEdge: topEdge)
                .onAppear {
                    BLEManager.shared.isConnectedToPinetime = true
                    BLEManagerVal.shared.firmwareVersion = "1.13.0"
                }
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
struct SizeBottomPreferenceKey: PreferenceKey {
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
