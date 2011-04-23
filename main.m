//
//  main.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/22/11.
//  Copyright 2011 trevorbentley. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
    int retVal = UIApplicationMain(argc, argv, @"UIApplication", @"mainAppDelegate");
    [pool release];
    return retVal;
}
