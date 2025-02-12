//
//  AlertNetwork.swift
//  Elucidativa
//
//  Created by Vitor Costa on 12/02/25.
//

import SwiftUI

struct AlertMessageDeleteCard: ViewModifier {
    @Binding var isShowing: Bool
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Sem Acesso a Internet", isPresented: $isShowing) {
                Button(role: .cancel) {
                    isShowing = false
                    action()
                } label: {
                    Text("OK")
                }
            } message: {
                Text("Nenhuma rede detectada. Conecte-se ao Wi-Fi ou à rede móvel e tente novamente.")
            }
    }
}
