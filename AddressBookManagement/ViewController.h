//
//  ViewController.h
//  AddressBookManagement
//
//  Created by Javier Delgado on 11/11/12.
//  Copyright (c) 2012 Javier Delgado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtFieldNumberContacts;


@end
