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

/**
 * \brief Initialize dropbox connection manager.
 *
 * Configured event handlers for dropbox handler, and sets default values.
 *
 * \return Initialized object
 */
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

/**
 * \brief Called after valid connection to Dropbox
 *
 * Fetches database from Dropbox, and prompts user for whether app should be
 * read-only or read/write.
 */
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

/**
 * \brief Call to connect to Dropbox service
 *
 * Creates Dropbox session.  Gives Dropbox login screen if no credentials are
 * stored.  If credentials are stored locally, prompts user for whether he
 * wants to use them.
 *
 * \return Yes if link has been established.
 */
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

/**
 * \brief Handles response to any Dropbox-related prompts
 *
 * Dispatches events and sets status based on user's response to all
 * dropbox-related prompts:
 * - Use Saved Credentials
 * - Allow editing
 * - Take over lock
 *
 * \param alertView Popup that caused this event
 * \param buttonIndex Button pressed on the popup
 */
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

/**
 * \brief Deletes stored credentials
 */
-(void)clearDropboxCredentials {
	[[DBSession sharedSession] unlink];
}

/**
 * \brief Save dropbox credentials to local storage
 * \return Yes on success, no if no credentials available
 */
-(BOOL)saveDropboxCredentials {
  NSString *token = [DBSession sharedSession].credentialStore.accessToken;
  NSString *secret = [DBSession sharedSession].credentialStore.accessTokenSecret;
  if (!token || !secret) return NO;
  [[DBSession sharedSession] 
    updateAccessToken:token
    accessTokenSecret:secret];
  return YES;
}

/**
 * \brief Initializes Dropbox RESTful client
 * \return Dropbox RESTful client instance, or nil on error.
 */
-(DBRestClient*) initRestClient {
  if (!self.restClient) {
    self.restClient = 
      [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
  }
  return self.restClient;
}

/**
 * \brief Display the Dropbox login window
 */
-(void) openDropboxLoginWindow {
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  DBLoginController* controller = [[DBLoginController new] autorelease];
  controller.delegate = self;
	[controller presentFromController:delegate.navController];
}

/**
 * \brief Request database file be downloaded from Dropbox
 *
 * This is asynchronous.  The download is not finished when this returns.
 */
-(void) readDatabaseFromDropbox {
  [[self restClient] loadMetadata:@"/all-seeing-eye/database.sql"];
}

/**
 * \brief Request that Database be written to Dropbox
 * This is asynchronous.  Returns before database is uploaded.
 *
 * \param localPath Local file to upload
 */
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

/**
 * \brief Request lock and write database to Dropbox (blocking)
 *
 * This is a BLOCKING call to get the lock, upload the database, and unlock.
 *
 * \param localPath Path to local file to upload
 */
-(void)getLockAndWriteDatabase:(NSString*)localPath {
  if (!self.hasLockPermission) return;
  [NSThread detachNewThreadSelector:@selector(writeDatabaseThread:) 
    toTarget:self withObject:localPath];
}

/**
 * \brief Thread spawned by getLockAndWriteDatabase:
 *
 * Lock, upload, and unlock.  Polls for completion, gives up if it takes too
 * long.
 *
 * \param localPath Path to local file to upload
 */
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

/**
 * \brief Attempts to create folder on Dropbox to obtain write lock
 * Asynchronous, returns before lock obtained.
 * \return No on error, yes if request scheduled.
 */
-(BOOL)tryToObtainDropboxLock {
  if (!self.hasLockPermission) return NO;
  NSString *folder = [@"/all-seeing-eye/" stringByAppendingString:g_lockfile];
  [[self restClient] createFolder:folder];  
  return YES;
}

/**
 * \brief Attempts to delete folder on Dropbox to release write lock
 * Asynchronous, returns before lock released.
 */
-(void)releaseDropboxLock {
  if (!self.hasLockPermission) return;
  NSString *folder = [@"/all-seeing-eye/" stringByAppendingString:g_lockfile];
  [[self restClient] deletePath:folder];
}

#pragma mark Dropbox callbacks

/**
 * \brief Callback - login failed
 *
 * Login failed, so re-launch login window.
 *
 * \param session Session that failed
 */
- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session {
  [self openDropboxLoginWindow];
}

/**
 * \brief Callback - login succeeded
 *
 * Save credentials and perform login initialization.
 *
 * \param controller Dropbox controller that logged in.
 */
- (void)loginControllerDidLogin:(DBLoginController*)controller {
  if (![[DBSession sharedSession] isLinked]) {
  	NSLog(@"Warning! Link not established");
    return;
  }
  [self saveDropboxCredentials];
  [self initialSetupAfterConnection];
}

/**
 * \brief Callback - login cancelled
 *
 * Not handled.  Have to restart app.
 *
 * \param controller Dropbox controller
 */
- (void)loginControllerDidCancel:(DBLoginController*)controller {  
}

/**
 * \brief Callback - Loaded directory info from Dropbox
 *
 * Called when directory info is available.  Launch full download of file.
 *
 * \param client RESTful client that requested download
 * \param metadata Info on file
 */
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

/**
 * \brief Callback - unused
 * \param client unused
 * \param path unused
 */
- (void)restClient:(DBRestClient*)client 
  metadataUnchangedAtPath:(NSString*)path {
}

/**
 * \brief Calback - Directory info request failed
 * If directory does not exist, create it.
 * \param client Client that caused request
 * \param error Error that occurred
 */
- (void)restClient:(DBRestClient*)client 
  loadMetadataFailedWithError:(NSError*)error {

  NSLog(@"Error loading metadata: %@", error);
  switch ([error code]) {
    case 404:
      [self.restClient createFolder:@"/all-seeing-eye"];
      [self.restClient loadMetadata:@"/all-seeing-eye"];
  }
  
}

/**
 * \brief Callback - Downloaded file
 *
 * Load downloaded database into memory and enable interface. 
 *
 * \param client Dropbox client
 * \param destPath Local path to downloaded file
 */
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath {
  NSLog(@"Loaded database from Dropbox");
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  NSURL *tmpurl = [NSURL fileURLWithPath:destPath];
	[delegate.dbManager reloadWithNewDatabaseFile: tmpurl];

  // For debugging, simulate a successful scan
  //[delegate.scanner simulatorDebug];
  
  // Enable operation after the database is loaded
  [(rootView*)delegate.viewController.view enableView];
}

/**
 * \brief Callback - Download failed
 *
 * Display error.  Can't fix this.
 *
 * \param client Dropbox client
 * \param error Reason for download failure
 */
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
  NSLog(@"Error loading file: %@", error);
  UIAlertView *alert = [[[UIAlertView alloc] 
    initWithTitle: @"DATABASE DOWNLOAD ERROR" 
    message: @"SERIOUS ERROR! DATABASE NOT FOUND! CANNOT RECOVER!"
    delegate: self
    cancelButtonTitle: nil
    otherButtonTitles: @"OH NO!",nil] autorelease];
  [alert show];
}

