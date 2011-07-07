//
//  dropboxSync.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 7/7/11.
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
 * \brief Handles database synchronization with dropbox API
 *
 * This class handles storing and loading the customer database on a remote
 * dropbox account using the dropbox public API and iOS SDK.  The database
 * is stored this way so multiple iOS devices can share one database and
 * keep synchronized in a convenient manner.
 *
 */

#import "dropboxSync.h"
#import "mainAppDelegate.h"

@implementation dropboxSync

-(BOOL)openDropboxSession {
  NSString* consumerKey = @"xga20sm7unl1qrj";
	NSString* consumerSecret = @"en3p0qpslf11cnn";

	DBSession* session = [[DBSession alloc] 
    initWithConsumerKey:consumerKey 
    consumerSecret:consumerSecret];
  if (!session || ![session isLinked]) return NO;
  
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
  [session release];
  
  return YES;
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session {
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	DBLoginController* loginController = [[DBLoginController new] autorelease];
	[loginController presentFromController:delegate.navController];
}

@end
