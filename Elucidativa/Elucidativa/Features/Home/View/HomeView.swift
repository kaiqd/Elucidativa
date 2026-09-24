////
////  HomeView.swift
////  Elucidativa
////
////  Created by Vitor Costa on 09/02/25.
////
//
//import SwiftUI
//
//struct HomeView: View {
//    @EnvironmentObject var viewModel: HomeViewModel
//    @State private var navigate: Bool = false
//    @State private var showSheet: Bool = false
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color.background.ignoresSafeArea()
//                
//                VStack(alignment: .leading, spacing: 0) {
//                    Text("Elucidativa")
//                        .font(.system(size: 28, weight: .bold))
//                        .foregroundStyle(.mainText)
//                        .padding(.bottom, 8)
//                    
//                    Text(NSLocalizedString("AppExplanation", comment: ""))
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundStyle(.black)
//                        .padding(.bottom, 16)
//                        .padding(.trailing, 7)
//                    
//                    CardReport() {
//                        showSheet.toggle()
//                    }
//                    .padding(.bottom, 47)
//                    
//                    Text(NSLocalizedString("Reports", comment: ""))
//                        .font(.system(size: 28, weight: .bold))
//                        .foregroundStyle(.mainText)
//                        .padding(.bottom, 8)
//                        .padding(.bottom, viewModel.examsList.isEmpty ? 70 : 0)
//                    
//                    if viewModel.examsList.isEmpty {
//                        Text(NSLocalizedString("NoReports", comment: ""))
//                            .font(.system(size: 20, weight: .bold))
//                            .multilineTextAlignment(.center)
//                            .foregroundStyle(.cardTextGalery)
//                            .padding(.horizontal, 24)
//                    } else {
//                        ScrollView {
//                            ForEach(0..<viewModel.examsList.count, id: \.self) { index in
//                                SmallCard(exam: viewModel.examsList[index])
//                                    .padding(.bottom, 4)
//                                    .onTapGesture {
//                                        viewModel.selectedExam = viewModel.examsList[index]
//                                        navigate.toggle()
//                                    }
//                            }
//                        }
//                        .scrollIndicators(.hidden)
//                    }
//                    
//                    Spacer()
//                }
//                .padding(.top, 26)
//                .padding(.horizontal, 24)
//            }
//            .sheet(isPresented: $showSheet, content: {
//                AddReportSheet()
//                    .environmentObject(viewModel)
//            })
//            .navigationDestination(isPresented: $navigate) {
//                ExamResult(exam: viewModel.selectedExam)
//                    .environmentObject(viewModel)
//            }
//            .navigationTitle("")
//        }
//    }
//}
//
//#Preview {
//    HomeView()
//        .environmentObject(HomeViewModel())
//}
