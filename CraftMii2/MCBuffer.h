//
//  MCBuffer.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 03/05/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCSocket.h"

@interface MCBuffer : NSObject
{
    void* buf;
    int pos;
    NSOutputStream* stream;
    MCSocket* socket;
}
@property(assign) NSOutputStream* stream;
@property(assign) MCSocket* socket;
+(MCBuffer*)bufferWithSocket:(MCSocket*)sock;
-(void)write:(uint8_t*)data length:(int)len;
-(void)writeZeroes:(int)len;
-(void)writeByte:(uint8_t)byte;
-(BOOL)tick;
@end
