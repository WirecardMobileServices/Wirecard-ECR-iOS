//
//  ContentView.swift
//  EcrDemo
//
//  Created by Danko, Radoslav on 06/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI
import Combine
import WDEcr

let kEcrHost: String = "kEcrHost"
let kEcrPort: String = "kEcrPort"

public enum ActionType: String, CaseIterable {
    case echo = "Echo"
    case pairing = "Pairing"
    case sale = "Sale"
    case preAuth = "Pre-Auth"
    case refund = "Refund"
    case installment = "Installment"
    case void = "Void"
    case settlement = "Settlement"
    case getLastTransaction = "Get Last Transaction"
    case getLastSettlement = "Get Last Settlement"
}

class TransactionViewModel: ObservableObject {
    
    @Published var host: String = "" {
        didSet {
            if host.count > 0 {
                UserDefaults.standard.set(host, forKey: kEcrHost)
            }
        }
    }
    @Published var port: String = "" {
        didSet {
            if port.count > 0 {
                UserDefaults.standard.set(port, forKey: kEcrPort)
            }
        }
    }
    
    @Published var deviceId: String = ""
    @Published var amount: String = ""
    @Published var selectedPaymentType: EcrTypes.PaymentType?
    @Published var order: String = ""
    @Published var tenure: String = ""
    @Published var invoiceNumber: String = ""
    
    @Published var shouldPerformRequest: Bool = false {
        didSet {
            executeEcr()
        }
    }
    @Published var transactionType: ActionType?
    @Published var saleRequest: EcrModel.Sale.Request?
    @Published var ecrResult: String? = ""
    
    private var ecr: Ecr<TcpIpDevice,JsonWrapper>?
    private var cancellable: Cancellable?
    
    init() {
        if let hostFromUserDefaults = UserDefaults.standard.string(forKey: kEcrHost) {
            self.host = hostFromUserDefaults
        }
        
        if let portFromUserDefaults = UserDefaults.standard.string(forKey: kEcrPort) {
            self.port = portFromUserDefaults
        }
        else {
            self.port = "7890"
        }
    }
    
    private func validateDevice() -> (host: String, port: UInt32)? {
        let validIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
        
        guard host.range(of: validIpAddressRegex, options: .regularExpression) != nil else {
            ecrResult?.append("\nError:\nInvalid port number")
            return nil
        }
        
        guard let port = UInt32(port) else {
            ecrResult?.append("\nError:\nInvalid port number")
            return nil
        }
        
        return (host, port)
    }
    
    private func validatePaymentType() -> EcrTypes.PaymentType? {
        guard let paymentType = selectedPaymentType else {
            ecrResult?.append("\nError:\nMissing Payment type")
            return nil
        }
        return paymentType
    }
    
    private func executeEcr() {
        
        ecrResult = ""
        
        guard let validatedHostPort = validateDevice() else { return }
        
        let ecr = Ecr<TcpIpDevice, JsonWrapper>(
            device: TcpIpDevice(
                ip: validatedHostPort.host,
                port: validatedHostPort.port
            )
        )

        // FIXME: - Validate input date before creating requests
        switch transactionType {
        case .echo:
            log(request: EcrModel.Echo.Request(deviceId: deviceId))
            handle(publisher: ecr.echo(deviceId: deviceId).eraseToAnyPublisher())
        case .pairing:
            let request = EcrModel.Pairing.RequestBody(deviceId: deviceId)
            log(request: EcrModel.Pairing.Request(requestBody: request))
            handle(publisher: ecr.pairing(request).eraseToAnyPublisher())
        case .settlement:
            log(request: EcrModel.Settlement.Request(deviceId: deviceId))
            handle(publisher: ecr.settlement(deviceId: deviceId).eraseToAnyPublisher())
        case .getLastTransaction:
        log(request: EcrModel.GetLastTransaction.Request(deviceId: deviceId))
            handle(publisher: ecr.getLastTransaction(deviceId: deviceId).eraseToAnyPublisher())
        case .getLastSettlement:
            log(request: EcrModel.GetLastSettlement.Request(deviceId: deviceId))
            handle(publisher: ecr.getLastSettlement(deviceId: deviceId).eraseToAnyPublisher())
        case .sale:
            guard let paymentType = validatePaymentType() else { return }
            let request = EcrModel.Sale.RequestBody(
                transactionAmount: amount,
                paymentType: paymentType,
                orderId: order,
                deviceId: deviceId
            )
            perform(request: request, action: ecr.sale(_:))
        case .refund:
            guard let paymentType = validatePaymentType() else { return }
            let request = EcrModel.Refund.RequestBody(
                transactionAmount: amount,
                paymentType: paymentType,
                orderId: order,
                deviceId: deviceId
            )
            perform(request: request, action: ecr.refund(_:))
        case .installment:
            guard let paymentType = validatePaymentType() else { return }
            let request = EcrModel.Installment.RequestBody(
                transactionAmount: amount,
                paymentType: paymentType,
                tenure: tenure,
                orderId: order,
                deviceId: deviceId
            )
            perform(request: request, action: ecr.installment(_:))
        case .preAuth:
            guard let paymentType = validatePaymentType() else { return }
            let request = EcrModel.PreAuth.RequestBody(
                transactionAmount: amount,
                paymentType: paymentType,
                orderId: order,
                deviceId: deviceId
            )
            perform(request: request, action: ecr.preAuth(_:))
        case .void:
            guard let paymentType = validatePaymentType() else { return }
            let request = EcrModel.Void.RequestBody(
                transactionAmount: amount,
                paymentType: paymentType,
                invoiceNumber: invoiceNumber,
                orderId: order,
                deviceId: deviceId
            )
            perform(request: request, action: ecr.void(_:))
        default:
            print("No transaction")
        }

    }
    
