import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userSettings: UserSettings
    @State private var name: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Bem-vindo(a) ao Elucidativa!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Tire fotos ou envie PDFs dos seus laudos de exames e receba uma explicação em linguagem simples e acessível.")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Como podemos te chamar?", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .padding(.top)

            Spacer()
            
            Button(action: {
                if !name.isEmpty {
                    userSettings.name = name
                    userSettings.hasCompletedOnboarding = true
                }
            }) {
                Text("Continuar")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom)
            .disabled(name.isEmpty)
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserSettings())
}
