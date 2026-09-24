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
    @Binding var selectedTab: AppTab
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var showAddPopup = false
    @StateObject private var addFlow = AddExamFlow()
    
    // For disclaimer alert
    @State private var showDisclaimerAlert = false
    @State private var pendingImageData: Data?
    @State private var pendingFileFormat: String?

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {

                    AddExamCard(onTap: { showAddPopup = true  })
                        .padding(.top, 8)

                    SectionHeader(title: "Exames recentes", trailingTitle: "Ver todos") {
                        selectedTab = .exams
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
        .sheet(isPresented: $addFlow.showCamera) { CameraPicker(image: $addFlow.capturedImage).ignoresSafeArea() }
        .sheet(isPresented: $addFlow.showPhotoLibrary) { PhotoLibraryPicker(image: $addFlow.pickedImage) }
        .sheet(isPresented: $addFlow.showDocumentPicker) { DocumentPicker(url: $addFlow.pickedFileURL) }
        .alert(item: $addFlow.alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
        .onChange(of: addFlow.capturedImage) { handleImage($0) }
        .onChange(of: addFlow.pickedImage) { handleImage($0) }
        .onChange(of: addFlow.pickedFileURL) { handleFile($0) }
        .disclaimerAlert(isPresented: $showDisclaimerAlert) {
            if let data = pendingImageData, let format = pendingFileFormat {
                viewModel.addExam(imageData: data, formaDeEntrega: format)
            }
            pendingImageData = nil
            pendingFileFormat = nil
        }
    }
    
    private func handleImage(_ image: UIImage?) {
        guard let img = image, let data = img.jpegData(compressionQuality: 0.8) else { return }
        triggerDisclaimer(imageData: data, format: "imagem")
        addFlow.capturedImage = nil
        addFlow.pickedImage = nil
    }
    
    private func handleFile(_ fileURL: URL?) {
        guard let url = fileURL else { return }
        
        let isAccessing = url.startAccessingSecurityScopedResource()
        defer { if isAccessing { url.stopAccessingSecurityScopedResource() } }
        
        if url.pathExtension.lowercased() == "pdf" {
            print("PDF processing not implemented yet.")
        } else {
            if let imageData = try? Data(contentsOf: url) {
                triggerDisclaimer(imageData: imageData, format: "imagem")
            }
        }
        addFlow.pickedFileURL = nil
    }
    
    private func triggerDisclaimer(imageData: Data, format: String) {
        pendingImageData = imageData
        pendingFileFormat = format
        showDisclaimerAlert = true
    }
}

#Preview {
    NewHomeView(selectedTab: .constant(.home))
        .environmentObject(HomeViewModel())
        .environmentObject(UserSettings())
}
