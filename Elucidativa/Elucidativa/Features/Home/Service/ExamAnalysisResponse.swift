import Foundation

struct GPTExamResponse: Decodable {
    let nome: String
    let lugar: String
    let tipoDeExame: String
    let nivel: String
    let descricao: String
}

enum ExamDocumentValidation {
    case valid(GPTExamResponse)
    case notAReport
    case uncertain
}

struct ExamAnalysisResponse: Decodable {
    private enum DocumentKind: String, Decodable {
        case report = "laudo"
        case notAReport = "nao_laudo"
        case uncertain = "incerto"
    }

    private let classificacaoDocumento: DocumentKind
    private let evidenciaExame: String
    private let evidenciaResultado: String
    private let exame: GPTExamResponse?

    func validate(against recognizedText: String) -> ExamDocumentValidation {
        switch classificacaoDocumento {
        case .notAReport:
            return .notAReport
        case .uncertain:
            return .uncertain
        case .report:
            guard let exame,
                  !exame.nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !exame.descricao.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  evidenceMatches(evidenciaExame, in: recognizedText),
                  evidenceMatches(evidenciaResultado, in: recognizedText) else {
                return .uncertain
            }
            return .valid(exame)
        }
    }

    private func evidenceMatches(_ evidence: String, in text: String) -> Bool {
        let normalizedEvidence = Self.normalized(evidence)
        return normalizedEvidence.count >= 6 && Self.normalized(text).contains(normalizedEvidence)
    }

    private static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "pt_BR"))
            .filter { $0.isLetter || $0.isNumber }
    }

    static let jsonSchema: [String: Any] = [
        "type": "object",
        "properties": [
            "classificacaoDocumento": [
                "type": "string",
                "enum": ["laudo", "nao_laudo", "incerto"]
            ],
            "evidenciaExame": ["type": "string"],
            "evidenciaResultado": ["type": "string"],
            "exame": [
                "anyOf": [
                    [
                        "type": "object",
                        "properties": [
                            "nome": ["type": "string"],
                            "lugar": ["type": "string"],
                            "tipoDeExame": ["type": "string", "enum": ["Sangue", "Urina", "Imagem", "Outro"]],
                            "nivel": ["type": "string", "enum": ["Normal", "Atencao", "Urgente"]],
                            "descricao": ["type": "string"]
                        ],
                        "required": ["nome", "lugar", "tipoDeExame", "nivel", "descricao"],
                        "additionalProperties": false
                    ],
                    ["type": "null"]
                ]
            ]
        ],
        "required": ["classificacaoDocumento", "evidenciaExame", "evidenciaResultado", "exame"],
        "additionalProperties": false
    ]
}
