import SwiftUI

// MARK: - Search field (flexível) + clear + onSubmit
private struct SearchField: View {
    @Binding var text: String
    var height: CGFloat = 48
    var onSubmit: (() -> Void)? = nil

    private let bg = Color(red: 250/255, green: 250/255, blue: 250/255) // #FAFAFA

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)

            TextField("Buscar exames...", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }

            if !text.isEmpty {
                Button {
                    text = ""
                    onSubmit?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: height/2, style: .continuous)
                .fill(bg)
        )
    }
}

// Botão redondo 48x48 (usa o asset "tabBarSelected")
private struct RoundIconButton: View {
    var systemName: String = "magnifyingglass"
    var size: CGFloat = 48
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.tabBarSelected)
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// Chips de filtro (inativo com borda)
private enum FilterKind: String, CaseIterable, Identifiable {
    case all = "Todos"
    case sangue = "Sangue"
    case urina = "Urina"
    case imagem = "Imagem"
    var id: String { rawValue }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.tabBarSelected : .clear)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(isSelected ? Color.tabBarSelected : Color(.systemGray4), lineWidth: 1.2)
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View
struct ExamsView: View {
    var onShowHelp: () -> Void
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var query: String = ""
    @State private var selectedFilter: FilterKind = .all

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                // Busca
                HStack(spacing: 12) {
                    SearchField(text: $query) { hideKeyboard() }
                    RoundIconButton(action: { hideKeyboard() })
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Filtros
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(FilterKind.allCases) { f in
                            FilterChip(title: f.rawValue, isSelected: f == selectedFilter) {
                                selectedFilter = f
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 2)
                }

                // Lista agrupada (já filtrada pela busca + chip)
                let grouped = groupedItems(filteredItems())
                if grouped.isEmpty {
                    Text("Nenhum exame encontrado.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 24)
                } else {
                    ForEach(grouped.keys.sorted(by: >), id: \.self) { year in
                        Text(verbatim: "\(year)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        ForEach(grouped[year]!.keys.sorted(by: >), id: \.self) { month in
                            Text(monthName(month))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 4)

                            VStack(spacing: 16) {
                                ForEach(grouped[year]![month]!) { exam in
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
                            .padding(.horizontal, 16)
                            .padding(.top, 6)
                            .padding(.bottom, 4)
                        }
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Exames")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onShowHelp) {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityLabel("Dúvidas frequentes")
            }
        }
    }

    // MARK: - Busca & agrupamento

    private func filteredItems() -> [ExamModel] {
        // filtro do chip
        let byFilter: (ExamModel) -> Bool = { item in
            switch selectedFilter {
            case .all:    return true
            case .sangue: return item.category == .sangue
            case .urina:  return item.category == .urina
            case .imagem: return item.category == .imagem
            }
        }

        // filtro por texto (case/acentos-insensitive)
        let q = normalize(query)
        let byQuery: (ExamModel) -> Bool = { item in
            guard !q.isEmpty else { return true }
            let haystack = normalize([item.title, item.lugar, item.tipoDeExame, item.formaDeEntrega, item.description].joined(separator: " "))
            return haystack.contains(q)
        }

        return viewModel.examsList.filter { byFilter($0) && byQuery($0) }
            .sorted(by: { $0.date > $1.date })
    }

    private func groupedItems(_ items: [ExamModel]) -> [Int: [Int: [ExamModel]]] {
        var dict: [Int: [Int: [ExamModel]]] = [:]
        let cal = Calendar.current
        for it in items {
            let y = cal.component(.year, from: it.date)
            let m = cal.component(.month, from: it.date)
            dict[y, default: [:]][m, default: []].append(it)
        }
        return dict
    }

    private func monthName(_ month: Int) -> String {
        var comps = DateComponents(); comps.year = 2024; comps.month = month; comps.day = 1
        let df = DateFormatter(); df.locale = Locale(identifier: "pt_BR"); df.setLocalizedDateFormatFromTemplate("LLLL")
        return df.string(from: Calendar.current.date(from: comps)!).capitalized
    }

    private func normalize(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

#Preview {
    ExamsView(onShowHelp: {})
        .environmentObject(HomeViewModel())
}
