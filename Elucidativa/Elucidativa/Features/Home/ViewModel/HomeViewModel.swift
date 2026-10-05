import SwiftUI
import UIKit
import Vision
import Network

// Struct to decode the JSON response from GPT
struct GPTExamResponse: Decodable {
    let nome: String
    let lugar: String
    let tipoDeExame: String
    let nivel: String // "Normal", "Atencao", "Urgente"
    let descricao: String
}

private struct OpenAIExamResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String
    }
}

class HomeViewModel: ObservableObject {
    private var persistenceService: ExamRepository = ExamCoreDataService()
    @Published var examsList: [ExamModel]
    @Published var selectedExam: ExamModel = .init()
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false
    
    init() {
        self.examsList = persistenceService.fetchExams()
    }
    
    func addExam(imageData: Data, formaDeEntrega: String, completion: ((ExamModel) -> Void)? = nil) {
        guard let image = UIImage(data: imageData) else {
            print("Error: Could not create UIImage from data.")
            return
        }
        
        extractText(from: image) { [weak self] extractedText in
            guard let self = self, let text = extractedText, !text.isEmpty else {
                print("Error: Could not extract text from image.")
                return
            }
            
            self.sendToGPT(text: text) { result in
                switch result {
                case .success(let gptResponse):
                    let nivel: InterpretationLevel
                    switch gptResponse.nivel.lowercased() {
                    case "normal":
                        nivel = .normal
                    case "atencao":
                        nivel = .attention
                    case "urgente":
                        nivel = .critical
                    default:
                        nivel = .normal
                    }
                    
                    let newExam = ExamModel(
                        date: Date(),
                        title: gptResponse.nome,
                        image: imageData,
                        description: gptResponse.descricao,
                        lugar: gptResponse.lugar,
                        tipoDeExame: gptResponse.tipoDeExame,
                        nivel: nivel,
                        formaDeEntrega: formaDeEntrega
                    )
                    
                    self.persistenceService.addExam(exam: newExam)
                    self.fetchData()
                    
                    // Call the completion handler with the new exam
                    completion?(newExam)
                    
                case .failure(let error):
                    print("Error sending to GPT: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteExam(id: UUID) {
        persistenceService.deleteExam(id: id)
        fetchData()
    }
    
    func checkNetworkConnectivity() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        networkMonitor.start(queue: workerQueue)
    }
    
    private func fetchData() {
        DispatchQueue.main.async {
            self.examsList = self.persistenceService.fetchExams()
        }
    }
    
    // MARK: - Private Helper Functions
    
    private func extractText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("OCR Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            let recognizedText = request.results as? [VNRecognizedTextObservation] ?? []
            let topCandidateTexts = recognizedText.compactMap { $0.topCandidates(1).first?.string }
            let fullText = topCandidateTexts.joined(separator: "\n")
            
            completion(fullText.isEmpty ? nil : fullText)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing OCR: \(error.localizedDescription)")
            completion(nil)
        }
    }

    private func sendToGPT(text: String, completion: @escaping (Result<GPTExamResponse, Error>) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
        
        let systemMessage = "Você é um sistema especializado em explicar termos médicos e científicos de forma acessível a pessoas leigas. Sua missão é receber um laudo de exame médico e fornecer uma explicação concisa sobre os achados descritos para o paciente, utilizando uma linguagem simples e compreensível para um estudante do ensino fundamental.\n\nEstrutura do texto de saída:\n\nResumo dos resultados:Inicie com um parágrafo resumindo o propósito do exame e destacando se há algum achado anormal. Se não houver, informe que nada de errado foi identificado.\n\nExplicação da gravidade:Caso haja algum achado anormal, explique a gravidade de maneira clara e simples, enfatizando que a palavra final sempre deve vir do médico responsável pelo caso.\n\nAchados críticos (se aplicável):Se houver achados críticos que necessitem atenção imediata, chame atenção com emojis e incentive a pessoa a marcar uma consulta de retorno o mais rápido possível."

        let userPrompt = """
        Analise o seguinte texto de um laudo de exame médico e extraia as informações solicitadas.
        Responda APENAS com um objeto JSON válido.

        O JSON deve ter a seguinte estrutura:
        {
          "nome": "Nome do Exame",
          "lugar": "Nome do Laboratório ou Hospital",
          "tipoDeExame": "Tipo de exame (ex: Sangue, Urina, Imagem)",
          "nivel": "Classifique a gravidade em uma das três opções: 'Normal', 'Atencao' ou 'Urgente'",
          "descricao": "A explicação concisa e simples dos resultados, seguindo a sua missão de ser um assistente acessível."
        }

        Texto do Laudo:
        ---
        \(text)
        ---
        """
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": systemMessage
                ],
                [
                    "role": "user",
                    "content": userPrompt
                ]
            ],
            "max_tokens": 1024,
            "temperature": 0.2,
            "response_format": ["type": "json_object"]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "GPTError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from GPT."])
                completion(.failure(noDataError))
                return
            }
            
            do {
                let openAIResponse = try JSONDecoder().decode(OpenAIExamResponse.self, from: data)
                guard let content = openAIResponse.choices.first?.message.content else {
                    let parsingError = NSError(domain: "GPTError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find content in GPT response."])
                    completion(.failure(parsingError))
                    return
                }

                guard let contentData = content.data(using: .utf8) else {
                    let dataError = NSError(domain: "GPTError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not convert content string to data."])
                    completion(.failure(dataError))
                    return
                }

                let gptResponse = try JSONDecoder().decode(GPTExamResponse.self, from: contentData)
                DispatchQueue.main.async {
                    completion(.success(gptResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
