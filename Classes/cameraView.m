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
@synthesize cameraLayer;


-(id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame: aRect]) {
		UIImage *wheelImage = [UIImage imageNamed: @"wheel-small.png"];
 		CGRect screenBounds = [[UIScreen mainScreen] bounds];
 		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -(((wheelImage.size.height) - screenBounds.size.height)/2), wheelImage.size.width, wheelImage.size.height)];
 		self.imageView.image = wheelImage;
 		self.imageView.userInteractionEnabled = YES;
 	  [self addSubview: self.imageView];
    [self setBackgroundColor:[UIColor blackColor]];
    
    //AVCaptureSession *session = [[AVCaptureSession alloc] init];
    //AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: session];
    //CALayer *viewLayer = <#Get a layer from the view in which you want to present the preview#>;
		//[viewLayer addSublayer:captureVideoPreviewLayer];
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

	self.cameraLayer = [CALayer layer];
	self.cameraLayer.frame = [[UIScreen mainScreen] bounds];
	self.cameraLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0f, 0, 0, 1);
	self.cameraLayer.contentsGravity = kCAGravityResizeAspectFill;
	[self.layer addSublayer:self.cameraLayer];

	[self.captureSession startRunning];
  
 	dispatch_release(queue);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{ 
	/*We create an autorelease pool because as we are not in the main_queue our code is
	 not executed in the main thread. So we have to create an autorelease pool for the thread we are in*/
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0); 
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer);  
    
    /*Create a CGImageRef from the CVImageBufferRef*/
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
	
    /*We release some components*/
    CGContextRelease(newContext); 
    CGColorSpaceRelease(colorSpace);
    
    /*We display the result on the custom layer. All the display stuff must be done in the main thread because
	 UIKit is no thread safe, and as we are not in the main thread (remember we didn't use the main_queue)
	 we use performSelectorOnMainThread to call our CALayer and tell it to display the CGImage.*/
	[self.cameraLayer performSelectorOnMainThread:@selector(setContents:) withObject: (id) newImage waitUntilDone:YES];
	
	/*We display the result on the image view (We need to change the orientation of the image so that the video is displayed correctly).
	 Same thing as for the CALayer we are not in the main thread so ...*/
	UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
	
	/*We relase the CGImageRef*/
	CGImageRelease(newImage);
	
	[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
	
	/*We unlock the  image buffer*/
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	[pool drain];
} 

@end
