//
//  numberInputVC.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 6/11/11.
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
///\file

#import <Foundation/Foundation.h>


@interface numberInputVC : UITableViewController <UITextFieldDelegate> {
  UITextField *textField;
  id delegate;
  id userData;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) id delegate;
/// Identifier data passed back to delegate after an event occurs
@property (nonatomic, retain) id userData;

-(id) initWithExistingNumber: (NSString*)number withUserData: (id)initUserData;

@end

@protocol NumberInputVCProtocol
- (void) numberInputView: (numberInputVC*) view 
         withUserData: (id)data
         updatedNumber: (NSString*)number;
@end
