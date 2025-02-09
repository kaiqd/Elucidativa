//
//  HomeViewModel.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var examsList: [ExamModel]
    
    init() {
        self.examsList = ExamModel.mockExams
    }
}
