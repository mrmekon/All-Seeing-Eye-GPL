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
#import "dropboxSync.h"
#import "rootView.h"

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

@synthesize doNotSaveDatabase;
@synthesize searchResultsActive;
@synthesize searchString;
@synthesize searchController;
@synthesize overlay;
@synthesize searchOverlay;

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
        //[self readRowsFromDb];
        
        // Create a search bar, make it the table header
        self.searchBar = [[UISearchBar alloc] 
          initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
        [self.searchBar sizeToFit];  
        self.tableView.tableHeaderView = self.searchBar;  
        
        // Create a search controller with search bar
        mainAppDelegate *delegate = 
          (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
        searchController = [
          [UISearchDisplayController alloc] initWithSearchBar: self.searchBar 
          contentsController:delegate.navController];
#if 0
        searchController = [
          [UISearchDisplayController alloc] initWithSearchBar: self.searchBar 
          contentsController:self];
#endif
        searchController.delegate = self;
        searchController.searchResultsDataSource = self;
        searchController.searchResultsDelegate = self;
        
        self.doNotSaveDatabase = NO;
        
        self.overlay = [[UIView alloc] initWithFrame:
          self.searchController.searchResultsTableView.frame];
        self.overlay.backgroundColor = [UIColor grayColor];
        self.overlay.alpha =  0.5;
        self.searchOverlay = [[UIView alloc] initWithFrame:
          self.tableView.frame];
        self.searchOverlay.backgroundColor = [UIColor grayColor];
        self.searchOverlay.alpha =  0.5;
    }
    return self;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
  // search ended
  self.searchResultsActive = NO;
  [self.searchController.searchResultsTableView setEditing: NO animated: YES];
  [self.tableView reloadData];
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
  if (!self.searchResultsActive) {
    [self setEditing: YES animated: YES];
    [self addDoneButton];
    [self addPlusButton];
  }
  else {
    [self.searchController.searchResultsTableView setEditing: YES animated: YES];
    [self addDoneButton];
    [self addPlusButton];
  }
} 

/**
 * \brief End table's edit mode
 * \param sender View that sent this message (sent by button press)
 */
- (void)doneButtonHandler:(id)sender {
  if (!self.searchResultsActive) {
    [self setEditing: NO animated: YES];
    [self addEditButton];
    [self clearPlusButton];
  }
  else {
    [self.searchController.searchResultsTableView setEditing: NO animated: YES];
    [self addEditButton];
    [self clearPlusButton];
  }
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
  
  self.doNotSaveDatabase = YES;
  
  userEntryVC *entryVC = [[[userEntryVC alloc] 
  	initWithStyle: UITableViewStyleGrouped
    withDbFile: self.dbFile
    withBarcode: nil] autorelease];
  [[self navigationController] pushViewController:entryVC animated:YES];
  [self doneButtonHandler: sender];
} 


/**
 * \brief Filter customers based on search terms
 *
 * Filters the database of customers down to only those with name or barcode
 * matching the current search term.  It searches anywhere in the name or
 * barcode, and is case and diacritic insensitive.  The sort order of
 * the original list will be maintained.
 *
 * \param controller ViewController that called
 * \param searchString Current search string
 * \return Whether table should be reloaded (always yes)
 */
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
        shouldReloadTableForSearchString:(NSString *)str {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:
    @"(name CONTAINS[cd] %@) || (barcode CONTAINS[cd] %@)", 
    str, str];
  self.searchRows = [self.allRows filteredArrayUsingPredicate: predicate];
  self.searchString = [NSString stringWithString: str];
  return YES;
}

/**
 * \brief Show navigation bar when view loads
 * \param animated Whether view appearance will animate
 */
