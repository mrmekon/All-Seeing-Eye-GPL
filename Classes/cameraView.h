//
//  CameraView.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 trevorbentley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@interface cameraView : UIView <AVCaptureVideoDataOutputSampleBufferDelegate> {
	UIImageView *imageView;
	AVCaptureSession *captureSession;
	CALayer *cameraLayer;

}
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) CALayer *cameraLayer;


-(id)initWithFrame:(CGRect)aRect;
- (void)initCapture;

@end
