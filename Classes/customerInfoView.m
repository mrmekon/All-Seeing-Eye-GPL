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

@interface customerInfoView (PrivateMethods)
- (void)displayInvalidScanNotification;
- (void)scanTimerCallback: (NSTimer*)timer;
- (void)scheduleScanTimeout;
@end

@interface customerInfoView () 
/**
 * Holds text representing user from most recent barcode scan
 */
@property (nonatomic, retain) NSMutableDictionary *currentScan;
/**
 * Timer for clearing screen after a scan is expired.
 */
@property (nonatomic, retain) NSTimer *scanTimer;
@end

@implementation customerInfoView

@synthesize currentScan;
@synthesize scanTimer;

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
    self.currentScan = [NSMutableDictionary dictionaryWithCapacity: 10];
    [self.currentScan setObject:@"No Scan" forKey:@"name"];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: @"Redeem Customer's Credit" forState:UIControlStateNormal];
    CGPoint buttonPoint =  CGPointMake(
      self.frame.size.width / 2, 
      self.frame.size.height - 110);
    button.frame = CGRectMake(0,0,600,60);
    [button setCenter: buttonPoint];
    [button addTarget: self action: @selector(redeemCredit) 
      forControlEvents: UIControlEventTouchDown];
    [self addSubview:button];
	}
  return self;
}

-(void)redeemCredit {
  NSLog(@"Redeemed!");
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  NSString *barcode = [self.currentScan objectForKey:@"barcode"];
  NSString *dbFile = delegate.dbManager.databasePath;
  if (!barcode || !dbFile) return;
  [delegate.customer clearCreditFromDb: dbFile withBarcode: barcode];
  
  NSNumber *tmp = [NSString stringWithFormat: @"%d", [delegate.customer 
    creditFromDb: dbFile withBarcode: barcode]];
  if (tmp)
    [self.currentScan setObject:tmp  forKey:@"credit"];
  
  [self performSelectorOnMainThread: @selector(redrawScreen)
        withObject: nil
        waitUntilDone: NO];
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

  NSString *name = [delegate.customer customerFromDb: dbFile 
                                      withBarcode: barcode];
  if (name)
    [self.currentScan setObject:name forKey:@"name"];

  if (!name || [name length] == 0) {
    [self.currentScan removeAllObjects];
  	[self displayInvalidScanNotification];
  }
  else {
    NSNumber *tmp = nil;
    [self.currentScan setObject:barcode forKey:@"barcode"];
    
    tmp = [NSString stringWithFormat: @"%d", [delegate.customer 
      levelFromDb: dbFile withBarcode: barcode]];
    if (tmp)
      [self.currentScan setObject:tmp  forKey:@"level"];
      
    tmp = [NSString stringWithFormat: @"%d", [delegate.customer 
      discountFromDb: dbFile withBarcode: barcode]];
    if (tmp)
      [self.currentScan setObject:tmp  forKey:@"discount"];
      
    tmp = [NSString stringWithFormat: @"%d", [delegate.customer 
      creditFromDb: dbFile withBarcode: barcode]];
    if (tmp)
      [self.currentScan setObject:tmp  forKey:@"credit"];
      
    tmp = [NSString stringWithFormat: @"%d", [delegate.customer 
      referralCountFromDb:dbFile withBarcode:barcode]];
    if (tmp)
      [self.currentScan setObject:tmp  forKey:@"referrals"];
  }
  
  // Check if customer is due for a level upgrade
  [delegate.customer updateLevelOfReferrerWithBarcode:barcode withDb: dbFile];
   
  // Schedule scan info to timeout eventually
  [self scheduleScanTimeout];

  // Draw customer's info on the screen
  [self performSelectorOnMainThread: @selector(redrawScreen)
        withObject: nil
        waitUntilDone: NO];
}

/**
 * \brief Schedule timer to expire a scan after 5 minutes
 *
 * Starts a timer on the main run loop that expires after 5 minutes, and
 * calls a callback to erase the information from the screen.
 * 
 */
- (void)scheduleScanTimeout {
	// Invalidate timer if it already exists
  if (self.scanTimer) {
  	[self.scanTimer invalidate];
    self.scanTimer = nil;
  }
  
  // Create a timer with a 5 minute timeout
  self.scanTimer = [NSTimer 
    timerWithTimeInterval:300.0
    target:self
    selector:@selector(scanTimerCallback:)
    userInfo:nil 
    repeats:NO];
    
  // Schedule timer on the main loop
  NSRunLoop *mainloop = [NSRunLoop mainRunLoop];
  [mainloop addTimer:self.scanTimer forMode:NSDefaultRunLoopMode];
}

/**
 * \brief Replace screen contents with "No scan"
 *
 * Intended to be called as a callback by the scan timer when it expires,
 * this function clears the information on the screen and replaced it with
 * the text "No scan".  This function causes the screen to be redrawn.
 * 
 * \param timer Unused.
 *
 */
