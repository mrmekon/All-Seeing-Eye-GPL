//
//  CustomerInfoView.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
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

@synthesize currentUser;

/**
 * \brief Initialize view to given size
 *
 * Creates view with given bounds.  Background color set to dark gray, and
 * registers for ASE_BarcodeScanned notification events.  Sets default
 * text values to display.
 *
 * \param aRect Size of view
 * \return Initialized instance of view
 *
 */
-(id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame: aRect]) {
    [self setBackgroundColor:[UIColor darkGrayColor]];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self 
            selector: @selector(newScanHandler:) 
            name:@"ASE_BarcodeScanned" 
            object: nil];
    self.currentUser = [NSMutableDictionary dictionaryWithCapacity: 10];
	}
  return self;
}

/**
 * \brief Deallocate resources
 *
 * Removes itself from notification center.
 *
 */
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  [super dealloc];
}

/**
 * \brief Handles new successful scan events
 *
 * Called when a barcode is successfully scanned (by notification system),
 * this just sets redrawScreen to be called on the main thread.
 * 
 * \param notif Notification that caused this to run
 *
 */
- (void)newScanHandler:(NSNotification *)notif {
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  NSString *barcode = delegate.scanner.lastCode;
  NSString *dbFile = delegate.dbManager.databasePath;
  
  NSString *name = [delegate.customer customerFromDb: dbFile withBarcode: barcode];
  if (name == nil)
  	name = [NSString stringWithString: barcode];
  [self.currentUser setObject: name forKey: @"name"];

  int level = [delegate.customer levelFromDb: dbFile withBarcode: barcode];
  if (level >= 0) {
  	NSString *lvl = [NSString stringWithFormat: @"Level %d",level];
	  [self.currentUser setObject: lvl forKey: @"level"];
  }

  
  [self performSelectorOnMainThread: @selector(redrawScreen)
        withObject: nil
        waitUntilDone: NO];
}

/**
 * \brief Tells view to redraw itself.
 */
- (void)redrawScreen {
  [self setNeedsDisplay];
}

/**
 * \brief Called when view needs to be redrawn
 *
 * Main GUI thread calls this when view needs to be redrawn.  This controls
 * what text is displayed in the view, and where.  Should be called each time
 * a new barcode is successfully scanned.  That happens automatically via the
 * notification system.
 *
 * \param rect Region to redraw.  Ignored, always full view.
 *
 */
- (void)drawRect:(CGRect)rect {
  [self drawCenteredText: [self.currentUser objectForKey: @"name"] y: 30];
  [self drawCenteredText: [self.currentUser objectForKey: @"level"] y: 80];
}

/**
 * \brief Draw centered text at the given y-coordinate
 *
 * \param str Text to draw on screen
 * \param y y coordinate to draw text
 *
 */
-(void) drawCenteredText: (NSString*)str y: (int)y {
	if (!str) return; // can't draw null.
  UIImage *img = [self imageFromText: str];
  [self drawCenteredImage: img y: y];
}

/**
 * \brief Draws an image on the view, centered on screen, at given y-coordinate.
 *
 * \param img Image to draw in view
 * \param y y coordinate to draw image
 *
 */
-(void) drawCenteredImage:(UIImage*)img y: (int)y {
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
  int x_offset = (screenSize.width - img.size.width)/2;
  CGRect r = CGRectMake(x_offset, y, img.size.width, img.size.height);
	[img drawInRect: r];
}

/**
 * \brief Creates an image containing the given text
 *
 * Given a string, this creates an image containing the text with a glowing
 * shadow, ready to be drawn on the view.  Draws with a large font, but
 * automatically shrinks font to text will fit on the screen, down to a small
 * size that is still readable on iPhone and iPad.  If the text won't fit
 * with the minimum font size, it is truncated with ellipses.
 *
 * \param text String to convert to image
 * \return Image containing formatted text
 *
 */
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
