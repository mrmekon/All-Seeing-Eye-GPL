//
//  All_Seeing_EyeAppDelegate.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/22/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

/** @mainpage
 *
 * All-Seeing Eye is an iOS application for restaurant/bar or other service 
 * industry companies to use and manage a Customer Loyalty program.  Membership
 * cards with unique barcodes are distributed to customers, and All-Seeing Eye
 * is used to scan a customer's card at the POS to determine his or her earned
 * benefits.
 *
 * @section User Interface
	*
 * All-Seeing Eye's user interface is split into two frames: a top frame that
 * shows a live feed from the iPad/iPhone rear camera, and a bottom frame that
 * shows customer information retrieved from a database after successfully
 * scanning a barcode with the camera.
 *
 * @section Customer Administration
 *
 * Not designed yet.
 *
 */

 
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


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    self.viewController = [[mainViewController alloc] init];
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; 
    self.scanner = [[codeScanner alloc] init];
        
        
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
    
    return YES;
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
