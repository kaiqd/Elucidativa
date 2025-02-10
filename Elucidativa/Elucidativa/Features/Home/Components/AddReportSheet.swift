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
            VStack {
                TextField(text: $text) {
                    Text("Nome do exame")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.black)
                }
                .foregroundStyle(.black)
                .frame(height: 50)
                .padding(.leading, 16)
                .background {
                    Color.white
                        .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.top, 20)
                
                CardGalery {
                    print("Teste")
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, -45)
            .background {
                Color.background
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
            }
            .toolbar {
                toolBarItems
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
                    .foregroundStyle(.black)
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
