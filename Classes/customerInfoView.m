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
#import "mainAppDelegate.h"

@implementation customerInfoView

@synthesize name;

-(id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame: aRect]) {
    [self setBackgroundColor:[UIColor darkGrayColor]];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self 
            selector: @selector(newScanHandler:) 
            name:@"ASE_BarcodeScanned" 
            object: nil];
    self.name = @"Peterman Von Helsingnator";
	}
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  [super dealloc];
}

- (void)newScanHandler:(NSNotification *)notif {
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  self.name = [NSString stringWithString: delegate.scanner.lastCode];
  [self performSelectorOnMainThread: @selector(redrawScreen)
        withObject: nil
        waitUntilDone: NO];
}

- (void)redrawScreen {
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  [self drawCenteredText: self.name y: 30];
}

-(void) drawCenteredText: (NSString*)str y: (int)y {
  UIImage *img = [self imageFromText: str];
  [self drawCenteredImage: img y: y];
}

-(void) drawCenteredImage:(UIImage*)img y: (int)y {
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
  int x_offset = (screenSize.width - img.size.width)/2;
  CGRect r = CGRectMake(x_offset, y, img.size.width, img.size.height);
	[img drawInRect: r];
}

-(UIImage *)imageFromText:(NSString *)text
{
	/* Set font and calculate size */
  CGSize screenSize = [[UIScreen mainScreen] bounds].size;
  
  /* Set min/max font sizes */
  float desiredFontSize = 50.0;
  float minimumFontSize = 10.0;
  
  //UIFont *font = [UIFont systemFontOfSize: desiredFontSize];  
  UIFont *font = [UIFont fontWithName: @"Courier-Bold" size: desiredFontSize];

	/* Determine size of text when drawn */
  CGSize size = [text sizeWithFont: font
                      minFontSize: minimumFontSize
                      actualFontSize: &desiredFontSize
                      forWidth: (screenSize.width * 0.80)
                      lineBreakMode: UILineBreakModeTailTruncation];

	/* Create drawing context with calculated size */
  UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
  
  /* Turn on drop-shadow */
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSetShadowWithColor(ctx, 
                              CGSizeMake(0.0, 0.0), // (x,y) offset
                              6.0, // blur amount
                              [[UIColor whiteColor] CGColor]);

	/* Draw text into image context */
  [text drawAtPoint: CGPointMake(0.0, 0.0) 
        forWidth: (screenSize.width * 0.80)
        withFont: font
        minFontSize: minimumFontSize
        actualFontSize: &desiredFontSize
        lineBreakMode: UILineBreakModeTailTruncation
        baselineAdjustment: UIBaselineAdjustmentAlignBaselines];
	
  /* Produce image from context */
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();    

  return image;
}


@end
