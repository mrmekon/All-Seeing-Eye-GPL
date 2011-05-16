//
//  All_Seeing_EyeAppDelegate.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/22/11.
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
///\file

#import <UIKit/UIKit.h>
#import "mainViewController.h"
#import "codeScanner.h"
#import "databaseManager.h"
#import "customerProtocol.h"

@interface mainAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow *window;
    UINavigationController *navController;
    mainViewController *viewController;
    codeScanner *scanner;
    databaseManager *dbManager;
    id <customerProtocol> customer;
    NSURL *newDatabaseFileUrl;
}

/// Application's main window
@property (nonatomic, retain) IBOutlet UIWindow *window;
/// Navigation controller (UI bar)
@property (nonatomic, retain) UINavigationController *navController;
/// Application's main view controller
@property (nonatomic, retain) IBOutlet mainViewController *viewController;
/// Application's barcode scanning logic
@property (nonatomic, retain) codeScanner *scanner;
/// Application's global database manager
@property (nonatomic, retain) databaseManager *dbManager;
/// Class instance that handles getting customer info from database
@property (nonatomic, retain) id <customerProtocol> customer;
/// URL of new database file from external application
@property (nonatomic, retain) NSURL *newDatabaseFileUrl;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;


@end

