//
//  WelcomeView.swift
//  InfiniLink
//
//  Created by John Stanley on 5/2/22.
//

import SwiftUI
import SpriteKit

struct WelcomeView: View {
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var deviceInfo = BLEDeviceInfo.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if !bleManager.isConnectedToPinetime || deviceInfo.firmware == "" {
                if bleManager.isConnectedToPinetime {
                    ZStack {
                        DeviceView()
                            .disabled(true)
                            .blur(radius: 64)
                        Rectangle()
                            .ignoresSafeArea()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.background)
                            .opacity(0.25)
                        VStack(spacing: 16) {
                            Text(NSLocalizedString("connecting", comment: "Connecting..."))
                                .font(.title.weight(.semibold))
                            Button {
                                bleManager.disconnect()
                            } label: {
                                Text(NSLocalizedString("stop_connecting", comment: "Stop Connecting"))
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                } else {
                    ZStack {
//                        GeometryReader{_ in
//                            SpriteView(scene: Background(), options: [.allowsTransparency])
//                        }
//                        .blur(radius: 64)
//                        .opacity(0.35)
//                        .ignoresSafeArea()
                        
                        GeometryReader { geometry in
                            Image("WatchHomePagePineTime")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 2.0, height: geometry.size.width * 2.0, alignment: .center)
                                .position(x: geometry.size.width / 2.0, y: geometry.size.height / 2.065)
                                .shadow(color: colorScheme == .dark ? Color.darkGray : Color.lightGray, radius: 128, x: 0, y: 0)
                                .brightness(colorScheme == .dark ? -0.01 : 0.06)
                            Text("Welcome to\nInfiniSync")
                                .font(.system(size: geometry.size.width / 12).weight(.semibold))
                                .foregroundColor(colorScheme == .dark ? Color.lightGray : Color.darkGray)
                                .position(x: geometry.size.width / 2.0, y: geometry.size.height / 7.5)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        VStack() {
                            VStack(spacing: 5) {
                                Spacer()
                                //if bleManager.isSwitchedOn {
                                Button(NSLocalizedString("start_pairing", comment: "")) {
                                    SheetManager.shared.sheetSelection = .connect
                                    SheetManager.shared.showSheet = true
                                }
                                .buttonStyle(NeumorphicButtonStyle(bgColor: colorScheme == .dark ? Color.darkGray : Color.lightGray))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 15)
                                .padding(.horizontal)
                                .onAppear {
                                    if bleManager.isSwitchedOn {
                                        bleManager.startScanning()
                                    }
                                }
                                Text("Don't have a Watch?")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.horizontal)
                                    .foregroundColor(.gray)
                                Link(destination: URL(string: "https://wiki.pine64.org/wiki/PineTime")!) {
                                    Text("Learn more about the PineTime")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .foregroundColor(.blue)
                                        .padding(.bottom, 5)
                                        .padding(.horizontal)
                                        .font(.body.weight(.semibold))
                                }
                            }
                            .padding()
                        }
                    }
                }
                
            } else {
                DeviceView()
            }
        }
        .background {
            ZStack {
                VStack {
                    Circle()
                        .fill(Color("Blue"))
                        .scaleEffect(0.7)
                        .offset(x: 20)
                        .blur(radius: 60)
                    Circle()
                        .fill(Color("Blue"))
                        .scaleEffect(0.7, anchor: .leading)
                        .offset(y: -20)
                        .blur(radius: 56)
    
                }
                Rectangle()
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .opacity(0.9)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            if bleManager.isSwitchedOn {
                bleManager.startScanning()
            }
        }
        .onDisappear {
            if bleManager.isScanning {
                bleManager.stopScanning()
            }
        }
        .navigationBarHidden(true)
        
    }
    
}

struct NeumorphicButtonStyle: ButtonStyle {
    var bgColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.body.weight(.semibold))
            .foregroundColor(Color.white)
            .background(Color.blue)
            .clipShape(Capsule())
            .foregroundColor(.primary)
    }
}

class Background: SKScene {
    override func sceneDidLoad() {
        size = UIScreen.main.bounds.size
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        scaleMode = .resizeFill
        
        backgroundColor = .clear
        
        let node = SKEmitterNode(fileNamed: "Background.sks")!
        addChild(node)
        
        node.particlePositionRange.dx = UIScreen.main.bounds.width
        node.particlePositionRange.dy = UIScreen.main.bounds.height
    }
}

#Preview {
    NavigationView {
        ContentView()
            .onAppear {
                BLEManager.shared.isConnectedToPinetime = false
                //BLEManagerVal.shared.firmwareVersion = "1.13.0"
            }
    }
}
