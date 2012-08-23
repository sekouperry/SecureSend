//
//  ContainerDetailViewController.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Crypto.h"
#import "ContainerDetailViewController.h"
#import "SecureContainer.h"
#import "SourceSelectionViewController.h"
#import "AppDelegate.h"
#import "FilePathFactory.h"
#import "NameCell.h"
#import "ZipArchive.h"
#import "CertificateXplorerViewController.h"
#import "LoadingView.h"
#import "PreviewViewController.h"
#import "RootViewController.h"

@interface ContainerDetailViewController() {
@private
    NSInteger rowAddFile;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation ContainerDetailViewController

#define SECTION_NAME 0
#define SECTION_ACTION 2
#define SECTION_FILES 1
#define NUMBER_ROWS_INFOS 1
#define NUMBER_SECTIONS 3
#define NUMBER_ROWS_ACTION 1
#define ROW_SEND_CONTAINER 0
#define ROW_NAME 0

#define SEGUE_TO_SOURCESEL @"toSourceSelectionViewController"
#define SEGUE_TO_XPLORER @"toCertificateXplorer"
#define SEGUE_TO_PREVIEW @"toPreviewImageScreen"
#define SEGUE_TO_SOURCESELVIEW @"toSourceSelectionView"
#define SEGUE_TO_ENCRYPT @"toEncryptAndSend"

@synthesize container, currentCertificate = _currentCertificate;
@synthesize popoverController=_myPopoverController;
@synthesize photos = _photos;
@synthesize shouldRotateToPortrait = _shouldRotateToPortrait;



- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linenbg.png"]];
//    CGRect background_frame = self.tableView.frame;
//    background_frame.origin.x = 0;
//    background_frame.origin.y = 0;
//    background.frame = background_frame;
//    background.contentMode = UIViewContentModeTop;
//    self.tableView.backgroundView = background;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
    
    
    
    //right buttons
    
    
    UIToolbar *tools = [[UIToolbar alloc]
                        initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 44.01f)]; // 44.01 shifts it up 1px for some reason
    tools.clearsContextBeforeDrawing = NO;
    tools.clipsToBounds = NO;
    tools.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f]; // closest I could get by eye to black, translucent style.
    // anyone know how to get it perfect?
    tools.barStyle = -1; // clear background
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    // Create a standard refresh button.
    UIBarButtonItem *bi = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(exportContainer)];
    [buttons addObject:bi];
    
    // Create a spacer.
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bi.width = 10.0f;
    [buttons addObject:bi];
    
    // Add profile button.
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFile)];
    bi.style = UIBarButtonItemStyleBordered;
    [buttons addObject:bi];
    
    // Add buttons to toolbar and toolbar to nav bar.
    [tools setItems:buttons animated:NO];
    UIBarButtonItem *twoButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];
    self.navigationItem.rightBarButtonItem = twoButtons;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    if (self.container.fileUrls.count == 0) {
        [self showHelpView];
    }
    else {
        [self removeHelpView];
    }
    

    
//    [self showTabBar:self.tabBarController];
}


