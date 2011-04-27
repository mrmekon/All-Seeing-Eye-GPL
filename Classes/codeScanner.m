//
//  codeScanner.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/27/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

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
	}
  
  return TRUE;
}

@end
