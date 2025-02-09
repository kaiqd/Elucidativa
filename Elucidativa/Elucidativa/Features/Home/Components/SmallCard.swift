//
//  SmallCard.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI

struct SmallCard: View {
    let exam: ExamModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exam.title)
                    .font(.system(size: 16, weight: .bold))
                
                Text(exam.date.formattedString())
                    .font(.system(size: 16, weight: .regular))
            }
            .foregroundStyle(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.mainStrongGreen)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background {
            Color.white
                .clipShape(.rect(cornerRadius: 8))
        }
    }
}

#Preview {
    ZStack {
        Color.blue
        
        ForEach(0..<ExamModel.mockExams.count, id: \.self) {
            SmallCard(exam: ExamModel.mockExams[$0])
                .padding(.horizontal, 16)
        }
    }
}
