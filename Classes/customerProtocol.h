//
//  customerProtocol.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 4/30/11.
//  Copyright 2011 Trevor Bentley. All rights reserved.
//

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
