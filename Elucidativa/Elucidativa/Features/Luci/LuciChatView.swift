import SwiftUI

private let actionStroke  = Color(red: 0xB3/255, green: 0xE5/255, blue: 0xF0/255) // #B3E5F0
private let userBubble    = Color(red: 0xE6/255, green: 0xF0/255, blue: 0xFA/255) // #E6F0FA
private let appBackground = Color(.systemBackground)
private let luciBubble    = Color(.secondarySystemBackground)

// MARK: - Balão
private struct ChatBubble: View {
    var text: String
    var isUser: Bool

    private let corner: CGFloat = 18
    private let maxBubbleWidth: CGFloat = 280

    var body: some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(isUser ? userBubble : luciBubble)
                    .shadow(color: isUser ? .clear : .black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
            .frame(maxWidth: maxBubbleWidth, alignment: .leading)
    }
}

// MARK: - Composer
private struct ComposerBar: View {
    @Binding var text: String
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: {}) {
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
                    .fill(Color("tabBarSelected"))
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
    @StateObject private var viewModel: LuciViewModel
    @State private var compose: String = ""
    
    init(conversation: ConversationModel) {
        _viewModel = StateObject(wrappedValue: LuciViewModel(conversation: conversation))
    }

    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 12) {
                    LuciHeader(avatar: nil)
                        .padding(.bottom, 4)
                    
                    ForEach(viewModel.conversation.messages) { message in
                        if message.isUser {
                            ChatBubble(text: message.text, isUser: true)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, -64)
                        } else {
                            ChatBubble(text: message.text, isUser: false)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .onChange(of: viewModel.conversation.messages.count) {
                    // Scroll to the bottom when a new message is added
                    if let lastMessage = viewModel.conversation.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(appBackground)
        .safeAreaInset(edge: .bottom) {
            ComposerBar(text: $compose) {
                if !compose.isEmpty {
                    viewModel.sendMessage(compose)
                    compose = ""
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onAppear { tabBar.isHidden = true }       // esconde tab bar no chat
        .onDisappear { tabBar.isHidden = false }   // volta tab bar ao sair
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let mockConversation = ConversationModel(id: UUID(), startDate: Date(), lastMessageText: "Test", lastMessageDate: Date(), messages: [
        ChatMessageModel(id: UUID(), text: "Hello", isUser: false, timestamp: Date())
    ])
    
    return NavigationStack {
        LuciChatView(conversation: mockConversation)
            .environmentObject(TabBarVisibility())
    }
}
