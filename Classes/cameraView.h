//
//  CameraView.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 trevorbentley. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface cameraView : UIView {
	UIImageView *imageView;

}
@property (nonatomic, retain) UIImageView *imageView;

-(id)initWithFrame:(CGRect)aRect;

@end