-(void) viewWillAppear:(BOOL)animated { 
  mainAppDelegate *delegate = 
      (mainAppDelegate*)[[UIApplication sharedApplication] delegate];

	[super viewWillAppear: animated];
  [[self navigationController] setNavigationBarHidden: NO animated: YES];
  [self addEditButton];
  
  [self.tableView setUserInteractionEnabled:NO];
  [self.searchController.searchResultsTableView setUserInteractionEnabled:NO];
  
  [self disableTableViews];

  // Grab the lock if this is our first time in
  if (!self.doNotSaveDatabase) {
    [delegate.dropbox tryToObtainDropboxLock];
  }
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear: animated];
  
  // Clear do-not-save flag.  This means we're coming out of editing
  // a user.
  if (self.doNotSaveDatabase) {
    self.doNotSaveDatabase = NO;
  }
  
  [self readRowsFromDb]; // re-read local database, in case it changed
  
  // If we're searching, reload search results and re-display search table
  if (self.searchResultsActive) {
    [self searchDisplayController:self.searchController
        shouldReloadTableForSearchString:self.searchString];
    [self.searchController.searchResultsTableView reloadData];
  }
  // If not searching, re-display main table
  else {
    [self.tableView reloadData]; // and reload table with new data
  }
  [self enableTableViews];
}

-(void)disableTableViews {
  [self.tableView setUserInteractionEnabled:NO];
  [self.view insertSubview:overlay aboveSubview:self.tableView];
  
  [self.searchController.searchResultsTableView setUserInteractionEnabled:NO];
  [self.searchController.searchContentsController.view 
    insertSubview:self.searchOverlay 
    aboveSubview:self.searchController.searchResultsTableView];
}

-(void)enableTableViews {
  [self.tableView setUserInteractionEnabled:YES];
  [self.overlay removeFromSuperview];
  
  [self.searchController.searchResultsTableView setUserInteractionEnabled:YES];
  [self.searchOverlay removeFromSuperview];
}

/**
 * \brief Write database to dropbox when editing is done
 * \param animated Whether view disappearance will animate
 */
-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear: animated];
  
  // If we're exiting admin page and not going to a user edit...
  if (!self.doNotSaveDatabase) {
    // save database back to dropbox
    mainAppDelegate *delegate = 
        (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                NSDocumentDirectory, 
                NSUserDomainMask, YES); 
    NSString* docDir = [paths objectAtIndex:0];
    NSString* tmppath = [docDir stringByAppendingString:@"/database.sql"];
    [(rootView*)delegate.viewController.view disableView];
    [delegate.dropbox writeDatabaseToDropbox: tmppath];
        
    // In case search is still up, hide it
    [self.searchController setActive:NO animated:NO];
        
    // Let go of the lock
    [delegate.dropbox releaseDropboxLock];
  }
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

  if (tableView == self.tableView) {
    // All results in admin view controller
    self.searchResultsActive = NO;
    return self.allRows.count;
  }
  else {
    // Search results from search view controller
    self.searchResultsActive = YES;
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
	if (!self.searchResultsActive) {
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
  NSDictionary *row = nil;
  if (!self.searchResultsActive) {
    row = [self.allRows objectAtIndex: indexPath.row];
  }
  else {
    row = [self.searchRows objectAtIndex: indexPath.row];
  }
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
  if (!self.searchResultsActive) {
    [self readRowsFromDb];
  }
  else {
    [self readRowsFromDb];
    [self searchDisplayController:self.searchController
        shouldReloadTableForSearchString:self.searchString];
    [self.searchController.searchResultsTableView reloadData];
  }
  
  // Animate deletion of row
  if (!self.searchResultsActive) {
    [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] 
      withRowAnimation:UITableViewRowAnimationFade];
  }
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
  NSDictionary *row = nil;
  if (!self.searchResultsActive) {
    row = [self.allRows objectAtIndex: indexPath.row];
  }
  else {
    row = [self.searchRows objectAtIndex: indexPath.row];
  }
  NSString *barcode = [row objectForKey: @"barcode"];
  if (!barcode) {
  	NSLog(@"Well that's a funny predicament.  Row has no barcode!");
    return;
  }
  
  // don't save DB when the view disappears
  self.doNotSaveDatabase = YES;
  
  // Hide search controller
  [self.searchController setActive:NO animated:YES];
  
  // Show customer entry form
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

