//
//  HomeViewModel.swift
//  Elucidativa
//
//  Created by Vitor Costa on 09/02/25.
//

import SwiftUI
import UIKit
import Vision
import Network

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
    
    func addExam(exam: ExamModel) {
        var examMock = exam
        examMock.date = Date.now
        
        if let image = UIImage(data: examMock.image) {
            extractText(from: image) { extractedText in
                sendToGPT(text: extractedText) { gptResponse in
                    examMock.description = gptResponse
                    self.persistenceService.addExam(exam: examMock)
                    self.fetchData()
                }
            }
        } else {
            examMock.description = "Imagem inválida ou não encontrada."
            persistenceService.addExam(exam: examMock)
            fetchData()
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
}


func extractText(from image: UIImage, completion: @escaping (String) -> Void) {
    guard let cgImage = image.cgImage else {
        completion("Erro: A imagem não pôde ser convertida para CGImage.")
        return
    }
    
    let request = VNRecognizeTextRequest { (request, error) in
        if let error = error {
            completion("Erro ao realizar OCR: \(error.localizedDescription)")
            return
        }
        
        var recognizedText = ""
        
        // Processando as observações de texto reconhecido
        for observation in request.results as? [VNRecognizedTextObservation] ?? [] {
            if let topCandidate = observation.topCandidates(1).first {
                recognizedText += topCandidate.string + "\n"
            }
        }
        
        // Se não houver texto, retornamos uma mensagem padrão
        completion(recognizedText.isEmpty ? "Nenhum texto encontrado." : recognizedText)
    }
    
    // Configuração do nível de reconhecimento de texto
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
        try handler.perform([request])
    } catch {
        completion("Erro ao processar a imagem: \(error.localizedDescription)")
    }
}

func sendToGPT(text: String, completion: @escaping (String) -> Void) {
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")
    
    let prompt = """
    Você é um sistema especializado em explicar termos médicos e científicos de forma acessível a pessoas leigas. Sua missão é receber um laudo de exame médico e fornecer uma explicação concisa sobre os achados descritos para o paciente, utilizando uma linguagem simples e compreensível para um estudante do ensino fundamental.

    Estrutura do texto de saída:

    Resumo dos resultados:Inicie com um parágrafo resumindo o propósito do exame e destacando se há algum achado anormal. Se não houver, informe que nada de errado foi identificado.

    Explicação da gravidade:Caso haja algum achado anormal, explique a gravidade de maneira clara e simples, enfatizando que a palavra final sempre deve vir do médico responsável pelo caso.

    Achados críticos (se aplicável):Se houver achados críticos que necessitem atenção imediata, chame atenção com emojis e incentive a pessoa a marcar uma consulta de retorno o mais rápido possível.

    Texto extraído do laudo: \(text)
    """
    
    let body: [String: Any] = [
        "model": "gpt-4",
        "messages": [
            [
                "role": "system",
                "content": "Você é um assistente médico que ajuda a traduzir laudos médicos em uma linguagem acessível."
            ],
            [
                "role": "user",
                "content": prompt
            ]
        ],
        "max_tokens": 1024,
        "temperature": 0.5
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        completion("Erro ao criar o corpo da requisição: \(error.localizedDescription)")
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion("Erro na requisição: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            completion("Erro: Não foi possível receber dados.")
            return
        }
        
        do {
            // Parse da resposta JSON
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content) // Envia o texto gerado pelo GPT
            } else {
                completion("Erro ao processar a resposta do GPT.")
            }
        } catch {
            completion("Erro ao parsear a resposta JSON: \(error.localizedDescription)")
        }
    }
    
    task.resume()
}


