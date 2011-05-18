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


@implementation userEntryVC

@synthesize dbFile;

- (id)initWithStyle:(UITableViewStyle)style withDbFile: (NSString*)db {
  self = [super initWithStyle:style];
  if (self) {
      self.dbFile = db;
  }
  return self;
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
  
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  
  // Get the section array.  Index math because it's packed with descrition strings.
  NSArray *section = [customerDef objectAtIndex: (indexPath.section*2)+1];
  
  // Get the row, a dictionary of metadata
  NSDictionary *row = [section objectAtIndex: indexPath.row];
  
  // Get correct cell type for the field
  NSString *cellID = [row objectForKey: @"cellType"];
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellID] autorelease];
  }
    
  // Label cell
  NSString *label = [row objectForKey: @"cellName"];
  cell.textLabel.text = label;

#if 0    
  // Configure the cell...
  cell.textLabel.text = @"Text Label";
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

