//
//  All_Seeing_EyeAppDelegate.m
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
    

/**
 * \brief Handles application creation and logic flow.
 *
 * Creates a mainViewController, the main interface for the application.  Also
 * stores the application-global class instances.
 *
 */
 
#import "mainAppDelegate.h"

@implementation mainAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize scanner;
@synthesize dbManager;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    self.viewController = [[mainViewController alloc] init];
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
    self.scanner = [[codeScanner alloc] init];
    self.dbManager = [[databaseManager alloc] initWithFile: @"database.sql"];
        
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
}

/**
 * \brief Handles requests for All-Seeing Eye to open a file
 *
 * This method gets called when the application is handed 
 *
 */
- (BOOL)application:(UIApplication*)app 
        openURL:(NSURL*)url
        sourceApplication:(NSString*)srcApp
        annotation:(id)annotation {
      
  NSLog(@"Received file open request from app: %@", srcApp);
  NSLog(@"File URL: %@", url.absoluteString);
  NSArray *urlParts = [url.absoluteString componentsSeparatedByString: @"/"];
  if ([urlParts count] <= 0) return NO;  
  NSString *filename = [urlParts objectAtIndex: [urlParts count]-1];
  NSString *msg = [NSString stringWithFormat: 
      @"Replace user database with downloaded file: %@?\n\n"
      "THIS WILL OVERWRITE ALL EXISTING DATA!!",
      filename];
  UIAlertView *alert = [[UIAlertView alloc] 
      initWithTitle: @"REPLACE DATABASE?" 
      message: msg 
      delegate: nil 
      cancelButtonTitle: @"CANCEL"
      otherButtonTitles: @"OK",nil];
  [alert show];
  
  return [dbManager reloadWithNewDatabaseFile: url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
