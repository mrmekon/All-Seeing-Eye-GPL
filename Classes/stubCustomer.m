//
//  stubCustomer.m
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 8/15/11.
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
 * Fake customer implementation.
 */
 
#import "stubCustomer.h"


@implementation stubCustomer

-(NSArray *)customerDefinition {
  return nil;
}

-(NSString*)getStringValueFromDb: (NSString*)dbFile
            withBarcode: (NSString*)barcode
            withFieldType: (NSString*)type
            withTable: (NSString*)table
            withField: (NSString*)field {
  return nil;  
}

-(BOOL)setStringValue: (NSString*)text
       toDb: (NSString*)dbFile
       withBarcode: (NSString*)barcode
       withFieldType: (NSString*)type
       withTable: (NSString*)table
       withField: (NSString*)field {
  return NO;
}

-(BOOL)addCustomertoDb: (NSString*)dbFile 
       withName: (NSString*)name
       withBarcode: (NSString*)barcode
       withReferrer: (NSString*)referrer {
  return NO;
}

-(BOOL)updateLevelOfReferrerWithBarcode:(NSString*)barcode
   withDb: (NSString*)dbFile {
  return NO;
}

-(int)countOfCustomersInDb: (NSString*)dbFile {
  return 0;
}

-(NSArray*)allCustomersInDb: (NSString*)dbFile {
  return nil;
}

-(NSString*)customerFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode {
  return nil;
}

-(int)levelFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode {
  return 0;
}

-(int)discountFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode {
  return 0;
}

-(int)creditFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode {
  return 0;
}

-(BOOL)clearCreditFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode {
  return NO;
}

-(int)referralCountFromDb: (NSString*)dbFile withBarcode: (NSString*)barcode {
  return 0;
}

-(int)countOfOtherBonusesFromDb: (NSString*)dbFile 
      withBarcode: (NSString*)barcode {
  return 0;
}

-(NSString*)otherBonusFromDb:  (NSString*)dbFile 
            withBarcode: (NSString*)barcode 
            bonusIndex: (int)idx {
  return nil;
}

-(BOOL)removeCustomerWithBarcode:(NSString*)barcode fromDb: (NSString*)dbFile {
  return NO;
}

@end
