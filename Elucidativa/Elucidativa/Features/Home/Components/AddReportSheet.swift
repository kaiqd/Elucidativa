//
//  AddReportSheet.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI

struct AddReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                VStack {
                    TextField(text: $text) {
                        Text("Nome do exame")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.black)
                    }
                    .frame(height: 50)
                    .padding(.leading, 16)
                    .background {
                        Color.white
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)
                    
                    CardGalery {
                        print("Teste")
                    }
                    
                    Spacer()
                }
                .padding(.top, -45)
                .toolbar {
                    toolBarItems
                }
            }
        }
    }
    
    private var toolBarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Text("Cancelar")
                    .foregroundStyle(.mainText)
                    .onTapGesture {
                        dismiss()
                    }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Novo Laudo")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Text("Enviar")
                    .foregroundStyle(text.isEmpty ? .gray : .mainStrongGreen)
            }
        }
    }
}

#Preview {
    AddReportSheet()
}
