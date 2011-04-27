//
//  MainViewController.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cameraView.h"

@interface mainViewController : UIViewController {
	UIImage *wheelImage;
  cameraView *cameraView;
}

@property (nonatomic, retain) UIImage *wheelImage;
@property (nonatomic, retain) cameraView *cameraView;


@end
