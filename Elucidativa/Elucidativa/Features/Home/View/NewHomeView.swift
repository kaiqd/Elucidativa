import SwiftUI

struct NewHomeView: View {
    @Binding var selectedTab: AppTab
    var onAddExam: () -> Void
    var onShowHelp: () -> Void

    @EnvironmentObject private var viewModel: HomeViewModel
    @EnvironmentObject private var userSettings: UserSettings

    private let accent = Color.tabBarSelected

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header

                if viewModel.examsList.isEmpty {
                    emptyState
                } else {
                    recentExams
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .background(Color.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Olá, \(userSettings.name)")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)

                Text("Seus exames em um só lugar.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button(action: onShowHelp) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 23))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(accent)
            .accessibilityLabel("Dúvidas frequentes")
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "doc.text")
                .font(.title2)
                .foregroundStyle(accent)
                .frame(width: 48, height: 48)
                .background(accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text("Nenhum exame adicionado")
                    .font(.title3.bold())

                Text("Envie uma foto do laudo para receber uma explicação em linguagem simples.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Button(action: onAddExam) {
                Text("Adicionar exame")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(accent, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private var recentExams: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Exames recentes")
                    .font(.title3.bold())

                Spacer()

                Button("Ver todos") { selectedTab = .exams }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
            }

            ForEach(viewModel.examsList.sorted(by: { $0.date > $1.date }).prefix(3)) { exam in
                ExamCardView(
                    name: exam.title,
                    urgency: nil,
                    dateText: exam.date.formattedString(),
                    place: exam.lugar,
                    examType: exam.tipoDeExame,
                    deliveryFormat: exam.formaDeEntrega,
                    level: exam.nivel,
                    descriptionText: exam.description
                )
            }
        }
    }
}

#Preview {
    NewHomeView(selectedTab: .constant(.home), onAddExam: {}, onShowHelp: {})
        .environmentObject(HomeViewModel())
        .environmentObject(UserSettings())
}
