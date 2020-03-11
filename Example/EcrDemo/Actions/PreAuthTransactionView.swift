//
//  PreAuthTransactionView.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 10/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI
import WDEcr

struct PreAuthTransactionView: View {
    
    @Binding var amount: String
    @Binding var paymentType: EcrTypes.PaymentType?
    @Binding var orderId: String

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
            
            TextField("Order Id", text: $orderId)
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

struct PreAuthTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        PreAuthTransactionView(
            amount: .constant("9.99"),
            paymentType: .constant(.cash),
            orderId: .constant("1234")
        )
        .previewLayout(.fixed(width: 300, height: 200))
    }
}
