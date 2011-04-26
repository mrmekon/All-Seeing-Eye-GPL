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
  NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);

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

-(CGImageRef) cropImage: (CGImageRef) img {
	float width = CGImageGetWidth(img);
  float height = CGImageGetHeight(img);
	CGRect imgRect = CGRectMake(0,0, width/3, height);
	return CGImageCreateWithImageInRect(img, imgRect);
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
	UIImage *image= [UIImage imageWithCGImage: croppedImg scale:1.0 orientation:UIImageOrientationRight];
		
	[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
	
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  CGContextRelease(newContext); 
  CGColorSpaceRelease(colorSpace);
	CGImageRelease(newImage);
  CGImageRelease(croppedImg);
	
	[pool drain];
} 

@end
