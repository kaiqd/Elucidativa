//
//  ExamResult.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI

struct ExamResult: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: HomeViewModel
    let exam: ExamModel
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading) {
                    Image(uiImage: UIImage(data: exam.image) ?? UIImage(resource: .mockExam))
                        .resizable()
                        .frame(maxWidth: 358, maxHeight: 200)
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.bottom, -8)
                    
                    if let attributedString = try? AttributedString(markdown: exam.description) {
                        Text(attributedString)
                            .padding(12)
                            .padding(.horizontal, 4)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.top, 24)
                            .padding(.bottom, 16)
                    } else {
                        Text(exam.description) // Caso falhe, exibe o texto bruto
                            .padding(12)
                            .padding(.horizontal, 4)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.top, 24)
                            .padding(.bottom, 16)
                    }
                    
                    Button {
                        viewModel.deleteExam(id: exam.id)
                        dismiss()
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
            .padding(.top, 8)
            .scrollIndicators(.hidden)
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
        .environmentObject(HomeViewModel())
}
