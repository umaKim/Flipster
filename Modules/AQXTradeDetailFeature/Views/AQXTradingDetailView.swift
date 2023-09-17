//
//  AQXTradingDetailView.swift
//  AQX
//
//  Created by 김윤석 on 2023/08/01.
//
import SwiftUIImageCachKit
import SwiftUI
import Combine
import Starscream

public enum AQXTradingDetailViewTradingType {
    case long
    case short
}

public enum AQXTradingDetailChartStatus: CGFloat {
    case show = 1
    case hide = 0
}

public enum LeverageType: Int, Identifiable {
    case none = 0
    case twentyFive = 25
    case fifty = 50
    case seventyFive = 75
    case hundered = 100
    
    public var id: Int {
        self.rawValue
    }
}

public struct AQXTradingDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: AQXTradingDetailViewModel
    @FocusState var focus: Bool
    
    public init(_ viewModel: AQXTradingDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        contentView
            .navigationBarHidden(true)
            .onAppear(perform: viewModel.onAppear)
            .onDisappear(perform: viewModel.onDisappear)
            .toolbar(.hidden, for: .tabBar)
            .background(Color(uiColor: .flipsterBlack))
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            navigationBar
            chartView
            leverageTypeBarView
            priceInputView
            Spacer()
            leveragePercentageButtonView
            numberKeyPadView
        }
        .animation(.easeInOut, value: viewModel.chartViewStatus)
    }
}

// Sub Components
extension AQXTradingDetailView {
    private var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    CacheImage(
                        urlString: viewModel.crypto?.image ?? "",
                        content: { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .cornerRadius(7.5)
                                
                            default:
                                Image(systemName: "exclamationmark.circle")
                            }
                        }
                    )
                    
                    Text("\(viewModel.crypto?.symbol.uppercased() ?? "")")
                        .bold()
                    
                }
                .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack {
                Text("\(viewModel.crypto?.currentPrice.decimalDigits(2) ?? "")")
                    .foregroundColor(Color(uiColor: .systemGray4))
                Text("\(viewModel.crypto?.priceChangePercentage24H.decimalDigits(2) ?? "")%")
                    .foregroundColor((viewModel.crypto?.priceChangePercentage24H ?? 0) > 0 ? .green : .red)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    if viewModel.chartViewStatus == .hide {
                        viewModel.chartViewStatus = .show
                    } else {
                        viewModel.chartViewStatus = .hide
                    }
                }
            } label: {
                HStack {
                    Text("Chart")
                        .bold()
                    Image(systemName: viewModel.chartViewStatus == .show ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
    
    private var chartView: some View {
        ZStack {
            switch viewModel.chartStatus {
            case .data(let data):
                ChartUIView(chartData: data)
                    .padding(.top)
            case .loading(let message):
                VStack(alignment: .center) {
                    Image(systemName: "chart.bar.fill")
                    Text(message)
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(Color(uiColor: .systemGray3))
            case .error(let message):
                VStack(alignment: .center) {
                    Image(systemName: "chart.bar.fill")
                    Text(message)
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(Color(uiColor: .systemGray3))
                
            case .none:
                EmptyView()
            }
        }
        .frame(height: UIScreen.main.bounds.height/2.8 * viewModel.chartViewStatus.rawValue)
    }
    
    private var leverageTypeBarView: some View {
        //long or short tab Bar
        HStack(spacing: 0) {
            BarButton(
                text: "Long",
                imageName: "chart.line.uptrend.xyaxis",
                onTap: {
                    viewModel.tradingType = .long
                }
            ).foregroundColor(viewModel.tradingType == .long ? Color.green : Color.gray)
            
            BarButton(
                text: "Short",
                imageName: "chart.line.downtrend.xyaxis",
                onTap: {
                    viewModel.tradingType = .short
                }
            ).foregroundColor(viewModel.tradingType == .short ? Color.red : Color.gray)
        }
        .padding(.top)
    }
    
    private var priceInputView: some View {
        HStack {
            Text(viewModel.priceInput)
                .placeholder(when: viewModel.priceInput.isEmpty) {
                    Text("Enter your funds")
                        .foregroundColor(.gray)
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .onTapGesture {
                    withAnimation {
                        viewModel.chartViewStatus = .hide
                    }
                }
            
            Spacer()
            
            Text("1x leverage")
                .foregroundColor(Color(uiColor: .systemGray))
        }
        .padding()
    }
    
    private var leveragePercentageButtonView: some View {
        VStack {
            HStack {
                ForEach(
                    viewModel.leverageTypes,
                    id: \.id
                ) { element in
                    Button {
                        viewModel.selectedLeverageType = element
                    } label: {
                        ZStack{
                            Rectangle()
                                .tint(Color(uiColor: viewModel.selectedLeverageType == element ? .systemBlue : .flipsterGray))
                            Text("\(element.rawValue)%")
                                .foregroundColor(Color(uiColor: viewModel.selectedLeverageType == element ? .white : .systemGray))
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
                        .foregroundColor(Color(uiColor: viewModel.reviewYourOrderButtonDisabled ? .systemGray : .systemBlue))
                    Text("Review your order")
                        .foregroundColor(Color(uiColor: viewModel.reviewYourOrderButtonDisabled ? .systemGray6 : .white))
                        .disabled(viewModel.reviewYourOrderButtonDisabled)
                }
            }
            .frame(height: 40)
            .padding(.horizontal)
            .cornerRadius(8)
            
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private var numberKeyPadView: some View {
        if viewModel.chartViewStatus == .hide {
            KeyPad(string: $viewModel.priceInput)
                .padding()
                .frame(height: 160)
                .padding(.bottom, 0)
                .transition(.move(edge: .bottom))
        }
    }
}
