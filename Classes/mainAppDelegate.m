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
#import "aitunesCustomer.h"

@implementation mainAppDelegate

@synthesize window;
@synthesize navController;
@synthesize viewController;
@synthesize scanner;
@synthesize dbManager;
@synthesize dropbox;
@synthesize customer;
@synthesize newDatabaseFileUrl;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    self.viewController = [[mainViewController alloc] init];
  	self.navController = [[UINavigationController alloc] 
      initWithRootViewController: self.viewController];
    [self.navController setNavigationBarHidden: NO animated: NO];
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
    self.scanner = [[codeScanner alloc] init];
    self.dbManager = [[databaseManager alloc] initWithFile: @"database.sql"];
    self.customer = [[aitunesCustomer alloc] init];
    self.dropbox = [[dropboxSync alloc] init];
                
    [self.window addSubview:navController.view];
    [self.window makeKeyAndVisible];
    [scanner simulatorDebug];

    [self.dropbox openDropboxSession];
      

    return YES;
}

/**
 * \brief Handles requests for All-Seeing Eye to open a file
 *
 * This method gets called when the application is handed a file from another
 * application.  Presumably, this should only be All-Seeing Eye database files
 * from email, Dropbox, or some other application.
 *
 * \param app Unused
 * \param url Full path to new file as URL
 * \param srcApp Unused
 * \param annotation Unused
 * \return Whether handling succeeded without error
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
  self.newDatabaseFileUrl = url;
  UIAlertView *alert = [[UIAlertView alloc] 
      initWithTitle: @"REPLACE DATABASE?" 
      message: msg 
      delegate: self 
      cancelButtonTitle: @"CANCEL"
      otherButtonTitles: @"OK",nil];
  [alert show];
  
  return YES;
}

/**
 * \brief Delegate for overwrite-database alert popup.
 *
 * If application is given a database file, it prompts user asking if he wants
 * to overwrite the existing database.  This delegate method is called with the
 * user response to that question.
 *
 * If user clicked cancel, nothing should happen.  If user clicked OK, the new
 * database should be copied over the existing one.
 *
 * \param alertView Alert that called this delegate
 * \param buttonIndex Button the user clicked
 *
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"Clicked button at index %d", buttonIndex);
  if (buttonIndex == [alertView cancelButtonIndex]) return;
  
  [dbManager reloadWithNewDatabaseFile: self.newDatabaseFileUrl];
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
