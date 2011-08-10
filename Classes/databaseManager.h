//
//  DatabaseManager.h
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
    
#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface databaseManager : NSObject {
  NSString *databasePath;
  NSString *logFile;
  NSString *logPrefix;
  
  @private
    NSString *databaseFile;
    NSFileHandle *logFileHandle;
    sqlite3 *globalDB;
}

/// Full path and filename of database
@property (nonatomic, retain) NSString *databasePath;
/// Full path and filename of log file
@property (nonatomic, retain) NSString *logFile;
/// String prefix for log files
@property (nonatomic, retain) NSString *logPrefix;

-(id)initWithFile: (NSString*)file;
-(BOOL)reloadWithNewDatabaseFile: (NSURL*)url;
-(BOOL)logString:(NSString*)str;

+(BOOL) openDbFile: (NSString*)file usingDbPointer: (sqlite3**) db;
+(void) closeDb: (sqlite3**)db;

@end
