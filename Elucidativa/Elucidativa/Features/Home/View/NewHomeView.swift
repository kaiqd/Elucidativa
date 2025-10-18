//
//  NewHomeView.swift
//  Elucidativa
//
//  Created by Kaique Diniz on 18/10/25.
//

import SwiftUI

// Header simples reutilizável
private struct SectionHeader: View {
    var title: String
    var trailingTitle: String?
    var onTapTrailing: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
            Spacer()
            if let trailingTitle {
                Button(trailingTitle) { onTapTrailing?() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.blue)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct NewHomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var showAddPopup = false
    @StateObject private var addFlow = AddExamFlow()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {

                    AddExamCard(onTap: { showAddPopup = true  })
                        .padding(.top, 8)

                    SectionHeader(title: "Exames recentes", trailingTitle: "Ver todos") {
                        // TODO: Navigate to ExamsView
                    }
                        .padding(.top, 4)

                    VStack(spacing: 20) {
                        if viewModel.examsList.isEmpty {
                            Text("Nenhum exame recente.")
                                .foregroundStyle(.secondary)
                                .padding()
                        } else {
                            ForEach(viewModel.examsList) { exam in
                                ExamCardView(
                                    name: exam.title,
                                    urgency: nil,
                                    dateText: exam.date.formattedString(),
                                    place: exam.lugar,
                                    examType: exam.tipoDeExame,
                                    deliveryFormat: exam.formaDeEntrega,
                                    level: exam.nivel,
                                    descriptionText: exam.description
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    SectionHeader(title: "Dicas de saúde")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            HealthTipCard(emoji: "💧", title: "Hidratação", tip: "Beba 2L de água por dia")
                            HealthTipCard(emoji: "🏃‍♂️", title: "Exercícios", tip: "30min por dia fazem diferença")
                            HealthTipCard(emoji: "🛌", title: "Sono", tip: "Busque 7–8h por noite")
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))

            if showAddPopup {
                AddExamPopup(
                    onClose: { showAddPopup = false },
                    onTakePhoto: {
                         showAddPopup = false
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            addFlow.showCamera = true
                        } else {
                            addFlow.alert = .init(title: "Câmera indisponível",
                                                  message: "Use um dispositivo com câmera ou tente a galeria.")
                        }
                    },
                    onSendFile: {
                         showAddPopup = false
                        addFlow.showDocumentPicker = true
                    },
                    onOpenGallery: {
                        showAddPopup = false
                        addFlow.showPhotoLibrary = true
                    }
                )
            }
        }
        .sheet(isPresented: $addFlow.showCamera) {
            CameraPicker(image: $addFlow.capturedImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $addFlow.showPhotoLibrary) {
            PhotoLibraryPicker(image: $addFlow.pickedImage)
        }
        .sheet(isPresented: $addFlow.showDocumentPicker) {
            DocumentPicker(url: $addFlow.pickedFileURL)
        }
        .alert(item: $addFlow.alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
        .onChange(of: addFlow.capturedImage) { image in
            guard let img = image, let data = img.jpegData(compressionQuality: 0.8) else { return }
            viewModel.addExam(imageData: data, formaDeEntrega: "imagem")
            addFlow.capturedImage = nil
        }
        .onChange(of: addFlow.pickedImage) { image in
            guard let img = image, let data = img.jpegData(compressionQuality: 0.8) else { return }
            viewModel.addExam(imageData: data, formaDeEntrega: "imagem")
            addFlow.pickedImage = nil
        }
        .onChange(of: addFlow.pickedFileURL) { fileURL in
            guard let url = fileURL else { return }
            
            let isAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if isAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            if url.pathExtension.lowercased() == "pdf" {
                print("PDF processing not implemented yet.")
            } else { // Assume it's an image
                if let imageData = try? Data(contentsOf: url) {
                    viewModel.addExam(imageData: imageData, formaDeEntrega: "imagem")
                }
            }
            addFlow.pickedFileURL = nil
        }
    }
}

#Preview {
    NewHomeView()
        .environmentObject(HomeViewModel())
}