import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var userSettings: UserSettings
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var isNameFocused: Bool
    @State private var name = ""

    private let accent = Color.tabBarSelected

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    brand

                    if !dynamicTypeSize.isAccessibilitySize {
                        ReportIllustration()
                            .frame(height: 208)
                            .padding(.top, 40)
                            .padding(.bottom, 36)
                    } else {
                        Spacer(minLength: 36)
                    }

                    Text("Entenda seus exames com clareza.")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Envie uma foto do laudo e receba uma explicação em linguagem simples para conversar melhor com seu médico.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 14)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            nameForm
        }
        .background(Color.background.ignoresSafeArea())
    }

    private var brand: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.text")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(accent, in: RoundedRectangle(cornerRadius: 10))

            Text("Elucidativa")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }

    private var nameForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Como podemos chamar você?")
                .font(.headline)

            TextField("Seu nome", text: $name)
                .textContentType(.givenName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)
                .submitLabel(.done)
                .focused($isNameFocused)
                .onSubmit(completeOnboarding)
                .padding(.horizontal, 16)
                .frame(minHeight: 54)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))

            Button(action: completeOnboarding) {
                HStack {
                    Text("Começar")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .frame(minHeight: 54)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(accent, in: RoundedRectangle(cornerRadius: 12))
            .disabled(trimmedName.isEmpty)
            .opacity(trimmedName.isEmpty ? 0.55 : 1)

            Text("A explicação não substitui a avaliação de um profissional de saúde.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 16)
        .background(Color.background)
    }

    private func completeOnboarding() {
        guard !trimmedName.isEmpty else { return }
        isNameFocused = false
        userSettings.name = trimmedName
        userSettings.hasCompletedOnboarding = true
    }
}

private struct ReportIllustration: View {
    private let accent = Color.tabBarSelected

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(accent.opacity(0.08))

            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                    Text("LAUDO")
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                }
                .foregroundStyle(accent)

                VStack(alignment: .leading, spacing: 10) {
                    line(width: 140)
                    line(width: 115)
                    line(width: 130)
                }
            }
            .padding(22)
            .frame(width: 210, height: 148, alignment: .topLeading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
            .rotationEffect(.degrees(-6))
            .offset(x: -24, y: -7)

            HStack(spacing: 8) {
                Image(systemName: "text.alignleft")
                Text("Em palavras simples")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(accent, in: Capsule())
            .offset(x: 30, y: 57)
        }
        .accessibilityHidden(true)
    }

    private func line(width: CGFloat) -> some View {
        Capsule()
            .fill(Color.primary.opacity(0.12))
            .frame(width: width, height: 7)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserSettings())
}
