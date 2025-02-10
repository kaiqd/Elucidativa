//
//  CardGalery.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI
import PhotosUI

struct CardGalery: View {
    var image: UIImage?
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipShape(.rect(cornerRadius: 16))
                } else {
                    VStack {
                        Image(systemName: "arrow.up.doc")
                            .resizable()
                            .frame(width: 33, height: 43)

                        Text("Selecionar foto da galeria")
                            .font(.system(size: 20, weight: .regular))
                    }
                    .foregroundStyle(.cardTextGalery)
                }
            }
            .frame(maxWidth: 358, maxHeight: 200)
            .background {
                Color.cardBackground
                    .clipShape(.rect(cornerRadius: 16))
            }
        }
    }
}

//#Preview {
//    VStack {
//        CardGalery(image: UIImage(resource: .mockExam)) {
//            print("Teste")
//        }
//    }
//    .background {
//        Color.blue
//            .frame(width: 420, height: 500)
//    }
//}
