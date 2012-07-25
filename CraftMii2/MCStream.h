//
//  MCStream.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 04/05/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//
//  MCStream is a wrapper around NSStream that implements 1.3's new encrypted protocol.
// 

#import <UIKit/UIKit.h>
#import "MCSocket.h"
@interface MCStream : NSObject <NSStreamDelegate>
{
    id delegate;
    NSStream* origStream;
    unsigned char state[256];
    BOOL stateInitialized;
    unsigned char* key;
    unsigned char is;
    unsigned char js;
    BOOL isRC4enabled;
    char* readbuf;
    int readbufpos;
    int readbufreadpos;
    MCSocket* socket;
}
@property(retain) id delegate;
@property(retain) NSStream* origStream;
@property(assign) unsigned char* key;
@property(assign) BOOL isRC4enabled;
@property(assign) MCSocket* socket;
+ (MCStream*)streamWithStream:(NSStream*)stream;
- (size_t)write:(uint_fast8_t*)data maxLength:(NSUInteger)len;
- (size_t)read:(uint_fast8_t*)data maxLength:(NSUInteger)len;
- (NSStreamStatus)streamStatus;
- (NSError *)streamError;
- (void)close;
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;
- (void)rc4:(int)len buffer:(char*)buffer;
@end
