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
#import "rootView.h"

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
@synthesize hasWriteLock;
@synthesize hasLockPermission;
@synthesize uploadInProgress;

-(id) init {
	if (self = [super init]) {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self 
            selector: @selector(initialSetupAfterConnection) 
            name:@"ASE_DropboxLoginComplete" 
            object: nil];
    [center addObserver: self 
            selector: @selector(tryToObtainDropboxLock) 
            name:@"ASE_DropboxShouldObtainLock" 
            object: nil];
    [center addObserver: self 
            selector: @selector(failedToObtainDropboxLock) 
            name:@"ASE_DropboxFailedToObtainLock" 
            object: nil];
    self.hasLockPermission = NO;
    self.hasWriteLock = NO;
  }
  return self;
}

-(void)initialSetupAfterConnection {
  UIAlertView *alert = [[[UIAlertView alloc] 
    initWithTitle: @"Allow Customer Editing?" 
    message: @"Only *ONE* device can edit customer information at a time.  "
       "If you want this device to edit customer information, press "
       "'Allow Edits', otherwise press 'Read-only'."
    delegate: self
    cancelButtonTitle: @"Read-only"
    otherButtonTitles: @"Allow Edits",nil] autorelease];
  [alert show];  
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
  if (alertView.title == @"Dropbox Login") {
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
  /* Should be master? */
  else if (alertView.title == @"Allow Customer Editing?") {
    switch (buttonIndex) {
    case 0: /* No */
      self.hasLockPermission = NO;
      break;
    case 1: /* Yes */
      self.hasLockPermission = YES;
      break;
    }
  }
  /* Should take over lock? */
  else if (alertView.title == @"Take Over Lock?") {
    switch (buttonIndex) {
    case 0: /* No */
      self.hasWriteLock = NO;  
      break;
    case 1: /* Yes */
      self.hasWriteLock = YES;  
      break;
    }
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
  if ([self hasWriteLock]) {
    self.uploadInProgress = YES;
    [[self restClient] uploadFile:@"database.sql" toPath:@"/all-seeing-eye/" 
      fromPath:localPath];
  }
  else {
    UIAlertView *alert = [[[UIAlertView alloc] 
      initWithTitle: @"Database NOT saved!" 
      message: @"WARNING!  You do not have the database lock, so the database "
      "is NOT being saved.  Repeat, any modifications to customer information "
      "were NOT SAVED!"
      delegate: self
      cancelButtonTitle: nil
      otherButtonTitles: @"I Understand",nil] autorelease];
    [alert show];
  }
}

-(void)getLockAndWriteDatabase:(NSString*)localPath {
  if (!self.hasLockPermission) return;
  [NSThread detachNewThreadSelector:@selector(writeDatabaseThread:) 
    toTarget:self withObject:localPath];
}

-(void)writeDatabaseThread: (id)localPath {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  BOOL timeout;
  
  [self performSelectorOnMainThread: @selector(tryToObtainDropboxLock) 
        withObject: nil 
        waitUntilDone: NO];
  timeout = YES;
  for (int i = 0; i < 100; i++) {
    if (self.hasWriteLock) {timeout = NO; break;}
    [NSThread sleepForTimeInterval:0.10];
  }
  if (timeout) {
    UIAlertView *alert = [[[UIAlertView alloc] 
      initWithTitle: @"DATABASE ERROR" 
      message: @"Failed to get database lock!  Changes are UNSAVED!"
      delegate: self
      cancelButtonTitle: nil
      otherButtonTitles: @"OK",nil] autorelease];
    [alert show];
    [pool release];
    return;
  }
  
  [self performSelectorOnMainThread: @selector(writeDatabaseToDropbox:) 
        withObject: localPath 
        waitUntilDone: NO];
  timeout = YES;
  for (int i = 0; i < 200; i++) {
    if (!self.uploadInProgress) {timeout = NO; break;}
    [NSThread sleepForTimeInterval:0.10];
  }
  if (timeout) {
    UIAlertView *alert = [[[UIAlertView alloc] 
      initWithTitle: @"DATABASE ERROR" 
      message: @"Failed to save database!  Changes are UNSAVED!"
      delegate: self
      cancelButtonTitle: nil
      otherButtonTitles: @"OK",nil] autorelease];
    [alert show];
    [self releaseDropboxLock];
    [pool release];
    return;
  }

  [self performSelectorOnMainThread: @selector(releaseDropboxLock) 
        withObject: nil 
        waitUntilDone: NO];
  timeout = YES;
  for (int i = 0; i < 100; i++) {
    if (!self.hasWriteLock) {timeout = NO; break;}
    [NSThread sleepForTimeInterval:0.10];
  }
  if (timeout) {
    // meh, who cares?
  }
  
  [pool release];
}


-(BOOL)tryToObtainDropboxLock {
  if (!self.hasLockPermission) return NO;
  NSString *folder = [@"/all-seeing-eye/" stringByAppendingString:g_lockfile];
  [[self restClient] createFolder:folder];  
  return YES;
}

-(void)releaseDropboxLock {
  if (!self.hasLockPermission) return;
  NSString *folder = [@"/all-seeing-eye/" stringByAppendingString:g_lockfile];
  [[self restClient] deletePath:folder];
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

  [delegate.scanner simulatorDebug];
  [(rootView*)delegate.viewController.view enableView];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
  NSLog(@"Error loading file: %@", error);
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath {
	NSLog(@"Upload complete from %@ to %@", srcPath, destPath);
  self.uploadInProgress = NO;
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress 
  forFile:(NSString*)destPath from:(NSString*)srcPath {
	NSLog(@"Upload progress: %f", progress);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	NSLog(@"Upload failed.");
}

- (void)restClient:(DBRestClient*)client 
  createdFolder:(DBMetadata*)folder {
  NSLog(@"Successfully made folder"); 
  self.hasWriteLock = YES; 
}

- (void)restClient:(DBRestClient*)client 
  createFolderFailedWithError:(NSError*)error {
  NSLog(@"Failed to create folder: %@", error);
  UIAlertView *alert = [[[UIAlertView alloc] 
    initWithTitle: @"Take Over Lock?" 
    message: @"Another device has already locked the database.  Only one "
       "device can edit the database at a time.  Do you want this device to "
       "take over the lock?\n\n*WARNING* if two device edit the database at "
       "the same time, customer data can be permanently lost.  Only take over "
       "the lock if you are certain no other device is or will edit the "
       "customer database!"
    delegate: self
    cancelButtonTitle: @"Stay Read-only"
    otherButtonTitles: @"Take Over Lock",nil] autorelease];
  [alert show];
  self.hasWriteLock = NO;
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path {
  NSLog(@"Successfully deleted %@", path);
  self.hasWriteLock = NO;
}

- (void)restClient:(DBRestClient*)client 
  deletePathFailedWithError:(NSError*)error {
  NSLog(@"Error deleting path: %@", error);
}


@end
