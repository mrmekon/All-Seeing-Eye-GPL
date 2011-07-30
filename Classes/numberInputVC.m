//
//  numberInputVC.m
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

#import "numberInputVC.h"


@implementation numberInputVC

@synthesize textField, delegate, userData;

-(id) initWithExistingNumber: (NSString*)number withUserData: (id)initUserData {
	if (self = [super initWithStyle: UITableViewStyleGrouped]) {
    self.textField = [[UITextField alloc] initWithFrame: CGRectMake(0,0,10,10)];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.textField.placeholder = @"";
    if ([number length] > 0)
    	self.textField.text = [NSString stringWithFormat:@"%d", [number intValue]];
    self.textField.delegate = self;
    self.userData = initUserData;
    
    // Register to be alerted when keyboard displays
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                          selector:@selector(keyboardWillShow:) 
                                          name:UIKeyboardWillShowNotification 
                                          object:nil];

  }
  return self;
}

- (BOOL)textField:(UITextField *)textField 
        shouldChangeCharactersInRange:(NSRange)range 
        replacementString:(NSString *)string {
	NSLog(@"Adding string: %@", string);
  for (int i = 0; i < [string length]; i++) {
  	char ch = [string characterAtIndex: i];
  	if (ch < '0' || ch > '9')
    	return NO;
  }
  return YES;
}

- (void)keyboardWillShow: (NSNotification *) note {
}

- (void) addCancelButton {
  UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonHandler:)] autorelease];
  self.navigationItem.leftBarButtonItem = button;
}

- (void) addDoneButton {
  UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonHandler:)] autorelease];
  self.navigationItem.rightBarButtonItem = button;
}

- (void) viewDidLoad {
	[super viewDidLoad];
  [self addCancelButton];
  [self addDoneButton];
}

- (void) viewDidUnload {
	[super viewDidUnload];
}

- (void) viewWillAppear: (BOOL) animated {
	[super viewWillAppear: animated];
}

- (IBAction)cancelButtonHandler:(id)sender {
  [self.navigationController popViewControllerAnimated: YES];
} 
- (IBAction)doneButtonHandler:(id)sender {
	NSString *content = [textField text];
  [delegate numberInputView: self
            withUserData: self.userData
            updatedNumber: content];
  [self.navigationController popViewControllerAnimated: YES];
} 

// Respond to 'Done' button press.
- (BOOL)textFieldShouldReturn:(UITextField*) field {
	[self doneButtonHandler: nil];
  return YES;
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
    static NSString *CellIdentifier = @"numberInputCell";
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger) section {
	switch (section) {
  	case 0:
    	break;
    default:
    	NSLog(@"WARNING: Header for invalid section %d", section);
  }
  return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger) section {
	switch (section) {
  	case 0:
    	break;
    default:
    	NSLog(@"WARNING: Footer for invalid section %d", section);
  }
	return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
	[textField release];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
