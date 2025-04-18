import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    var onRecognized: ((CVPixelBuffer) -> Void)?

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onRecognized = onRecognized
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
}
