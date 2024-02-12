//
//  Extensions.swift
//  InfiniLink
//
//  Created by Liam Willey on 1/5/24.
//

import Foundation
import UIKit
import SwiftUI

extension View {
    func blurredSheet<Content: View>(_ style: AnyShapeStyle,show: Binding<Bool>,onDismiss: @escaping ()->(),@ViewBuilder content: @escaping ()->Content)->some View{
        self
            .sheet(isPresented: show, onDismiss: onDismiss) {
                if #available(iOS 16.4, *) {
                    content()
                        .presentationBackground(style)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    content()
                        .background(RemovebackgroundColor())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background {
                            Rectangle()
                                .fill(style)
                                .ignoresSafeArea(.container, edges: .all)
                            }
                }
            }
    }
}

extension UINavigationController {
    override open func viewDidLoad() {
        @AppStorage("lockNavigation") var lockNavigation = false
        
        super.viewDidLoad()
        if !lockNavigation {
            interactivePopGestureRecognizer?.delegate = nil
        }
    }
}

fileprivate struct RemovebackgroundColor: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            uiView.superview?.superview?.backgroundColor = .clear
        }
    }
}
