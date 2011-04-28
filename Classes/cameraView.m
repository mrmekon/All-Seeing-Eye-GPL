//
//  CameraView.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//
//  This file is part of All-Seeing Eye.
// 
//  All-Seeing Eye is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  All-Seeing Eye is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with All-Seeing Eye.  If not, see <http://www.gnu.org/licenses/>.


/**
 * \brief Cropped view of rear camera video stream.
 *
 * This UIView subclass presents a rectangular, live video view from the default
 * camera.  The frames captured from the camera are set as the background image
 * of the view.  
 *
 * This class also implements the delegate of a video capture device, and the method
 * that receieves each video frame passes them off to the  
 *
 * Each frame is cropped to (SCREEN_WIDTH)x(SCREEN_HEIGHT/4), but note that it will
 * happily display outside of its bounds box, so this class should be initialized
 * with the correct size region given to initWithFrame:.
 */

#import "cameraView.h"
#import "mainAppDelegate.h"
#import "codeScanner.h"

@implementation cameraView

@synthesize imageView;
@synthesize captureSession;

/**
 * \brief Initialize view with a rectangle
 *
 * Creates an image with the same size as the given bound rectangle, and sets
 * that image as the only subview of cameraView.  The image will be changed
 * to be the most recent frame from the video when the video is running.
 *
 * <b>NOTE</b>: This class has *only* been tested with the input rectangle: 
 *  <b>(SCREEN_WIDTH, SCREEN_HEIGHT/4)</b>
 *
 * Other sizes may or may not work without code changes.  This does work
 * correctly on both iPad and iPhone, though.
 *
 * \param aRect Bounding rectangle for this view.
 * \return Initialized instance of class
 *
 */
-(id)initWithFrame:(CGRect)aRect {
  if (self = [super initWithFrame: aRect]) {
    // Initialize 
    self.imageView = [[UIImageView alloc] initWithFrame:
        CGRectMake(0.0, 0.0, aRect.size.width,aRect.size.height)];
        
    [self addSubview: self.imageView];
    [self setBackgroundColor:[UIColor blackColor]];
  }
  return self;
}

/**
 * \brief Start video capture for this view.
 *
 * Connects to video input device, sets local delegate method as video output
 * handler, configures frame queue, autofocus, framerate, etc, 
 *
 * \param
 * \return
 */
- (void)initCapture {
  NSError *err;

  /* Video capture format variables */  
  NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
  NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
  NSDictionary* videoSettings = [NSDictionary dictionaryWithObject: value forKey:key]; 

  /* Setup dispatch queue (for video frames waiting to be handled) */
  dispatch_queue_t queue;
  queue = dispatch_queue_create("cameraQueue", NULL);

  /* Enable autofocus (iPhone 4, not iPad) */    
  AVCaptureDevice *videoDevice = 
    [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
  if ([videoDevice isFocusModeSupported: AVCaptureFocusModeContinuousAutoFocus]) {
    [videoDevice lockForConfiguration: &err];
    [videoDevice setFocusMode: AVCaptureFocusModeContinuousAutoFocus];
    [videoDevice unlockForConfiguration];
  }

  /* Get input device (default video device, should be rear camera). */
  AVCaptureDevice *captureDevice = [AVCaptureDevice 
      defaultDeviceWithMediaType: AVMediaTypeVideo];
  AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput 
      deviceInputWithDevice: captureDevice error: nil];
  
  /* Get output device (delegate frames to processing method) */
  AVCaptureVideoDataOutput *captureOutput = 
      [[[AVCaptureVideoDataOutput alloc] init] autorelease];
  
  /* Output device settings.  Set delegate, frame format, framerate. */
  captureOutput.alwaysDiscardsLateVideoFrames = YES; 
  captureOutput.minFrameDuration = CMTimeMake(1, 10); // caps framerate  
  [captureOutput setSampleBufferDelegate:self queue:queue];
  [captureOutput setVideoSettings:videoSettings]; 
  
  /* Create capture session with our input and outputs */
  self.captureSession = [[[AVCaptureSession alloc] init] autorelease];
  [self.captureSession addInput:captureInput];
  [self.captureSession addOutput:captureOutput];

  /* Start session (delegate will now be called with each frame) */
  [self.captureSession startRunning];
  
  /* Cleanup memory */
  dispatch_release(queue);
}

