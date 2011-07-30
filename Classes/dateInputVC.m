//
//  dateInputVC.m
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

#import "dateInputVC.h"

@interface dateInputVC (PrivateMethods)
- (void) addCancelButton;
- (void) addDoneButton;
@end


@implementation dateInputVC

@synthesize delegate;
@synthesize userData;
@synthesize pickerView;

/**
 * \brief Initialize view controller with existing text and identifying data
 * \param initText Text to pre-fill text field with
 * \param initUserData Data passed back to delegate.  Used to ID caller.
 * \return Initialized instance
 */
-(id) initWithExistingText: (NSString*)initText withUserData: (id)initUserData {
	if (self = [super init]) {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
  	self.pickerView = [[UIDatePicker alloc] initWithFrame: screenBounds];
    self.pickerView.datePickerMode =  UIDatePickerModeDate;
    self.view = [[UIView alloc] initWithFrame: screenBounds];
		self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview: self.pickerView];
    
    if (initText && [initText length] > 0) {
      NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat: @"MM/dd/yyyy"];
      [dateFormatter setLocale: usLocale];
      NSDate *startdate = [dateFormatter dateFromString: initText];
      if (startdate)
        [self.pickerView setDate: startdate animated: NO];
		}
        
    [self addCancelButton];
    [self addDoneButton];
    
		// This is just something to pass back to the delegate.  Save it
    // and don't touch.
    self.userData = initUserData;
  }
  return self;
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
 * \brief Add a 'done' button to the navigation bar
 */
- (void)addDoneButton {
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] 
    initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
    target:self 
    action:@selector(doneButtonHandler:)] autorelease];
	self.navigationItem.rightBarButtonItem = button;
}


/**
 * \brief Handle 'cancel' click -- pop off nav controller.
 * \param sender View that sent the event (unused)
 */
- (void)cancelButtonHandler:(id)sender {
  [self.navigationController popViewControllerAnimated: YES];
} 

/**
 * \brief Handle 'cancel' click -- pop off nav controller.
 * \param sender View that sent the event (unused)
 */
- (void)doneButtonHandler:(id)sender {
  NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat: @"MM/dd/yyyy"];
  [dateFormatter setLocale: usLocale];
  
  [delegate dateInputView: self
            withUserData: self.userData
            updatedText: [dateFormatter stringFromDate: [self.pickerView date]]];

  [self.navigationController popViewControllerAnimated: YES];
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
	[super dealloc];
}

@end
