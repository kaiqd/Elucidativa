import SwiftUI

// MARK: - SearchField (maior, flexível)
private struct SearchField: View {
    @Binding var text: String
    var height: CGFloat = 54
    var placeholder: String = "Buscar conversas..."

    private let bg = Color(red: 250/255, green: 250/255, blue: 250/255) // #FAFAFA

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .submitLabel(.search)
        }
        .padding(.horizontal, 16)
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: height/2, style: .continuous).fill(bg)
        )
    }
}

// MARK: - Chips de filtro (inativo com borda)
private enum LuciFilter: String, CaseIterable, Identifiable {
    case todas = "Todas"
    case hoje = "Hoje"
    case estaSemana = "Esta Semana"
    case esteMes = "Este Mês"
    var id: String { rawValue }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(isSelected ? Color("tabBarSelected") : .clear)
                )
                .overlay(
                    Capsule().stroke(isSelected ? Color("tabBarSelected") : Color(.systemGray4), lineWidth: 1.2)
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

private struct NewConversationButton: View {
    var action: () -> Void

    private let corner: CGFloat = 18

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold)) // 24x24

                Text("Nova Conversa")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))  // 20x20
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(width: 327, height: 56) // tamanho correto
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Color("tabBarSelected"))
            )
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
            .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Célula da conversa (327x80)
private struct ConversationRow: View {
    var title: String
    var preview: String
    var time: String
    var unread: Int

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                Text(time)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                if unread > 0 {
                    ZStack {
                        Circle().fill(Color("tabBarSelected"))
                        Text("\(unread)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 28, height: 28)
                }
            }

            Text(preview)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
                .opacity(0.6)
                .padding(.top, 6)
        }
        .frame(width: 327, height: 80)
        .contentShape(Rectangle()) // área de toque cheia
    }
}

// MARK: - Header com avatar 84x84
struct LuciHeader: View {
    var avatar: Image? = nil

    var body: some View {
        VStack(spacing: 14) {
            (avatar ?? Image(systemName: "person.crop.circle.fill"))
                .resizable()
                .scaledToFill()
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .foregroundStyle(Color("tabBarSelected"))

            Text("Oi, eu sou a Luci!")
                .font(.system(size: 23, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Estou aqui para te ajudar a entender seus exames de forma simples e clara.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
}

// MARK: - LuciView (tela)
struct LuciView: View {
    @State private var query: String = ""
    @State private var selectedFilter: LuciFilter = .todas
    
    @State private var conversations: [ConversationModel] = []
    @State private var path = NavigationPath()
    
    private let chatService: ChatRepository = ChatCoreDataService()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 20) {

                    // Header
                    LuciHeader(avatar: nil)

                    // Busca
                    HStack(spacing: 12) {
                        SearchField(text: $query)
                        Button { hideKeyboard() } label: {
                            Circle()
                                .fill(Color("tabBarSelected"))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.white)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    // Filtros
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(LuciFilter.allCases) { f in
                                FilterChip(title: f.rawValue, isSelected: f == selectedFilter) {
                                    selectedFilter = f
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Botão Nova conversa → abre ChatView
                    NewConversationButton {
                        let newConversation = chatService.createConversation()
                        conversations.insert(newConversation, at: 0)
                        path.append(newConversation)
                    }
                    .padding(.horizontal, 16)

                    // Conversation History List
                    VStack(alignment: .leading, spacing: 0) {
                        if conversations.isEmpty {
                            Text("Nenhuma conversa anterior.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 50)
                        } else {
                            ForEach(conversations) { conversation in
                                Button(action: {
                                    path.append(conversation)
                                }) {
                                    ConversationRow(
                                        title: conversation.messages.first?.text ?? "Nova Conversa",
                                        preview: conversation.lastMessageText,
                                        time: conversation.lastMessageDate.formattedString(),
                                        unread: 0 // Unread count not implemented
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Spacer(minLength: 24)
                }
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Luci")
            .navigationDestination(for: ConversationModel.self) { conversation in
                LuciChatView(conversation: conversation)
            }
            .onAppear {
                conversations = chatService.fetchConversations()
            }
        }
    }

    private func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
        #endif
    }
}

#Preview {
    NavigationStack { // para visualizar o push no Preview
        LuciView()
    }
}