//
//  MCPlayer.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCPlayer.h"
/*
public boolean handleLavaMovement()
{
 return worldObj.isMaterialInBB(boundingBox.expand(-0.10000000149011612D, -0.40000000596046448D, -0.10000000149011612D), Material.lava);
 return worldObj.isMaterialInBB(boundingBox.expand(-0.10000000149011612D, -0.40000000596046448D, -0.10000000149011612D), Material.water);
}

*/
/*
 @property(assign) BOOL crouched;
 @property(assign) BOOL sprinting;
 - (double)stance;
 - (double)speedPerTick;
*/
/*
 Every tick, most living entities (players, non-flying mobs) have their vertical speed decreased by 0.08 (blocks per tick), then multiplied by 0.98
 */

@implementation MCPlayer
@synthesize crouched, sprinting, flying;
- (double)stance
{
    return [self y] + (crouched ? 1.5399f : 1.6200f);
}
- (void)moveWithYaw:(double)yaw andPitch:(double)pitch
{
    return;
}
- (BOOL)isOnWater
{
    return NO;
}
- (BOOL)isOnLava
{
    return NO;
}
- (BOOL)isOnLadder
{
    return NO;
}
- (BOOL)isFalling
{
    return NO;
}
- (BOOL)onGround
{
    return onGround;
}
@end
