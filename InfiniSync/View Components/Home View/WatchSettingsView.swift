//
//  WatchSettingsView.swift
//  InfiniLink
//
//  Created by Liam Willey on 2/11/24.
//

import SwiftUI

struct WatchSettingsView: View {
    @ObservedObject var bleManagerVal = BLEManagerVal.shared
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presMode
    
    @State var settings: Settings? = nil
    
    @State var hasMadeChanges = false
    
    @State var watchfaces: [String] = ["digital24H", "analog", "PTS24HStepStyle1", "terminal24H"]
    @State var selection = 0
    
    var body: some View {
        VStack {
            if UptimeManager.shared.connectTime != nil {
                content
            } else {
                DFUWithoutBLE(title: NSLocalizedString("pinetime_not_available", comment: ""), subtitle: NSLocalizedString("please_check_your_connection_and_try_again", comment: ""))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackgroundColor"))
    }
    
    var content: some View {
        VStack(spacing: 0) {
            ZStack() {
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.medium)
                        .font(.body.weight(.semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                        .frame(minWidth: 48, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(NSLocalizedString("watch_settings", comment: ""))
                    .foregroundColor(.primary)
                    .font(.title3.weight(.semibold))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            Divider()
            if let settings = settings {
                GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            HStack {
                                TabView(selection: $selection) {
                                    ForEach(watchfaces.indices, id: \.self) { index in
                                        HStack {
                                            Spacer()
                                            VStack {
                                                Spacer()
                                                WatchFaceView(watchface: .constant(index))
                                                    .frame(width: geometry.size.width / 2.4, height: geometry.size.width / 2.4, alignment: .center)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                            .frame(minHeight: 265)
                            .padding(-16)
                            .onChange(of: selection) { newWatchface in
                                if newWatchface != settings.watchFace {
                                    hasMadeChanges = true
                                } else {
                                    hasMadeChanges = false
                                }
                            }
                        }
                        VStack {
                            HStack {
                                Text(NSLocalizedString("display_timeout", comment: ""))
                                Spacer()
                                Text("\(settings.screenTimeOut / 1000) Seconds")
                                    .foregroundColor(.gray)
                            }
                            .modifier(RowModifier(style: .capsule))
                            HStack {
                                Text(NSLocalizedString("display_wakeup", comment: ""))
                                Spacer()
                                Group {
                                    // TODO: Add handling for multiple cases
                                    switch settings.wakeUpMode {
                                    case .SingleTap:
                                        Text("Single Tap")
                                    case .DoubleTap:
                                        Text("Double Tap")
                                    case .RaiseWrist:
                                        Text("Raise Wrist")
                                    case .Shake:
                                        Text("Shake Wake")
                                    case .LowerWrist:
                                        Text("Lower Wrist")
                                    }
                                }
                                .foregroundColor(.gray)
                            }
                            .modifier(RowModifier(style: .capsule))
                            HStack {
                                Text(NSLocalizedString("time_format", comment: ""))
                                Spacer()
                                Group {
                                    switch settings.clockType {
                                    case .H12:
                                        Text("12 Hour")
                                    case .H24:
                                        Text("24 Hour")
                                    }
                                }
                                .foregroundColor(.gray)
                            }
                            .modifier(RowModifier(style: .capsule))
                            HStack {
                                Text(NSLocalizedString("steps_goal", comment: ""))
                                Spacer()
                                Text("\(settings.stepsGoal)")
                                    .foregroundColor(.gray)
                            }
                            .modifier(RowModifier(style: .capsule))
                            HStack {
                                Text(NSLocalizedString("weather", comment: ""))
                                Spacer()
                                Group {
                                    switch settings.weatherFormat {
                                    case .Metric:
                                        Text("Metric")
                                    case .Imperial:
                                        Text("Imperial")
                                    }
                                }
                                .foregroundColor(.gray)
                            }
                            .modifier(RowModifier(style: .capsule))
                            HStack {
                                Text(NSLocalizedString("hourly_chimes", comment: ""))
                                Spacer()
                                Group {
                                    switch settings.chimesOption {
                                    case .None:
                                        Text("None")
                                    case .Hours:
                                        Text("Hour")
                                    case .HalfHours:
                                        Text("Half Hour")
                                    }
                                }
                                .foregroundColor(.gray)
                            }
                            .modifier(RowModifier(style: .capsule))
                        }
                        .padding()
                    }
                }
            } else {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .onAppear {
            if let settings = settings {
                self.selection = Int(settings.watchFace)
            } else {
                BLEFSHandler.shared.readSettings { settings in
                    self.settings = settings
                    self.selection = Int(settings.watchFace)
                    self.bleManagerVal.watchFace = Int(settings.watchFace)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
}

struct WatchFaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .padding(.vertical, 4)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(.gray, lineWidth: 1)
                    .opacity(0.4)
            )
            .frame(maxWidth: 155, maxHeight: 155)
    }
}

#Preview {
    WatchSettingsView(settings: Settings(version: 7, stepsGoal: 10000, screenTimeOut: 1500, clockType: .H12, weatherFormat: .Imperial, notificationStatus: .On, watchFace: 2, chimesOption: .None, pineTimeStyle: .init(), watchFaceInfineat: .init(), wakeUpMode: .SingleTap, shakeWakeThreshold: 1500, brightLevel: 1))
}
