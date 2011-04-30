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
 */
 
#import <UIKit/UIKit.h>


@protocol customerProtocol

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
@end
