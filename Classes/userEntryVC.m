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
 * This is a table view that displays all of the information about a customer
 * that is or will be stored in the database.  An administrator uses this
 * view to create a new customer or change details about an existing customer.
 *
 */
 
#import "userEntryVC.h"
#import "mainAppDelegate.h"
#import "databaseManager.h"
#import "textFieldInputVC.h"

@interface userEntryVC (PrivateMethods)
- (NSMutableArray*)initContent;
@end

@implementation userEntryVC

@synthesize dbFile;
@synthesize barcode;

// Stores current content of the cells prior to writing back to database.
// Content is an array with one entry per section, each entry itself an 
// array with one entry per cell, each cell being an NSString.
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
 * \brief Add a cancel button to navigation controller
 */
- (void) addCancelButton {
  UIBarButtonItem *button = [[[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem: UIBarButtonSystemItemCancel 
    target:self 
    action:@selector(cancelButtonHandler:)] autorelease];
  self.navigationItem.leftBarButtonItem = button;
}

/**
 * \brief Add a 'save' button to the navigation bar
 */
- (void)addSaveButton {
	UIBarButtonItem *buttonEdit = [[[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
    target:self 
    action:@selector(saveButtonHandler:)] autorelease];
	self.navigationItem.rightBarButtonItem = buttonEdit;
}

/**
 * \brief Setup view and nav controller when loading
 */
- (void) viewDidLoad {
	[super viewDidLoad];
  [self addCancelButton];
  [self addSaveButton];
}

/**
 * \brief Handle 'cancel' click -- pop off nav controller.
 * \param sender View that sent the event (unused)
 */
- (void)cancelButtonHandler:(id)sender {
  [self.navigationController popViewControllerAnimated: YES];
} 

/**
 * \brief Handle 'save' click -- save to DB and pop off nav controller.
 *
 * Writes out every currently stored cell value to its matching field in the
 * database.  This writes fields even if they have not been modified, so it
 * is currently fairly inefficient.
 *
 * \param sender View that sent the event (unused)
 */
- (void)saveButtonHandler:(id)sender {
  if (!self.barcode) {
    // Create customer first
  }

  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  for (int i = 0; i < [self numberOfSectionsInTableView:self.tableView]; i++) {
    for (int j = 0; j < [self tableView: self.tableView numberOfRowsInSection:i]; j++) {
      NSIndexPath *idx = [NSIndexPath indexPathForRow:j inSection:i];
      NSDictionary *dict = [self rowMetadataFromIndexPath: idx];
      NSString *text = [[self.content objectAtIndex: i] objectAtIndex: j];
      [delegate.customer setStringValue: text
           toDb: self.dbFile
           withBarcode: self.barcode
           withFieldType: [dict objectForKey: @"cellType"]
           withTable: [dict objectForKey: @"dbTable"]
           withField: [dict objectForKey: @"dbField"]];
    }  
  }
  [self.navigationController popViewControllerAnimated: YES];
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

/**
 * \brief Number of grouped sections to display.  Decided by customer definition.
 * \param tableView Table view making request
 * \return Number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  return [customerDef count]/2;
}

/**
 * \brief Number of rows in given section.  Decided by customer definition.
 * \param tableView Table view making request
 * \param section Section to get row count of
 * \return Number of rows.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  NSArray *sectionArray = [customerDef objectAtIndex: (section*2)+1];
  return [sectionArray count];
}

/**
 * \brief Title of given section
 * \param tableView Table view making request
 * \param section Section to get header for
 * \return Text to use as header for section.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  return [customerDef objectAtIndex: (section*2)];
}

/**
 * \brief Get a reusable cell, or create one if none exists.
 * \param tableView table view making request
 * \param cellID Unique identifier of cell type
 * \return A table view cell available for use
 */
- (UITableViewCell*)getReusableCellFromTable: (UITableView *)tableView 
                    WithID: (NSString*)cellID {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
      reuseIdentifier:cellID] autorelease];
  }
  return cell;
}

/**
 * \brief Get metadata describing what information should be stored at given cell.
 * \param indexPath Section and row of cell to get info for
 * \return Dictionary from customerDefinition that describes this cell's data
 */
- (NSDictionary *)rowMetadataFromIndexPath: (NSIndexPath *)indexPath {
	// Get customer database definition
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSArray *customerDef = [delegate.customer customerDefinition];
  
  // Get the section array.  Index math because it alternates descriptions
  // and section arrays, so two elements in the array per section.
  NSArray *section = [customerDef objectAtIndex: (indexPath.section*2)+1];
  
  // Get the row, a dictionary of metadata
  NSDictionary *row = [section objectAtIndex: indexPath.row];
  return row;
}

/**
 * \brief Get cell filled with data for given location in table
 * \param tableView table view making request
 * \param indexPath Section and row of cell to fill
 * \return Table view cell filled with correct information
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // All cells are text, so they can share an ID
  UITableViewCell *cell = [self getReusableCellFromTable: tableView 
    WithID: @"textcell"];

	NSDictionary *row = [self rowMetadataFromIndexPath: indexPath];
  
  // Label cell
  cell.textLabel.text = [row objectForKey: @"cellName"];
  // Fill cell content
	cell.detailTextLabel.text = [[self.content objectAtIndex: indexPath.section]
    objectAtIndex: indexPath.row];

  return cell;
}

/**
 * \brief Handle callback from a textFieldInputVC changing a cell's text
 *
 * Called when the administrator presses 'done' after changing a text field,
 * this replaces the text in the cell in RAM with the new value.  Nothing
 * pushed to the DB yet.
 *
 * \param textView the textFieldInputVC that fired this callback
 * \param data Unique cell identifying data given to the text view
 * \param text The new text input by the user
 */
- (void) textInputView: (textFieldInputVC*) textView 
         withUserData: (id)data
         updatedText: (NSString*)text {
  NSIndexPath *indexPath = (NSIndexPath*)data;
  NSString *newVal = (text)?text:@""; // replace null with empty string
  
  // Write it to the cell data, and refresh table
  [[self.content objectAtIndex: indexPath.section] 
    replaceObjectAtIndex:indexPath.row withObject:newVal];
  [self.tableView reloadData];
}

/**
 * \brief Handle selection of a cell (launch view for editing cell)
 * \param tableView Table view that caused this event
 * \param indexPath Section and row of cell that was selected
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *row = [self rowMetadataFromIndexPath: indexPath];
	NSString *cellContents = [[self.content objectAtIndex: indexPath.section]
    objectAtIndex: indexPath.row];
    
  // For text fields: textFieldInputVC
  if ([row objectForKey:@"cellType"] == @"text") {
    UITableViewController *nextView = [[[textFieldInputVC alloc] 
      initWithExistingText: cellContents 
      withUserData: indexPath] 
      autorelease];
    if (nextView != nil) {
      [(textFieldInputVC*)nextView setDelegate: self];
      [self.navigationController pushViewController: nextView animated:YES];
    }    
  }
}

/**
 * \brief Try to free some memory
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 * \brief Try to free some memory
 */
- (void)viewDidUnload {
}

/**
 * \brief Deallocate object
 */
- (void)dealloc {
    [super dealloc];
}


@end

