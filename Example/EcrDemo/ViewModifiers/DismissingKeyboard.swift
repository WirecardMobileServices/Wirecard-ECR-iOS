//
//  DismissingKeyboard.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 09/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct DismissingKeyboard: ViewModifier {
    
    func body(content: Content) -> some View {
     content
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
}
