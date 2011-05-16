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
 * 
 */
 
#import "userAdminVC.h"
#import "mainAppDelegate.h"
#import "databaseManager.h"

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

- (id)initWithStyle:(UITableViewStyle)style withDbFile: (NSString*)db {
    self = [super initWithStyle:style];
    if (self) {
        self.dbFile = db;
        mainAppDelegate *delegate = 
          (mainAppDelegate*)[[UIApplication sharedApplication] delegate];
          
        // Get all customers from database and sort
        self.allRows = [[delegate.customer allCustomersInDb: db]
        	sortedArrayUsingFunction: rowSort context: nil];
        
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

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/**
 * \brief Show navigation bar when view loads
 * \param animated Whether view appearance will animate
 */
-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
  [[self navigationController] setNavigationBarHidden: NO animated: YES];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSLog(@"Section %d, row %d", indexPath.section, indexPath.row);

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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



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

