//
//  MainViewController.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/23/11.
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
 * \brief Main view controller during normal use.
 *
 * This view controller simply initializes a new rootView and sets it as
 * the fullscreen view.
 *
 */
 
#import "mainViewController.h"
#import "rootView.h"
#import "userAdminVC.h"
#import "mainAppDelegate.h"

@implementation mainViewController

@synthesize wheelImage;
@synthesize cameraView;

/**
 * \brief Initialize main application's view controller
 *
 * Creates a full-screen rootView class and sets it as the main VC's view.
 * Also registers for the ASE_AdminRequested notification, so this class can
 * handle creation of modal user administration views.
 *
 * \return Initialized instance of class
 */
-(id) init {
	if (self = [super init]) {
 		CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *root = [[[rootView alloc] initWithFrame: screenBounds] autorelease];
    [self setView: root];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self 
            selector: @selector(requestAdminView) 
            name:@"ASE_AdminRequested" 
            object: nil];
  }
  return self;
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
  [self.navigationController setNavigationBarHidden: YES animated: YES];
}

/**
 * \brief Request to load administration controller on main thread.
 *
 * Register as a notification callback, registers 'displayAdminView' method
 * to be called in main thread's event loop.  This exists so a secondary thread
 * can request the administration view controller be loaded.
 *
 */
-(void)requestAdminView {
  [self performSelectorOnMainThread: @selector(displayAdminView) 
        withObject: nil 
        waitUntilDone: YES];
}

/**
 * \brief Create and display a user administration view
 *
 * Creates a userAdminVC class, which provides the user interface for managing
 * registered users.  Displays the userAdminVC as a modal view.
 *
 */
-(void)displayAdminView {
  NSLog(@"Displaying admin view!");

  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  NSString *dbFile = delegate.dbManager.databasePath;
  userAdminVC *adminController = [[[userAdminVC alloc] 
  	initWithStyle: UITableViewStylePlain
    withDbFile: dbFile] autorelease];
  [[self navigationController] pushViewController:adminController animated:YES];
  //[self presentModalViewController: adminController animated:YES];
}

@end
