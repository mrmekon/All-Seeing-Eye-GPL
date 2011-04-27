//
//  CustomerInfoView.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface customerInfoView : UIView {

}

-(id)initWithFrame:(CGRect)aRect;
- (void)drawRect:(CGRect)rect;
-(UIImage *)imageFromText:(NSString *)text;

@end
