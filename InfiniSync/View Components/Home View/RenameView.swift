//
//  RenamedView.swift
//  InfiniLink
//
//  Created by John Stanley on 11/16/21.
//

import SwiftUI

struct RenameView: View {
    @ObservedObject var bleManager = BLEManager.shared
    @ObservedObject var deviceInfo = BLEDeviceInfo.shared
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var changedName: String = BLEDeviceInfo.shared.deviceName
    private var nameManager = DeviceNameManager()
    
    @FocusState var keyboardFocused
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack() {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.medium)
                        .font(.body.weight(.semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                        .frame(minWidth: 48, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(NSLocalizedString("name", comment: ""))
                    .foregroundColor(.primary)
                    .font(.title3.weight(.semibold))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            Divider()
            VStack {
                TextField("InfiniTime", text: $changedName)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Capsule())
                    .submitLabel(.done)
                    .onSubmit {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        nameManager.updateName(deviceUUID: bleManager.infiniTime.identifier.uuidString, name: changedName)
                        changedName = ""
                        presentationMode.wrappedValue.dismiss()
                    }
                    .focused($keyboardFocused)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                keyboardFocused = true
                            }
                        }
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    RenameView()
}
