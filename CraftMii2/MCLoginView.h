//
//  MCLoginView.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 28/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSocketDelegate.h"
#import "MCViewController.h"
@class MBProgressHUD,MCAuth,MCSocket,MCLoginView4iPadViewController;
@interface MCLoginView : UITableViewController <UITextFieldDelegate, MCSocketDelegate>
{
    UITextField* user;
    UITextField* pass;
    UITextField* server;
    MBProgressHUD* HUD;
    MCAuth* auth;
    MCSocket* sock;
    MCViewController* game;
    MCLoginView4iPadViewController* masterController;
}
@property(retain) MCSocket* sock;
@property(retain) MCLoginView4iPadViewController* masterController;
-(void)login:(id)sender;
-(void)selectedServer:(NSArray*)server;
@end
