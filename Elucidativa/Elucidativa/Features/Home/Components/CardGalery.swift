//
//  CardGalery.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI

struct CardGalery: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "arrow.up.doc")
                .resizable()
                .frame(width: 33, height: 43)
            
            Text("Selecionar foto da galeria")
                .font(.system(size: 20, weight: .regular))
        }
        .foregroundStyle(.cardTextGalery)
        .frame(maxWidth: 358, maxHeight: 200)
        .background {
            Color.background
                .clipShape(.rect(cornerRadius: 16))
        }
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    VStack {
        CardGalery() {
            print("Teste")
        }
    }
    .background {
        Color.blue
            .frame(width: 420, height: 500)
    }
}
