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
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self 
            selector: @selector(causePulseInMainThread) 
            name:@"ASE_BarcodeScanned" 
            object: nil];
	}
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  [super dealloc];
}

/**
 * \brief Call pulseOverlay: on main thread
 *
 * Since pulseOverlay: requires graphics redraws, it must be run on the main
 * thread.  But since it is called by a notification that is not necessarily 
 * running on the main thread, this function gets called by the notification
 * and scheduls pulseOverlay: to be called later on the main thread.
 *
 */
-(void)causePulseInMainThread {
  [self performSelectorOnMainThread: @selector(pulseOverlay) 
        withObject: nil 
        waitUntilDone: YES];
}

/**
 * \brief Briefly flashes screen white
 *
 * Visual indicator when a barcode is successfully scans, overlays the entire
 * screen white that rapidly fades in and out in opacity.  Result is a quick
 * white flash that only semi-obscures the screen, and provides feedback that
 * a scan succeeded.
 *
 */
-(void)pulseOverlay {
	UIView *overlay = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
  [overlay setBackgroundColor: [UIColor whiteColor]];
  overlay.alpha = 0.0;
  [self addSubview: overlay];
  [UIView animateWithDuration: 0.3
    animations:^ {
        overlay.alpha = 0.8;
    }
  ];
  [UIView animateWithDuration: 0.3
    animations:^ {
        overlay.alpha = 0.0;
    }
  ];
}


@end
