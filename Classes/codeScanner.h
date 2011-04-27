//
//  codeScanner.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/27/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBarSDK.h"


@interface codeScanner : NSObject {
	ZBarImageScanner *scanner;
  NSString *lastCode;
}

@property (nonatomic, retain) ZBarImageScanner *scanner;
@property (nonatomic, retain) NSString *lastCode;

- (BOOL) scanImage: (CGImageRef) img;
-(void) logSomething;

@end
