//
//  MCPacket.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCSocket;
@interface MCPacket : NSObject <NSStreamDelegate>
{
    MCSocket* sock;
    unsigned char identifier;
    unsigned char last;
    NSMutableData* buffer;
    const unsigned char* data;
    int cachedoffset;
    int cachedoffset1;
    int cachedoffset2;
    int cachedoffset3;
    int cached_bflen;
    int bytestoread;
}
@property(retain) MCSocket* sock;
@property(assign) unsigned char identifier;
@property(retain) NSMutableData* buffer;
+(MCPacket*)packetWithID:(unsigned char)idt andSocket:(MCSocket*)sock;
-(void)preload;
@end
