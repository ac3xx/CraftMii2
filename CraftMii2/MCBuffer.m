//
//  MCBuffer.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 03/05/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#define __REQUIRES_ERR__ 1

#import "MCBuffer.h"
#import "MCSocket.h"
#define BUFFER_LEN 10240
@implementation MCBuffer
@synthesize stream, socket;
-(MCBuffer*)init
{
    self = [super init];
    buf = malloc(BUFFER_LEN);
    return self;
}
+(MCBuffer*)bufferWithSocket:(MCSocket*)sock
{
    MCBuffer* ret = [self new];
    [ret setStream:[sock outputStream]];
    return [ret autorelease];
}
-(void)write:(uint8_t*)data length:(int)len
{
    if (pos+len >= BUFFER_LEN) {
        [self tick];
    }
    memcpy(buf+pos, data, len);
    pos += len;
}
-(void)writeZeroes:(int)len
{
    if (pos+len >= BUFFER_LEN) {
        [self tick];
    }
    bzero(buf+pos, len);
    pos += len;
}
-(void)writeByte:(uint8_t)byte
{
    if (pos+1 >= BUFFER_LEN) {
        [self tick];
    }
    *(char*)(buf+pos) = byte;
    pos++;
}
-(BOOL)tick
{
    if (pos && [stream streamStatus] == NSStreamStatusOpen) {
        int rly_written = 0;
        while (rly_written<pos) {
            errno = 0;
            int pass = [stream write:(unsigned char*)(buf+rly_written) maxLength:(pos-rly_written)];
            if (errno) {
                return NO;
            }
            if (pass >= -1) {
                rly_written += pass;
            } else {
                return NO;
            }
        }
        pos = 0;
        return YES;
    }
    return NO;
}
-(oneway void)dealloc
{
    free(buf);
    socket = nil;
    stream = nil;
    [super dealloc];
}
@end
