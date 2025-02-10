//
//  Model.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI
import CoreData

struct ExamModel: Identifiable {
    var id: UUID
    var date: Date
    var title: String
    var image: Data
    var description: String
    
    init(id: UUID? = nil,
         date: Date,
         title: String,
         image: Data,
         description: String) {
        self.id = id ?? UUID()
        self.date = date
        self.title = title
        self.image = image
        self.description = description
    }
    
    init() {
        self.id = UUID()
        self.date = Date.now
        self.title = "Endoscopia"
        self.image = Data()
        self.description = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
    }
    
    init(examCoreData: ExamCoreData) {
        self.id = examCoreData.id ?? UUID()
        self.date = examCoreData.date ?? Date()
        self.title = examCoreData.title ?? ""
        self.image = examCoreData.image ?? Data()
        self.description = examCoreData.translation ?? ""
    }
        
    static let mockExams: [ExamModel] = [ .init(), .init()]
}

extension ExamModel {
    func toExamCoreData(context: NSManagedObjectContext) -> ExamCoreData {
        let examCoreData = ExamCoreData(context: context)
        examCoreData.id = self.id
        examCoreData.date = self.date
        examCoreData.title = self.title
        examCoreData.image = self.image
        examCoreData.translation = self.description
        return examCoreData
    }
}
