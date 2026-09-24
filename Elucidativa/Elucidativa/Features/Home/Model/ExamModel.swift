//
//  Model.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI
import CoreData

// This enum is now public to be accessible by ExamsView
enum ExamCategory {
    case sangue
    case urina
    case imagem
    case outro
}

struct ExamModel: Identifiable {
    var id: UUID
    var date: Date
    var title: String // nome
    var image: Data
    var description: String // descricao
    var lugar: String
    var tipoDeExame: String
    var nivel: InterpretationLevel
    var formaDeEntrega: String
    
    // Computed property to determine category from exam type string
    var category: ExamCategory {
        switch tipoDeExame.lowercased() {
        case "sangue":
            return .sangue
        case "urina":
            return .urina
        case "imagem":
            return .imagem
        default:
            return .outro
        }
    }
    
    init(id: UUID? = nil,
         date: Date,
         title: String,
         image: Data,
         description: String,
         lugar: String,
         tipoDeExame: String,
         nivel: InterpretationLevel,
         formaDeEntrega: String) {
        self.id = id ?? UUID()
        self.date = date
        self.title = title
        self.image = image
        self.description = description
        self.lugar = lugar
        self.tipoDeExame = tipoDeExame
        self.nivel = nivel
        self.formaDeEntrega = formaDeEntrega
    }
    
    init() {
        self.id = UUID()
        self.date = Date.now
        self.title = "Endoscopia"
        self.image = UIImage(resource: .mockExam).jpegData(compressionQuality: 1.0) ?? Data()
        self.description = "Lorem Ipsum is **simply** dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        self.lugar = "Lab Fleury"
        self.tipoDeExame = "Endoscopia Digestiva Alta"
        self.nivel = .normal
        self.formaDeEntrega = "imagem"
    }
    
    init(examCoreData: ExamCoreData) {
        self.id = examCoreData.id ?? UUID()
        self.date = examCoreData.date ?? Date()
        self.title = examCoreData.title ?? ""
        self.image = examCoreData.image ?? Data()
        self.description = examCoreData.translation ?? ""
        self.lugar = examCoreData.lugar ?? ""
        self.tipoDeExame = examCoreData.tipoDeExame ?? ""
        self.nivel = InterpretationLevel(rawValue: examCoreData.nivel ?? "normal") ?? .normal
        self.formaDeEntrega = examCoreData.formaDeEntrega ?? ""
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
        examCoreData.lugar = self.lugar
        examCoreData.tipoDeExame = self.tipoDeExame
        examCoreData.nivel = self.nivel.rawValue
        examCoreData.formaDeEntrega = self.formaDeEntrega
        return examCoreData
    }
}
