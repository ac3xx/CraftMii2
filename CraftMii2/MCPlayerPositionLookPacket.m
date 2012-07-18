//
//  MCPlayerPositionLookPacket.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 28/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCPlayerPositionLookPacket.h"
#import "MCBuffer.h"
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
    uint64_t xf = 0;
    uint64_t* xpt = &xf;
    uint32_t yf = 0;
    uint32_t* ypt = &yf;
    xf=OSSwapInt64(*(uint64_t*)&x);
    [[socket outputBuffer] write:((uint8_t*)((const void*)((const uint64_t*)xpt))) length:8];
    xf=OSSwapInt64(*(uint64_t*)&y);
    [[socket outputBuffer] write:((uint8_t*)((const void*)((const uint64_t*)xpt))) length:8];
    xf=OSSwapInt64(*(uint64_t*)&stance);
    [[socket outputBuffer] write:((uint8_t*)((const void*)((const uint64_t*)xpt))) length:8];
    xf=OSSwapInt64(*(uint64_t*)&z);
    [[socket outputBuffer] write:((uint8_t*)((const void*)((const uint64_t*)xpt))) length:8];
    yf=OSSwapInt32(*(uint32_t*)&yaw);
    [[socket outputBuffer] write:((uint8_t*)((const void*)((const uint32_t*)ypt))) length:4];
    yf=OSSwapInt32(*(uint32_t*)&pitch);
    [[socket outputBuffer] write:((uint8_t*)((const void*)((const uint32_t*)ypt))) length:4];
    [[socket outputBuffer] writeByte:(uint8_t)onGround];
}
-(void)dealloc
{
    [super dealloc];
}
@end
