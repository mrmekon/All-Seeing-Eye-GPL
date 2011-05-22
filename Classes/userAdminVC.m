//
//  userAdminVC.m
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

/**
 * \brief User administration view, displays list of all registered users.
 *
 * Displays all customers in the database in a table view.  Bolded name is the
 * main text, and the customer's barcode value is the smaller alternate 
 * description text.
 *
 * User can select a customer to view and edit details about him/her.
 *
 * User can add new customers to the database, and delete existing ones.
 *
 * This view loads all of the database information into RAM for sorting and
 * display, which means there is some unknown memory constraint on how many
 * customers can be in the database without causing serious problems.  This
 * is a known design limitation.
 *
 */
 
#import "userAdminVC.h"
#import "mainAppDelegate.h"
#import "databaseManager.h"
#import "userEntryVC.h"

/**
 * \brief Sorts two rows (as dictionaries) by (guessed) last name
 * 
 * Comparator for use as NSArray sorting function.
 *
 * Compares customer names based on the last WORD in their name, which may
 * or may not be their actual last name.  This is done because the database
 * does not store name parts, and determining the "last name" correctly is
 * fairly impossible.
 *
 * \param dict1 First row to compare (dictionary with name and barcode)
 * \param dict2 Second row to compare (dictionary with name and barcode)
 * \param context Extra data (always null)
 * \return NSComparisonResult of last word from each name
 */
NSInteger rowSort(id dict1, id dict2, void *context)
{
	// Get names, split on spaces, pick last word as "last name"
  NSArray *names1 = [[dict1 objectForKey: @"name"] componentsSeparatedByString: @" "];
  int lastIdx1 = names1.count - 1;
  NSString *last1 = [names1 objectAtIndex: lastIdx1];
  NSArray *names2 = [[dict2 objectForKey: @"name"] componentsSeparatedByString: @" "];
  int lastIdx2 = names2.count - 1;
  NSString *last2 = [names2 objectAtIndex: lastIdx2];
      
  return [last1 caseInsensitiveCompare: last2];
}

@implementation userAdminVC

@synthesize dbFile;
@synthesize allRows;
@synthesize searchRows;
@synthesize searchBar;

/**
 * \brief Initialize a new instance with the given database
 *
 * Initializer stores the database, reads all the customers from the database,
 * and creates a search bar and search controller.
 *
 * \param db Database file to administer
 * \return Initialized instance of class 
 */
- (id)initWithDbFile: (NSString*)db {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.dbFile = db;

        // Get all customers from database and sort
        [self readRowsFromDb];
        
        // Create a search bar, make it the table header
        self.searchBar = [[UISearchBar alloc] 
          initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
        [self.searchBar sizeToFit];  
        self.tableView.tableHeaderView = self.searchBar;  
        
        // Create a search controller with search bar
        UISearchDisplayController *searchController = [
          [UISearchDisplayController alloc] initWithSearchBar: self.searchBar 
          contentsController:self];
        searchController.delegate = self;
        searchController.searchResultsDataSource = self;
        searchController.searchResultsDelegate = self;
    }
    return self;
}

/**
 * \brief Reads names/barcodes of all customers from the database.
 *
 * Reads names/barcodes of all the customers, and stores them in a global
 * variable that the cells will use to populate themselves.  They are 
 * sorted by a guess at the last name (the last word of the name field).
 *
 */
- (void)readRowsFromDb {
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
  self.allRows = [[delegate.customer allCustomersInDb: self.dbFile]
    sortedArrayUsingFunction: rowSort context: nil];
}

/**
 * \brief Add an 'edit' button to the navigation bar
 */
