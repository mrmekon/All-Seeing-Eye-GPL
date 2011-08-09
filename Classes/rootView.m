//
//  rootView.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/26/11.
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
 * \brief Main view during normal use, divides screen into two subviews.
 *
 * This view is displayed full-screen during normal (non-administrative)
 * operation, and divides itself into two subviews.  The top subview, 1/4th
 * of the screen, is given to a cameraView.  The bottom 3/4ths of the screen
 * is given to a customerInfoView.
 *
 * This view also handles the user input that launches the administration
 * UI as a modal view.
 *
 */

#import "rootView.h"

@implementation rootView

@synthesize disabledOverlayView;

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
    
    [self disableView];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self 
            selector: @selector(causePulseInMainThread) 
            name:@"ASE_BarcodeScanned" 
            object: nil];
            
    // Handle a 2-finger swipe to the right
    UISwipeGestureRecognizer  *rightSwipe = [[UISwipeGestureRecognizer alloc]
			initWithTarget:self action:@selector(handleRightSwipe:)];
    rightSwipe.numberOfTouchesRequired = 2;
    [self addGestureRecognizer: rightSwipe];
    [rightSwipe release];
	}
  return self;
}

-(void)disableView {
  if (self.disabledOverlayView) return; // already disabled
  
  self.disabledOverlayView = [[[UIView alloc] initWithFrame: 
    [[UIScreen mainScreen] bounds]] autorelease];
  [self.disabledOverlayView setBackgroundColor:[UIColor redColor]];
  [self.disabledOverlayView setAlpha:0.25];
  [self setUserInteractionEnabled:NO];
  [self addSubview: self.disabledOverlayView];
}

-(void)enableView {
  [self setUserInteractionEnabled:YES];
  [self.disabledOverlayView removeFromSuperview];
  self.disabledOverlayView = nil;
}


- (void)handleRightSwipe:(UIGestureRecognizer *)sender {
	//CGPoint pt = [sender locationInView: self];
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center postNotificationName: @"ASE_AdminRequested"
          object: self
          userInfo: nil];
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
