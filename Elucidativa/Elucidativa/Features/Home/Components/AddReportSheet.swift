//
//  AddReportSheet.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI
import PhotosUI

struct AddReportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showAlert: Bool = false
    
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
                
                CardGalery(image: selectedImage, selectedItem: $selectedItem)
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            }
                        }
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
            .modifier(AlertMessageDeleteCard(isShowing: $showAlert, action: {
//                viewModel.checkNetworkConnectivity()
//                showAlert = viewModel.isConnected
            }))
            .toolbar {
                toolBarItems
            }
            .onAppear {
                viewModel.checkNetworkConnectivity()
                showAlert = viewModel.isConnected
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
                    .onTapGesture {
                        viewModel.checkNetworkConnectivity()
                        showAlert = !viewModel.isConnected
                        
                        if !text.isEmpty && selectedImage != nil {
                            let exam = ExamModel(date: Date(),
                                                 title: text,
                                                 image: selectedImage?.pngData() ?? Data(),
                                                 description: "Lorem ipsulon caraio")
                            if !showAlert {
                                dismiss()
                                viewModel.addExam(exam: exam)
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    AddReportSheet()
        .environmentObject(HomeViewModel())
}
