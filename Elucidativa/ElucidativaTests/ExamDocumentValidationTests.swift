import XCTest
@testable import Elucidativa

final class ExamDocumentValidationTests: XCTestCase {
    func testAcceptsReportWhenExamAndResultEvidenceAppearInOCR() throws {
        let response = try makeResponse(
            classification: "laudo",
            examEvidence: "Hemograma completo",
            resultEvidence: "Hemoglobina: 14 g/dL"
        )
        let text = "LABORATÓRIO EXEMPLO\nHEMOGRAMA COMPLETO\nHemoglobina: 14 g/dL"

        guard case .valid(let exam) = response.validate(against: text) else {
            return XCTFail("Um laudo com evidências presentes no OCR deveria ser aceito.")
        }
        XCTAssertEqual(exam.nome, "Hemograma completo")
    }

    func testRejectsUnrelatedDocumentEvenIfExamFieldsWereFilled() throws {
        let response = try makeResponse(
            classification: "nao_laudo",
            examEvidence: "Parque das Flores",
            resultEvidence: "Entrada gratuita"
        )

        guard case .notAReport = response.validate(against: "Parque das Flores. Entrada gratuita.") else {
            return XCTFail("Texto de uma paisagem com placa não deve virar exame.")
        }
    }

    func testDoesNotAcceptEvidenceAbsentFromOCR() throws {
        let response = try makeResponse(
            classification: "laudo",
            examEvidence: "Hemograma completo",
            resultEvidence: "Hemoglobina: 14 g/dL"
        )

        guard case .uncertain = response.validate(against: "Hemograma completo. Resultado ilegível.") else {
            return XCTFail("Evidência que não aparece no OCR deve bloquear o salvamento.")
        }
    }

    func testUncertainDocumentIsNotAccepted() throws {
        let response = try makeResponse(
            classification: "incerto",
            examEvidence: "",
            resultEvidence: "",
            exam: NSNull()
        )

        guard case .uncertain = response.validate(against: "Exa?e Re?ultado ilegível") else {
            return XCTFail("Documento incerto deve pedir uma nova imagem.")
        }
    }

    private func makeResponse(
        classification: String,
        examEvidence: String,
        resultEvidence: String,
        exam: Any = [
            "nome": "Hemograma completo",
            "lugar": "Laboratório Exemplo",
            "tipoDeExame": "Sangue",
            "nivel": "Normal",
            "descricao": "Resultados dentro da referência."
        ]
    ) throws -> ExamAnalysisResponse {
        let json: [String: Any] = [
            "classificacaoDocumento": classification,
            "evidenciaExame": examEvidence,
            "evidenciaResultado": resultEvidence,
            "exame": exam
        ]
        return try JSONDecoder().decode(
            ExamAnalysisResponse.self,
            from: JSONSerialization.data(withJSONObject: json)
        )
    }
}
