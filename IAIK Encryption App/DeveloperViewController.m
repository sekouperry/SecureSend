//
//  DeveloperViewController.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 21.08.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/ABAddressBook.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DeveloperViewController.h"
#import "TestFlight.h"
#import "KeyChainStore.h"
#import "AppDelegate.h"
#import "UserCertificate.h"
#import "UserIdentity.h"
#import "UserPrivateKey.h"

@interface DeveloperViewController ()

@property (nonatomic, strong) NSMutableDictionary *keychainItemData;

@end

@implementation DeveloperViewController

@synthesize keychainItemData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)resetUserDefaults:(UIButton *)sender {    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"prevStartupVersions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)openFeedback:(UIButton *)sender {
    [TestFlight openFeedbackView];
}

- (IBAction)deleteAllCertificates:(UIButton *)sender {
    ABAddressBookRef addressbookref = ABAddressBookCreate();
    NSArray *allpeople = (__bridge NSArray*) ABAddressBookCopyArrayOfAllPeople(addressbookref);
        
    //deleting all certificates of all recipients
    for (int i = 0; i < allpeople.count; i++) {
        ABRecordRef ref = (__bridge_retained ABRecordRef)[allpeople objectAtIndex:i];
        NSString *identifier = [NSString stringWithFormat:@"%d", ABRecordGetRecordID(ref)];
        
        [KeyChainStore removeItemForKey:identifier type:kDataTypeCertificate];
    }
    
    //deleting user certificates
    //fetching entries from core data
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UserCertificate"];
    NSSortDescriptor *sortById = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortById, nil];
    [request setSortDescriptors:sortDescriptors];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSArray *result = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error %@", [error localizedDescription]);
        abort();
    }
    
    
    for (UserCertificate *certificate in result) {
        UserIdentity *identity = certificate.ref_identity;
        UserPrivateKey *privateKey = identity.ref_private_key;
        
        //removing items out of the keychain
        [KeyChainStore removeItemForKey:certificate.accessKey type:kDataTypeCertificate];
        [KeyChainStore removeItemForKey:privateKey.accessKey type:kDataTypePrivateKey];
    }
    
    
    //deleting coredata db
    NSPersistentStore *store = [appDelegate.persistentStoreCoordinator.persistentStores objectAtIndex:0];
    NSURL *storeURL = store.URL;
    NSPersistentStoreCoordinator *storeCoordinator = appDelegate.persistentStoreCoordinator;
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
}

- (IBAction)resetkeychainButton:(UIButton *)sender {
    
    //NSString *key = @"3";
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:(__bridge id)kSecClassCertificate forKey:(__bridge id)(kSecClass)];
    [query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef) query);
    
    NSLog(@"status: %ld", status);

    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    NSLog(@"error: %@", [error localizedDescription]);
}

- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)unlinkButtonClicked:(UIButton *)sender {
    
    [[DBSession sharedSession] unlinkAll];
}

@end
