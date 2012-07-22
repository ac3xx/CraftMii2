//
//  MCStream.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 04/05/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//
//  A wrapper to NSStream w/ MCCrypto support ;P
//  Also buffered reads! :)
//
/*
 @property(retain) id delegate;
 + (MCStream*)streamWithStream:(NSStream*)stream;
 - (size_t)write:(uint_fast8_t*)data maxLength:(NSUInteger)len;
 - (size_t)read:(uint_fast8_t*)data maxLength:(NSUInteger)len;
 - (NSStreamStatus)streamStatus;
 - (NSError *)streamError;
 - (void)close;
 - (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
 - (char*)getRC4streamUntil:(int)position writeToBuffer:(char*)buffer;
 - (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;
*/
#define RBUFSIZE 51200
#import "MCStream.h"
#define RC4SWAP(x,y) {char __k=*(char*)x; *x=*(char*)y; *y=(char)__k;}
@implementation MCStream
@synthesize delegate, origStream, isRC4enabled, key;
+(MCStream*)streamWithStream:(NSStream*)stream
{
    //return stream;
    MCStream* retv = [[[MCStream alloc] init] autorelease];
    [retv setDelegate:[stream delegate]];
    [retv setOrigStream:stream];
    [stream setDelegate:retv];
    return retv;
}
-(id)init
{
    readbuf = malloc(RBUFSIZE);
    readbufpos = 0;
    readbufreadpos = 0;
    return self;
}
- (size_t)write:(uint_fast8_t*)data maxLength:(NSUInteger)len
{
    if (isRC4enabled) {
        [self rc4:len buffer:(char*)data];
    }
    return [(NSOutputStream*)origStream write:data maxLength:len];
}
- (size_t)read:(uint_fast8_t*)data maxLength:(NSUInteger)len
{
    if (len>(readbufpos-readbufreadpos)) {
        len=(readbufpos-readbufreadpos);
    }
    if (len == 0)
        return 0;
    else if (len == 1) 
        *data = *(readbuf+readbufreadpos);
    else 
        memcpy(data, (readbuf+readbufreadpos), len);
    if (isRC4enabled) {
        [self rc4:len buffer:(char*)data];
    }
    readbufreadpos+=len;
    if (readbufpos == readbufreadpos) {
        readbufpos = 0;
        readbufreadpos = 0;
    }
    return len;
}
- (size_t)_read:(uint_fast8_t*)data maxLength:(NSUInteger)len
{
    int lent = [(NSInputStream*)origStream read:data maxLength:len];
    return lent;
}
- (NSStreamStatus)streamStatus
{
    return [origStream streamStatus];
}
- (NSError *)streamError
{
    return [origStream streamError];
}
- (void)close
{
    return [origStream close];
}
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    return [origStream removeFromRunLoop:aRunLoop forMode:mode];
}
- (void)rc4:(int)len buffer:(char*)buffer
{
    /*
     I officially hate RC4, however here's my implementation!
     */
    if (!stateInitialized) {
        unsigned char c=0;
        for (int p=0; p<256; p++) {
            state[p] = p;
        }
        for (int p=0; p<256; p++) {
            c = (c + state[p] + key[p % 16]) & 0xFF;
            RC4SWAP(&state[p], &state[c]);
        }
        stateInitialized = YES;
    }
    while (len--) {
        is = (is + 1) & 0xFF;
        js = (js + state[is]) & 0xFF;
        RC4SWAP(&state[js], &state[is]);
        *buffer++ = *buffer ^ state[(state[js] + state[is]) & 0xFF];
    }
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    if (streamEvent == NSStreamEventHasBytesAvailable) {
        if (RBUFSIZE==readbufreadpos) {
            readbufpos=0;
            readbufreadpos=0;
        }
        if (RBUFSIZE-readbufpos) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^(){
            @synchronized(self)
                {
                    readbufpos += [self _read:(uint_fast8_t*)(readbuf+readbufpos) maxLength:(RBUFSIZE-readbufpos)];
                    while (readbufreadpos - readbufpos) {
                        [delegate stream:(NSStream*)self handleEvent:streamEvent];
                    }
                }
            });
            return;
        }
    }
    return [delegate stream:(NSStream*)self handleEvent:streamEvent];
}
-(void)dealloc
{
    @synchronized(self)
    {
        free(readbuf);
        readbuf = nil;
    }
    [self setOrigStream:nil];
    [self setDelegate:nil];
    [super dealloc];
}
@end
