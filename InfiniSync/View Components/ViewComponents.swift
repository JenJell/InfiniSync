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
    var titleView: Title
    var contentView: Content
    
    init(@ViewBuilder titleView: @escaping ()->Title, @ViewBuilder contentView: @escaping ()->Content) {
        self.titleView = titleView()
        self.contentView = contentView()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
                .font(.callout)
                .lineLimit(1)
                .frame(height: 38)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .background(Color("AppSecondaryColor"), in: CustomCorner(corners: [.topLeft, .topRight], radius: 12))
            
            VStack {
                Divider()
                    .padding(.horizontal)
                
                contentView
                    .padding()
            }
            .background(Color("AppSecondaryColor"), in: CustomCorner(corners: [.bottomLeft, .bottomRight], radius: 12))
        }
        //.colorScheme(.dark)
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
    ProgressView()
}