- (void)addEditButton {
	UIBarButtonItem *buttonEdit = [[[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
    target:self 
    action:@selector(editButtonHandler:)] autorelease];
	self.navigationItem.rightBarButtonItem = buttonEdit;
}

/**
 * \brief Add a 'done' button to the navigation bar
 */
- (void)addDoneButton {
	UIBarButtonItem *buttonDone = [[[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
    target:self 
    action:@selector(doneButtonHandler:)] autorelease];
	self.navigationItem.rightBarButtonItem = buttonDone;
}

/**
 * \brief Add a 'plus' button to the navigation bar
 */
- (void)addPlusButton {
  UIBarButtonItem *buttonPlus = [[[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
    target:self 
    action:@selector(plusButtonHandler:)] autorelease];
  self.navigationItem.leftBarButtonItem = buttonPlus;
}

/**
 * \brief Remove 'plus' button to the navigation bar
 */
- (void) clearPlusButton {
	self.navigationItem.leftBarButtonItem = nil;
}

/**
 * \brief Put table in 'edit' mode, which allows insertion and deletion.
 * \param sender View that sent this message (sent by button press)
 */
- (void)editButtonHandler:(id)sender {
	[self setEditing: YES animated: YES];
  [self addDoneButton];
  [self addPlusButton];
} 

/**
 * \brief End table's edit mode
 * \param sender View that sent this message (sent by button press)
 */
- (void)doneButtonHandler:(id)sender {
	[self setEditing: NO animated: YES];
  [self addEditButton];
  [self clearPlusButton];
}

/**
 * \brief Jump to view that allows new customer to be created
 * \param sender View that sent this message (sent by button press)
 */ 
- (void)plusButtonHandler:(id)sender {
	//AdjectiveInputVC *inputVC = [[AdjectiveInputVC alloc] initWithStyle: UITableViewStyleGrouped];
  //inputVC.delegate = self;
  //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: inputVC];
  //[[self navigationController] presentModalViewController: nav animated:YES];
} 


/**
 * \brief Filter customers based on search terms
 *
 * Filters the database of customers down to only those with name or barcode
 * matching the current search term.  It compares the search only to the start
 * of name/barcode, and is case and diacritic insensitive.  The sort order of
 * the original list will be maintained.
 *
 * \param controller ViewController that called
 * \param searchString Current search string
 * \return Whether table should be reloaded (always yes)
 */
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
        shouldReloadTableForSearchString:(NSString *)searchString {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:
    @"(name BEGINSWITH[cd] %@) || (barcode BEGINSWITH[cd] %@)", 
    searchString, searchString];
  self.searchRows = [self.allRows filteredArrayUsingPredicate: predicate];
  return YES;
}


/**
 * \brief Show navigation bar when view loads
 * \param animated Whether view appearance will animate
 */
-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
  [[self navigationController] setNavigationBarHidden: NO animated: YES];
  [self addEditButton];
}


/**
 * \brief Number of sections in table view (always 1)
 * \param tableView UITableView that called this
 * \return Number of sections
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Just one section.  Let 'em search.  Sorting would be a bitch since the db
  // does not differentiate first/last names.
  return 1;
}

/**
 * \brief Number of rows in the selected section
 *
 * Returns number of all customers normally, or number of customers matching
 * search terms if a search is active.
 *
 * \param tableView UITableView that called it
 * \param section Section of table to enumerate
 * \return Number of rows in selected section
 */
- (NSInteger)tableView:(UITableView *)tableView 
             numberOfRowsInSection:(NSInteger)section {
	NSLog(@"Table view section request");
  if (tableView == self.tableView) {
    // All results in admin view controller
    return self.allRows.count;
  }
  else {
    // Search results from search view controller
    return self.searchRows.count;
  }
}


/**
 * \brief Fill contents of specified table cell
 *
 * Given a section and row, returns a table cell with the content set to
 * whatever information from the database is intended to be displayed at that
 * location.
 *
 * \param tableView Table to create cell on
 * \param indexPath Section and row of table to create cell on
 * \return Cell with contents set correctly for its location
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }
  
	// Choose from all customers or search results based on requester.
	NSDictionary *cellDict = nil;
	if (tableView == self.tableView) {
  	cellDict = [self.allRows objectAtIndex: indexPath.row];
  }
  else {
  	cellDict = [self.searchRows objectAtIndex: indexPath.row];  
  }

  cell.textLabel.text = [cellDict objectForKey: @"name"];
  cell.detailTextLabel.text = [cellDict objectForKey: @"barcode"];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
  return cell;
}


/**
 * \brief Delete a customer at the user's request
 *
 * Called when the 'delete' button is clicked in edit mode, this
 * function deletes the customer from the database and updates the local
 * copy of the database and the table display.
 *
 * \param tv Table view that this is acting on
 * \param editingStyle What action is requested.  Only answers deletes.
 * \param indexPath Section and row of cell to delete.
 */
- (void)tableView:(UITableView *)tv 
        commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
        forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle != UITableViewCellEditingStyleDelete) {
    return; // only support deletes
  }
    
  // Figure out which barcode we're deleting
	NSDictionary *row = [self.allRows objectAtIndex: indexPath.row];
  NSString *barcode = [row objectForKey: @"barcode"];
  if (!barcode) {
  	NSLog(@"Well that's a funny predicament.  Row has no barcode!");
    return;
  }
  
  // Delete it from the database
  mainAppDelegate *delegate = 
    (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate.customer removeCustomerWithBarcode: barcode fromDb: self.dbFile];
  
  // Reread database
  [self readRowsFromDb];
  
  // Animate deletion of row
  [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] 
    withRowAnimation:UITableViewRowAnimationFade];
}

/**
 * \brief Handle selection of a specific cell
 *
 * Performs the appropriate action when a cell is clicked, which is most likely
 * displaying a new view that shows all of the selected customer's information.
 *
 * \param tableView Table view that has a selection
 * \param indexPath Section and row of table view that was selected
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *row = [self.allRows objectAtIndex: indexPath.row];
  NSString *barcode = [row objectForKey: @"barcode"];
  if (!barcode) {
  	NSLog(@"Well that's a funny predicament.  Row has no barcode!");
    return;
  }
  userEntryVC *entryVC = [[[userEntryVC alloc] 
  	initWithStyle: UITableViewStyleGrouped
    withDbFile: self.dbFile
    withBarcode: barcode] autorelease];
  [[self navigationController] pushViewController:entryVC animated:YES];
}

/**
 * \brief Free memory usage if possible
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 * \brief Free memory usage if possible
 */
- (void)viewDidUnload {
}


/**
 * \brief Deconstructor
 */
- (void)dealloc {
    [super dealloc];
}


@end

