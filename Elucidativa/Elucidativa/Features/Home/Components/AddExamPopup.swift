import SwiftUI

struct AddExamPopup: View {
    var onClose: () -> Void
    var onTakePhoto: () -> Void
    var onSendFile: () -> Void
    var onOpenGallery: () -> Void

    private let corner: CGFloat = 22
    private let tileSize = CGSize(width: 135, height: 126)

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea().onTapGesture { onClose() }

            VStack(spacing: 18) {
                HStack {
                    Text("Adicionar Exame")
                        .font(.headline.weight(.semibold))
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5).opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Tile(icon: "camera.fill", titleTop: "Tirar", titleBottom: "foto", size: tileSize, action: onTakePhoto)
                        Tile(icon: "doc.fill", titleTop: "Enviar", titleBottom: "arquivo", size: tileSize, action: onSendFile)
                    }
                    HStack(spacing: 16) {
                        Spacer(minLength: 0)
                        Tile(icon: "photo.fill.on.rectangle.fill", titleTop: "Abrir", titleBottom: "galeria", size: tileSize, action: onOpenGallery)
                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
            }
            .frame(width: 360, height: 383)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 12)
            )
        }
        .transition(.scale.combined(with: .opacity))
    }
}

private struct Tile: View {
    let icon: String
    let titleTop: String
    let titleBottom: String
    let size: CGSize
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color("tabBarSelected"))
                VStack(spacing: 0) {
                    Text(titleTop)
                    Text(titleBottom)
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
            }
            .frame(width: size.width, height: size.height)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(.systemGray4).opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}
