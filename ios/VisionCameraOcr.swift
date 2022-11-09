import Vision
import VisionKit

@objc(OCRFrameProcessorPlugin)
public class OCRFrameProcessorPlugin: NSObject, FrameProcessorPluginBase {
    
    private static let context = CIContext(options: nil)
    
    @objc
    public static func callback(_ frame: Frame!, withArgs _: [Any]!) -> Any! {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
            print("Failed to get CVPixelBuffer!")
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create CGImage!")
            return nil
        }
        
        let result: Dictionary = TextDetector.detectText(image: cgImage)
        
        return [
            "result": [
                "text": result["text"] ?? "",
                "blocks": result["blocks"] ?? []
            ]
        ]
    }
    
}
