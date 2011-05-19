//
//  userEntryVC.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 5/17/11.
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
 * \brief Customer entry form, for entering description of new customer
 *
 * 
 */
 
#import "userEntryVC.h"
#import "mainAppDelegate.h"
#import "databaseManager.h"

@interface userEntryVC (PrivateMethods)
- (NSMutableArray*)initContent;
@end

@implementation userEntryVC

@synthesize dbFile;
@synthesize barcode;

/// Stores current content of the cells prior to writing back to database.
/// Content is an array with one entry per section, each entry itself an 
/// array with one entry per cell, each cell being an NSString.
@synthesize content;

/**
 * \brief Initialize customer entry UI form
 *
 * \param style Valid iOS UITableView style
 * \param db Database file to operate on
 * \param barcode Barcode of customer to edit, or nil for new customer
 * \return New instance of class
 *
 */
- (id)initWithStyle:(UITableViewStyle)style 
      withDbFile: (NSString*)db 
      withBarcode: (NSString*)code {
  self = [super initWithStyle:style];
  if (self) {
      self.dbFile = db;
      self.barcode = code;
      self.content = [self initContent];
  }
  return self;
}

/**
 * \brief Initialize array of unsaved customer data
 *
 * Data in all the cells needs to be stored in RAM before it is written out to
 * the database, so it is stored in this oversized data structure.  This 
 * initializes the data structure to an array of arrays of strings.  Outermost
 * array represents sections of the UI, inner arrays represent cells, which 
 * contain strings.
 *
 * Every cell is initialized to nil if creating a new customer.  If this is an
 * existing customer, meaning the global 'barcode' variable is set, cells are
 * filled with values from the database using the customerProtocol messages.
 *
 * \return Allocated arrays with customer data, or empty strings if new customer
 */
- (NSMutableArray*)initContent {
	NSMutableArray *tmpContent; // what we're building
  
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  int sectionCount = [customerDef count]/2;
  
  // Outer array has one entry per section
	tmpContent = [NSMutableArray arrayWithCapacity: sectionCount];
  
  // Each section contains one string per cell
  for (int i = 0; i < sectionCount; i++) {
    NSArray *sectionArray = [customerDef objectAtIndex: (i*2)+1];
    int cellCount = [sectionArray count];
    NSMutableArray *tmpRows = [NSMutableArray arrayWithCapacity: cellCount];
    
    // Add one string per cell (fetch from DB if appropriate)
    for (int j = 0; j < cellCount; j++) {
    	// fuckin' high level languages... this can't be nil.
    	NSString *cellContent = @"";
      
      if (self.barcode) {
      	// get value from database
	      NSDictionary *row = [sectionArray objectAtIndex: j];
        NSString *dbContent = [delegate.customer 
          getStringValueFromDb: self.dbFile
          withBarcode: self.barcode
          withFieldType: [row objectForKey: @"cellType"]
          withTable: [row objectForKey: @"dbTable"]
          withField: [row objectForKey: @"dbField"]
        ];
        if (dbContent) cellContent = dbContent;
      }
      [tmpRows addObject: cellContent];
    }
    [tmpContent addObject: tmpRows];
  }
  return tmpContent;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  return [customerDef count]/2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  NSArray *sectionArray = [customerDef objectAtIndex: (section*2)+1];
  return [sectionArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  return [customerDef objectAtIndex: (section*2)];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // All cells are text, so they can share an ID
  NSString *cellID = @"textcell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
      reuseIdentifier:cellID] autorelease];
  }

	// Get customer database definition
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  
  // Get the section array.  Index math because it alternates descriptions
  // and section arrays, so two elements in the array per section.
  NSArray *section = [customerDef objectAtIndex: (indexPath.section*2)+1];
  
  // Get the row, a dictionary of metadata
  NSDictionary *row = [section objectAtIndex: indexPath.row];
      
  // Label cell
  NSString *label = [row objectForKey: @"cellName"];
  cell.textLabel.text = label;

#if 0
  NSString *contents = [delegate.customer 
    getStringValueFromDb: self.dbFile
    withBarcode: barcode
    withFieldType: (NSString*)type
    withTable: (NSString*)table
    withField: (NSString*)field];
#endif
	cell.detailTextLabel.text = [[self.content objectAtIndex: indexPath.section]
    objectAtIndex: indexPath.row];
#if 0    
  cell.detailTextLabel.text = @"Detail text";
#endif
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

