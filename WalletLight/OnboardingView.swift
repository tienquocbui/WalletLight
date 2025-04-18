import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to WalletLight")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("About the App")
                        .font(.title2)
                        .bold()
                    Text("WalletLight helps visually impaired users manage their cash by recognizing banknotes through the camera. The app provides tools to calculate payments and suggests optimal change.")

                    Text("Disclaimer")
                        .font(.title2)
                        .bold()
                    Text("This application uses a machine learning model for banknote recognition. Due to time constraints and limited data, the model may misidentify non-currency objects. Ensure only valid banknotes are scanned for accurate detection.")

                    Text("Ownership")
                        .font(.title2)
                        .bold()
                    Text("Developed by: Tien Quoc (Kelvin) Bui\nLinkedIn: buitienquoc\nEmail: tien-quoc.bui@epita.fr")
                }
                .padding()
            }

            Button(action: { hasSeenOnboarding = true }) {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}
