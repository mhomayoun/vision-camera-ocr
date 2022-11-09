#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <React/RCTBridgeModule.h>

@interface VISION_EXPORT_SWIFT_FRAME_PROCESSOR(scanOCR, OCRFrameProcessorPlugin)
@end

@interface RCT_EXTERN_MODULE(TextDetector, NSObject)
    RCT_EXTERN_METHOD(imageToText:(NSString)imageData);
@end
