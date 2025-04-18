import SwiftUI
import AVFoundation

struct ScanMoneyView: View {
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.presentationMode) var presentationMode

    @State private var recognizedText: String = "Waiting for detection..."
    @State private var isScanning: Bool = false
    @State private var isCaptured: Bool = false
    @State private var capturedImage: CVPixelBuffer?
    @State private var capturedAmount: Double?

    private let classifier = CurrencyClassifierWrapper.shared
    private let speechSynthesizer = AVSpeechSynthesizer()

    var onAmountDetected: ((Double) -> Void)? = nil // callback for CalculateView

    var body: some View {
        ZStack {
            CameraView(isScanning: $isScanning, onRecognized: { image in
                self.capturedImage = image
            })
            .edgesIgnoringSafeArea(.all)

            VStack {
                Text(recognizedText)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Spacer()

                if !isCaptured {
                    Button(action: {
                        isCaptured = true
                        isScanning = true
                        if let image = capturedImage {
                            handleCapturedImage(image)
                        }
                    }) {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white.opacity(1)))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding(.bottom, 130)
                } else {
                    HStack(spacing: 40) {
                        Button(action: {
                            resetScanning() // Cancel: not money add
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.red)
                        }

                        Button(action: {
                            if let amount = capturedAmount, [5, 10, 20, 50, 100, 200].contains(Int(amount)) {
                                if let onAmountDetected = onAmountDetected {
                                    onAmountDetected(amount) // callback for CalculateView
                                } else {
                                    walletManager.addMoney(denomination: amount) // WalletView
                                }
                            }
                            presentationMode.wrappedValue.dismiss() // close camera
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.bottom, 130)
                }
            }
        }
    }

    func handleCapturedImage(_ image: CVPixelBuffer) {
        classifier.classify(image: image) { result, confidence in
            DispatchQueue.main.async {
                if let text = result,
                   let amount = Double(text.filter { "0123456789.".contains($0) }),
                   confidence >= 0.8,
                   [5, 10, 20, 50, 100, 200].contains(Int(amount)) {

                    self.recognizedText = "Detected: \(Int(amount))€"
                    self.capturedAmount = amount
                    speakOnce("\(Int(amount)) euros")
                } else {
                    self.recognizedText = "Low confidence, try again!"
                    speakOnce("Recognition confidence too low. Please try again.")
                    self.isCaptured = false
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

    func resetScanning() {
        self.isCaptured = false
        self.capturedAmount = nil
        self.recognizedText = "Waiting for detection..."
    }
}

struct ScanMoneyView_Previews: PreviewProvider {
    static var previews: some View {
        ScanMoneyView()
            .environmentObject(WalletManager())
    }
}