/**
 * \brief Callback - File uploaded
 *
 * Enable interface.
 *
 * \param client Dropbox client
 * \param destPath Path uploaded to
 * \param srcPath Path uploaded from
 */
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath {
	NSLog(@"Upload complete from %@ to %@", srcPath, destPath);
  self.uploadInProgress = NO;
  
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  [(rootView*)delegate.viewController.view enableView];
}

/**
 * \brief Callback - Upload progress report
 *
 * Unused.
 *
 * \param client Dropbox client
 * \param progress How complete upload is
 */
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress 
  forFile:(NSString*)destPath from:(NSString*)srcPath {
	NSLog(@"Upload progress: %f", progress);
}

- (void)restClient:(DBRestClient*)client 
  loadProgress:(CGFloat)progress 
  forFile:(NSString*)destPath {
  NSLog(@"Download progress: %f", progress);
}

/**
 * \brief Callback - Upload failed
 *
 * Error displayed.  Can't recover.
 *
 * \param client Dropbox client
 * \param error What went wrong.
 */
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	NSLog(@"Upload failed: %@", error);
  UIAlertView *alert = [[[UIAlertView alloc] 
    initWithTitle: @"DATABASE UPLOAD ERROR" 
    message: @"SERIOUS ERROR! DATABASE NOT UPLOADED! CANNOT RECOVER!"
    delegate: self
    cancelButtonTitle: nil
    otherButtonTitles: @"OH NO!",nil] autorelease];
  [alert show];
}

/**
 * \brief Callback - Folder (dropbox lock) created
 *
 * Update global variables to show that we have the lock
 *
 * \param client Dropbox client
 * \param folder Folder that was created
 */
- (void)restClient:(DBRestClient*)client 
  createdFolder:(DBMetadata*)folder {
  NSLog(@"Successfully obtained lock"); 
  self.hasWriteLock = YES; 
}

/**
 * \brief Callback - Folder create failed (failed to get lock)
 *
 * This means the lock might already exist.  Ask if user wants to take over it.
 *
 * \param client Dropbox client
 * \param error Error that happened
 */
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

/**
 * \brief Callback - Folder (lock) deleted
 * \param client Dropbox client
 * \param path Path of folder deleted
 */
- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path {
  NSLog(@"Successfully deleted %@", path);
  self.hasWriteLock = NO;
}

/**
 * \brief Callback - Folder delete failed (can't release lock)
 *
 * Strange error.  We ignore it.
 *
 * \param client Dropbox client
 * \param error Error that happened
 */
- (void)restClient:(DBRestClient*)client 
  deletePathFailedWithError:(NSError*)error {
  NSLog(@"Error deleting path: %@", error);
}


@end
