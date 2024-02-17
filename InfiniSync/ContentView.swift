//
//  ContentView.swift
//  InfiniLink
//
//  Created by Alex Emry on 8/5/21.
//

import SwiftUI

enum Tab {
    case home
    case settings
}

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var batteryNotifications = BatteryNotifications()
    @ObservedObject var sheetManager = SheetManager.shared
    @ObservedObject var deviceInfo = BLEDeviceInfo.shared
    
    @ObservedObject var deviceDataForTopLevel: DeviceData = deviceData
    @State var selection: Tab = .home
    
    
    @AppStorage("autoconnect") var autoconnect: Bool = false
    @AppStorage("autoconnectUUID") var autoconnectUUID: String = ""
    @AppStorage("batteryNotification") var batteryNotification: Bool = false
    @AppStorage("onboarding") var onboarding: Bool!// = false
    @AppStorage("lastVersion") var lastVersion: String = ""
    @AppStorage("showDisconnectAlert") var showDisconnectConfDialog: Bool = false
    
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    private func switchToTab(tab: Tab) {
        selection = tab
        
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }
    
    var body: some View {
        GeometryReader { geometry in
            let topEdge = geometry.safeAreaInsets.top
            NavigationView {
                WelcomeView(topEdge: topEdge)
                    .alert(isPresented: $bleManager.setTimeError, content: {
                        Alert(title: Text(NSLocalizedString("failed_set_time", comment: "")), message: Text(NSLocalizedString("failed_set_time_description", comment: "")), dismissButton: .default(Text(NSLocalizedString("dismiss_button", comment: ""))))})
                    .alert(isPresented: $showDisconnectConfDialog) {
                        Alert(title: Text(NSLocalizedString("disconnect_alert_title", comment: "")), primaryButton: .destructive(Text(NSLocalizedString("disconnect", comment: "Disconnect")), action: bleManager.disconnect), secondaryButton: .cancel())
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .blurredSheet(.init(.regularMaterial), show: $sheetManager.showSheet) {} content: {
                SheetManager.CurrentSheet()
                    .onDisappear {
                        if !sheetManager.upToDate {
                            if onboarding == nil {
                                onboarding = false
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                if !bleManager.isConnectedToPinetime {
                    if bleManager.isSwitchedOn {
                        self.bleManager.startScanning()
                    }
                }
            }
            .preferredColorScheme((deviceDataForTopLevel.chosenTheme == "System") ? nil : appThemes[deviceDataForTopLevel.chosenTheme])
            .onChange(of: bleManager.batteryLevel) { bat in
                batteryNotifications.notify(bat: Int(bat), bleManager: bleManager)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification), perform: { output in
                if bleManager.isConnectedToPinetime {
                    ChartManager.shared.addItem(dataPoint: DataPoint(date: Date(), value: 0, chart: ChartsAsInts.connected.rawValue))
                }
            })
        }
    }
    
    var tabBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                TabBarItem(selection: $selection, tab: .home, imageName: "house")
                    .onTapGesture {
                        switchToTab(tab: .home)
                    }
                    .frame(maxWidth: .infinity)
                
                TabBarItem(selection: $selection, tab: .settings, imageName: "gear")
                    .onTapGesture {
                        switchToTab(tab: .settings)
                    }
                    .frame(maxWidth: .infinity)
            }
            .padding(12)
        }
    }
}

struct CustomBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .red
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct PresentationBackgroundView: UIViewRepresentable {
    
    var presentationBackgroundColor = Color.clear

    @MainActor
    private static var backgroundColor: UIColor?
    
    func makeUIView(context: Context) -> UIView {
        
        class DummyView: UIView {
            var presentationBackgroundColor = UIColor.clear
            
            override func didMoveToSuperview() {
                super.didMoveToSuperview()
                superview?.superview?.backgroundColor = presentationBackgroundColor
            }
        }
        
        let presentationBackgroundUIColor = UIColor(presentationBackgroundColor)
        let dummyView = DummyView()
        dummyView.presentationBackgroundColor = presentationBackgroundUIColor
        
        Task {
            Self.backgroundColor = dummyView.superview?.superview?.backgroundColor
            dummyView.superview?.superview?.backgroundColor = presentationBackgroundUIColor
        }
        
        return dummyView
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        uiView.superview?.superview?.backgroundColor = Self.backgroundColor
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { /* likely there is need to update */}
}

extension View {
    func presentationBackground(_ color: Color = .clear) -> some View {
        self.background(PresentationBackgroundView(presentationBackgroundColor: color))
    }
}

struct TabBarItem: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selection: Tab
    let tab: Tab
    let imageName: String
    
    var body: some View {
        if selection == tab {
            HStack {
                Image(systemName: imageName)
                Text(tab == .home ? NSLocalizedString("home", comment: "") : NSLocalizedString("settings", comment: ""))
            }
            .imageScale(.large)
            .font(.body.weight(.semibold))
            .foregroundColor(colorScheme == .dark ? .white : .darkestGray)
            .cornerRadius(10)
            .padding(8)
        } else {
            HStack {
                Image(systemName: imageName)
                Text(tab == .home ? NSLocalizedString("home", comment: "") : NSLocalizedString("settings", comment: ""))
            }
            .foregroundColor(Color.gray)
            .imageScale(.large)
            .padding(8)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BLEManager())
        .environmentObject(DFU_Updater())
}

let deviceData: DeviceData = DeviceData()
