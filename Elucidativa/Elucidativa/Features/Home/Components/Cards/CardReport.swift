//
//  CardReport.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI

struct CardReport: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "doc.fill.badge.plus")
                .resizable()
                .frame(width: 43, height: 48)
            
            Text(NSLocalizedString("AddReport", comment: ""))
                .font(.system(size: 16, weight: .medium))
        }
        .foregroundStyle(.cardText)
        .frame(width: 335, height: 147)
        .background {
            Color.cardBackground
                .clipShape(.rect(cornerRadius: 16))
        }
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    VStack {
        CardReport() {
            print("Teste")
        }
    }
    .background {
        Color.blue
            .frame(width: 420, height: 500)
    }
}
