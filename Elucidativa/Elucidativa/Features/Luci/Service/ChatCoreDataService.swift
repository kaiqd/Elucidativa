import Foundation
import CoreData

class ChatCoreDataService: ChatRepository {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchConversations() -> [ConversationModel] {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        
        // Sort by last message date, newest first
        let sortDescriptor = NSSortDescriptor(keyPath: \Conversation.lastMessageDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let conversationEntities = try context.fetch(fetchRequest)
            return conversationEntities.map(ConversationModel.init)
        } catch {
            print("Failed to fetch conversations: \(error)")
            return []
        }
    }
    
    func createConversation() -> ConversationModel {
        let context = coreDataStack.persistentContainer.viewContext
        let newConversationEntity = Conversation(context: context)
        newConversationEntity.id = UUID()
        newConversationEntity.startDate = Date()
        newConversationEntity.lastMessageDate = Date()
        newConversationEntity.lastMessageText = "Nova conversa"
        
        coreDataStack.saveContext()
        
        return ConversationModel(conversationEntity: newConversationEntity)
    }
    
    func addMessage(to conversationId: UUID, text: String, isUser: Bool) {
        let context = coreDataStack.persistentContainer.viewContext
        
        guard let conversationEntity = findConversationById(id: conversationId) else {
            print("Conversation with ID \(conversationId) not found.")
            return
        }
        
        let newMessageEntity = ChatMessage(context: context)
        newMessageEntity.id = UUID()
        newMessageEntity.text = text
        newMessageEntity.isUser = isUser
        newMessageEntity.timestamp = Date()
        
        conversationEntity.addToMessages(newMessageEntity)
        conversationEntity.lastMessageText = text
        conversationEntity.lastMessageDate = newMessageEntity.timestamp
        
        coreDataStack.saveContext()
    }
    
    func deleteConversation(id: UUID) {
        let context = coreDataStack.persistentContainer.viewContext
        
        if let conversationEntity = findConversationById(id: id) {
            context.delete(conversationEntity)
            coreDataStack.saveContext()
        } else {
            print("Conversation with ID \(id) not found.")
        }
    }
    
    private func findConversationById(id: UUID) -> Conversation? {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch conversation by ID: \(error)")
            return nil
        }
    }
}
