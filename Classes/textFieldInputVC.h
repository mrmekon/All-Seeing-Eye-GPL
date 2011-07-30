//
//  textFieldInputVC.h
//  All-Seeing Eye
//
//  Created by Trevor Bentley on 5/21/11.
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


@interface textFieldInputVC : UITableViewController <UITextFieldDelegate> {
  UITextField *textField;
  id delegate;
  id userData;
}

/// The editable text field within the displayed table cell
@property (nonatomic, retain) UITextField *textField;
/// Delegate implementing textInputVCProtocol
@property (nonatomic, retain) id delegate;
/// Identifier data passed back to delegate after an event occurs
@property (nonatomic, retain) id userData;


-(id) initWithExistingText: (NSString*)initText withUserData: (id)initUserData;

@end

@protocol textInputVCProtocol
/**
 * \brief Protocol describing how textFieldInputVC informs delegate of text change
 *
 * A textFieldInputVC is created and displayed by another view.  That view 
 * gets informed of changes to the text via the delegate callback methods
 * specified in textInputVCProtocol.
 *
 * Expected usage is to have a view controller that implements 
 * textInputVCProtocol.  It will create a textFieldInputVC view, set itself
 * as the delegate, and push the text field view onto the view controller
 * stack.  When the user is finished, the methods defined in this protocol
 * will be called on the originating view.
 *
 */
 
 
- (void) textInputView: (textFieldInputVC*) textView 
         withUserData: (id)data
         updatedText: (NSString*)text;
@end
