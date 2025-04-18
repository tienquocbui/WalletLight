import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var recognizedText: String = ""
    @State private var isScanning: Bool = false
    @State private var walletBalance: Double = 0.0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
            ZStack {
                VStack {
                    CameraView(isScanning: $isScanning, onRecognized: handleRecognizedText)
                        .frame(height: 400)
                        .cornerRadius(10)
                        .padding()
                    
                    Text("Detected: \(recognizedText)")
                        .font(.largeTitle)
                        .padding()
                    
                    Button(action: {
                        if let amount = Double(recognizedText), [5, 10, 20, 50, 100, 200].contains(Int(amount)) {
                            walletBalance += amount
                            speak("Added \(Int(amount)) euros to wallet. Total balance: \(Int(walletBalance)) euros.")
                        }
                    }) {
                        Text("Add to Wallet")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Text("Wallet Balance: \(Int(walletBalance))€")
                        .font(.title)
                        .padding()
                }
            }
    }

    func handleRecognizedText(_ pixelBuffer: CVPixelBuffer) {
        CurrencyClassifierWrapper.shared.classify(image: pixelBuffer) { result,_  in
            DispatchQueue.main.async {
                if let text = result {
                    self.recognizedText = text
                    speakOnce("\(text) euros")
                }
            }
        }
    }

    func speakOnce(_ text: String) {
        if !speechSynthesizer.isSpeaking {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            speechSynthesizer.speak(utterance)
        }
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
}
