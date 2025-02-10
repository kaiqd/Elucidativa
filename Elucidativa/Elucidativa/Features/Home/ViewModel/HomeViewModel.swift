//
//  HomeViewModel.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    private var persistenceService: ExamRepository = ExamCoreDataService()
    @Published var examsList: [ExamModel]
    @Published var selectedExam: ExamModel = .init()
    
    init() {
        self.examsList = persistenceService.fetchExams()
    }
    
    func addExam(exam: ExamModel) {
        var examMock = exam
        examMock.date = Date.now
        examMock.description = "Alguma coisa"
        persistenceService.addExam(exam: examMock)
        fetchData()
    }
    
    func deleteExam(id: UUID) {
        persistenceService.deleteExam(id: id)
        fetchData()
    }
    
    private func fetchData() {
        self.examsList = persistenceService.fetchExams()
    }
}