- (void)scanTimerCallback: (NSTimer*)timer {
  // Replace all on-screen info with "No scan" and remove timer
  [self.currentScan removeAllObjects];
  [self.currentScan setObject:@"No Scan" forKey:@"name"];
  [self performSelectorOnMainThread: @selector(redrawScreen)
        withObject: nil
        waitUntilDone: NO];
  self.scanTimer = nil;
}

/**
 * \brief Set scan name to something invalid
 *
 * Called when user has scanned a barcode that is not in the database, this
 * function replaces the name text with "No account found!".  It does not
 * cause the screen to be redrawn.
 *
 */
- (void)displayInvalidScanNotification {
	[self.currentScan setObject:@"No account found!" forKey:@"name"];
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
  [self drawCenteredText: [self.currentScan objectForKey:@"name"] y: 30];
  
  NSString *barcode = [self.currentScan objectForKey:@"barcode"];
  if (barcode) {
    NSString *temp = [[@"Barcode:" stringByPaddingToLength: 15 
                                   withString:@" " 
                                   startingAtIndex: 0] 
                      stringByAppendingString: barcode];
    [self drawLeftJustifiedText: temp y: 150];
  }
  
  NSString *level = [self.currentScan objectForKey:@"level"];
  if (level) {
    NSString *temp = [[@"Level:" stringByPaddingToLength: 15 
                                 withString:@" " 
                                 startingAtIndex: 0] 
                      stringByAppendingString: level];
    [self drawLeftJustifiedText: temp y: 200];
  }
  
  NSString *discount = [self.currentScan objectForKey:@"discount"];
  if (level) {
    NSString *temp = [[[@"Discount:" stringByPaddingToLength: 15 
                                 withString:@" " 
                                 startingAtIndex: 0] 
                      stringByAppendingString: discount]
                      stringByAppendingString: @"%"];
    [self drawLeftJustifiedText: temp y: 250];
  }
  
  NSString *credit = [self.currentScan objectForKey:@"credit"];
  if (credit) {
    NSString *temp = [[[@"Credit:" stringByPaddingToLength: 15 
                                 withString:@" " 
                                 startingAtIndex: 0] 
                      stringByAppendingString: @"$"]
                      stringByAppendingString: credit];
    [self drawLeftJustifiedText: temp y: 300];
  }

  NSString *count = [self.currentScan objectForKey:@"referrals"];
  if (count) {
    NSString *temp = [[@"Referrals:" stringByPaddingToLength: 15 
                                 withString:@" " 
                                 startingAtIndex: 0] 
                      stringByAppendingString: count];
    [self drawLeftJustifiedText: temp y: 400];
  }

}

- (NSString*)labelKey:(NSString*)key withLabel:(NSString*)label {
  NSString *val = [self.currentScan objectForKey:key];
  NSString *temp = nil;
  if (val) {
    temp = [[label stringByPaddingToLength: 15 
                                 withString:@" " 
                                 startingAtIndex: 0] 
                      stringByAppendingString: val];
  }
  return temp;
}

/**
 * \brief Draw centered text at the given y-coordinate
 *
 * \param str Text to draw on screen
 * \param y y coordinate to draw text
 *
 */
-(void) drawCenteredText: (NSString*)str y: (int)y {
  UIImage *img = [self imageFromText: str withMaxFontSize: 55.0];
  [self drawCenteredImage: img y: y];
}

/**
 * \brief Draw left-justified text at the given y-coordinate
 *
 * \param str Text to draw on screen
 * \param y y coordinate to draw text
 *
 */
-(void) drawLeftJustifiedText: (NSString*)str y: (int)y {
  UIImage *img = [self imageFromText: str withMaxFontSize: 40.0];
  [self drawLeftJustifiedImage: img y: y];
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
 * \brief Draws an image on the view, left-justified, at given y-coordinate.
 *
 * \param img Image to draw in view
 * \param y y coordinate to draw image
 *
 */
-(void) drawLeftJustifiedImage:(UIImage*)img y: (int)y {
  int x_offset = 20;
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
-(UIImage *)imageFromText:(NSString *)text withMaxFontSize: (float)maxFont
{
	/* Set font and calculate size */
  CGSize screenSize = [[UIScreen mainScreen] bounds].size;
  
  /* Set min/max font sizes */
  float desiredFontSize = maxFont;
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
  NSLog(@"Desired size: %f", desiredFontSize);
	/* Draw text into image context */
  [text drawAtPoint: CGPointMake(0.0, 0.0) 
        forWidth: (screenSize.width * 0.80)
        withFont: font
        minFontSize: minimumFontSize
        actualFontSize: &desiredFontSize
        lineBreakMode: UILineBreakModeTailTruncation
        baselineAdjustment: UIBaselineAdjustmentAlignBaselines];
	NSLog(@"Actual size: %f", desiredFontSize);
  /* Produce image from context */
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

  UIGraphicsEndImageContext();    

  return image;
}


@end
