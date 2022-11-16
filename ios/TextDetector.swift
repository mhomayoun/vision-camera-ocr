import Foundation
import Vision
import VisionKit

@objc(TextDetector)
public class TextDetector: NSObject {
    
    @objc
    public static func imageToText(_ imageData: NSString) -> Dictionary<String, Any> {
		let ciImage = CIImage(data: Data(base64Encoded: imageData as String)!)
        // TODO: implement https://github.com/a7medev/react-native-ml-kit/blob/main/text-recognition/ios/TextRecognition.m#L77
		return detectText(image: ciImage!.cgImage!)
    }
    
    public static func detectText(image: CGImage) -> Dictionary<String, Any> {
        let handler = VNImageRequestHandler(cgImage: image)
        do {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en_US"]
            try handler.perform([request])
            guard let observations: [VNRecognizedTextObservation] = request.results, observations.count > 0 else {
                print("No text found")
                return [:]
            }
            
            return [
                "text": observations.compactMap({$0.topCandidates(1).first?.string}).joined(separator: "\n"),
                "blocks": getBoundingRects(observations: observations, image: image)
            ]
            
        } catch {
            return [:]
        }
    }
    
    private static func getBoundingRects(observations: [VNRecognizedTextObservation], image: CGImage) -> [[String: Any]] {
        let rects: [[String: Any]] = observations.compactMap { observation in

            // Find the top observation.
            guard let candidate = observation.topCandidates(1).first else { return nil }
            
            // Find the bounding-box observation for the string range.
            let stringRange = candidate.string.startIndex..<candidate.string.endIndex
            let boxObservation = try? candidate.boundingBox(for: stringRange)
            
            // Get the normalized CGRect value.
            let boundingBox = boxObservation?.boundingBox ?? .zero
            // Convert the rectangle from normalized coordinates to image coordinates.
            let rect: CGRect = VNImageRectForNormalizedRect(boundingBox,
                        Int(image.width),
                        Int(image.height));
            
            let offsetX = (rect.midX - ceil(rect.width)) / 2.0
            let offsetY = (rect.midY - ceil(rect.height)) / 2.0

            let x = rect.maxX + offsetX
            let y = rect.minY + offsetY
            
            return [
                "text": candidate.string,
                "rect": [
                    "x": rect.midX + (rect.midX - x),
                    "y": rect.midY + (y - rect.midY),
                    "width": rect.width,
                    "height": rect.height,
                ]
            ]
        }
        
        return rects
    }
    
}

