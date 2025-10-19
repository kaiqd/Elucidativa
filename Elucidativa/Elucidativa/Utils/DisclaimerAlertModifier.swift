import SwiftUI

struct DisclaimerAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    var onConfirm: () -> Void

    func body(content: Content) -> some View {
        content
            .alert("Isenção de Responsabilidade", isPresented: $isPresented) {
                Button("Entendi", role: .cancel, action: onConfirm)
            } message: {
                Text("Este aplicativo não é um médico e não fornece diagnósticos. As análises são geradas por inteligência artificial e podem conter erros. Sempre consulte um profissional de saúde qualificado para interpretar seus exames.")
            }
    }
}

extension View {
    func disclaimerAlert(isPresented: Binding<Bool>, onConfirm: @escaping () -> Void) -> some View {
        self.modifier(DisclaimerAlertModifier(isPresented: isPresented, onConfirm: onConfirm))
    }
}
