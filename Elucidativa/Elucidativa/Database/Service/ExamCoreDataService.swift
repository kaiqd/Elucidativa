//
//  ExamCoreDataService.swift
//  Elucidativa
//
//  Created by Vitor Costa on 10/02/25.
//

import Foundation
import CoreData

class ExamCoreDataService: ExamRepository {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchExams() -> [ExamModel] {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ExamCoreData> = ExamCoreData.fetchRequest()
        var examList: [ExamModel] = []
        
        do {
            if let examCoreData = try? context.fetch(fetchRequest) {
                examCoreData.forEach({
                    examList.append(ExamModel(examCoreData: $0))
                })
            }
        }
        
        return examList
    }
    
    func addExam(exam: ExamModel) {
        let context = coreDataStack.persistentContainer.viewContext
        let examCoreData = exam.toExamCoreData(context: context)
        
        coreDataStack.saveContext()
    }
    
    func deleteExam(id: UUID) {
        let context = coreDataStack.persistentContainer.viewContext
        
        if let examCoreData = findExamById(id: id) {
            context.delete(examCoreData)
            
            coreDataStack.saveContext()
        } else {
            print("Habit with ID \(id) not found.")
        }
    }
}

extension ExamCoreDataService {
    private func findExamById(id: UUID) -> ExamCoreData? {
        let context = coreDataStack.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ExamCoreData> = ExamCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch objective by ID: \(error)")
            return nil
        }
    }
}
