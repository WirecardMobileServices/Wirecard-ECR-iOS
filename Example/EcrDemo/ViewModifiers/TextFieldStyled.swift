//
//  TextFieldStyled.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 09/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct TextFieldStyled: ViewModifier {
    func body(content: Content) -> some View {
     content
        .padding()
        .background(Color.accentColor.opacity(0.25))
        .cornerRadius(6)
    }
}
