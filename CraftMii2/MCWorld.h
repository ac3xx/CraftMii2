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
@end
