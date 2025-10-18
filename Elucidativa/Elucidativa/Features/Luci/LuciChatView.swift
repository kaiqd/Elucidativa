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

// MARK: - Botão de ação
private struct ChatActionButton: View {
    var emoji: String
    var title: String

    var body: some View {
        HStack(spacing: 10) {
            Text(emoji)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
        }
        .foregroundStyle(actionStroke)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(
            Capsule().stroke(actionStroke, lineWidth: 1.4)
        )
    }
}

// MARK: - Composer
private struct ComposerBar: View {
    @Binding var text: String

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

            Button(action: {}) {
                Circle()
                    .fill(Color("tabBarSelected"))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "paperplane.fill")
                                .rotationEffect(.degrees(17))
                                .foregroundStyle(.white))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(appBackground)
        .overlay(alignment: .top) { Rectangle().fill(Color(.systemGray5)).frame(height: 0.5) }
    }
}

// MARK: - ChatView
struct ChatView: View {
    @EnvironmentObject private var tabBar: TabBarVisibility
    @State private var compose: String = ""

    private let luciIntro =
    """
    Como posso te ajudar hoje? Você pode me enviar um exame novo ou tirar dúvidas sobre seus resultados anteriores 😊
    """

    private let messages: [(text: String, isUser: Bool)] = [
        ("Luci, o que significa hemoglobina baixa?", true),
        (
        """
        Ótima pergunta! A hemoglobina é como um "táxi" que leva oxigênio pelo seu corpo. 🚕
        Quando está baixa, você pode sentir:
        • Cansaço constante
        • Falta de ar
        • Tontura

        Isso pode indicar anemia. Importante conversar com seu médico sobre suplementação de ferro e alimentação rica em folhas verdes escuras! 🥬
        """,
        false
        )
    ]

    private let cols = [GridItem(.flexible(minimum: 140), spacing: 12),
                        GridItem(.flexible(minimum: 140), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                LuciHeader(avatar: nil)
                    .padding(.bottom, 4)

                // Intro da Luci (esquerda)
                HStack {
                    ChatBubble(text: luciIntro, isUser: false)
                    Spacer(minLength: 0)
                }
                .padding(.leading, 16)

                // Botões de ação
                LazyVGrid(columns: cols, spacing: 12) {
                    ChatActionButton(emoji: "📷", title: "Enviar exame")
                    ChatActionButton(emoji: "❓", title: "Tirar dúvida")
                    ChatActionButton(emoji: "📊", title: "Ver histórico")
                    ChatActionButton(emoji: "💊", title: "Medicamentos")
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                // Mensagens
                VStack(spacing: 12) {
                    ForEach(Array(messages.enumerated()), id: \.offset) { _, m in
                        if m.isUser {
                            ChatBubble(text: m.text, isUser: true)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, -64)   
                        } else {
                            ChatBubble(text: m.text, isUser: false)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)
                        }
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.top, 8)
        }
        .background(appBackground)
        // Composer fixo ao fundo
        .safeAreaInset(edge: .bottom) {
            ComposerBar(text: $compose)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onAppear { tabBar.isHidden = true }       // esconde tab bar no chat
        .onDisappear { tabBar.isHidden = false }   // volta tab bar ao sair
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ChatView()
            .environmentObject(TabBarVisibility())
    }
}
