//
//  MCSocketDelegate.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 27/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCMetadata;
@class MCPacket;
@class MCSlot;
@class MCChunk;
@class MCSocket;
@protocol MCSocketDelegate <NSObject>
@optional
- (void)slot:(MCSlot*)slot hasFinishedParsing:(NSDictionary*)infoDict;
@optional
- (void)metadata:(MCMetadata*)metadata hasFinishedParsing:(NSArray*)infoArray;
@optional
- (void)packet:(MCPacket*)packet gotParsed:(NSDictionary*)infoDict;
@optional
- (void)chunkDidUpdate:(MCChunk*)chunk;
@optional
- (void)socketDidTick:(MCSocket*)socket;
@end
