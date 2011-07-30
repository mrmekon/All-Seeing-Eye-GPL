//
//  main.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/22/11.
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
//
//  Developer contact information:
//
//  Trevor Bentley
//  495 Water Shadow Ln
//  Alpharetta, GA 30022
//  USA
//
//  trevor@trevorbentley.com
//  http://www.trevorbentley.com
//  
//  Twitter: @mrmekon
//  LinkedIn: http://www.linkedin.com/in/trevorbentley
//  Tumblr: http://mrmekon.tumblr.com
//  Flickr: http://www.flickr.com/photos/mrmekon
//

/** @mainpage
 *
 * All-Seeing Eye is an iOS application for restaurant/bar or other service 
 * industry companies to use and manage a Customer Loyalty program.  Membership
 * cards with unique barcodes are distributed to customers, and All-Seeing Eye
 * is used to scan a customer's card at the POS to determine his or her earned
 * benefits.
 *
 * @section User Interface
	*
 * All-Seeing Eye's user interface is split into two frames: a top frame that
 * shows a live feed from the iPad/iPhone rear camera, and a bottom frame that
 * shows customer information retrieved from a database after successfully
 * scanning a barcode with the camera.
 *
 * @section Customer Administration
 *
 * An alternate view is available for managing the customer database from within
 * All-Seeing Eye.  The user enters administration mode by performing a two-
 * fingered swipe on the screen while at the main interface.
 *
 * The administration view shows a table with all registered customers, sorted
 * roughly by last name.  This table has a search bar to rapidly search by
 * name or barcode.  The administrator can select a customer to view and edit
 * detailed information, can push a button to add a new customer, or can enter
 * the edit mode and subsequently delete customers.
 *
 * The customer detail page is launched by creating a new customer or clicking
 * on an existing one.  This page shows all of the detailed information stored
 * in the local database regarding a customer.  This includes things like name,
 * barcode, contact information, and birth date.  The administrator can view
 * and edit any of this information using the provided interface.
 *
 * When finished administering, the simply press the 'done' or 'back' buttons
 * until you arrive back at the main barcode scanning interface.
 *
 */
 
#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
    int retVal = UIApplicationMain(argc, argv, @"UIApplication", @"mainAppDelegate");
    [pool release];
    return retVal;
}
