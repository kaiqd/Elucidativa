import SwiftUI

// OpenAI API response structs
struct OpenAIResponse: Decodable {
    let choices: [Choice]
}

struct Choice: Decodable {
    let message: Message
}

struct Message: Decodable {
    let role: String
    let content: String
}


@MainActor
class LuciViewModel: ObservableObject {
    @Published var conversation: ConversationModel
    
    private var chatService: ChatRepository
    
    init(conversation: ConversationModel, chatService: ChatRepository = ChatCoreDataService()) {
        self.conversation = conversation
        self.chatService = chatService
        
        if conversation.messages.isEmpty {
            let initialMessage = "Como posso te ajudar hoje? Você pode me enviar um exame novo ou tirar dúvidas sobre seus resultados anteriores 😊"
            chatService.addMessage(to: conversation.id, text: initialMessage, isUser: false)
            self.conversation.messages.append(ChatMessageModel(id: UUID(), text: initialMessage, isUser: false, timestamp: Date()))
        }
    }
    
    func sendMessage(_ text: String) {
        chatService.addMessage(to: conversation.id, text: text, isUser: true)
        let userMessage = ChatMessageModel(id: UUID(), text: text, isUser: true, timestamp: Date())
        conversation.messages.append(userMessage)
        
        Task {
            await sendToGPT()
        }
    }
    
    private func sendToGPT() async {
        let history = buildHistoryForGPT()
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // IMPORTANT: Replace with your actual OpenAI API key.
        request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": history,
            "max_tokens": 1024,
            "temperature": 0.7 // A bit more creative for a chat
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            if let luciResponseText = openAIResponse.choices.first?.message.content {
                chatService.addMessage(to: conversation.id, text: luciResponseText, isUser: false)
                let luciMessage = ChatMessageModel(id: UUID(), text: luciResponseText, isUser: false, timestamp: Date())
                conversation.messages.append(luciMessage)
            }
            
        } catch {
            print("Error sending to GPT: \(error)")
            let errorMessage = "Desculpe, não consegui processar sua mensagem. Tente novamente."
            conversation.messages.append(ChatMessageModel(id: UUID(), text: errorMessage, isUser: false, timestamp: Date()))
        }
    }
    
    private func buildHistoryForGPT() -> [[String: String]] {
        var history: [[String: String]] = []
        
        // Add persona as the system message
        let persona = "Você é Luci, uma assistente de IA especializada em saúde. Sua missão é ajudar os usuários a entenderem seus laudos de exames e tirar dúvidas sobre saúde de forma simples, clara e acolhedora, como se estivesse conversando com um estudante do ensino fundamental. Você não deve fornecer diagnósticos, mas sim explicar os termos e resultados. Sempre reforce que o usuário deve consultar um médico."
        history.append(["role": "system", "content": persona])
        
        // Add messages from conversation
        for message in conversation.messages {
            let role = message.isUser ? "user" : "assistant"
            history.append(["role": role, "content": message.text])
        }
        
        return history
    }
}
