//
//  All_Seeing_EyeAppDelegate.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/22/11.
//  Copyright 2011 trevorbentley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainViewController.h"
#import "codeScanner.h"

@interface mainAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    mainViewController *viewController;
    codeScanner *scanner;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet mainViewController *viewController;
@property (nonatomic, retain) codeScanner *scanner;

@end

