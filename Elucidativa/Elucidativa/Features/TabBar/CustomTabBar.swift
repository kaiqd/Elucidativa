import SwiftUI

enum AppTab: Hashable { case home, exams }

struct CustomTabBar: View {
    @Binding var selected: AppTab
    var onCenterTap: () -> Void

    private let accent = Color.tabBarSelected

    var body: some View {
        HStack(spacing: 0) {
            tab(.home, title: "Início", symbol: "house")
            addButton
            tab(.exams, title: "Exames", symbol: "doc.text")
        }
        .frame(height: 76)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(Divider(), alignment: .top)
        .ignoresSafeArea(.keyboard)
    }

    private var addButton: some View {
        Button(action: onCenterTap) {
            VStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(accent, in: Circle())

                Text("Adicionar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Adicionar exame")
    }

    private func tab(_ tab: AppTab, title: String, symbol: String) -> some View {
        let isSelected = selected == tab

        return Button {
            selected = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 23, weight: isSelected ? .semibold : .regular))
                    .frame(height: 26)
                Text(title)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? accent : .secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ContentView()
}
