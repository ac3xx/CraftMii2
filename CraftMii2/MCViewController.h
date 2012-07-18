//
//  MCViewController.h
//  CraftMii2
//
//  Created by qwertyoruiop on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "MCSocket.h"

@interface MCViewController : GLKViewController <MCSocketDelegate>
{
    MCSocket* socket;
    BOOL canSendPackets;
    int tickCount;
    int add;
    UIProgressView* expview;
    UILabel* levelview;
    UIAlertView* respawnAlert;
    UIProgressView* lifeview;
    UIProgressView* foodview;
    UIProgressView* satview_;
}
@property(retain)MCSocket* socket;

@end
