import Foundation
import CoreData

struct ConversationModel: Identifiable, Hashable {
    let id: UUID
    var startDate: Date
    var lastMessageText: String
    var lastMessageDate: Date
    var messages: [ChatMessageModel]

    // Conformance to Hashable
    static func == (lhs: ConversationModel, rhs: ConversationModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ChatMessageModel: Identifiable, Hashable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    var image: Data? = nil // Added for displaying images in chat
}

// Extension to map from Core Data to our model
extension ConversationModel {
    init(conversationEntity: Conversation) {
        self.id = conversationEntity.id ?? UUID()
        self.startDate = conversationEntity.startDate ?? Date()
        self.lastMessageText = conversationEntity.lastMessageText ?? ""
        self.lastMessageDate = conversationEntity.lastMessageDate ?? Date()
        
        let messageEntities = conversationEntity.messages as? Set<ChatMessage> ?? []
        self.messages = messageEntities.map(ChatMessageModel.init)
            .sorted(by: { $0.timestamp < $1.timestamp })
    }
}

// Note: The image property is not persisted in Core Data for ChatMessageModel
extension ChatMessageModel {
    init(chatMessageEntity: ChatMessage) {
        self.id = chatMessageEntity.id ?? UUID()
        self.text = chatMessageEntity.text ?? ""
        self.isUser = chatMessageEntity.isUser
        self.timestamp = chatMessageEntity.timestamp ?? Date()
        self.image = nil // Image is not saved in the chat history DB
    }
}
