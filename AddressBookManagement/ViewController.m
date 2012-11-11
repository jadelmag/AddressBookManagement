//
//  ViewController.m
//  AddressBookManagement
//
//  Created by Javier Delgado on 11/11/12.
//  Copyright (c) 2012 Javier Delgado. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *firstNames;
@property (nonatomic, strong) NSArray *lastNames;

@end

@implementation ViewController

#pragma mark -
#pragma mark lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,&error);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef err) {
        // callback can occur in background, address book must be accessed on thread it was created on
        dispatch_async(dispatch_get_main_queue(), ^{
            if (err) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:(__bridge NSString *)(err) delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
            } else if (!granted) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No permissions granted" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
            } else {
                // access granted
                bool wantToSaveChanges = YES;
                bool didSave;
                CFErrorRef error2 = NULL;
                if (ABAddressBookHasUnsavedChanges(addressBook)) {
                    if (wantToSaveChanges) {
                        didSave = ABAddressBookSave(addressBook, &error2);
                        if (!didSave)
                        {
                            //Handle error here.
                            [[[UIAlertView alloc] initWithTitle:@"" message:@"AddressBook not Changed" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
                        }
                    } else {
                        ABAddressBookRevert(addressBook);
                    }
                }
            }
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextField Protocol

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [_txtFieldNumberContacts resignFirstResponder];
    }
}

#pragma mark -
#pragma mark IBAction

- (IBAction)generateContacts:(id)sender
{
    if ([_txtFieldNumberContacts.text isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Number of contacts are empty" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
    }
    else
    {
        if ([self isABAddressBookCreateWithOptionsAvailable])
        {
            CFErrorRef error = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,&error);
            [self newContactWithAddressBook:addressBook];
        }
    }
}

- (IBAction)removeContacts:(id)sender
{
    if ([self isABAddressBookCreateWithOptionsAvailable])
    {
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,&error);
        [self remove:addressBook];
        CFRelease(addressBook);
    }
}

#pragma mark -
#pragma mark AddresBook

-(BOOL)isABAddressBookCreateWithOptionsAvailable
{
    return &ABAddressBookCreateWithOptions != NULL;
}

- (BOOL)existsInAddressBook:(ABRecordRef)personCreated inAddressBook:(ABAddressBookRef)addressBook
{
    NSArray *contactArr = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    for (int i = 0; i < [contactArr count]; i++)
    {
        ABRecordRef person = (__bridge ABRecordRef)[contactArr objectAtIndex:i];
        
        NSString *name = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        NSString *name2 = (__bridge NSString *)(ABRecordCopyValue(personCreated, kABPersonFirstNameProperty));
        NSString *lastName2 = (__bridge NSString *)(ABRecordCopyValue(personCreated, kABPersonLastNameProperty));
        
        if ([name isEqualToString:name2] && [lastName isEqualToString:lastName2])
        {
            CFRelease((__bridge CFTypeRef)(name));
            CFRelease((__bridge CFTypeRef)(name2));
            CFRelease((__bridge CFTypeRef)(lastName));
            CFRelease((__bridge CFTypeRef)(lastName2));
            CFRelease((__bridge CFTypeRef)(contactArr));
            return YES;
        }
        else
        {
            CFRelease((__bridge CFTypeRef)(name));
            CFRelease((__bridge CFTypeRef)(name2));
            CFRelease((__bridge CFTypeRef)(lastName));
            CFRelease((__bridge CFTypeRef)(lastName2));
        }
    }
    CFRelease((__bridge CFTypeRef)(contactArr));
    return NO;
}

