//
//  MCLoginView.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 28/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCLoginView.h"
#import "MCAppDelegate.h"
#import "MBProgressHUD.h"
#import "MCSocket.h"
#import "MCAuth.h"
#import "MCPacket.h"
#import "MCPlayerPositionLookPacket.h"
#import "MCViewController.h"
#import "MCLoginView4iPadViewController.h"

@implementation MCLoginView
@synthesize masterController;
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
    self.navigationItem.title = @"Welcome to CraftMii!";
    self.navigationItem.prompt = @"Enter server and login info below to play";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)] autorelease];
    }
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(login:)] autorelease];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)add:(id)sender
{
    if (([server text] && ![[server text] isEqualToString:@""]) && ([user text] && ![[user text] isEqualToString:@""])) {
        [[self masterController] addServer:[NSArray arrayWithObjects:[server text], [user text], [pass text], nil]];
        /*[server setText:@""];
        [pass setText:@""];
        [user setText:@""];*/
    } else {
        [[self navigationItem] setPrompt:@"Please enter at least a server and an username"];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)selectedServer:(NSArray*)servers
{
    switch ([servers count]) {
        case 3:
            [pass setText:[servers objectAtIndex:2]];
        case 2:
            [user setText:[servers objectAtIndex:1]];
        case 1:
            [server setText:[servers objectAtIndex:0]];
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    server = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    server.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    server.keyboardAppearance = UIKeyboardAppearanceAlert;
    server.returnKeyType = UIReturnKeyNext;
    server.autocorrectionType = UITextAutocorrectionTypeNo;
    server.autocapitalizationType = UITextAutocapitalizationTypeNone;
    server.keyboardType = UIKeyboardTypeURL;
    server.delegate = self;
    server.clearButtonMode = UITextFieldViewModeWhileEditing;
    //server.text = @"176.31.64.248";
    [server becomeFirstResponder];
    server.tag=1;
    user = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    user.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    user.keyboardAppearance = UIKeyboardAppearanceAlert;
    user.returnKeyType = UIReturnKeyNext;
    user.autocorrectionType = UITextAutocorrectionTypeNo;
    user.autocapitalizationType = UITextAutocapitalizationTypeNone;
    user.tag=2;
    user.delegate = self;
    //user.text = @"Test";
    pass = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    pass.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    pass.keyboardAppearance = UIKeyboardAppearanceAlert;
    pass.returnKeyType = UIReturnKeyGo;
    pass.autocorrectionType = UITextAutocorrectionTypeNo;
    pass.autocapitalizationType = UITextAutocapitalizationTypeNone;
    pass.tag=3;
    pass.secureTextEntry = YES;
    pass.delegate = self;
    [self selectedServer:[[NSUserDefaults standardUserDefaults] objectForKey:@"iPhoneCachedInfos"]];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section ? 2 : 1;
}

- (void)login:(id)sender
{
    [user resignFirstResponder];
    [pass resignFirstResponder];
    [server resignFirstResponder];
    HUD = [[MBProgressHUD alloc] initWithView:[[[UIApplication sharedApplication] delegate] window]];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = (id<MBProgressHUDDelegate>) self;
    HUD.labelText = @"Logging In..";
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[server text], [user text], [pass text], nil] forKey:@"iPhoneCachedInfos"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Show the HUD while the provided method executes in a new thread
    [HUD show:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self performSelectorInBackground:@selector(doLogin:) withObject:nil];
}

- (void)metadata:(MCMetadata *)metadata hasFinishedParsing:(NSArray *)infoArray
{
    [game metadata:metadata hasFinishedParsing:infoArray];
}

- (void)slot:(MCSlot *)slot hasFinishedParsing:(NSDictionary *)infoDict
{
    [game slot:slot hasFinishedParsing:infoDict];
}

- (void)packet:(MCPacket*)packet gotParsed:(NSDictionary *)infoDict
{
    [game packet:packet gotParsed:infoDict];
    if ([packet identifier] == 0x02) {
        if ([infoDict objectForKey:@"ErrorCode"])
            self.navigationItem.prompt = [infoDict objectForKey:@"ErrorCode"];
        else
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                game = [[[MCViewController alloc] initWithNibName:@"MCViewController_iPhone" bundle:nil] autorelease];
            } else {
                game = [[[MCViewController alloc] initWithNibName:@"MCViewController_iPad" bundle:nil] autorelease];
            }
            [game setSocket:sock];
            [[self navigationController] pushViewController:game animated:YES];
        }
        [HUD hide:YES];
    }
    if ([packet identifier] == 0xFF) {
        [HUD hide:YES];
        UIColor* color = nil;
        self.navigationItem.prompt=@"";
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSArray* txt = [infoDict objectForKey:@"Message"];
        for (NSArray* message in txt) {
            for (NSString* tx in message) {
                if (!color) {
                    color=(UIColor*)tx;
                    continue;
                }
                self.navigationItem.prompt=[self.navigationItem.prompt stringByAppendingFormat:@"%@", tx];
                color = nil;
            }
            
        }
        [[self navigationController] popToViewController:self animated:YES];
        game = nil;
        [server becomeFirstResponder];
        NSLog(@"D/C'd :(");
    }
}

- (void)socketDidTick:(MCSocket*)socket
{
    [game socketDidTick:socket];
}

- (void)doLogin:(NSArray* )infos
{
    auth = [MCAuth authWithUsername:[user text] andPassword:[pass text]];
    [auth login];
    sock = [[MCSocket alloc] initWithServer:[server text] andAuth:auth];
    [sock setDelegate:self];
    [sock performSelectorOnMainThread:@selector(connect:) withObject:[NSNull null] waitUntilDone:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField* view = (UITextField*)[[self tableView] viewWithTag:[textField tag]+1];
    [view becomeFirstResponder];
    if (!view) {
        [self login:nil];
    }
    [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([textField tag] == 2||[textField tag]==1) ? 0 : 1 inSection:([textField tag]!=1) ? 1 : 0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch (indexPath.section) {
            case 1:
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text=@"Username";
                        cell.accessoryView = user;
                        break;
                    case 1:
                        cell.textLabel.text=@"Password";
                        cell.accessoryView = pass;
                        break;
                    default:
                        break;
                }
                break;
            case 0: 
                cell.textLabel.text=@"Server";
                cell.accessoryView = server;
                break;
            default:
                break;
        }
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[[self tableView:tableView cellForRowAtIndexPath:indexPath] accessoryView] becomeFirstResponder];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
