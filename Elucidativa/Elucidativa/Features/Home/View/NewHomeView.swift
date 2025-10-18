//
//  NewHomeView.swift
//  Elucidativa
//
//  Created by Kaique Diniz on 18/10/25.
//

import SwiftUI

// Header simples reutilizável
private struct SectionHeader: View {
    var title: String
    var trailingTitle: String?
    var onTapTrailing: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
            Spacer()
            if let trailingTitle {
                Button(trailingTitle) { onTapTrailing?() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.blue)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct NewHomeView: View {
    // ⬇️ Estado para o popup e fluxo (mesmo dos botões da tab bar)
    @State private var showAddPopup = false
    @StateObject private var addFlow = AddExamFlow()

    private let examsMock: [(name: String, date: String, place: String, type: String, format: String, level: InterpretationLevel, desc: String)] = [
        ("Hemograma Completo", "Há 2 dias", "Lab Sabin", "Sangue", "PDF", .normal,
         "Todos os valores estão dentro do esperado. Suas células do sangue estão funcionando bem!"),
        ("Glicemia em Jejum", "Há 1 semana", "Lab Fleury", "Sangue", "PDF", .attention,
         "Glicose um pouco elevada (115 mg/dL). Vale conversar com seu médico sobre alimentação."),
        ("Colesterol Total", "Há 2 semanas", "Lab Delboni", "Sangue", "PDF", .normal,
         "Colesterol controlado! LDL e HDL em níveis saudáveis.")
    ]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {

                    // ✅ Toca no card → abre o popup de adicionar exame
                    AddExamCard(onTap: { showAddPopup = true  })
                        .padding(.top, 8)

                    SectionHeader(title: "Exames recentes", trailingTitle: "Ver todos") { }
                        .padding(.top, 4)

                    VStack(spacing: 20) {
                        ForEach(Array(examsMock.enumerated()), id: \.offset) { _, e in
                            ExamCardView(
                                name: e.name,
                                urgency: nil,
                                dateText: e.date,
                                place: e.place,
                                examType: e.type,
                                deliveryFormat: e.format,
                                level: e.level,
                                descriptionText: e.desc
                            )
                        }
                    }
                    .padding(.horizontal, 16)

                    SectionHeader(title: "Dicas de saúde")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            HealthTipCard(emoji: "💧", title: "Hidratação", tip: "Beba 2L de água por dia")
                            HealthTipCard(emoji: "🏃‍♂️", title: "Exercícios", tip: "30min por dia fazem diferença")
                            HealthTipCard(emoji: "🛌", title: "Sono", tip: "Busque 7–8h por noite")
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))

            if showAddPopup {
                AddExamPopup(
                    onClose: { showAddPopup = false },
                    onTakePhoto: {
                         showAddPopup = false
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            addFlow.showCamera = true
                        } else {
                            addFlow.alert = .init(title: "Câmera indisponível",
                                                  message: "Use um dispositivo com câmera ou tente a galeria.")
                        }
                    },
                    onSendFile: {
                         showAddPopup = false
                        addFlow.showDocumentPicker = true
                    },
                    onOpenGallery: {
                        showAddPopup = false
                        addFlow.showPhotoLibrary = true
                    }
                )
            }
        }
        .sheet(isPresented: $addFlow.showCamera) {
            CameraPicker(image: $addFlow.capturedImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $addFlow.showPhotoLibrary) {
            PhotoLibraryPicker(image: $addFlow.pickedImage)
        }
        .sheet(isPresented: $addFlow.showDocumentPicker) {
            DocumentPicker(url: $addFlow.pickedFileURL)
        }
        .alert(item: $addFlow.alert) { item in
            Alert(title: Text(item.title), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    NewHomeView()
}
