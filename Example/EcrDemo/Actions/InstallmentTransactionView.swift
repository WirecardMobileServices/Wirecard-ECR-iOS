//
//  InstallmentTransactionView.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 10/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI
import WDEcr

struct InstallmentTransactionView: View {
    
    @Binding var amount: String
    @Binding var paymentType: EcrTypes.PaymentType?
    @Binding var tenure: String
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
            
            TextField("Tenure", text: $tenure)
                .disableAutocorrection(true)
                .modifier(TextFieldStyled())
            
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

struct InstallmentTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        InstallmentTransactionView(
            amount: .constant("9.99"),
            paymentType: .constant(.cash),
            tenure: .constant("6"),
            orderId: .constant("1234")
        )
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
