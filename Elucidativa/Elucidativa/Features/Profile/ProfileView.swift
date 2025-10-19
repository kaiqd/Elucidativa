import SwiftUI

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct ProfileView: View {
    
    let faqItems: [FAQItem] = [
        FAQItem(question: "O que este app faz?",
                answer: "O Elucidativa ajuda você a entender seus laudos de exames. Basta enviar uma foto ou PDF do seu laudo e nossa inteligência artificial irá gerar uma explicação em linguagem simples e acessível."),
        FAQItem(question: "Este aplicativo substitui um médico?",
                answer: "Não. Este aplicativo é uma ferramenta de auxílio e não substitui, em nenhuma hipótese, a consulta, o diagnóstico e o acompanhamento de um profissional de saúde qualificado. Use as informações aqui presentes para ter uma conversa mais informada com seu médico."),
        FAQItem(question: "Meus dados e laudos estão seguros?",
                answer: "Sim. Seus exames são processados de forma anônima e não são armazenados em nossos servidores após a análise. O histórico de suas conversas e exames fica salvo apenas no seu dispositivo."),
        FAQItem(question: "Quais tipos de exames posso enviar?",
                answer: "Você pode enviar a maioria dos laudos de exames que contenham texto, como exames de sangue, urina, imagem (com laudo), etc. A qualidade da análise depende da clareza e legibilidade do texto no documento."),
        FAQItem(question: "A análise da IA é 100% precisa?",
                 answer: "A inteligência artificial é uma ferramenta poderosa, mas pode cometer erros. Os resultados e a análise gerada devem ser vistos como um ponto de partida para sua compreensão e não como um fato absoluto. Sempre valide as informações com seu médico.")
    ]
    
    var body: some View {
        NavigationStack {
            List(faqItems) { item in
                DisclosureGroup(item.question) {
                    Text(item.answer)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
                .font(.headline)
            }
            .navigationTitle("Dúvidas Frequentes")
        }
    }
}

#Preview {
    ProfileView()
}