//
//  ExamRepository.swift
//  Elucidativa
//
//  Created by Vitor Costa on 10/02/25.
//

import Foundation

protocol ExamRepository {
    func fetchExams() -> [ExamModel]
    func addExam(exam: ExamModel)
    func deleteExam(id: UUID)
}
