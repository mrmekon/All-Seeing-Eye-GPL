//
//  textFieldInputVC.m
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

/**
 * \brief Displays a single, editable text-field and keyboard.
 *
 * This is a full UITableViewController that displays a single cell with
 * an editable text field in it.  It has a permanently displayed
 * virtual keyboard, too.
 *
 * Expected usage is to have a table view that shows non-editable text fields.
 * When a user selects one of these fields, it creates a textFieldInputVC
 * view and shows it with animation.  The user enters or edits text data, and
 * then closes this view.  The launching view should then update its text
 * content with the result.
 *
 * This view is expected to be pushed on a navigation controller's stack, and
 * will subsequently pop itself off the stack when the user finishes.
 *
 * The header for this class also defines a protocol that it uses for returning
 * the result of the user's input.  A view that uses this class is expected
 * to implement textInputVCProtocol.
 *
 */

#import "textFieldInputVC.h"


@implementation textFieldInputVC

@synthesize textField;
@synthesize delegate;
@synthesize userData;

-(id) initWithExistingText: (NSString*)initText withUserData: (id)initUserData {
	if (self = [super initWithStyle: UITableViewStyleGrouped]) {
    self.textField = [[UITextField alloc] initWithFrame: CGRectMake(0,0,10,10)];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = @"";
    self.textField.text = initText;
    self.textField.delegate = self;

		// This is just something to pass back to the delegate.  Save it
    // and don't touch.
    self.userData = initUserData;
  }
  return self;
}

- (void) addCancelButton {
  UIBarButtonItem *button = [[[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem: UIBarButtonSystemItemCancel 
    target:self 
    action:@selector(cancelButtonHandler:)] autorelease];
  self.navigationItem.leftBarButtonItem = button;
}

- (void) viewDidLoad {
	[super viewDidLoad];
  [self addCancelButton];
}

- (void) viewDidUnload {
	[super viewDidUnload];
}

- (void) viewWillAppear: (BOOL) animated {
	[super viewWillAppear: animated];
}

- (void)cancelButtonHandler:(id)sender {
  [self.navigationController popViewControllerAnimated: YES];
} 

/**
 * \brief Handle 'done' button on keyboard by saving entered text and exiting.
 */
- (BOOL)textFieldShouldReturn:(UITextField*) field {
	NSString *content = [textField text];
  [delegate textInputView: self
       withUserData: self.userData
       updatedText: content];
  [self.navigationController popViewControllerAnimated: YES];
  return NO;
}

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { 
    static NSString *CellIdentifier = @"textFieldInputCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell.contentView addSubview: self.textField];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect frameRect = CGRectMake(10, 
        0, 660, 44);
        [textField setFrame: frameRect];
        [self.textField becomeFirstResponder];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
  return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger) section {
	return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[textField release];
	[super dealloc];
}

@end
