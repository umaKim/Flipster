//
//  AQXTradingDetailView.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/01.
//
import Kingfisher
import SwiftUI
import Combine

enum AQXTradingDetailViewTradingType {
    case long
    case short
}

enum AQXTradingDetailChartStatus: CGFloat {
    case show = 1
    case hide = 0
}

enum LeverageType: Int, Identifiable {
    case none = 0
    case twentyFive = 25
    case fifty = 50
    case seventyFive = 75
    case hundered = 100
    
    var id: Int {
        self.rawValue
    }
}

struct AQXTradingDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var vm: AQXTradingDetailViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            chartView
            
            leverageTypeBarView
            
            HStack {
                TextField(
                    "",
                    text: $vm.priceInput,
                    onEditingChanged: { _ in
                        withAnimation {
                            vm.chartViewStatus = .hide
                        }
                    }
                )
                .placeholder(when: vm.priceInput.isEmpty) {
                        Text("Enter your funds")
                        .foregroundColor(.gray)
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                
                Text("1x leverage")
                    .foregroundColor(Color(uiColor: .systemGray))
            }
            .padding()
            .animation(.easeInOut, value: vm.chartViewStatus)
            
            Spacer()
            
            leveragePercentageButtonView
            
            if vm.chartViewStatus == .hide {
                KeyPad(string: $vm.priceInput)
                    .padding()
                    .frame(height: 160)
                    .padding(.bottom, 0)
                    .transition(.move(edge: .bottom))
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            vm.onDisappear()
        }
        .background(Color(uiColor: .flipsterBlack))
    }
}

// Sub Components
extension AQXTradingDetailView {
    private var navigationBar: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    KFImage(.init(string: vm.crypto?.image ?? ""))
                        .placeholder({ progress in
                            Image(systemName: "person.circle")
                        })
                        .resizable()
                        .frame(width: 15, height: 15)
                        .cornerRadius(7.5)
                    
                    Text("\(vm.crypto?.symbol.uppercased() ?? "")")
                        .bold()
                    
                }
                .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack {
                Text("\(vm.crypto?.currentPrice.decimalDigits(2) ?? "")")
                    .foregroundColor(Color(uiColor: .systemGray4))
                Text("\(vm.crypto?.priceChangePercentage24H.decimalDigits(2) ?? "")%")
                    .foregroundColor((vm.crypto?.priceChangePercentage24H ?? 0) > 0 ? .green : .red)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    if vm.chartViewStatus == .hide {
                        vm.chartViewStatus = .show
                    } else {
                        vm.chartViewStatus = .hide
                    }
                }
            } label: {
                HStack {
                    Text("Chart")
                        .bold()
                    Image(systemName: vm.chartViewStatus == .show ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
    
    private var chartView: some View {
        ZStack {
            ChartUIView(chartData: vm.chartData)
                .padding(.top)
            
            if vm.chartData == nil {
                VStack(alignment: .center) {
                    Image(systemName: "chart.bar.fill")
                    Text("Loading...")
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(Color(uiColor: .systemGray3))
            }
        }
        .frame(height: UIScreen.main.bounds.height/2.8 * vm.chartViewStatus.rawValue)
        .animation(.default, value: vm.chartViewStatus)
    }
    
    private var leverageTypeBarView: some View {
        //long or short tab Bar
        HStack(spacing: 0) {
            Button {
                vm.tradingType = .long
            } label: {
                VStack(spacing: 6) {
                    HStack {
                        Text("Long")
                            .bold()
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    
                    Rectangle()
                        .background(.green)
                        .frame(height: 3)
                }
                .frame(width: UIScreen.main.bounds.width/2)
            }
            .foregroundColor(vm.tradingType == .long ? Color.green : Color.gray)
            
            Button {
                vm.tradingType = .short
            } label: {
                VStack(spacing: 6) {
                    
                    HStack(alignment: .center) {
                        Text("Short")
                            .bold()
                        Image(systemName: "chart.line.downtrend.xyaxis")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    
                    Rectangle()
                        .background(.red)
                        .frame(height: 3)
                }
                .frame(width: UIScreen.main.bounds.width/2)
            }
            .foregroundColor(vm.tradingType == .short ? Color.red : Color.gray)
        }
        .padding(.top)
        .animation(.default, value: vm.chartViewStatus)
    }
    
    private var leveragePercentageButtonView: some View {
        VStack {
            HStack {
                ForEach(
                    vm.leverageTypes,
                    id: \.id
                ) { element in
                    Button {
                        vm.selectedLeverageType = element
                    } label: {
                        ZStack{
                            Rectangle()
                                .tint(Color(uiColor: vm.selectedLeverageType == element ? .systemBlue : .flipsterGray))
                            Text("\(element.rawValue)%")
                                .foregroundColor(Color(uiColor: vm.selectedLeverageType == element ? .white : .systemGray))
                        }
                        .frame(width: (UIScreen.main.bounds.width / 4) - 15, height: 30)
                        .cornerRadius(8)
                    }
                }
            }
            
            Button {
                // reviewYourOrder Button tapped logic
            } label: {
                ZStack{
                    Rectangle()
                        .tint(Color(uiColor: .systemGray))
                    Text("Review your order")
                        .foregroundColor(Color(uiColor: vm.reviewYourOrderButtonDisabled ? .systemGray6 : .red))
                        .disabled(vm.reviewYourOrderButtonDisabled)
                }
            }
            .frame(height: 40)
            .padding(.horizontal)
            .cornerRadius(8)
            
        }
        .animation(.default, value: vm.chartViewStatus)
    }
    
}
