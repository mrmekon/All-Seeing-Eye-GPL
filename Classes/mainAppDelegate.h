//
//  All_Seeing_EyeAppDelegate.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/22/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//
///\file

#import <UIKit/UIKit.h>
#import "mainViewController.h"
#import "codeScanner.h"

@interface mainAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    mainViewController *viewController;
    codeScanner *scanner;
}

/// Application's main window
@property (nonatomic, retain) IBOutlet UIWindow *window;
/// Application's main view controller
@property (nonatomic, retain) IBOutlet mainViewController *viewController;
/// Application's barcode scanning logic
@property (nonatomic, retain) codeScanner *scanner;

@end

