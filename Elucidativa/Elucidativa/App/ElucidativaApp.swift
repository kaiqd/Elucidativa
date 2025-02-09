//
//  ElucidativaApp.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI

@main
struct ElucidativaApp: App {
    @StateObject private var viewModel: HomeViewModel = .init()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
        }
    }
}
