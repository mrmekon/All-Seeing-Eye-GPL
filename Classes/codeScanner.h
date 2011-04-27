//
//  codeScanner.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/27/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//
///\file

#import <Foundation/Foundation.h>
#import "ZBarSDK.h"


@interface codeScanner : NSObject {
	ZBarImageScanner *scanner;
  NSString *lastCode;
}

/// ZBar barcode scanner instance
@property (nonatomic, retain) ZBarImageScanner *scanner;
/// String of the last barcode scan result.
@property (nonatomic, retain) NSString *lastCode;

- (BOOL) scanImage: (CGImageRef) img;
-(void) logSomething;

@end
