//
//  MCLoginView4iPadViewController.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 03/05/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCLoginView4iPadViewController.h"

@interface MCLoginView4iPadViewController ()

@end

@implementation MCLoginView4iPadViewController
@synthesize detailController;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        NSArray* rt = [[NSUserDefaults standardUserDefaults] objectForKey:@"Servers"];
        if (!rt) {
            rt = [NSArray array];
        }
        _objects = [rt mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[self navigationItem] setTitle:@"Server List"];
    [[self navigationItem] setPrompt:@"You can add servers clicking the + button"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_objects count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)addServer:(NSArray*)array
{
    [_objects addObject:array];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_objects count]-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[NSUserDefaults standardUserDefaults] setObject:_objects forKey:@"Servers"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[_objects objectAtIndex:indexPath.row] objectAtIndex:0];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIActionSheet* vw = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure to remove %@?", [[_objects objectAtIndex:indexPath.row] objectAtIndex:0]] delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Remove" otherButtonTitles:@"Cancel", nil] autorelease];
        [vw setTag:[indexPath row]];
        CGRect aFrame = [self.tableView rectForRowAtIndexPath:indexPath];
        [vw showFromRect:[self.tableView convertRect:aFrame toView:self.view] inView:self.view animated:YES];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [_objects removeObjectAtIndex:[actionSheet tag]];
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[actionSheet tag] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [[NSUserDefaults standardUserDefaults] setObject:_objects forKey:@"Servers"];
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
    [detailController performSelector:@selector(selectedServer:) withObject:[_objects objectAtIndex:indexPath.row]];
}

- (void)dealloc
{
    [self setDetailController:nil];
    [_objects release];
    [super dealloc];
}
@end
