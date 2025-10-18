import SwiftUI

final class TabBarVisibility: ObservableObject { @Published var isHidden = false }

struct MainView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showAddPopup: Bool = false
    
    @State private var homePath = NavigationPath()
    @State private var examsPath = NavigationPath()
    @State private var luciPath = NavigationPath()
    @State private var profilePath = NavigationPath()
    
    @StateObject private var tabBar = TabBarVisibility()
    @StateObject private var addFlow = AddExamFlow()   // ⬅️ fluxo do popup
    
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                case .home:   NavigationStack(path: $homePath) { NewHomeView() }
                case .exams:  NavigationStack(path: $examsPath) { ExamsView() }
                case .luci:   NavigationStack(path: $luciPath) { LuciView() }
                case .profile:NavigationStack(path: $profilePath) { ProfileView() }
                }
            }
            .environmentObject(tabBar)
        }
        // Tab bar no inset
        .safeAreaInset(edge: .bottom) {
            if !tabBar.isHidden {
                CustomTabBar(
                    selected: $selectedTab,
                    icons: [
                        .home:    (name: "home",   title: "Início"),
                        .exams:   (name: "exames", title: "Exames"),
                        .luci:    (name: "luci",   title: "Luci"),
                        .profile: (name: "perfill", title: "Perfil")
                    ],
                    onCenterTap: { showAddPopup = true  }
                )
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        // Popup
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
        // ===== PICKERS =====
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
        // Alerts simples (para erros ou ausências)
        .alert(item: $addFlow.alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    MainView()
        .environmentObject(HomeViewModel())
}
