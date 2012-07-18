//
//  MCPlayerPositionLookPacket.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 28/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCSendPacket.h"
/*
 [NSNumber numberWithDouble:*(double*)x], @"X",
 [NSNumber numberWithDouble:*(double*)stance], @"Stance",
 [NSNumber numberWithDouble:*(double*)y], @"Y",
 [NSNumber numberWithDouble:*(double*)z], @"Z",
 [NSNumber numberWithFloat:*(float*)yaw], @"Yaw",
 [NSNumber numberWithFloat:*(float*)pitch], @"Pitch",
 [NSNumber numberWithBool:(*(BOOL*)(data+41))], @"On Ground",
 */

@interface MCPlayerPositionLookPacket : MCSendPacket
{
    double x;
    double stance;
    double y;
    double z;
    float yaw;
    float pitch;
    BOOL onGround;
}
@property(assign) double x;
@property(assign) double stance;
@property(assign) double y;
@property(assign) double z;
@property(assign) float yaw;
@property(assign) float pitch;
@property(assign) BOOL onGround; 
+(MCPlayerPositionLookPacket*)packetWithInfo:(NSDictionary *)infoDict;
-(void)sendToSocket:(MCSocket *)socket;
@end
