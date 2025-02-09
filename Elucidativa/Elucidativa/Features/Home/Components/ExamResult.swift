//
//  ExamResult.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI

struct ExamResult: View {
    @Environment(\.dismiss) var dismiss
    let exam: ExamModel
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text(exam.description)
                    .padding(12)
                    .padding(.horizontal, 4)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                Button {
//                    showAlert = true
                } label: {
                    Text("Apagar Laudo")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(.button)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }, label: {
                    Text("Voltar")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.mainStrongGreen)
                        .offset(x: -22)
                })
            }
            
            ToolbarItem(placement: .principal) {
                Text(exam.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.mainStrongGreen)
            }
        }
    }
}

#Preview {
    ExamResult(exam: .init())
}
