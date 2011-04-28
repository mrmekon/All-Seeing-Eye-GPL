//
//  CustomerInfoView.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface customerInfoView : UIView {
	NSString *name;
}

@property (nonatomic, retain) NSString *name;

-(id)initWithFrame:(CGRect)aRect;
- (void)newScanHandler:(NSNotification *)notif;
- (void)redrawScreen;
- (void)drawRect:(CGRect)rect;
-(void) drawCenteredText: (NSString*)str y: (int)y;
-(void) drawCenteredImage:(UIImage*)img y: (int)y;
-(UIImage *)imageFromText:(NSString *)text;

@end
