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
  [self drawText: self.name x: 30 y: 30];
}

-(void) drawText: (NSString*)str x: (int)x y: (int)y {
  UIImage *img = [self imageFromText: str];
  [self drawImage: img x: x y: y];
}

-(void) drawImage:(UIImage*)img x: (int)x y: (int)y {
  CGRect r = CGRectMake(x, y, img.size.width, img.size.height);
	[img drawInRect: r];
}

-(UIImage *)imageFromText:(NSString *)text
{
	/* Set font and size */
  //[UIFont fontWithName: @"Courier-Bold" size: 40]
  UIFont *font = [UIFont systemFontOfSize:50.0];  
  CGSize size  = [text sizeWithFont:font];

  UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
  
  /* Add drop-shadow */
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);

	/* Draw text into image context */
  [text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
	
  /* Produce image from context */
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();    

  return image;
}


@end
