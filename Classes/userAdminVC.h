//
//  userAdminVC.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 5/15/11.
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

#import <UIKit/UIKit.h>


@interface userAdminVC : UITableViewController <UISearchDisplayDelegate> {
	NSString *dbFile;
  NSArray *allRows;
  NSArray *searchRows;
  UISearchBar *searchBar;
  
	@private
  	BOOL doNotSaveDatabase;
    BOOL searchResultsActive;
    NSString *searchString;
    UISearchDisplayController *searchController;
    UIView *overlay;
    UIView *searchOverlay;
}

/// Full path to database file
@property(nonatomic, retain) NSString *dbFile;
/// Local copy of names/barcodes of all customers in the database
@property(nonatomic, retain) NSArray *allRows;
/// Copy of customers in allRows who match the current search terms
@property(nonatomic, retain) NSArray *searchRows;
/// Search bar UI element
@property(nonatomic, retain) UISearchBar *searchBar;

/// Set to tell controller not to save database when it disappears
@property(nonatomic) BOOL doNotSaveDatabase;
@property(nonatomic) BOOL searchResultsActive;
@property(nonatomic, retain) NSString *searchString;
@property(nonatomic, retain) UISearchDisplayController *searchController;
@property(nonatomic, retain) UIView *overlay;
@property(nonatomic, retain) UIView *searchOverlay;

- (id)initWithDbFile: (NSString*)db;
- (void)readRowsFromDb;

@end
