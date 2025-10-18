import Foundation
import CoreData

struct ConversationModel: Identifiable, Hashable {
    let id: UUID
    var startDate: Date
    var lastMessageText: String
    var lastMessageDate: Date
    var messages: [ChatMessageModel] // Renamed

    // Conformance to Hashable
    static func == (lhs: ConversationModel, rhs: ConversationModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Renamed from ChatMessage
struct ChatMessageModel: Identifiable, Hashable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
}

// Extension to map from Core Data to our model
extension ConversationModel {
    init(conversationEntity: Conversation) {
        self.id = conversationEntity.id ?? UUID()
        self.startDate = conversationEntity.startDate ?? Date()
        self.lastMessageText = conversationEntity.lastMessageText ?? ""
        self.lastMessageDate = conversationEntity.lastMessageDate ?? Date()
        
        let messageEntities = conversationEntity.messages as? Set<ChatMessage> ?? []
        // Use ChatMessageModel here
        self.messages = messageEntities.map(ChatMessageModel.init)
            .sorted(by: { $0.timestamp < $1.timestamp })
    }
}

// Renamed from ChatMessage
extension ChatMessageModel {
    init(chatMessageEntity: ChatMessage) {
        self.id = chatMessageEntity.id ?? UUID()
        self.text = chatMessageEntity.text ?? ""
        self.isUser = chatMessageEntity.isUser
        self.timestamp = chatMessageEntity.timestamp ?? Date()
    }
}
