//
//  DatabaseManager.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/29/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//
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
//    

/**
 * \brief Handles interaction with sqlite database
 *
 * This class handles all interaction with the local sqlite database.  This
 * includes adding, deleting, and finding records, copying the database to
 * the correct location on the filesystem, and retrieving an updated
 * db from a remote location.
 *
 */
#import "databaseManager.h"

@interface databaseManager (PrivateMethods)
-(NSString*) pathFromFile: (NSString*)file;
-(BOOL) copyDatabaseToDocuments;
-(void)generateLogFileNameAndOpen;
-(void) closeGlobalDB;
@end

@interface databaseManager () 
/// Just filename of database without path
@property (nonatomic, retain) NSString *databaseFile;
/// Handle for access to logFile
@property (nonatomic, retain) NSFileHandle *logFileHandle;
/// Handle for customer database
@property (nonatomic, assign) sqlite3 *globalDB;
@end


@implementation databaseManager

@synthesize databasePath;
@synthesize databaseFile;
@synthesize globalDB;
@synthesize logFile;
@synthesize logFileHandle;
@synthesize logPrefix;

/**
 * \brief Create instance, and create new database file if needed.
 *
 * Given a filename, this initializes a database manager that uses that file
 * in the user's local Documents directory.  If a database does not already
 * exist in that directory, a new db is copied there from the application
 * bundle.
 *
 * \param filename Filename of customer database
 * \return Initialized instance
 *
 */
-(id) initWithFile: (NSString*)filename {
	if (self = [super init] ) {
    self.logPrefix = @"ase_log";
		self.databaseFile = filename;
  	self.databasePath = [self pathFromFile: filename];
    [self copyDatabaseToDocuments]; 
    
    [self generateLogFileNameAndOpen];    
  }
  return self;
}

/**
 * \brief Copy database to user's directory if it does not already exist there. 
 * 
 * \return YES if a copy is performed, NO if it isn't.
 *
 */
-(BOOL) copyDatabaseToDocuments {
  NSError *err = nil;

	/* Determine if file already exists in user's directory */
	NSFileManager *fileManager = [[NSFileManager defaultManager] autorelease];
  BOOL alreadyExists = [fileManager fileExistsAtPath: self.databasePath];  
	if (alreadyExists) {
  	[fileManager removeItemAtPath: self.databasePath error: nil]; // overwrite
  	//return NO; // skip
  }
  
  /* Copy from application bundle to user's dir */
  NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] 
      stringByAppendingPathComponent: self.databaseFile];
  [fileManager  copyItemAtPath: resourcePath 
                toPath: self.databasePath 
                error: &err];
  if (err != nil) {
  	NSLog(@"Copy error: %@", [err localizedDescription]);
    return NO;
  }
  return YES;
}

/**
 * \brief Generate name for log file and open it
 *
 * Log file name: ase_log-[devce UDID]-[epoch time].log
 *
 */
-(void)generateLogFileNameAndOpen {
  BOOL err = YES;
  
  long epoch = (long)([[NSDate date] timeIntervalSince1970]);
	NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                          NSUserDomainMask, 
                                                          YES);
  NSString *docPath = [docPaths objectAtIndex: 0];
  NSString *filename = [NSString stringWithFormat:@"%@-%@-%ld.log",
    self.logPrefix, [UIDevice currentDevice].uniqueIdentifier,epoch];
  self.logFile = [docPath stringByAppendingPathComponent: filename];
  NSLog(@"Logfile: %@", self.logFile);
  
  NSFileManager *fileManager = [[NSFileManager defaultManager] autorelease];
  err = [fileManager createFileAtPath:self.logFile contents:nil attributes:nil];
  self.logFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logFile];
  [self.logFileHandle seekToEndOfFile];
}

/**
 * \brief Write a string to the open log file and flush to disk
 *
 * \param str String to write to log file
 * \return Yes on success, no if log file is not open
 */
-(BOOL)logString:(NSString*)str {
  if (!self.logFileHandle) return NO;
  NSString *logstr = [NSString stringWithFormat:@"%@: %@\n",
    [NSDate date], str];
  [self.logFileHandle writeData:
    [logstr dataUsingEncoding: NSUTF8StringEncoding]];
  NSLog(@"%@",logstr);
  [self.logFileHandle synchronizeFile];
  return YES;
}

/**
 * \brief Copies over existing database with a new database file
 *
 * This copies a new database file, specified in the 'url' argument, over
 * the existing database.  It is an overwrite operation, so the old db
 * is lost forever.
 *
 * This method is expected to be called when an external application, such as
 * an e-mail client, delegates All-Seeing Eye to open a database.
 *
 * \param url Full path to new database file
 * \return Whether overwrite was successful
 *
 */
-(BOOL) reloadWithNewDatabaseFile: (NSURL*)url {
  NSError *err = nil;
  
  [self closeGlobalDB];
	NSFileManager *fileManager = [[NSFileManager defaultManager] autorelease];  
  
  /* If a database is already in user's Documents, delete it. */
  BOOL alreadyExists = [fileManager fileExistsAtPath: self.databasePath];  
	if (alreadyExists) {
  	[fileManager removeItemAtPath: self.databasePath error: nil];
  }  
  
  /* Copy new database to user's Documents */
  //[fileManager copyItemAtPath: url.absoluteString toPath: self.databasePath error: &err];
  [fileManager copyItemAtPath: url.path toPath: self.databasePath error: &err];
  if (err != nil) {
  	NSLog(@"Copy error: %@", [err localizedDescription]);
    return NO;
  }

  return YES;
}

/**
 * \brief Closes global database connection if it's open
 */
-(void) closeGlobalDB {
  if (self.globalDB) {
    sqlite3_close(self.globalDB);
	}
	self.globalDB = nil;
}

/**
 * \brief Generate full path to where database file should be located
 *
 * Generates path to the given filename in the user's Documents directory.
 *
 * \param file Filename to convert to full path
 * \return String with full path to filename in user's directory
 */
-(NSString *)pathFromFile: (NSString*)file {
	NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                          NSUserDomainMask, 
                                                          YES);
  NSString *docPath = [docPaths objectAtIndex: 0];
  NSString *path = [docPath stringByAppendingPathComponent: file];
  return path;
}


-(void) dealloc {
	[self closeGlobalDB];
  if (self.logFileHandle) {
    [self.logFileHandle closeFile];
    self.logFileHandle = nil;
  }
	[databasePath release];
  [databaseFile release];
  [super dealloc];
}


/**
 * \brief Opens a sqlite database file
 * \param file Full path to database file
 * \param db Handle to make reference to open database (output parameter)
 * \return Whether open succeeded
 */
+(BOOL) openDbFile: (NSString*)file usingDbPointer: (sqlite3**) db {
  int result = sqlite3_open([file UTF8String], db);
  if (result != SQLITE_OK) return NO;
  return YES;
}

/**
 * \brief Closes given database connection if it's open
 * \param db Pointer to database handle
 */
+(void) closeDb: (sqlite3**)db {
  if (db && *db) {
    sqlite3_close(*db);
	}
	*db = nil;
}

@end
