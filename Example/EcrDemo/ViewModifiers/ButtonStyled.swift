//
//  ButtonStyled.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 09/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct ButtonStyled: ViewModifier {
    
    func body(content: Content) -> some View {
     content
        .padding()
        .frame(
            maxWidth: .infinity,
            maxHeight: 60,
            alignment: .center
        )
        .background(Color.accentColor.opacity(0.25))
        .foregroundColor(Color.primary)
        .cornerRadius(6)
    }
    
}
