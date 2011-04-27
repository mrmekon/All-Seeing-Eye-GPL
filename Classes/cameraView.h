//
//  CameraView.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//
///\file

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

/** 
 * Factor to scale video frame by to make it full screen, because iPad screen is 768px wide
 * and the video frame is 720px wide.  768/720 ~= 1.0666
 */
#define VIDEO_ENLARGEMENT_FACTOR  1.0666


@interface cameraView : UIView <AVCaptureVideoDataOutputSampleBufferDelegate> {
	UIImageView *imageView;
	AVCaptureSession *captureSession;
}
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) AVCaptureSession *captureSession;

-(id)initWithFrame:(CGRect)aRect;
- (void)initCapture;
-(CGImageRef) cropImage: (CGImageRef) img;
-(UIImage*) addFrameOverlay: (UIImage*) baseImg;
-(void) captureOutput:(AVCaptureOutput *)captureOutput 
				didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
        fromConnection:(AVCaptureConnection *)connection;

@end
