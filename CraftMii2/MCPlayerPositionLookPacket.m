//
//  MCPlayerPositionLookPacket.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 28/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCPlayerPositionLookPacket.h"
#import "MCBuffer.h"
typedef union MCType32
{
float f;
int i;
} MCType32;

typedef union MCType64
{
double d;
long long l;
} MCType64;
/*
 [NSNumber numberWithDouble:*(double*)x], @"X",
 [NSNumber numberWithDouble:*(double*)stance], @"Stance",
 [NSNumber numberWithDouble:*(double*)y], @"Y",
 [NSNumber numberWithDouble:*(double*)z], @"Z",
 [NSNumber numberWithFloat:*(float*)yaw], @"Yaw",
 [NSNumber numberWithFloat:*(float*)pitch], @"Pitch",
 [NSNumber numberWithBool:(*(BOOL*)(data+41))], @"On Ground",
*/
// TOO MANY TYPECASTS, LOL
@implementation MCPlayerPositionLookPacket
@synthesize x, stance, y, z, yaw, pitch, onGround;
+(MCPlayerPositionLookPacket*)packetWithInfo:(NSDictionary *)infoDict
{
    MCPlayerPositionLookPacket* ret = [MCPlayerPositionLookPacket new];
    [ret setX:([[infoDict objectForKey:@"X"] doubleValue])];
    [ret setY:([[infoDict objectForKey:@"Y"] doubleValue])];
    [ret setStance:([[infoDict objectForKey:@"Stance"] doubleValue])];
    [ret setZ:([[infoDict objectForKey:@"Z"] doubleValue])];
    [ret setYaw:([[infoDict objectForKey:@"Yaw"] floatValue])];
    [ret setPitch:([[infoDict objectForKey:@"Pitch"] floatValue])];
    [ret setOnGround:[[infoDict objectForKey:@"On Ground"] boolValue]];
    return [ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    [[socket outputBuffer] writeByte:(uint8_t)0x0D];
    MCType32 a;
    MCType64 b;
    b.d = x;
    b.l = OSSwapInt64(b.l);
    [[socket outputBuffer] write:(uint_fast8_t*)&(b.l) length:8];
    b.d = y;
    b.l = OSSwapInt64(b.l);
    [[socket outputBuffer] write:(uint_fast8_t*)&(b.l) length:8];
    b.d = stance;
    b.l = OSSwapInt64(b.l);
    [[socket outputBuffer] write:(uint_fast8_t*)&(b.l) length:8];
    b.d = z;
    b.l = OSSwapInt64(b.l);
    [[socket outputBuffer] write:(uint_fast8_t*)&(b.l) length:8];
    a.f = yaw;
    a.i = OSSwapInt32(a.i);
    [[socket outputBuffer] write:(uint_fast8_t*)&(a.i) length:4];
    a.f = pitch;
    a.i = OSSwapInt32(a.i);
    [[socket outputBuffer] write:(uint_fast8_t*)&(a.i) length:4];
    [[socket outputBuffer] writeByte:(uint8_t)onGround];
}
-(void)dealloc
{
    [super dealloc];
}
@end
