import Foundation

protocol ChatRepository {
    func fetchConversations() -> [ConversationModel]
    func createConversation() -> ConversationModel
    func addMessage(to conversationId: UUID, text: String, isUser: Bool)
    func deleteConversation(id: UUID)
}
