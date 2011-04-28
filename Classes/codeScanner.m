//
//  codeScanner.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/27/11.
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
