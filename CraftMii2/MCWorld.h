//
//  MCWorld.h
//  CraftMii2
//
//  Created by qwertyoruiop on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCBoundingBox.h"
#import "MCChunk.h"

@class MCSocket;
@interface MCWorld : NSObject
{
    NSMutableDictionary* chunkPool;
    MCSocket* socket;
}
@property(retain) NSMutableDictionary* chunkPool;
@property(assign) MCSocket* socket;
- (MCChunk*)chunkAtCoord:(MCChunkCoord)coord allocate:(BOOL)alloc;
- (void)removeChunkFromPool:(MCChunk*)chunk;
- (void)deallocateChunk:(NSDictionary*)infoDict;
- (void)allocateChunk:(NSDictionary*)infoDict;
- (void)updateChunk:(NSDictionary*)infoDict;
- (void)removeChunkFromPool:(MCChunk *)chunk;
- (MCBlock)getBlock:(MCBlockCoord)coord;
- (void)setBlock:(MCBlockCoord)coord to:(MCBlock)to;
- (void)deallocateChunks;
- (MCSection*)getSection:(MCBlockCoord)coord;
@end
