//
//  MCLoginView4iPadViewController.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 03/05/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCLoginView;
@interface MCLoginView4iPadViewController : UITableViewController <UIActionSheetDelegate>
{
    MCLoginView* detailController;
    NSMutableArray* _objects;
}
@property(retain) MCLoginView* detailController;
- (void)addServer:(NSArray*)array;

@end
