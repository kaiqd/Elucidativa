import Foundation

final class OpenCodeExamService {
    private let apiKey: String
    private let session: URLSession
    private let endpoint = URL(string: "https://opencode.ai/zen/go/v1/responses")!

    var isConfigured: Bool {
        !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.session = session
    }

    func analyze(
        systemMessage: String,
        userPrompt: String,
        completion: @escaping (Result<ExamAnalysisResponse, Error>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(ServiceError.missingKey))
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("Elucidativa/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "x-opencode-session")

        let body: [String: Any] = [
            "model": "gpt-6-luna",
            "input": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": userPrompt]
            ],
            "max_output_tokens": 2048,
            "text": [
                "format": [
                    "type": "json_schema",
                    "name": "exam_analysis",
                    "schema": ExamAnalysisResponse.jsonSchema,
                    "strict": true
                ]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.failure(ServiceError.httpStatus(status)))
                return
            }

            guard let data else {
                completion(.failure(ServiceError.missingOutput))
                return
            }

            do {
                let response = try JSONDecoder().decode(ResponsesResult.self, from: data)
                let contents = response.output.compactMap(\.content).flatMap { $0 }
                guard response.status == nil || response.status == "completed",
                      let output = contents.first(where: { $0.type == "output_text" })?.text,
                      let outputData = output.data(using: .utf8) else {
                    throw ServiceError.missingOutput
                }
                completion(.success(try JSONDecoder().decode(ExamAnalysisResponse.self, from: outputData)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

private struct ResponsesResult: Decodable {
    let status: String?
    let output: [Output]

    struct Output: Decodable {
        let content: [Content]?
    }

    struct Content: Decodable {
        let type: String
        let text: String?
    }
}

private enum ServiceError: LocalizedError {
    case missingKey
    case httpStatus(Int)
    case missingOutput

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "Chave do OpenCode Go não configurada."
        case .httpStatus(let status):
            return "OpenCode Go retornou HTTP \(status)."
        case .missingOutput:
            return "OpenCode Go não retornou uma análise completa."
        }
    }
}
