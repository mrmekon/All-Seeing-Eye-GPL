//
//  codeScanner.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/27/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

/**
 * \brief Handles scanning images for barcodes
 *
 * This class keeps an instance of the ZBar barcode scanner.  It receives
 * images from the cameraView and scans them for barcodes.  If a barcode is
 * detected, the decoded result is stored in an instance variable for decoding.
 *
 */
 
 
#import "codeScanner.h"

@implementation codeScanner

@synthesize scanner;
@synthesize lastCode;

- (id) init {
	if (self = [super init]) {
  	self.scanner = [[ZBarImageScanner alloc] init];
  }
  return self;
}

- (BOOL) scanImage: (CGImageRef) img {
	ZBarImage *zimg = [[[ZBarImage  alloc] initWithCGImage: img] autorelease];
  NSInteger result = [self.scanner scanImage: zimg];    
  if (!result) return FALSE;
  
  ZBarSymbolSet *symbols = zimg.symbols;
  for(ZBarSymbol *symbol in symbols) {
  	NSLog(@"Symbol type: %@", symbol.typeName);
    NSLog(@"Symbol data: %@", symbol.data);
    self.lastCode = [NSString stringWithString: symbol.data];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName: @"ASE_BarcodeScanned"
            object: self
            userInfo: nil];
	}
  
  return TRUE;
}

@end
