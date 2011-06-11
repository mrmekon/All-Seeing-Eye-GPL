//
//  phoneInputVC.m
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

/**
 * \brief Displays a single, editable text-field and keyboard.
 *
 */

#import "phoneInputVC.h"


@implementation phoneInputVC

@synthesize textField;
@synthesize delegate;
@synthesize userData;

/**
 * \brief Initialize view controller with existing text and identifying data
 * \param initText Text to pre-fill text field with
 * \param initUserData Data passed back to delegate.  Used to ID caller.
 * \return Initialized instance
 */
-(id) initWithExistingText: (NSString*)initText withUserData: (id)initUserData {
	if (self = [super initWithStyle: UITableViewStyleGrouped]) {
    self.textField = [[UITextField alloc] initWithFrame: CGRectMake(0,0,10,10)];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.keyboardType = UIKeyboardTypePhonePad;
    self.textField.placeholder = @"";
    self.textField.text = initText;
    self.textField.delegate = self;

		// This is just something to pass back to the delegate.  Save it
    // and don't touch.
    self.userData = initUserData;
  }
  return self;
}

- (BOOL)textField:(UITextField *)textField 
        shouldChangeCharactersInRange:(NSRange)range 
        replacementString:(NSString *)string {
	NSLog(@"Adding string: %@", string);
  for (int i = 0; i < [string length]; i++) {
  	char ch = [string characterAtIndex: i];
  	if (!isdigit(ch) && ch != '(' && ch != ')' &&
        ch != '-') {
    	return NO;
    }
  }
  return YES;
}

/**
 * \brief Add a cancel button to navigation controller
 */
- (void) addCancelButton {
  UIBarButtonItem *button = [[[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem: UIBarButtonSystemItemCancel 
    target:self 
    action:@selector(cancelButtonHandler:)] autorelease];
  self.navigationItem.leftBarButtonItem = button;
}

/**
 * \brief Setup view and nav controller when loading
 */
- (void) viewDidLoad {
	[super viewDidLoad];
  [self addCancelButton];
}


/**
 * \brief Handle 'cancel' click -- pop off nav controller.
 * \param sender View that sent the event (unused)
 */
- (void)cancelButtonHandler:(id)sender {
  [self.navigationController popViewControllerAnimated: YES];
} 

/**
 * \brief Handle 'done' button on keyboard by saving entered text and exiting.
 * \param field Text field in question
 * \return Always returns NO, but calls delegate and pops itself off nav controller.
 */
- (BOOL)textFieldShouldReturn:(UITextField*) field {
	NSString *content = [textField text];
  [delegate phoneInputView: self
       withUserData: self.userData
       updatedText: content];
  [self.navigationController popViewControllerAnimated: YES];
  return NO;
}

/**
 * \brief Number of sections (always 1)
 * \param tableView Unused
 * \return One, 1, uno.
 */
- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView {
  return 1;
}

/**
 * \brief Number of rows in given section (always 1)
 * \param tableView Unused
 * \param section Section in question (unused)
 * \return One, 1, uno.
 */
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

/**
 * \brief Detect cell selection, and cancel it.
 * \param tableView Table view that issued request.
 * \param indexPath Section and row of cell selected.
 */
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}


/**
 * \brief Get a reusable cell filled with contents
 * \param tableView Table view in need of cell
 * \param indexPath Location in table of cell to return
 * \return Cell filled with text from global text field
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { 
    static NSString *CellIdentifier = @"phoneInputCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell.contentView addSubview: self.textField];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frameRect = CGRectMake(10, 0, 660, 44);
        [textField setFrame: frameRect];
        [self.textField becomeFirstResponder];
    }

    return cell;
}

/**
 * \brief Get section header (there aren't any)
 * \param tableView unused
 * \param section unused
 * \return Always nil.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
  return nil;
}

/**
 * \brief Get section footer (there aren't any)
 * \param tableView unused
 * \param section unused
 * \return Always nil.
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger) section {
	return nil;
}


/**
 * \brief Try to free up some ram
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/**
 * \brief Release memory
 */
- (void)dealloc {
	[textField release];
	[super dealloc];
}

@end