/**
 * \brief Crop a video frame
 *
 * Crop height to 1/4th of screen height.
 *
 * <b>NOTE</b>: Frame is rotated when received from camera, so this function
 * actually sets the "width" to SCREEN_HEIGHT/4, since the width of the
 * unrotated image will become the height of the rotated one.
 *
 * \param img Image to crop (frame from video capture).
 * \return Cropped image
 */
-(CGImageRef) cropImage: (CGImageRef) img {
  CGRect screenSize = [[UIScreen mainScreen] bounds];
  float width = screenSize.size.height / (4 * VIDEO_ENLARGEMENT_FACTOR);
  float height = screenSize.size.width;
  CGRect imgRect = CGRectMake(0,0, width, height);
  return CGImageCreateWithImageInRect(img, imgRect);
}

/**
 * \brief Adds a 'target' overlay to image frame
 *
 * Given a cropped video frame, overlays a translucent 'target' image over it
 * to give the viewer an indication of where the barcode should be.
 *
 * \bug Overlayed image is fixed size, so this only works on iPad.  
 *
 * \param baseImg Cropped image to add overlay to
 * \return New image with overlay
 */
-(UIImage*) addFrameOverlay: (UIImage*) baseImg {
  UIImage *overlayImg = [UIImage imageNamed: @"frameOverlay.png"];
  
  UIGraphicsBeginImageContext(baseImg.size);  
  
  [baseImg drawInRect:CGRectMake(0, 0, 
                                 baseImg.size.width, baseImg.size.height)];  
  [overlayImg drawInRect:CGRectMake(0, 0, overlayImg.size.width, overlayImg.size.height) blendMode: kCGBlendModeNormal alpha: 0.5];  
  
  UIImage *blendedImg = UIGraphicsGetImageFromCurrentImageContext();  
  
  UIGraphicsEndImageContext();  

  return blendedImg;
}

/**
 * \brief Delegate to receive, display, and scan incoming video frames.
 *
 * Called whenever the camera has a new frame captured, this method crops,
 * overlays, rotates, and resizes the frame before displaying it.  It also
 * passes the frame to the global barcode scanner to check if any barcodes
 * are readable.
 *
 * \param captureOutput Output device that generated the frame
 * \param sampleBuffer Raw data returned from the camera
 * \param connection Unused.
 */
-(void) captureOutput:(AVCaptureOutput *)captureOutput 
        didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
        fromConnection:(AVCaptureConnection *)connection 
{ 
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  /* Get image data from the raw sample buffer */
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
  CVPixelBufferLockBaseAddress(imageBuffer,0); 
  uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
  size_t width = CVPixelBufferGetWidth(imageBuffer); 
  size_t height = CVPixelBufferGetHeight(imageBuffer);  
    
  /* Create a core graphics image from data */
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
  CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, 
      bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | 
      kCGImageAlphaPremultipliedFirst);
  CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
    
  /* Crop the image for our view */
  CGImageRef croppedImg = [self cropImage: newImage];
  
  /* Scan the cropped image for barcodes */
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  codeScanner *scanner = delegate.scanner;
  [scanner scanImage: croppedImg];

  /* Convert to Cocoa image, enlarging to fit iPad screen (720px width -> 768px 
  width), and rotating to correct orientation. */
  UIImage *image= [UIImage  imageWithCGImage: croppedImg 
                            scale: (1/VIDEO_ENLARGEMENT_FACTOR) 
                            orientation: UIImageOrientationRight];

  /* Overlay the 'target' over the image */      
  image = [self addFrameOverlay: image];

  /* Set subview to the image, so the screen will update  Do this on the main
  thread since it's a GUI operation. */
  [self.imageView performSelectorOnMainThread: @selector(setImage:) 
                  withObject: image 
                  waitUntilDone: YES];
  
  /* Clean up locks and allocated memory */
	CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
  CGContextRelease(newContext); 
  CGColorSpaceRelease(colorSpace);
  CGImageRelease(newImage);
  CGImageRelease(croppedImg);
  
  [pool drain];
} 

@end
