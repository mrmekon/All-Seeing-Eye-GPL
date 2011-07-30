//
//  dropboxSync.h
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
///\file

#import <Foundation/Foundation.h>
#import "DropboxSDK.h"

@interface dropboxSync : NSObject <DBSessionDelegate, DBLoginControllerDelegate, DBRestClientDelegate> {
  DBRestClient *restClient;
  BOOL hasWriteLock;
  BOOL hasLockPermission;
}

@property (nonatomic, retain) DBRestClient *restClient;
@property (nonatomic) BOOL hasWriteLock;
@property (nonatomic) BOOL hasLockPermission;

-(BOOL)openDropboxSession;

-(void)writeDatabaseToDropbox: (NSString*)localPath;
-(BOOL)tryToObtainDropboxLock;
-(void)releaseDropboxLock;

@end
