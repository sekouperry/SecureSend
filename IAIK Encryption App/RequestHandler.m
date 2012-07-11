//
//  RequestHandler.m
//  IAIK Encryption App
//
//  Created by Christof Stromberger on 11.07.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "RequestHandler.h"
#import "RootViewController.h"

@implementation RequestHandler

@synthesize request = _request;
@synthesize delegate = _delegate;

- (void)requestReceived
{
    
    //showing alert to enter code, setting rootviewcontroller as delegate
    NSString *title = @"You have received a Certificate-Request from another user. This app will guide you through the certificate exchange process.\n\n"
    @"First it opens the Mail composer for you. After that it opens the Message composer.\n\n"
    @"You must only click 'send' in the composers.";
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.delegate = self;
    [alert show];
}


#pragma mark - UIAlertViewDelegateMethods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != 0)
    {
        //[self.delegate performSelectorOnMainThread:@selector(manageCertificateRequest:) withObject:self.request waitUntilDone:NO];
        [(RootViewController*)self.delegate manageCertificateRequest:self.request];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    
}


@end