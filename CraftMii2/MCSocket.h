//
//  MCSocket.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 23/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCAuth.h"
#import "MCEntity.h"
#import "MCSlot.h"
#import "MCSocketDelegate.h"
#import "MCPlayer.h"
@class MCBuffer;
@class MCPacket;
@class MCSlot;
@class MCMetadata;
@class MCChunk;
@class MCWorld;
@interface MCSocket : NSObject <NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    MCAuth* auth;
    MCPlayer* player;
    NSString* server;
    id<MCSocketDelegate> delegate;
    NSMutableData* buffer;
    unsigned const char * dataBuffer;
    unsigned const char * metadataArea;
    MCBuffer* outputBuffer;
    BOOL isConnected;
    BOOL isInUse;
    int lPacket;
    unsigned int ticks;
    unsigned int lpingtick;
    int identifier;
    MCWorld* world;
}
@property(retain) NSInputStream *inputStream;
@property(retain) NSOutputStream *outputStream;
@property(assign) unsigned const char * dataBuffer;
@property(assign) unsigned const char * metadataArea;
@property(retain) MCAuth* auth;
@property(retain) NSString* server;
@property(readonly) MCPlayer* player;
@property(retain) MCBuffer* outputBuffer;
@property(retain) id<MCSocketDelegate> delegate;
@property(retain) NSMutableData* buffer;
@property(assign) unsigned int ticks;
@property(assign) int identifier;
@property(retain) MCWorld* world;
@property(assign) BOOL isConnected;
- (MCSocket*)initWithServer:(NSString*)iserver andAuth:(MCAuth*)iauth;
- (void)metadata:(MCMetadata*)metadata hasFinishedParsing:(NSArray*)infoArray;
- (void)slot:(MCSlot*)slot hasFinishedParsing:(NSDictionary*)infoDict;
- (void)packet:(MCPacket*)packet gotParsed:(NSDictionary*)infoDict;
- (void)connect;
- (void)__connect;
- (void)connect:(BOOL)threaded;
- (void)writeBuffer;
- (int)version;
- (void)disconnect;
- (void)disconnectWithReason:(NSString*)reason;
- (void)tick;
- (void)chunkDidUpdate:(MCChunk*)chunk;
@end
