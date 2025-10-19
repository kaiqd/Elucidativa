import SwiftUI

struct AddExamCard: View {
    @EnvironmentObject var userSettings: UserSettings
    var onTap: (() -> Void)? = nil

    private let height: CGFloat = 254
    private let ctaSize = CGSize(width: 343, height: 109)
    private let corner: CGFloat = 28

    private let bgColor   = Color(red: 0xE6/255, green: 0xF0/255, blue: 0xFA/255) // #E6F0FA
    private let dashColor = Color(red: 0xB3/255, green: 0xE5/255, blue: 0xF0/255) // #B3E5F0

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Seja bem vindo(a),")
                    .font(.system(size: 13.8))
                    .foregroundStyle(.secondary)

                Text(userSettings.name)
                    .font(.system(size: 22.7, weight: .bold))

                Spacer(minLength: 16)

                HStack {
                    Spacer()
                    ctaView
                    Spacer()
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .background(bgColor)                             // ⬅️ fundo do bloco
        .ignoresSafeArea(.container, edges: .horizontal) // ⬅️ pega a tela toda na horizontal
    }

    @ViewBuilder
    private var ctaView: some View {
        let visual = ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)

            VStack(spacing: 8) {
                Text("Enviar novo exame")
                    .font(.system(size: 17.2, weight: .semibold))
                    .multilineTextAlignment(.center)

                Text("Tire uma foto ou envie o PDF")
                    .font(.system(size: 13.6))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
        .frame(width: ctaSize.width, height: ctaSize.height)
        .overlay {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .strokeBorder(
                    dashColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [6, 6])
                )
                .padding(1.5)
        }

        if let onTap {
            Button(action: onTap) { visual }.buttonStyle(.plain)
        } else {
            visual
        }
    }
}
