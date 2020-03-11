//
//  ViewMaximized.swift
//  EcrDemo
//
//  Created by Pulik, Jaroslav on 09/12/2019.
//  Copyright © 2019 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct ViewMaximized: ViewModifier {
    
    let maxHeight: CGFloat
    let alignment: Alignment
    
    init(maxHeight: CGFloat = .infinity, alignment: Alignment = .center) {
        self.maxHeight = maxHeight
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        content
            .frame(
                maxWidth: .infinity,
                maxHeight: maxHeight,
                alignment: alignment
            )
    }
    
}
