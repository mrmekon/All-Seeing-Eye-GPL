//
//  rootView.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/26/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//
///\file

#import <Foundation/Foundation.h>
#import "cameraView.h"
#import "customerInfoView.h"

/// What portion of screen is dedicated to camera frame (1/N of screen)
#define CAMERA_FRAME_DIVIDER  4
/// What portion of screen is dedicated to customer info (1/N of screen)
#define CUSTOMER_FRAME_DIVIDER 1.333


@interface rootView : UIView {

}

-(id)initWithFrame:(CGRect)aRect;
- (void)dealloc;
-(void)causePulseInMainThread;
-(void)pulseOverlay;

@end
