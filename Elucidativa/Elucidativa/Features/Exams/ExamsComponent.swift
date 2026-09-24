//
//  ExamsComponent.swift
//  Elucidativa
//
//  Created by Kaique Diniz on 18/10/25.
//

import SwiftUI

// MARK: - Nível de interpretação (cores)
enum InterpretationLevel: String {
    case normal    = "Normal"
    case attention = "Atenção"
    case high      = "Alto"
    case critical  = "Crítico"

    var tint: Color {
        switch self {
        case .normal:    return Color.normal
        case .attention: return Color.atencao
        case .high:      return Color(hue: 0.07, saturation: 0.80, brightness: 0.90)  // laranja
        case .critical:  return Color.urgente
        }
    }
    var pillBackground: Color { tint.opacity(0.15) }
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
    @State private var showVLibras = false
    let name: String
    let urgency: String?
    let dateText: String
    let place: String
    let examType: String
    let deliveryFormat: String
    let level: InterpretationLevel
    let descriptionText: String

    var minHeight: CGFloat = 120

    private let corner: CGFloat = 20
    private let stripeWidth: CGFloat = 6
    private let stripeInsetLeading: CGFloat = 0
    private let stripeXOffset: CGFloat = -1
    private let stripeTopBottomInset: CGFloat = 6
    private let contentPadding: CGFloat = 16

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(level.tint)
                    .frame(width: stripeWidth)
                    .padding(.leading, stripeInsetLeading)
                    .padding(.vertical, stripeTopBottomInset)
                    .offset(x: stripeXOffset)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        HStack(spacing: 8) {
                            Text(name)
                                .font(.system(size: 15.6, weight: .semibold))
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
                    .font(.system(size: 12.6))
                    .foregroundStyle(.secondary)

                    Text(descriptionText)
                        .font(.system(size: 13.6))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)

                    if !descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            showVLibras = true
                        } label: {
                            Label("Ver em Libras", systemImage: "hands.sparkles")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.tabBarSelected)
                        .accessibilityHint("Abre a explicação deste exame no VLibras")
                        .padding(.top, 4)
                    }
                }
                .padding(contentPadding)
            }
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        }
        .frame(maxWidth: .infinity)   // ⬅️ ocupa toda a largura disponível
        .frame(minHeight: minHeight)
        .sheet(isPresented: $showVLibras) {
            VLibrasView(text: descriptionText)
        }
    }
}

// MARK: - Previews
#Preview("Descrição obrigatória") {
    VStack(spacing: 18) {
        ExamCardView(
            name: "Hemograma Completo",
            urgency: nil,
            dateText: "Há 2 dias",
            place: "Lab Sabin",
            examType: "Sangue",
            deliveryFormat: "PDF",
            level: .normal,
            descriptionText: "Todos os valores estão dentro do esperado. Suas células do sangue estão funcionando bem!"
        )
        ExamCardView(
            name: "Glicemia em Jejum",
            urgency: nil,
            dateText: "Há 1 semana",
            place: "Lab Fleury",
            examType: "Sangue",
            deliveryFormat: "PDF",
            level: .attention,
            descriptionText: "Glicose um pouco elevada (115 mg/dL). Vale conversar com seu médico sobre alimentação."
        )
    }
    .padding()
    .background(Color(.secondarySystemBackground))
}