// help view begin
- (void)showHelpView {
    if ([self.view viewWithTag:200] == nil) {
        UIImage *image = [UIImage imageNamed:@"filehelp"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 200;
        
        [self.view addSubview:imageView];
    }
}

- (void)removeHelpView {
    UIView *view = [self.view viewWithTag:200];
    if (view != nil) {
        view.hidden = YES;
        [self.view bringSubviewToFront:view];
        [view removeFromSuperview];
        [self.view setNeedsLayout];
        [self.view setNeedsDisplay];
    }
}
//end of help view



- (void)exportContainer
{
    [self performSegueWithIdentifier:SEGUE_TO_XPLORER sender:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.container.fileUrls count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    if(indexPath.section == 0)
    {
        //get path of file
        NSString* path = [container.fileUrls objectAtIndex:indexPath.row];
        cell.textLabel.text = [path lastPathComponent];
        
        //test
        NSError *error;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        NSLog(@"attributes: %@", attributes);
        
        if (error)
        {
            NSLog(@"Error occured by receiving file attributes");
        }
        
        //date created
        NSDate *dateCreated = [attributes objectForKey:NSFileCreationDate]; //vs. NSFileModificationDate
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        //NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
        NSString *formattedDateString = [dateFormatter stringFromDate:dateCreated];
        //NSLog(@"formattedDateString for locale %@: %@", [[dateFormatter locale] localeIdentifier], formattedDateString);
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
        
        //check extensions
        if([[path pathExtension] isEqualToString:EXTENSION_JPG] 
           || [[path pathExtension] isEqualToString:EXTENSION_JPEG]
           || [[path pathExtension] isEqualToString:EXTENSION_GIF]
           || [[path pathExtension] isEqualToString:EXTENSION_PNG]
           || [[path pathExtension] isEqualToString:EXTENSION_PDF])
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else 
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            }
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    //teeeeest! debug
    self.shouldRotateToPortrait = YES;
    
    NSString* path = [self.container.fileUrls objectAtIndex:indexPath.row];
    
    
    //test
    NSString *pathExtension = [path pathExtension];
    
    if ([pathExtension isEqualToString:EXTENSION_JPG] 
        || [pathExtension isEqualToString:EXTENSION_JPEG]
        || [pathExtension isEqualToString:EXTENSION_PNG]
        || [pathExtension isEqualToString:EXTENSION_GIF])
    {
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        MWPhoto *photo;
        
        photo = [MWPhoto photoWithFilePath:path];
        [photos addObject:photo];
        self.photos = photos;
        
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = NO;
        
        [self.navigationController pushViewController:browser animated:YES];
    }
    else if ([pathExtension isEqualToString:EXTENSION_PDF])
    {
        [self performSegueWithIdentifier:SEGUE_TO_PREVIEW sender:path];
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//test
#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if(indexPath.section == 0 && indexPath.row != rowAddFile)
        return YES;
    
    //return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError * error;
    if([[NSFileManager defaultManager] removeItemAtPath:[self.container.fileUrls objectAtIndex:indexPath.row] error:&error] == NO)
    {
        NSLog(@"Problem deleting file");
        
        //TODO error description
    }
    
    [self.container.fileUrls removeObjectAtIndex:indexPath.row];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
    if (self.container.fileUrls.count == 0) {
        [self showHelpView];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - ModifyContainerPropertyDelegate methods

-(void) addFilesToContainer:(NSArray*) filePaths
{
    [self.container.fileUrls addObjectsFromArray:filePaths];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_FILES] withRowAnimation:UITableViewRowAnimationRight];
    //todo! didn't work after refactoring of iPad UI
    
    if (self.container.fileUrls.count > 0) {
        [self removeHelpView];
    }
    
    [self.tableView reloadData]; 
}

-(void)addFile
{
    [self performSegueWithIdentifier:SEGUE_TO_SOURCESEL sender:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //TODO cover errors
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ModifyCertPropertyDelegate methods

-(void) setCert: (NSData*) cert
{
    self.currentCertificate = cert;
    
    [self dismissModalViewControllerAnimated:YES];
    
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose action", @"Title for alert in container detail view") delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Share via Dropbox",  @"Alert button in container detail view to share container using Dropbox"), 
                             NSLocalizedString(@"Send Container via Email", @"Button in alter view in container detail view for sending a container via email"), nil];
    
//    [action showInView:self.view];
    [action showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - methods for sharing container

-(void) sendContainerMail: (NSData*) data
{
    
    //creating and initialising mail composer
    MFMailComposeViewController* mailcontroller = [[MFMailComposeViewController alloc] init];
    [mailcontroller setSubject:NSLocalizedString(@"Container", @"Subject for mail when sending an encrypted container in container detail view")];
    [mailcontroller setTitle:NSLocalizedString(@"Secure files via container", @"Title for mail when sending an encrypted container in container detail view")];
    mailcontroller.mailComposeDelegate = self;
    
    
    //attaching encrypted file to mail
    NSString* filename = [self.container.name stringByAppendingPathExtension:@"iaikcontainer"];
    
    [mailcontroller addAttachmentData:data mimeType:@"application/iaikencryption" fileName:filename];
    
    [self presentModalViewController:mailcontroller animated:YES];
}


#pragma mark - methods for encrypting/zipping containers

-(NSData*) zipAndEncryptContainer
{
    //Creating zipper for compressing data
    ZipArchive* zipper = [[ZipArchive alloc] init];
    
    NSString* zippath = [FilePathFactory getTemporaryZipPath];
    
    //creating zip-file at documents-directory
    bool success = [zipper CreateZipFile2:zippath];
    
    if(success == NO)
    {
        NSLog(@"Could not create zip-file!!");
    }
    
    BOOL goodfolder = [zipper addFileToZip:self.container.basePath newname:[[self.container.basePath lastPathComponent] stringByAppendingPathExtension:DIRECTORY_EXTENSION]];
    
    if(goodfolder == NO)
    {
        NSLog(@"Could not add folder to zip!!");
    }
    
    
    //adding files of container to zip
    for(NSString* path in self.container.fileUrls)
    {
        BOOL good = [zipper addFileToZip:path newname:[path lastPathComponent]];
        if(good == NO)
        {
            NSLog(@"Could not add file to zip!!");
        }
    }
    
    //closing zip
    [zipper CloseZipFile2];
    
    //getting zipped data
    NSData* zippeddata = [NSData dataWithContentsOfFile:zippath];
    
    //deleting zip-file
    if([[NSFileManager defaultManager] 	fileExistsAtPath:[FilePathFactory getTemporaryZipPath]])
    {
        
        NSError* removeerror;
        bool really = [[NSFileManager defaultManager] removeItemAtPath:zippath error:&removeerror];
        
        if(really == NO)
        {
            NSLog(@"Error deleting zip-file %@",[removeerror userInfo]);
        }
    }
    
    NSArray* contents_after = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FilePathFactory applicationDocumentsDirectory] error:nil];
    
    NSLog(@"currrent contents after deletion of zip-file: %@",contents_after.description);
    
    NSData* encryptedContainer = [[Crypto getInstance] encryptBinaryFile:zippeddata withCertificate:self.currentCertificate];
    
    return encryptedContainer;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    self.currentCertificate = nil;
    
    //[actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 1) { //not so pretty...
        return;
    }
    
    self.tableView.userInteractionEnabled = NO;
    self.navigationController.view.userInteractionEnabled = NO;
    self.tabBarController.view.userInteractionEnabled = NO;
    
    UIView *load = [LoadingView showLoadingViewInView:self.view.window withMessage:@"Encrypting Container"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* encryptedcontainer = [self zipAndEncryptContainer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [load removeFromSuperview];
            self.tableView.userInteractionEnabled = YES;
            self.navigationController.view.userInteractionEnabled = YES;
            self.tabBarController.view.userInteractionEnabled = YES;
            
            switch (buttonIndex) {
                case 0:
                {   //todo just for debug purposes
                    //[[DBSession sharedSession] unlinkAll];
                    
                    UITabBarController *tabBar = self.tabBarController;
                    UINavigationController* navi = (UINavigationController*)[tabBar.viewControllers objectAtIndex:0];
                    RootViewController* root = (RootViewController*)[navi.viewControllers objectAtIndex:0];
                    
                    if (![[DBSession sharedSession] isLinked])
                    {
                        [[DBSession sharedSession] linkFromController:root];
                        
                    }
                    else
                    {
                        [root uploadFileToDropbox:encryptedcontainer withName:self.container.name];
                            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Dropbox"
                                                                              message:@"Uploading can take several minutes based on the container size. The App will notify you when it is finished."
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                            
                            [message show];
                    }
                    break;
                }
                case 1: //change this to 1 if dropbox action is also visible
                {
                    if([MFMailComposeViewController canSendMail])
                    {
                        [self sendContainerMail:encryptedcontainer];
                    }
                    else 
                    {
                        NSLog(@"cannot send mail");    
                    }
                    break;
                }
                default:
                    break;
            }

            
        }); 
    });
    
    
    
   }

#pragma mark - segue control methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_SOURCESEL])
    {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        SourceSelectionViewController* src = (SourceSelectionViewController*)[nav.viewControllers objectAtIndex:0];//(SourceSelectionViewController*) segue.destinationViewController;
        src.basePath = self.container.basePath;
        src.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_XPLORER])
    {
        UINavigationController* navi = (UINavigationController*) segue.destinationViewController;
        
        CertificateXplorerViewController* xplorer = [navi.viewControllers objectAtIndex:0];
        
        xplorer.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_PREVIEW])
    {
        PreviewViewController* prev = (PreviewViewController*) segue.destinationViewController;
        NSString* path = (NSString*) sender;
        prev.path = path;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_SOURCESELVIEW])
    {
        SourceSelectionViewController *destination = (SourceSelectionViewController*)segue.destinationViewController;
        destination.basePath = self.container.basePath;
        destination.delegate = self;
        
        UIStoryboardPopoverSegue* popSegue = (UIStoryboardPopoverSegue*)segue;        
        self.popoverController = popSegue.popoverController;
    }
}

-(void) dealloc
{

}

@end
