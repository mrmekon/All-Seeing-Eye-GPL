//
//  CameraView.h
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


/**
 * Image view filled with video frame and displayed in cameraView.
 */
@property (nonatomic, retain) UIImageView *imageView;

/**
 * Video capture session used to interact with camera.
 */
@property (nonatomic, retain) AVCaptureSession *captureSession;


-(id)initWithFrame:(CGRect)aRect;
- (void)initCapture;
-(CGImageRef) cropImage: (CGImageRef) img;
-(UIImage*) addFrameOverlay: (UIImage*) baseImg;
-(void) captureOutput:(AVCaptureOutput *)captureOutput 
				didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
        fromConnection:(AVCaptureConnection *)connection;

@end
