//
//  ExamsComponent.swift
//  Elucidativa
//
//  Created by Kaique Diniz on 18/10/25.
//

import SwiftUI

enum InterpretationLevel: String {
    case normal    = "Normal"
    case attention = "Atenção"
    case high      = "Alto"
    case critical  = "Crítico"

    var tint: Color {
        switch self {
        case .normal:    return Color(hue: 0.47, saturation: 0.55, brightness: 0.66)  // verde
        case .attention: return Color(hue: 0.12, saturation: 0.80, brightness: 0.90)  // amarelo
        case .high:      return Color(hue: 0.07, saturation: 0.80, brightness: 0.90)  // laranja
        case .critical:  return Color(hue: 0.00, saturation: 0.78, brightness: 0.90)  // vermelho
        }
    }
    var pillBackground: Color { tint.opacity(0.15) }
}

struct Chip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct StatusPill: View {
    let level: InterpretationLevel
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(level.tint).frame(width: 8, height: 8)
            Text(level.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(level.tint)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(level.pillBackground)
        .clipShape(Capsule())
    }
}

struct ExamCardView: View {
    // Conteúdos
    let name: String
    let urgency: String?
    let dateText: String
    let place: String
    let examType: String
    let deliveryFormat: String
    let level: InterpretationLevel

    // Dimensão fixa
    var width: CGFloat = 327
    var height: CGFloat = 120

    // Constantes visuais
    private let corner: CGFloat = 20
    private let stripeWidth: CGFloat = 6
    private let stripeInsetLeading: CGFloat = 0   // distância da borda interna
    private let stripeXOffset: CGFloat = -1       // empurra levemente p/ a esquerda
    private let stripeTopBottomInset: CGFloat = 6 // encurta um pouco a altura
    private let contentPadding: CGFloat = 16

    var body: some View {
        ZStack(alignment: .leading) {
            // Camada com sombra (não é clipada)
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)

            // Conteúdo + listra, CLIPADOS pelo mesmo corner
            ZStack(alignment: .leading) {
                // LIStra
                Rectangle()
                    .fill(level.tint)
                    .frame(width: stripeWidth)
                    .padding(.leading, stripeInsetLeading)
                    .padding(.vertical, stripeTopBottomInset)
                    .offset(x: stripeXOffset)

                // Conteúdo textual
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        HStack(spacing: 8) {
                            Text(name)
                                .font(.title3.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)

                            if let urgency, !urgency.isEmpty {
                                Text(urgency.uppercased())
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .foregroundStyle(.white)
                                    .background(level.tint)
                                    .clipShape(Capsule())
                            }
                        }

                        Spacer(minLength: 8)
                        StatusPill(level: level)
                    }

                    HStack(spacing: 6) {
                        Text(dateText)
                        Text("•").opacity(0.4)
                        Text(place)
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Chip(text: examType)
                        Chip(text: deliveryFormat)
                        Spacer()
                    }
                    .padding(.top, 2)
                }
                .padding(contentPadding)
            }
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        }
        .frame(width: width, height: height)
    }
}

#Preview("Normal") {
    ExamCardView(
        name: "Colesterol e Frações",
        urgency: nil,
        dateText: "28/10",
        place: "Lab Delboni",
        examType: "Sangue",
        deliveryFormat: "PDF",
        level: .normal
    )
    .padding()
    .background(Color(.secondarySystemBackground))
}

#Preview("Crítico + Urgência") {
    ExamCardView(
        name: "PCR Alta Sensibilidade",
        urgency: "URGENTE",
        dateText: "12/09",
        place: "Fleury",
        examType: "Sangue",
        deliveryFormat: "PDF",
        level: .critical
    )
    .padding()
    .background(Color(.secondarySystemBackground))
}
