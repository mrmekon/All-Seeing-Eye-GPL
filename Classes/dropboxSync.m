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
#import "databaseManager.h"

@interface dropboxSync (PrivateMethods) 
-(void)openDropboxLoginWindow;
-(DBRestClient*)initRestClient;
-(void)clearDropboxCredentials;
-(BOOL)saveDropboxCredentials;
-(void)readDatabaseFromDropbox;
-(BOOL)tryToObtainDropboxLock;
@end

NSString *g_lockfile = @"dropbox.lock";

@implementation dropboxSync

@synthesize restClient;

-(id) init {
	if (self = [super init]) {
  }
  return self;
}

-(void)initialSetupAfterConnection {
  [self tryToObtainDropboxLock];
  [self readDatabaseFromDropbox];
}

-(BOOL)openDropboxSession {
  NSString* consumerKey = @"xga20sm7unl1qrj";
	NSString* consumerSecret = @"en3p0qpslf11cnn";

	DBSession* session = [[DBSession alloc] 
    initWithConsumerKey:consumerKey 
    consumerSecret:consumerSecret];
  if (!session) return NO;
  
	session.delegate = self;
	[DBSession setSharedSession:session];
  [session release];
  
  [self initRestClient];
  
  if ([[DBSession sharedSession] savedCredentials] != nil) {
	  UIAlertView *alert = [[[UIAlertView alloc] 
      initWithTitle: @"Dropbox Login" 
      message: @"Use saved Dropbox account?" 
      delegate: self
      cancelButtonTitle: @"no"
      otherButtonTitles: @"YES",nil] autorelease];
  	[alert show];  
  }
  else {
    [self openDropboxLoginWindow];
  }
  
  return [[DBSession sharedSession] isLinked];
}

- (void)alertView:(UIAlertView *)alertView 
  clickedButtonAtIndex:(NSInteger)buttonIndex {
  /* Use saved credentials? */
  switch (buttonIndex) {
  case 0: /* No */
  	[self clearDropboxCredentials];
    [self openDropboxLoginWindow];
    break;
  case 1: /* Yes */
    [self initialSetupAfterConnection];
  	break;
  }
}

-(void)clearDropboxCredentials {
	[[DBSession sharedSession] unlink];
}

-(BOOL)saveDropboxCredentials {
  NSString *token = [DBSession sharedSession].credentialStore.accessToken;
  NSString *secret = [DBSession sharedSession].credentialStore.accessTokenSecret;
  if (!token || !secret) return NO;
  [[DBSession sharedSession] 
    updateAccessToken:token
    accessTokenSecret:secret];
  return YES;
}

-(DBRestClient*) initRestClient {
  if (!self.restClient) {
    self.restClient = 
      [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
  }
  return self.restClient;
}

-(void) openDropboxLoginWindow {
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  DBLoginController* controller = [[DBLoginController new] autorelease];
  controller.delegate = self;
	[controller presentFromController:delegate.navController];
}

-(void) readDatabaseFromDropbox {
  [[self restClient] loadMetadata:@"/all-seeing-eye/database.sql"];
}

-(void) writeDatabaseToDropbox: (NSString*)localPath {
  [[self restClient] uploadFile:@"database.sql" toPath:@"/all-seeing-eye/" 
    fromPath:localPath];
}

-(BOOL)tryToObtainDropboxLock {
  /* Create random large integer */
  long x = (arc4random() % 65536) + 65536;
  
  /* Write integer to file */
  NSString *str = [NSString stringWithFormat:@"%ld",x];
  NSLog(@"Rand int: %@", str);
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(
              NSDocumentDirectory, 
              NSUserDomainMask, YES); 
  NSString* docDir = [paths objectAtIndex:0];
  NSString* file = [docDir stringByAppendingFormat:@"/%@",g_lockfile];
  NSLog(@"Uploading file: %@", file);
  
  if (![str writeToFile:file atomically:NO 
        encoding:NSUTF8StringEncoding error:nil])
    return NO;
  
  /* Upload file to dropbox */
  [[self restClient] uploadFile:g_lockfile toPath:@"/all-seeing-eye/" 
    fromPath:file];
  return YES;
}

-(void)releaseDropboxLock {

}

#pragma mark Dropbox callbacks

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session {
  [self openDropboxLoginWindow];
}

- (void)loginControllerDidLogin:(DBLoginController*)controller {
  if (![[DBSession sharedSession] isLinked]) {
  	NSLog(@"Warning! Link not established");
    return;
  }
  [self saveDropboxCredentials];
  [self initialSetupAfterConnection];
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
  NSLog(@"cancel");
}

- (void)restClient:(DBRestClient*)client 
  loadedMetadata:(DBMetadata*)metadata {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(
              NSDocumentDirectory, 
              NSUserDomainMask, YES); 
  NSString* docDir = [paths objectAtIndex:0];
  NSString* tmppath = [docDir stringByAppendingString:@"/dbtemp.sql"];
  
	NSFileManager *fileManager = [[NSFileManager defaultManager] autorelease];  
  /* If a database is already in user's Documents, delete it. */
	if ([fileManager fileExistsAtPath: tmppath]) {
  	[fileManager removeItemAtPath: tmppath error: nil];
  }  
  [self.restClient loadFile:@"/all-seeing-eye/database.sql" intoPath:tmppath];  
}

- (void)restClient:(DBRestClient*)client 
  metadataUnchangedAtPath:(NSString*)path {

  NSLog(@"Metadata unchanged!");
}

- (void)restClient:(DBRestClient*)client 
  loadMetadataFailedWithError:(NSError*)error {

  NSLog(@"Error loading metadata: %@", error);
  switch ([error code]) {
    case 404:
      [self.restClient createFolder:@"/all-seeing-eye"];
      [self.restClient loadMetadata:@"/all-seeing-eye"];
  }
  
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath {
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  NSURL *tmpurl = [NSURL fileURLWithPath:destPath];
	[delegate.dbManager reloadWithNewDatabaseFile: tmpurl];

}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
  NSLog(@"Error loading file: %@", error);
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath {
	NSLog(@"Upload complete from %@ to %@", srcPath, destPath);
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress 
  forFile:(NSString*)destPath from:(NSString*)srcPath {
	NSLog(@"Upload progress: %f", progress);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	NSLog(@"Upload failed.");
}



@end
