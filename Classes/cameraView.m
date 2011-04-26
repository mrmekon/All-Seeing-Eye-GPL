//
//  CameraView.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 trevorbentley. All rights reserved.
//

#import "cameraView.h"

@implementation cameraView

@synthesize imageView;
@synthesize captureSession;


-(id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame: aRect]) {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0, aRect.size.width,aRect.size.height)];
 	  [self addSubview: self.imageView];
    [self setBackgroundColor:[UIColor blackColor]];
	}
  return self;
}

- (void)initCapture {
	NSError *err;
  
  NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);

	/* enable autofocus for iPhone 4 */    
  AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  if ([videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
  	[videoDevice lockForConfiguration: &err];
  	[videoDevice setFocusMode: AVCaptureFocusModeContinuousAutoFocus];
  	[videoDevice unlockForConfiguration];
  }

	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput 
  	deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]
		error:nil];
  
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	captureOutput.alwaysDiscardsLateVideoFrames = YES; 
	captureOutput.minFrameDuration = CMTimeMake(1, 10); // optional, sets max framerate  
	[captureOutput setSampleBufferDelegate:self queue:queue];
	[captureOutput setVideoSettings:videoSettings]; 
  
	self.captureSession = [[AVCaptureSession alloc] init];
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];

	[self.captureSession startRunning];
  
 	dispatch_release(queue);
}

// Factor to scale video frame by to make it full screen, because iPad screen is 768px wide
// and the video frame is 720px wide.  768/720 ~= 1.0666
#define VIDEO_ENLARGEMENT_FACTOR  1.0666

-(CGImageRef) cropImage: (CGImageRef) img {
	CGRect screenSize = [[UIScreen mainScreen] bounds];
	float width = screenSize.size.width / (3 * VIDEO_ENLARGEMENT_FACTOR);
  float height = screenSize.size.height;
	CGRect imgRect = CGRectMake(0,0, width, height);
	return CGImageCreateWithImageInRect(img, imgRect);
}

-(UIImage*) addFrameOverlay: (UIImage*) baseImg {
  UIImage *overlayImg = [UIImage imageNamed: @"frameOverlay.png"];
  
  UIGraphicsBeginImageContext(baseImg.size);  
  
  [baseImg drawInRect:CGRectMake(0, 0, baseImg.size.width, baseImg.size.height)];  
  [overlayImg drawInRect:CGRectMake(0, 0, overlayImg.size.width, overlayImg.size.height) blendMode: kCGBlendModeNormal alpha: 0.5];  
  
  UIImage *blendedImg = UIGraphicsGetImageFromCurrentImageContext();  
  
  UIGraphicsEndImageContext();  

  return blendedImg;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{ 
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

 	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
  CVPixelBufferLockBaseAddress(imageBuffer,0); 
  uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
  size_t width = CVPixelBufferGetWidth(imageBuffer); 
  size_t height = CVPixelBufferGetHeight(imageBuffer);  
    
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
  CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
  CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
	
  CGImageRef croppedImg = [self cropImage: newImage];
	UIImage *image= [UIImage imageWithCGImage: croppedImg scale: (1/VIDEO_ENLARGEMENT_FACTOR) orientation:UIImageOrientationRight];
	image = [self addFrameOverlay: image];
      
	[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
	
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  CGContextRelease(newContext); 
  CGColorSpaceRelease(colorSpace);
	CGImageRelease(newImage);
  CGImageRelease(croppedImg);
	
	[pool drain];
} 

@end
