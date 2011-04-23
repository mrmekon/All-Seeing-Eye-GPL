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

-(id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame: aRect]) {
		UIImage *wheelImage = [UIImage imageNamed: @"wheel-small.png"];
 		CGRect screenBounds = [[UIScreen mainScreen] bounds];
 		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -(((wheelImage.size.height) - screenBounds.size.height)/2), wheelImage.size.width, wheelImage.size.height)];
 		self.imageView.image = wheelImage;
 		self.imageView.userInteractionEnabled = YES;
 	  [self addSubview: self.imageView];
    [self setBackgroundColor:[UIColor blackColor]];
	}
  return self;
}


@end
