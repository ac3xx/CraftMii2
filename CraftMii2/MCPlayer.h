//
//  MCPlayer.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCEntity.h"

/*
 #define PLAYER_SPEED 4.31/20
 #define PLAYER_SPRINT_SPEED 5.55/20
 #define PLAYER_HEIGHT 1.62
 #define PLAYER_CROUCHED_HEIGHT 1.54
*/

@interface MCPlayer : MCEntity
{
    BOOL sprinting;
    BOOL crouched;
    BOOL flying;
}
@property(assign) BOOL crouched;
@property(assign) BOOL sprinting;
@property(assign) BOOL flying;
- (double)stance;
@end
