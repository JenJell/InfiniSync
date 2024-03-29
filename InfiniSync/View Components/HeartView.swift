//
//  StepsView.swift
//  InfiniLink
//
//  Created by Alex Emry on 10/21/21.
//
//


import SwiftUI

struct HeartView: View {
    @AppStorage("lastStatusViewWasHeart") var lastStatusViewWasHeart: Bool = false
    
    @ObservedObject var bleManagerVal = BLEManagerVal.shared
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presMode
    
    let chartManager = ChartManager.shared
    
    @State private var animationAmount: CGFloat = 1
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ChartDataPoint.timestamp, ascending: true)], predicate: NSPredicate(format: "chart == 0"))
    private var chartPoints: FetchedResults<ChartDataPoint>
    
    var body: some View {
        let dataPoints = ChartManager.shared.convert(results: chartPoints)
        
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
                Text(NSLocalizedString("heart_rate", comment: "Heart Rate"))
                    .foregroundColor(.primary)
                    .font(.title3.weight(.semibold))
                Button {
                    chartManager.currentChart = .heart
                    SheetManager.shared.sheetSelection = .chartSettings
                    SheetManager.shared.showSheet = true
                } label: {
                    Image(systemName: "gear")
                        .imageScale(.medium)
                        .font(.body.weight(.semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                        .frame(minWidth: 48, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            Divider()
            if dataPoints.count < 2 {
                VStack(alignment: .center, spacing: 14) {
                    Spacer()
                    Image(systemName: "heart")
                        .imageScale(.large)
                        .font(.system(size: 30).weight(.semibold))
                        .foregroundColor(.red)
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("oops", comment: ""))
                            .font(.largeTitle.weight(.bold))
                        Text(NSLocalizedString("insufficient_heart_rate_data", comment: ""))
                            .font(.title3.weight(.semibold))
                    }
                    Spacer()
                }
            } else {
                VStack {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 10.0)
                            .opacity(0.3)
                            .foregroundColor(Color.gray)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(bleManagerVal.heartBPM / 250, 1.0)))
                            .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.red)
                            .rotationEffect(Angle(degrees: 90.0 - Double(bleManagerVal.heartBPM / 250) * 180.0))
                        VStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 35))
                                .imageScale(.large)
                            
                            Text(String(format: "%.0f", bleManagerVal.heartBPM) + " " + NSLocalizedString("bpm", comment: "BPM"))
                                .font(.system(size: 32).weight(.bold))
                        }
                        .foregroundColor(.red)
                    }
                    .padding(30)
                }
                VStack {
                    HeartChart()
                        .padding(.top, 10)
                }
                .ignoresSafeArea()
                .padding(20)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            chartManager.currentChart = .heart
            lastStatusViewWasHeart = true
        }
    }
}

#Preview {
    NavigationView {
        HeartView()
    }
}
