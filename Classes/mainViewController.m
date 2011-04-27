//
//  MainViewController.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

/**
 * \brief Main view controller during normal use.
 *
 * This view controller simply initializes a new rootView and sets it as
 * the fullscreen view.
 *
 */
 
#import "mainViewController.h"
#import "rootView.h"

@implementation mainViewController

@synthesize wheelImage;
@synthesize cameraView;


-(id) init {
	if (self = [super init]) {
 		CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *root = [[[rootView alloc] initWithFrame: screenBounds] autorelease];
    [self setView: root];
  }
  return self;
}

@end
