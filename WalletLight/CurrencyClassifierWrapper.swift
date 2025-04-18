import CoreML
import Vision

class CurrencyClassifierWrapper {
    static let shared = CurrencyClassifierWrapper()
    private var model: VNCoreMLModel?

    private init() {
        do {
            let currencyModel = try CurrencyClassifier(configuration: MLModelConfiguration())
            model = try VNCoreMLModel(for: currencyModel.model)
        } catch {
            print("Error loading model: \(error)")
        }
    }

    func classify(image: CVPixelBuffer, completion: @escaping (String?, Float) -> Void) {
        guard let model = model else {
            completion(nil, 0.0)
            return
        }

        let request = VNCoreMLRequest(model: model) { request, _ in
            guard let results = request.results as? [VNClassificationObservation], let firstResult = results.first else {
                completion(nil, 0.0)
                return
            }
            completion(firstResult.identifier, firstResult.confidence)
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform classification: \(error)")
                completion(nil, 0.0)
            }
        }
    }
}
