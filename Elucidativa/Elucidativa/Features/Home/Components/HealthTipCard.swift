//
//  HealthTipCard.swift
//  Elucidativa
//
//  Created by Kaique Diniz on 18/10/25.
//

import SwiftUI

struct HealthTipCard: View {
    var emoji: String
    var title: String
    var tip: String

    var width: CGFloat = 200
    var height: CGFloat = 143

    private let corner: CGFloat = 18
    private let bgColor = Color(red: 0xE6/255, green: 0xF0/255, blue: 0xFA/255) // #E6F0FA

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(bgColor)

            VStack(alignment: .leading, spacing: 8) {
                Text(emoji)
                    .font(.system(size: 28))

                Text(title)
                    .font(.headline) 
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(tip)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)

                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .frame(width: width, height: height)
        .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }
}

#Preview("Health Tips") {
    HStack(spacing: 16) {
        HealthTipCard(
            emoji: "💧",
            title: "Hidratação",
            tip: "Beba 2L de água por dia"
        )
        HealthTipCard(
            emoji: "🏃‍♂️",
            title: "Exercícios",
            tip: "30min por dia fazem diferença"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
