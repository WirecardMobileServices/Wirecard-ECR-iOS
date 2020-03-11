//
//  PaymentTypesListView.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 09/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI
import WDEcr

struct PaymentTypesListView: View {
    
    @Binding var selectedPaymentType: EcrTypes.PaymentType?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var paymentTypes = EcrTypes.PaymentType.allCases
    
    var body: some View {
        List(paymentTypes, id: \.self) { paymentType in
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                self.selectedPaymentType = paymentType
            }) {
                Text(paymentType.rawValue + ": " + paymentType.definition)
            }
        }
        .navigationBarTitle("Payment types list")
    }
    
}

struct PaymentTypesListView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentTypesListView(selectedPaymentType: .constant(.cash))
    }
}
