import SwiftUI

struct MainView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showCreateSheet: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                switch selectedTab {
                case .home:
                    HomeView()
                case .exams:
                    ExamsView()
                case .luci:
                    LuciView()
                case .profile:
                    ProfileView()
                }
            }

            CustomTabBar(
                selected: $selectedTab,
                icons: [
                    .home: (name: "home", title: "Início"),
                    .exams: (name: "exames", title: "Exames"),
                    .luci: (name: "luci", title: "Luci"),
                    .profile: (name: "perfill", title: "Perfil")
                ],
                onCenterTap: {
                    showCreateSheet.toggle()
                }
            )
        }
        .sheet(isPresented: $showCreateSheet) {
            Text("Ação do botão +")
                .font(.title)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    MainView()
        .environmentObject(HomeViewModel())
}
