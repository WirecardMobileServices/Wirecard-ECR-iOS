//
//  PairingView.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 30/03/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct PairingView: View {
    
    @Binding var deviceId: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            TextField("Device Id", text: $deviceId)
                .disableAutocorrection(true)
                .modifier(TextFieldStyled())
            
        }
        .padding()
    }
    
}

struct PairingView_Previews: PreviewProvider {
    static var previews: some View {
        PairingView(deviceId: .constant("12345"))
    }
}
