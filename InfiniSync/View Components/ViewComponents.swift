//
//  ViewComponents.swift
//  InfiniSync
//
//  Created by Jen on 2/13/24.
//

import Foundation
import SwiftUI


struct CustomStackView<Title: View, Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let stopHeight: CGFloat = 80
    
    var titleView: Title
    var contentView: Content
    var topEdge: CGFloat
    
    @State var topOffset: CGFloat = 0
    @State var bottomOffset: CGFloat = 0
    
    init(_ topEdge: CGFloat, @ViewBuilder titleView: @escaping ()->Title, @ViewBuilder contentView: @escaping ()->Content) {
        self.titleView = titleView()
        self.contentView = contentView()
        self.topEdge = topEdge
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
                .font(.callout)
                .lineLimit(1)
                .frame(height: 38)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .background(Color("AppSecondaryColor"), in: CustomCorner(corners: bottomOffset < 38 ? .allCorners : [.topLeft, .topRight], radius: 12))
                .zIndex(1)
            
            VStack {
                Divider()
                    .padding(.horizontal)
                
                contentView
                    .padding([.horizontal, .bottom])
            }
            .background(Color("AppSecondaryColor"), in: CustomCorner(corners: [.bottomLeft, .bottomRight], radius: 12))
            .offset(y: topOffset >= stopHeight + topEdge ? 0 : -(-topOffset + stopHeight + topEdge))
            .zIndex(0)
            .clipped()
            .opacity(getOpacity())
        }
        .cornerRadius(12)
        .opacity(getOpacity())
        .offset(y: topOffset >= stopHeight + topEdge ? 0 : -topOffset + stopHeight + topEdge)
        .overlay(
            GeometryReader{ geo in
                AnyView(Color.clear
                    .frame(width: 0, height: 0)
                    .preference(key: SizePreferenceKey.self, value: geo.frame(in: .global).minY)
                    .preference(key: SizeBottomPreferenceKey.self, value: geo.frame(in: .global).maxY)
                )}.onPreferenceChange(SizePreferenceKey.self) { preferences in
                    self.topOffset = preferences
                }.onPreferenceChange(SizeBottomPreferenceKey.self) { preferences in
                    self.bottomOffset = preferences - (stopHeight + topEdge)
                })
        .modifier(CornerModifier(bottomOffset: $bottomOffset, topEdge: topEdge))
    }
    
    func getOpacity() -> CGFloat {
        if bottomOffset < 28 {
            let progress = bottomOffset / 28
            
            return progress
        }
        return 1
    }
}

struct CustomButtonView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    let stopHeight: CGFloat = 80
    
    var contentView: Content
    var topEdge: CGFloat
    
    @State var topOffset: CGFloat = 0
    @State var bottomOffset: CGFloat = 0
    
    init(_ topEdge: CGFloat, @ViewBuilder contentView: @escaping ()->Content) {
        self.contentView = contentView()
        self.topEdge = topEdge
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                contentView
                    .padding()
            }
            .background(Color("AppSecondaryColor"), in: CustomCorner(corners: [.allCorners], radius: 12))
            .zIndex(0)
            .opacity(getOpacity())
        }
        .cornerRadius(12)
        .opacity(getOpacity())
        .offset(y: topOffset >= stopHeight + topEdge ? 0 : -topOffset + stopHeight + topEdge)
        .overlay(
            GeometryReader{ geo in
                AnyView(Color.clear
                    .frame(width: 0, height: 0)
                    .preference(key: SizePreferenceKey.self, value: geo.frame(in: .global).minY)
                    .preference(key: SizeBottomPreferenceKey.self, value: geo.frame(in: .global).maxY)
                )}.onPreferenceChange(SizePreferenceKey.self) { preferences in
                    self.topOffset = preferences
                }.onPreferenceChange(SizeBottomPreferenceKey.self) { preferences in
                    self.bottomOffset = preferences - (stopHeight + topEdge)
                })
    }
    
    func getOpacity() -> CGFloat {
        if bottomOffset < 28 {
            let progress = bottomOffset / 28
            
            return progress
        }
        return 1
    }
}

struct CornerModifier: ViewModifier {
    @Binding var bottomOffset: CGFloat
    var topEdge: CGFloat
    
    func body(content: Content) -> some View {
        if bottomOffset < 38 {
            content
        } else {
            content
                .cornerRadius(12)
        }
    }
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in ract: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: ract, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct LoadingIcon: View {
    @State private var isRotating = 0.0
    
    var body: some View {
        ZStack {
            ZStack {
                Image("InfiniSyncLoadingBase")
                    .resizable()
                    .rotationEffect(.degrees(isRotating))
//                Image("InfiniSyncLoadingHands")
//                    .resizable()
            }
            .aspectRatio(contentMode: .fit)
            .onAppear {
                withAnimation(.linear(duration: 0.75)
                    .speed(1.0).repeatForever(autoreverses: false)) {
                        isRotating = 360.0
                    }
            }
            .frame(maxWidth: 32, maxHeight: 32, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    NavigationView {
        GeometryReader { geometry in
            let topEdge = geometry.safeAreaInsets.top
            DeviceView(topEdge: topEdge)
                .onAppear {
                    BLEManager.shared.isConnectedToPinetime = true
                    BLEManagerVal.shared.firmwareVersion = "1.14.0"
                }
        }
    }
}
