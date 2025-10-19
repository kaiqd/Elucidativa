import SwiftUI

private let actionStroke  = Color(red: 0xB3/255, green: 0xE5/255, blue: 0xF0/255) // #B3E5F0
private let userBubble    = Color(red: 0xE6/255, green: 0xF0/255, blue: 0xFA/255) // #E6F0FA
private let appBackground = Color(.systemBackground)
private let luciBubble    = Color(.secondarySystemBackground)

// MARK: - Balão
private struct ChatBubble: View {
    var message: ChatMessageModel

    private let corner: CGFloat = 18
    private let maxBubbleWidth: CGFloat = 280

    var body: some View {
        if let imageData = message.image, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: maxBubbleWidth)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        } else {
            Text(message.text)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(message.isUser ? userBubble : luciBubble)
                        .shadow(color: message.isUser ? .clear : .black.opacity(0.06), radius: 8, x: 0, y: 4)
                )
                .frame(maxWidth: maxBubbleWidth, alignment: .leading)
        }
    }
}

// MARK: - Composer
private struct ComposerBar: View {
    @Binding var text: String
    var onSend: () -> Void
    var onAttachment: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onAttachment) {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 36, height: 36)
                    .overlay(Image(systemName: "paperclip").font(.system(size: 16)).foregroundStyle(.secondary))
            }
            .buttonStyle(.plain)

            TextField("Digite sua dúvida...", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                )

            Button(action: onSend) {
                Circle()
                    .fill(Color.tabBarSelected)
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "paperplane.fill")
                                .rotationEffect(.degrees(17))
                                .foregroundStyle(.white))
            }
            .buttonStyle(.plain)
            .disabled(text.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(appBackground)
        .overlay(alignment: .top) { Rectangle().fill(Color(.systemGray5)).frame(height: 0.5) }
    }
}

// MARK: - ChatView
struct LuciChatView: View {
    @EnvironmentObject private var tabBar: TabBarVisibility
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    @StateObject private var luciViewModel: LuciViewModel
    @State private var compose: String = ""
    
    @State private var showAddPopup = false
    @StateObject private var addFlow = AddExamFlow()
    
    // For disclaimer alert
    @State private var showDisclaimerAlert = false
    @State private var pendingImageData: Data?
    @State private var pendingFileFormat: String?
    
    init(conversation: ConversationModel) {
        _luciViewModel = StateObject(wrappedValue: LuciViewModel(conversation: conversation))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(spacing: 12) {
                            LuciHeader(avatar: nil)
                                .padding(.bottom, 4)
                            
                            ForEach(luciViewModel.conversation.messages) { message in
                                HStack {
                                    if message.isUser {
                                        Spacer()
                                        ChatBubble(message: message)
                                    } else {
                                        ChatBubble(message: message)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .onChange(of: luciViewModel.conversation.messages.count) {
                            if let lastMessage = luciViewModel.conversation.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .background(appBackground)
                .onTapGesture {
                    hideKeyboard()
                }
                
                ComposerBar(text: $compose, onSend: {
                    if !compose.isEmpty {
                        luciViewModel.sendMessage(compose)
                        compose = ""
                    }
                }, onAttachment: {
                    showAddPopup = true
                })
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            if showAddPopup {
                AddExamPopup(
                    onClose: { showAddPopup = false },
                    onTakePhoto: {
                        showAddPopup = false
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            addFlow.showCamera = true
                        } else {
                            addFlow.alert = .init(title: "Câmera indisponível", message: "Use um dispositivo com câmera ou tente a galeria.")
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
        .onAppear { tabBar.isHidden = true }
        .onDisappear { tabBar.isHidden = false }
        .navigationBarTitleDisplayMode(.inline)
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
                // 1. Add the image message to the chat (UI only, not persisted)
                let imageMessage = ChatMessageModel(id: UUID(), text: "", isUser: true, timestamp: Date(), image: data)
                luciViewModel.conversation.messages.append(imageMessage)
                
                // 2. Call the view model to process the exam
                homeViewModel.addExam(imageData: data, formaDeEntrega: format) { newExam in
                    // 3. In the completion, add Luci's response to the chat
                    let responseText = "Analisei seu exame '\(newExam.title)'. Aqui está o resumo:\n\n\(newExam.description)"
                    luciViewModel.addLuciMessage(responseText)
                }
            }
            pendingImageData = nil
            pendingFileFormat = nil
        }
    }
    
    // MARK: - Helper Functions
    
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
            luciViewModel.addLuciMessage("Desculpe, ainda não consigo processar arquivos PDF.")
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    let mockConversation = ConversationModel(id: UUID(), startDate: Date(), lastMessageText: "Test", lastMessageDate: Date(), messages: [
        ChatMessageModel(id: UUID(), text: "Hello", isUser: false, timestamp: Date())
    ])
    
    return NavigationStack {
        LuciChatView(conversation: mockConversation)
            .environmentObject(TabBarVisibility())
            .environmentObject(HomeViewModel())
            .environmentObject(UserSettings())
    }
}
