//
//  TransactionView.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 09/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI
import WDEcr

struct TransactionView<Content: View>: View {
    
    var transactionViewContent: Content
    
    @Binding var action: ActionType?
    @Binding var shouldPerformRequest: Bool
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 10) {
                
                transactionViewContent
                
                Spacer()
                .modifier(ViewMaximized(alignment:.topLeading))
                
                Button(action: {
                    self.shouldPerformRequest = false
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Send")
                    .modifier(ButtonStyled())
                })
                .padding()
                
            }
            .navigationBarTitle(action?.rawValue ?? "Transaction type needs to be selected")
            .navigationBarItems(
                trailing: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Close")
                })
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}


struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(
            transactionViewContent: Text("Trancaction content here"),
            action: .constant(.echo),
            shouldPerformRequest: .constant(false)
        )
        .previewDevice("iPhone 11 Pro")
    }
}
