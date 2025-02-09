//
//  HomeView.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var navigate: Bool = false
    @State private var selectedExam: ExamModel = .init()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Elucidativa")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.mainText)
                        .padding(.bottom, 8)
                    
                    Text("Envie uma foto do seu laudo e receba uma explicação em linguagem simples e acessível.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black)
                        .padding(.bottom, 16)
                        .padding(.trailing, 7)
                    
                    CardReport() {
                        print("Teste")
                    }
                    .padding(.bottom, 47)
                    
                    Text("Meus Laudos")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.mainText)
                        .padding(.bottom, 8)
                        .padding(.bottom, viewModel.examsList.isEmpty ? 70 : 0)
                    
                    if viewModel.examsList.isEmpty {
                        Text("Nenhum resultado de laudo ainda cadastrado")
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.cardTextGalery)
                            .padding(.horizontal, 24)
                    } else {
                        ScrollView {
                            ForEach(0..<ExamModel.mockExams.count, id: \.self) { index in
                                SmallCard(exam: ExamModel.mockExams[index])
                                    .padding(.bottom, 4)
                                    .onTapGesture {
                                        selectedExam = ExamModel.mockExams[index]
                                        navigate.toggle()
                                    }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                    
                    Spacer()
                }
                .padding(.top, 26)
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $navigate) {
                ExamResult(exam: selectedExam)
                    .onDisappear {
                        selectedExam = .init()
                    }
            }
            .navigationTitle("")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel())
}
