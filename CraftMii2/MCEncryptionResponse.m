//
//  MCEncryptionResponse.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 07/05/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCEncryptionResponse.h"
#import "MCBuffer.h"
#import "MCSocket.h"
@implementation MCEncryptionResponse
@synthesize data;
+(MCEncryptionResponse*)packetWithInfo:(NSDictionary *)infoDict
{
    NSData* dt = [infoDict objectForKey:@"Data"];
    if (!dt) return nil;
    MCEncryptionResponse* ret = [MCEncryptionResponse new];
    [ret setData:dt];
    return [ret autorelease];
}
-(void)sendToSocket:(MCSocket *)socket
{
    [[socket outputBuffer] writeByte:0xFC];
    short ln = OSSwapInt16([data length]);
    [[socket outputBuffer] write:(uint8_t*)&ln length:2];
    [[socket outputBuffer] write:(uint8_t*)[data bytes] length:[data length]];
}
@end
