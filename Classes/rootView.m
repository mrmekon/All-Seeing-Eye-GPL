//
//  rootView.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/26/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

/**
 * \brief Main view during normal use, divides screen into two subviews.
 *
 * This view is displayed full-screen during normal (non-administrative)
 * operation, and divides itself into two subviews.  The top subview, 1/4th
 * of the screen, is given to a cameraView.  The bottom 3/4ths of the screen
 * is given to a customerInfoView.
 *
 */

#import "rootView.h"


@implementation rootView


-(id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame: aRect]) {
 		CGRect cameraBounds = [[UIScreen mainScreen] bounds];
    cameraBounds.size.height /= CAMERA_FRAME_DIVIDER;
  	cameraView *camView = [[[cameraView alloc] initWithFrame: cameraBounds] autorelease];
    [camView initCapture];
  	[self addSubview: camView];
    
 		CGRect customerBounds = [[UIScreen mainScreen] bounds];
    customerBounds.origin.y += cameraBounds.size.height;
    customerBounds.size.height /= CUSTOMER_FRAME_DIVIDER;
  	customerInfoView *customerView = [[[customerInfoView alloc] initWithFrame: customerBounds] autorelease];
  	[self addSubview: customerView];
    [self setBackgroundColor:[UIColor blackColor]];
	}
  return self;
}


@end
