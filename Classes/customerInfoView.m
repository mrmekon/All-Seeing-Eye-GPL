//
//  CustomerInfoView.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

/**
 * \brief View to display customer information after scanning card.
 *
 * This UIView subclass presents fills all screen real estate not used by
 * the video display.  When a customer's information is retrieved from the
 * database, it is displayed in a large, easily-readable format in this
 * frame.
 *
 * Layout is intentionally minimalistic, and font is large, so information can
 * be parsed quickly by busy employees at a point-of-sale.
 *
 */
 
#import "customerInfoView.h"

@implementation customerInfoView

-(id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame: aRect]) {
		UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"Dummy Person-Name";
    [self addSubview: nameLabel];
    [self setBackgroundColor:[UIColor darkGrayColor]];
	}
  return self;
}

- (void)drawRect:(CGRect)rect {
	CGPoint p = {10, 10};
  [@"some text" drawAtPoint:p withFont: [UIFont fontWithName: @"Courier-Bold" size: 40]];
  
  UIImage *test = [self imageFromText: @"just some dummy text"];
  CGSize  s = test.size;
  CGRect r = CGRectMake(50,50,s.width, s.height);
	[test drawInRect: r];

}


-(UIImage *)imageFromText:(NSString *)text
{
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:50.0];  
    CGSize size  = [text sizeWithFont:font];

    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0 
        UIGraphicsBeginImageContext(size);

    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger 
    //
    // CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);

    // draw in context, you can use also drawInRect:withFont:
    [text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];

    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    

    return image;
}


@end