    private func perform<Req: Encodable, Res: EcrResponsable>(
        request: Req,
        action: (Req) -> (AnyPublisher<Res, EcrTypes.Failure>)
    ) {
        log(request: request)
        handle(publisher: action(request))
    }
    
    private func log<Req: Encodable>(request: Req) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        ecrResult?.append(
            "Sending:\n\(String(data: try! encoder.encode(request), encoding: .utf8) ?? "")"
        )
    }

    private func handle<D: EcrResponsable>(publisher: AnyPublisher<D, EcrTypes.Failure>) {
        cancellable = publisher.map { result -> String in
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return String(data: try! encoder.encode(result), encoding: .utf8) ?? ""
        }
        .catch { failure -> Just<String> in
            Just(failure.localizedDescription)
        }
        .sink(receiveValue: { [weak self] (result) in
            self?.ecrResult?.append("\n\nReceived:\n" + result)
        })
    }
    
}

//MARK: - UI -
struct ContentView: View {

    @State private var showingSheet: Bool = false
    @State private var shouldShowTransactionView: Bool = false
    
    @ObservedObject var viewModel = TransactionViewModel()

    var body: some View {
        VStack(alignment: .center) {
            
            HStack(alignment: .center) {
                
                TextField("Host", text: $viewModel.host)
                    .keyboardType(.URL)
                    .modifier(TextFieldStyled())
                    .disableAutocorrection(true)
                
                TextField("Port", text: $viewModel.port)
                    .keyboardType(.numberPad)
                    .disableAutocorrection(true)
                    .modifier(TextFieldStyled())
                    .frame(maxWidth: 100)
                
            }
            
            VStack(alignment: .center) {
                
                Text("Status")
                    .font(.headline)
                
                Divider()
                    .padding(.vertical)
                
                ScrollView {
                    Group {
                        Text("Console log ... \n\n")
                            .fontWeight(.light)
                            .foregroundColor(.secondary)
                        +
                        Text(self.viewModel.ecrResult ?? "")
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                    }
                    .modifier(ViewMaximized(alignment: .topLeading))
                }
                .lineLimit(nil)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = self.viewModel.ecrResult
                    }) {
                        Text("Copy to clipboard")
                        Image(systemName: "globe")
                    }
                }
            }
            .padding(.top)
            .modifier(DismissingKeyboard())
            
            Button(action: {
                self.showingSheet = true
                self.viewModel.transactionType = nil
            }, label: {
                Text("Transaction")
                .modifier(ButtonStyled())
            })
            .popSheet(isPresented: $showingSheet, content: {
                PopSheet(title: Text("Select action"), message: nil, buttons:
                    ActionType.allCases.map({ action -> PopSheet.Button in
                        PopSheet.Button(
                            kind: .default,
                            label: Text(action.rawValue).font(.system(size: 24, weight: .light))
                        ) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.viewModel.transactionType = action
                                self.shouldShowTransactionView.toggle()
                            }
                        }
                    })
                )
            })
            
        }
        .padding()
        .sheet(isPresented: $shouldShowTransactionView) {
            TransactionView(
                transactionViewContent: self.transactionViewContent,
                action: self.$viewModel.transactionType,
                shouldPerformRequest: self.$viewModel.shouldPerformRequest
            )
        }

    }
    
    var transactionViewContent: AnyView {
        switch viewModel.transactionType {
        case .pairing, .echo, .settlement, .getLastSettlement, .getLastTransaction:
            return AnyView(
                PairingView(
                    deviceId: $viewModel.deviceId
                )
            )
        case .sale:
            return AnyView(
                SaleTransactionView(
                    amount: $viewModel.amount,
                    paymentType: $viewModel.selectedPaymentType,
                    orderId: $viewModel.order,
                    deviceId: $viewModel.deviceId
                )
            )
        case .refund:
            return AnyView(
                RefundTransactionView(
                    amount: $viewModel.amount,
                    paymentType: $viewModel.selectedPaymentType,
                    orderId: $viewModel.order,
                    deviceId: $viewModel.deviceId
                )
            )
        case .installment:
            return AnyView(
                InstallmentTransactionView(
                    amount: $viewModel.amount,
                    paymentType: $viewModel.selectedPaymentType,
                    tenure: $viewModel.tenure,
                    orderId: $viewModel.order,
                    deviceId: $viewModel.deviceId
                )
            )
        case .preAuth:
            return AnyView(
                PreAuthTransactionView(
                    amount: $viewModel.amount,
                    paymentType: $viewModel.selectedPaymentType,
                    orderId: $viewModel.order,
                    deviceId: $viewModel.deviceId
                )
            )
        case .void:
            return AnyView(
                VoidTransactionView(
                    amount: $viewModel.amount,
                    paymentType: $viewModel.selectedPaymentType,
                    invoiceNumber: $viewModel.invoiceNumber,
                    orderId: $viewModel.order,
                    deviceId: $viewModel.deviceId
                )
            )
        default:
            return AnyView(
                Text("No action selected")
                .padding()
            )
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.colorScheme, .light)
            
            ContentView()
                .environment(\.colorScheme, .dark)
        }
        .previewDevice("iPhone 11 Pro")
    }
}