- (void)newContactWithAddressBook:(ABAddressBookRef)addressbook
{
    for (int i=0;i<[_txtFieldNumberContacts.text intValue];i++)
    {
        // Creating new entry
        ABRecordRef person = ABPersonCreate();
        
        // Setting basic properties
        ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)([self.firstNames objectAtIndex:(arc4random() % self.firstNames.count)]) , nil);
        ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)([self.lastNames objectAtIndex:(arc4random() % self.lastNames.count)]), nil);
        ABRecordSetValue(person, kABPersonJobTitleProperty, @"Desarrollador", nil);
        ABRecordSetValue(person, kABPersonDepartmentProperty, @"Departamento iPhone", nil);
        ABRecordSetValue(person, kABPersonOrganizationProperty, @"Sociedad Limitada", nil);
        ABRecordSetValue(person, kABPersonNoteProperty, @"iOS and android Development", nil);
        
        NSString *sCellphone1 = [NSString stringWithFormat:@"015-%d%d%d%d-%d%d%d%d",arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10];
        NSString *sCellphone2 = [NSString stringWithFormat:@"015-%d%d%d%d-%d%d%d%d",arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10];
        NSString *sCellphone3 = [NSString stringWithFormat:@"015-%d%d%d%d-%d%d%d%d",arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10,arc4random() % 10];
        
        // Adding phone numbers
        ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(sCellphone1), (CFStringRef)@"iPhone", NULL);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(sCellphone2), (CFStringRef)@"Trabajo", NULL);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(sCellphone3), (CFStringRef)@"Movil", NULL);
        ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
        CFRelease(phoneNumberMultiValue);
        
        // Adding image
        UIImage *imageUser = [UIImage imageNamed:@"contacto.png"];
        NSData *data = [NSData dataWithData:UIImagePNGRepresentation(imageUser)];
        ABPersonSetImageData(person, (__bridge CFDataRef)data, nil);
        
        // Adding url
        ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(urlMultiValue, @"http://www.ekembi.com", kABPersonHomePageLabel, NULL);
        ABRecordSetValue(person, kABPersonURLProperty, urlMultiValue, nil);
        CFRelease(urlMultiValue);
        
        // Adding emails
        ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMultiValue, @"info@ekembi.com", (CFStringRef)@"Global", NULL);
        ABMultiValueAddValueAndLabel(emailMultiValue, @"contact@ekembi.com", (CFStringRef)@"Trabajo", NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, nil);
        CFRelease(emailMultiValue);
        
        // Adding address
        ABMutableMultiValueRef addressMultipleValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
        NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
        [addressDictionary setObject:@"Camino de vera" forKey:(NSString *)kABPersonAddressStreetKey];
        [addressDictionary setObject:@"Valencia" forKey:(NSString *)kABPersonAddressCityKey];
        [addressDictionary setObject:@"46022" forKey:(NSString *)kABPersonAddressZIPKey];
        [addressDictionary setObject:@"España" forKey:(NSString *)kABPersonAddressCountryKey];
        [addressDictionary setObject:@"ES" forKey:(NSString *)kABPersonAddressCountryCodeKey];
        ABMultiValueAddValueAndLabel(addressMultipleValue, (__bridge CFTypeRef)(addressDictionary), kABHomeLabel, NULL);
        
        ABRecordSetValue(person, kABPersonAddressProperty, addressMultipleValue, nil);
        CFRelease(addressMultipleValue);
        
        if ([self existsInAddressBook:person inAddressBook:addressbook])
        {
            i--;
            CFRelease(person);
        }
        else
        {
            // Adding person to the address book
            ABAddressBookAddRecord(addressbook, person, nil);
            ABAddressBookSave(addressbook, nil);
            CFRelease(person);
            
            NSLog(@"Contacto: %d",i+1);
        }
    }
    
    CFRelease(addressbook);
    [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@ contacts added",_txtFieldNumberContacts.text] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
}

- (void)remove:(ABAddressBookRef)addressbook
{
    int numContacts = 0;
    
	NSArray *people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressbook);
	
	for (id record in people) {
		
		ABRecordRef recordRef = (__bridge_retained ABRecordRef)record;
		ABAddressBookRemoveRecord(addressbook, recordRef, NULL);
        numContacts++;
	}
	
	ABAddressBookSave(addressbook, NULL);
    
    [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%d contacts Removed",numContacts] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
}

#pragma mark -
#pragma mark Names and LastNames Generators

- (NSArray *)firstNames
{
    if (_firstNames == nil)
    {
        NSError  *sError;
        NSString *sFilePath;
        NSString *sString;
        
        sError = nil;
        
        sFilePath = [[NSBundle mainBundle] pathForResource:@"firstnames" ofType:@"txt"];
        if (sFilePath)
        {
            sString = [NSString stringWithContentsOfFile:sFilePath encoding:NSUTF8StringEncoding error:&sError];
            if (sError)
            {
                [[[UIAlertView alloc] initWithTitle:[sError localizedDescription] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
            if (sString)
            {
                [self setFirstNames:[sString componentsSeparatedByString:@"\n"]];
            }
        }
    }
    
    return _firstNames;
}

- (NSArray *)lastNames
{
    if (_lastNames == nil)
    {
        NSError  *sError;
        NSString *sFilePath;
        NSString *sString;
        
        sError = nil;
        
        sFilePath = [[NSBundle mainBundle] pathForResource:@"lastnames" ofType:@"txt"];
        if (sFilePath)
        {
            sString = [NSString stringWithContentsOfFile:sFilePath encoding:NSUTF8StringEncoding error:&sError];
            if (sError)
            {
                [[[UIAlertView alloc] initWithTitle:[sError localizedDescription] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
            if (sString)
            {
                [self setLastNames:[sString componentsSeparatedByString:@"\n"]];
            }
        }
    }
    
    return _lastNames;
}

@end
