//
//  Extensions.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import Foundation

extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
}
