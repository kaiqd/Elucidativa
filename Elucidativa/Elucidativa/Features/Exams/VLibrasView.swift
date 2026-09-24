import SwiftUI
import WebKit

struct VLibrasView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isTranslationOpen = false

    let text: String

    var body: some View {
        NavigationStack {
            Group {
                if isTranslationOpen {
                    VStack(spacing: 0) {
                        Text("Toque no ícone do VLibras e selecione o trecho que deseja traduzir.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()

                        VLibrasWebView(text: text)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Tradução em Libras")
                            .font(.title2.bold())

                        Text("A explicação do exame será exibida com o widget oficial do VLibras. Ao selecionar um trecho para tradução, esse texto poderá ser enviado ao serviço VLibras.")
                            .font(.body)

                        Button("Abrir VLibras") {
                            isTranslationOpen = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.mainStrongGreen)

                        Spacer()
                    }
                    .padding(24)
                }
            }
            .navigationTitle("VLibras")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}

private struct VLibrasWebView: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.loadHTMLString(html, baseURL: URL(string: "https://vlibras.gov.br/"))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    private var html: String {
        let plainText = (try? AttributedString(
            markdown: text,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )).map { String($0.characters) } ?? text

        let escapedText = plainText
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")

        return """
        <!doctype html>
        <html lang="pt-BR">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            body { margin: 0; padding: 20px 20px 100px; font: 17px/1.5 -apple-system, BlinkMacSystemFont, sans-serif; color: #202124; background: #fff; }
            main { white-space: pre-wrap; overflow-wrap: anywhere; }
          </style>
        </head>
        <body>
          <main>\(escapedText)</main>
          <script src="https://vlibras.gov.br/app/vlibras-plugin.js"></script>
        </body>
        </html>
        """
    }
}
