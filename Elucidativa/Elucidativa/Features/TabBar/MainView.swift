import SwiftUI

final class TabBarVisibility: ObservableObject { @Published var isHidden = false }

struct MainView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showAddPopup: Bool = false
    @State private var showFAQ = false
    
    @State private var homePath = NavigationPath()
    @State private var examsPath = NavigationPath()
    
    @StateObject private var tabBar = TabBarVisibility()
    @StateObject private var addFlow = AddExamFlow()
    @State private var showDisclaimerAlert = false
    @State private var pendingImageData: Data?
    @State private var pendingFileFormat: String?
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .home: NavigationStack(path: $homePath) {
                    NewHomeView(
                        selectedTab: $selectedTab,
                        onAddExam: { showAddPopup = true },
                        onShowHelp: { showFAQ = true }
                    )
                }
                case .exams: NavigationStack(path: $examsPath) {
                    ExamsView(onShowHelp: { showFAQ = true })
                }
                }
            }
            .environmentObject(tabBar)
            .environmentObject(viewModel)
            .environmentObject(userSettings)
        }
        .safeAreaInset(edge: .bottom) {
            if !tabBar.isHidden {
                CustomTabBar(selected: $selectedTab, onCenterTap: { showAddPopup = true })
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .sheet(isPresented: $showFAQ) {
            NavigationStack {
                ProfileView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Fechar") { showFAQ = false }
                        }
                    }
            }
        }
        .overlay {
            if showAddPopup {
                AddExamPopup(
                    onClose: { showAddPopup = false  },
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
        .onChange(of: addFlow.capturedImage) { _, image in handleImage(image) }
        .onChange(of: addFlow.pickedImage) { _, image in handleImage(image) }
        .onChange(of: addFlow.pickedFileURL) { _, url in handleFile(url) }
        .disclaimerAlert(isPresented: $showDisclaimerAlert) {
            if let data = pendingImageData, let format = pendingFileFormat {
                viewModel.addExam(imageData: data, formaDeEntrega: format) { result in
                    if case .failure(let error) = result {
                        addFlow.alert = .init(
                            title: "Não foi possível adicionar o exame",
                            message: error.localizedDescription
                        )
                    }
                }
            }
            pendingImageData = nil
            pendingFileFormat = nil
        }
        .overlay {
            if let stage = viewModel.processingStage {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 14) {
                        ProgressView()
                            .controlSize(.large)
                            .tint(.tabBarSelected)

                        Text(stage == .reading ? "Lendo o exame" : "Analisando o exame")
                            .font(.headline)

                        Text(stage == .reading
                             ? "Estamos extraindo o texto do laudo."
                             : "Isso pode levar alguns instantes.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(28)
                    .frame(maxWidth: 300)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func handleImage(_ image: UIImage?) {
        guard let image, let data = image.jpegData(compressionQuality: 0.8) else { return }
        triggerDisclaimer(imageData: data, format: "imagem")
        addFlow.capturedImage = nil
        addFlow.pickedImage = nil
    }

    private func handleFile(_ fileURL: URL?) {
        guard let url = fileURL else { return }

        let isAccessing = url.startAccessingSecurityScopedResource()
        defer { if isAccessing { url.stopAccessingSecurityScopedResource() } }

        if url.pathExtension.lowercased() == "pdf" {
            addFlow.alert = .init(
                title: "PDF ainda não disponível",
                message: "Por enquanto, envie uma foto ou imagem do laudo."
            )
        } else if let imageData = try? Data(contentsOf: url) {
            triggerDisclaimer(imageData: imageData, format: "imagem")
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
    MainView()
        .environmentObject(HomeViewModel())
        .environmentObject(UserSettings())
}
