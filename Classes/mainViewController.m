//
//  MainViewController.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 trevorbentley. All rights reserved.
//

#import "mainViewController.h"
#import "cameraView.h"


@implementation mainViewController

@synthesize wheelImage;
@synthesize cameraView;

-(id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder: aDecoder]) {
 		CGRect screenBounds = [[UIScreen mainScreen] bounds];
  	UIView *subview = [[[cameraView alloc] initWithFrame: screenBounds] autorelease];
  	[self setView: subview];
  }
  return self;
}

-(id) init {
	if (self = [super init]) {
 		CGRect screenBounds = [[UIScreen mainScreen] bounds];
  	cameraView *subview = [[[cameraView alloc] initWithFrame: screenBounds] autorelease];
    [subview initCapture];
  	[self setView: subview];
  }
  return self;
}

@end
