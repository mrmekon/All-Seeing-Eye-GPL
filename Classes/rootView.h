//
//  rootView.h
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
///\file

#import <Foundation/Foundation.h>
#import "cameraView.h"
#import "customerInfoView.h"

/// What portion of screen is dedicated to camera frame (1/N of screen)
#define CAMERA_FRAME_DIVIDER  4
/// What portion of screen is dedicated to customer info (1/N of screen)
#define CUSTOMER_FRAME_DIVIDER 1.333


@interface rootView : UIView {
  @private
    UIView *disabledOverlayView;
}

@property(nonatomic, retain) UIView *disabledOverlayView;

-(id)initWithFrame:(CGRect)aRect;
- (void)dealloc;
-(void)causePulseInMainThread;
-(void)pulseOverlay;
-(void)enableView;

@end
