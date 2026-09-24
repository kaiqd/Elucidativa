//
//  CustomTabBar.swift
//  Elucidativa
//
//  Created by Kaique Diniz on 15/10/25.
//

import SwiftUI

enum AppTab: Hashable { case home, exams, luci, profile }

enum TabIcon {
    case asset(String)
    case sfSymbol(String)
}

struct TabSpec {
    let icon: TabIcon
    let title: String
}

//struct ContentView: View {
//    @State private var selected: AppTab = .home
//    @State private var showCreate = false
//    @State private var yOffset: CGFloat = -19
//
//    var body: some View {
//        VStack {
//            ZStack(alignment: .bottom) {
//                switch selected {
//                case .home:    Color.white.ignoresSafeArea().overlay(Text("Início"))
//                case .exams:   Color.white.ignoresSafeArea().overlay(Text("Exames"))
//                case .luci:    Color.white.ignoresSafeArea().overlay(Text("Luci"))
//                case .profile: Color.white.ignoresSafeArea().overlay(Text("Perfil"))
//                }
//
//                CustomTabBar(
//                    selected: $selected,
//                    icons: [
//                        .home:    (name: "home",    title: "Início"),
//                        .exams:   (name: "exams",   title: "Exames"),
//                        .luci:    (name: "luci",    title: "Luci"),
//                        .profile: (name: "perfill", title: "Perfil")
//                    ],
//                    onCenterTap: { showCreate = true },
//                    yOffset: yOffset
//                )
//            }
//            .sheet(isPresented: $showCreate) { Text("Ação do +").font(.title) }
//            
//            VStack {
//                Slider(value: $yOffset, in: -40...20, step: 1)
//                    .padding()
//                Text("Y Offset: \(Int(yOffset))")
//            }
//            .padding(.bottom)
//        }
//    }
//}

struct CustomTabBar: View {
    @Binding var selected: AppTab
    let icons: [AppTab: TabSpec]
    var onCenterTap: () -> Void
    var yOffset: CGFloat = -4

    private let centralSize: CGFloat = 56
    private let iconSize: CGFloat = 24
    private let active = Color.tabBarSelected
    private let inactive = Color.gray.opacity(0.7)

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                tab(.home)
                tab(.exams)
                spacerForCenter()
                tab(.luci)
                tab(.profile)
            }
            .frame(height: 74)
            .padding(.horizontal, 24)
            .background(.ultraThinMaterial)
            .overlay(Divider(), alignment: .top)

            Button(action: onCenterTap) {
                ZStack {
                    Circle().fill(active)
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white)
                        .bold()
                    Circle().strokeBorder(Color.white, lineWidth: 4)
                }
                .frame(width: centralSize, height: centralSize)
            }
            .offset(y: yOffset)
        }
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private func tab(_ t: AppTab) -> some View {
        let isSel = selected == t
        let spec = icons[t]!

        VStack(spacing: 6) {
            // ⬇️ Renderização correta para cada tipo
            switch spec.icon {
            case .asset(let name):
                Image(name)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(isSel ? active : inactive)

            case .sfSymbol(let systemName):
                Image(systemName: systemName)
                    .font(.system(size: iconSize, weight: .regular))
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(isSel ? active : inactive)
            }

            Text(spec.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSel ? active : inactive)
                .underline(true, color: (isSel ? active : inactive).opacity(0.9))
                .padding(.bottom, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { selected = t }
    }

    private func spacerForCenter() -> some View {
        Color.clear.frame(width: centralSize + 40, height: 1)
    }
}
#Preview {
    ContentView()
}
