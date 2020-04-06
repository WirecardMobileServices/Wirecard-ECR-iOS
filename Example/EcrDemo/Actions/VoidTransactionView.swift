//
//  VoidTransactionView.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 10/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI
import WDEcr

struct VoidTransactionView: View {
    
    @Binding var amount: String
    @Binding var paymentType: EcrTypes.PaymentType?
    @Binding var invoiceNumber: String
    @Binding var orderId: String
    @Binding var deviceId: String

    var body: some View{
        VStack(alignment: .center, spacing: 10) {
            
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
                .modifier(TextFieldStyled())
            
            NavigationLink(
                destination: PaymentTypesListView(
                    selectedPaymentType: $paymentType
                )
            ) {
                Text(paymentTypeText)
            }
            .padding(.vertical)
            
            TextField("Invoice number", text: $invoiceNumber)
                .disableAutocorrection(true)
                .modifier(TextFieldStyled())
            
            TextField("Order Id", text: $orderId)
                .disableAutocorrection(true)
                .modifier(TextFieldStyled())
            
            TextField("Device Id", text: $deviceId)
                .disableAutocorrection(true)
                .modifier(TextFieldStyled())
            
        }
        .padding()
    }
    
    private var paymentTypeText: String {
        paymentType != nil ?
            paymentType!.rawValue + ": " + paymentType!.definition :
            "Select payment type"
    }
    
}

struct VoidTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        VoidTransactionView(
            amount: .constant("9.99"),
            paymentType: .constant(.cash),
            invoiceNumber: .constant("000010"),
            orderId: .constant("1234"),
            deviceId: .constant("abcd")
        )
        .previewLayout(.fixed(width: 300, height: 200))
    }
}
