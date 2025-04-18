import SwiftUI
import AVFoundation

struct HomeView: View {
    @State private var recognizedText: String = "Waiting for detection..."
    @State private var isScanning: Bool = false
    @State private var isCaptured: Bool = false
    @State private var capturedImage: CVPixelBuffer?
    @State private var capturedAmount: Int?
    @EnvironmentObject var walletManager: WalletManager
    private let classifier = CurrencyClassifierWrapper.shared
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            CameraView(isScanning: .constant(true), onRecognized: { image in
                self.capturedImage = image
            })
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(recognizedText)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                if !isCaptured {
                    Button(action: {
                        isCaptured = true
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
                    HStack {
                        Button(action: {
                            resetScanning()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.red)
                        }
                        .padding()
                        
                        Button(action: {
                            if let amount = capturedAmount {
                                walletManager.addMoney(denomination: Double(amount))
                            }
                            resetScanning()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.green)
                        }

                        .padding()
                    }
                    .padding(.bottom, 130)
                }
            }
        }
    }
    
    func handleCapturedImage(_ image: CVPixelBuffer) {
        classifier.classify(image: image) { result, confidence in
            DispatchQueue.main.async {
                print("result \(String(describing: result))")
                print("confidence \(String(describing: confidence))")
                print("amount \(String(describing: Double(result!)))")
                
                if let text = result {
                    let extractedNumber = text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    
                    if let amount = Int(extractedNumber), confidence >= 0.8, [5, 10, 20, 50, 100, 200].contains(Int(amount)) {
                        self.recognizedText = "\(amount) euros"
                        self.speakOnce("\(text)")
                        self.capturedAmount = amount
                        print("Extracted amount: \(amount)")
                    } else {
//                        Low confidence to ask again recognition
                        self.recognizedText = "Low confidence, try again!"
                        self.isCaptured = false
                    }
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
        self.recognizedText = "Waiting for detection..."
        self.capturedAmount = nil
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WalletManager())
    }
}
