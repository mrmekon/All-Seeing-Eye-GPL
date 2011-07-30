//
//  customerProtocol.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/30/11.
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
 * \brief Protocol for requesting customer data
 *
 * This file defines a protocol to be implemented by classes that provide data
 * about a customer via database lookups.  A class that directly accesses the
 * database should implement this protocol, and expect to be called by a
 * view that handles displaying customer data.
 *
 * This is split out as a protocol to support the idea of deploying to multiple
 * venues with minimal code change.  The database specifics and reward levels
 * can change without changing the frontend view.  It does, however, limit the
 * reward system to having levels, percent discounts, and monetary credits.
 *
 * Certain information is mandatory (name, level, etc), but this protocol
 * also provides mechanisms for adding additional information to each
 * customer account, and generalizes it such that a UI implementing this
 * protocol should be able to support fairly large customer descriptions.
 * The generic system only supports 1-1 mappings, however.
 *
 */
 
#import <UIKit/UIKit.h>


@protocol customerProtocol

/**
 * \brief Return description of customer database
 *
 * Returns a deeply-nested data structure that defines the information
 * stored in the customer database.  This data structure is used as the basis
 * for creating and editing customer entries, and describes everything the
 * application needs to display, get, and set customer info.
 *
 * The format of the data structure is as follows:
 *
 * The top-level returned object is an array of Section Names and Sections.  
 * Sections define which fields should be grouped together when displayed.  
 * For example, a "contact information" section might group the phone and
 * street address.
 *
 * The top-level array alternates section name (NSString*), section (NSArray*),
 * section name, section...  two entries per section.
 *
 * The section array contains a variable number of Row dictionaries.  Rows 
 * represent a single piece of information about a customer, and map to a field
 * in the database.
 *
 * The row dictionary keys can be:
 *   - cellName  -- Name to display as cell label on UI
 *   - cellType  -- Type of data represented
 *   - dbTable   -- Name of table in db that stores this field
 *   - dbField   -- Name of corresponding field in db's table
 *   - required  -- Whether this field is required
 * 
 * \return Data structure representing customer database
 */
-(NSArray *)customerDefinition;

/**
 * \brief Get a field value from the DB as a string
 *
 * Generic, abstract interface to fetch the value of any field from the 
 * customer database using data that the UI can get by other customerProtocol
 * queries.  Specifically, 'type','table', and 'field' should be a valid
 * combination from a dictionary in customerDefinition.  Customer to query is
 * determined by the barcode.
 *
 * \param dbFile Database file to search in
 * \param barcode Barcode of customer to get information on
 * \param type Type of field being queried (determines string formatting)
 * \param table Table in database to query
 * \param field Field in database to query
 * \return String value of requested field.
 *
 */
-(NSString*)getStringValueFromDb: (NSString*)dbFile
            withBarcode: (NSString*)barcode
            withFieldType: (NSString*)type
            withTable: (NSString*)table
            withField: (NSString*)field;

/**
 * \brief Set a field value to the DB as a string
 *
 * Generic, abstract interface to set the value of any field from the 
 * customer database using data that the UI can get by other customerProtocol
 * queries.  Specifically, 'type','table', and 'field' should be a valid
 * combination from a dictionary in customerDefinition.  Customer to query is
 * determined by the barcode.
 *
 * \param text Text to set field to
 * \param dbFile Database file to write to
 * \param barcode Barcode of customer to modify
 * \param type Type of field being queried (determines string formatting)
 * \param table Table in database to query
 * \param field Field in database to query
 * \return String value of requested field.
 *
 */
-(BOOL)setStringValue: (NSString*)text
       toDb: (NSString*)dbFile
       withBarcode: (NSString*)barcode
       withFieldType: (NSString*)type
       withTable: (NSString*)table
       withField: (NSString*)field;
  
/**
 * \brief Add new customer to database with given name and barcode value
 * \param dbFile Full path to database file
 * \param name Name of new customer
 * \param barcode Barcode of new customer
 * \return Yes for success
 */
-(BOOL)addCustomertoDb: (NSString*)dbFile 
       withName: (NSString*)name
       withBarcode: (NSString*)barcode;
       
/**
 * \brief Get number of registered customers
 * \param dbFile Database to search
 * \return Number of customers
 */
-(int)countOfCustomersInDb: (NSString*)dbFile;

/**
 * \brief Get all customers from the database
 * \param dbFile Database to query
 * \return Dictionary of all customers, with name as key and barcode as value
 */
-(NSArray*)allCustomersInDb: (NSString*)dbFile;

/**
 * \brief Get customer name
 * \param dbFile Database to search
 * \param barcode Barcode number to match
 * \return Customer name
 */
-(NSString*)customerFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode;

/**
 * \brief Get customer rewards level
 * \param dbFile Database to search
 * \param barcode Barcode number to match
 * \return Customer rewards level
 */
-(int)levelFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode;

/**
 * \brief Get customer discount percentage
 * \param dbFile Database to search
 * \param barcode Barcode number to match
 * \return Customer discount percentage
 */
-(int)discountFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode;

/**
 * \brief Get customer monetary credits
 * \param dbFile Database to search
 * \param barcode Barcode number to match
 * \return Customer's monetary credits
 */
-(int)creditFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode;

/**
 * \brief Get number of bonus rewards customer has
 * \param dbFile Database to search
 * \param barcode Barcode number to match
 * \return Number of bonus rewards customer has
 */
-(int)countOfOtherBonusesFromDb: (NSString*)dbFile 
      withBarcode: (NSString*)barcode;

/**
 * \brief Get the requested bonus reward for a given customer
 *
 * In addition to percent discount and monetary credits, a customer can have
 * any number of miscellaneous earned bonus rewards.  Since these aren't
 * specifically understood by the system, they are simply stored as strings.
 * This function returns a string describing a specific reward.
 *
 * \param dbFile Database to search
 * \param barcode Barcode number to match
 * \return A customer's specific bonus reward (as string)
 */
-(NSString*)otherBonusFromDb:  (NSString*)dbFile 
            withBarcode: (NSString*)barcode 
            bonusIndex: (int)idx;
            
/**
 * \brief Remove given customer
 * \param barcode Barcode of customer to remove
 * \param dbFile Database to search
 * \return Whether customer was successfully removed
 */
-(BOOL)removeCustomerWithBarcode:(NSString*)barcode fromDb: (NSString*)dbFile;

@end
