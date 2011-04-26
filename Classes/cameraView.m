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
 		CGRect screenBounds = [self bounds];
 		//self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -(((wheelImage.size.height) - screenBounds.size.height)/2), wheelImage.size.width, wheelImage.size.height)];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0, aRect.size.width,aRect.size.height)];
 		//self.imageView.image = wheelImage;
 		//self.imageView.userInteractionEnabled = YES;
 	  [self addSubview: self.imageView];
    //[self setBackgroundColor:[UIColor blackColor]];
    [self setBackgroundColor:[UIColor whiteColor]];
    
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
  CGRect screenSize = [[UIScreen mainScreen] bounds];
  CGRect rect = [self bounds];
	self.cameraLayer.frame = screenSize;
  //self.cameraLayer.bounds = rect;
  //self.cameraLayer.masksToBounds = YES;
	//self.cameraLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0f, 0, 0, 1);
	self.cameraLayer.contentsGravity = kCAGravityResizeAspectFill;
  
  CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
  const CGFloat myColor[] = {1.0, 0, 0, 1.0};
  CGColorRef c = CGColorCreate(rgb, myColor);
  [self.cameraLayer setBackgroundColor: c];
  CGColorSpaceRelease(rgb);
  
	//[self.layer addSublayer:self.cameraLayer];

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
	
    
	//[self.cameraLayer performSelectorOnMainThread:@selector(setContents:) withObject: (id) newImage waitUntilDone:YES];
	
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
