//
//  MCWorld.m
//  CraftMii2
//
//  Created by qwertyoruiop on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCWorld.h"

@implementation MCWorld
@synthesize chunkPool, socket;
- (id)init
{
    if ((self = [super init]))
    {
        NSMutableDictionary* poolRef = (id)CFDictionaryCreateMutable(nil, 0, nil, &kCFTypeDictionaryValueCallBacks);
        [self setChunkPool:poolRef];
        [poolRef release];
    }
    return self;
}


- (MCChunk*)chunkAtCoord:(MCChunkCoord)coord allocate:(BOOL)alloc
{
    @synchronized(self)
    {
        MCChunk* chunk = [chunkPool objectForKey:(id)((coord.x << 16) | coord.z)];
        if (chunk || !alloc) {
            return chunk;
        }
        chunk = [MCChunk new];
        [chunk setX:coord.x];
        [chunk setZ:coord.z];
        [chunk setWorld:self];
        CFDictionarySetValue((CFMutableDictionaryRef)chunkPool, (const void*)((coord.x << 16) | coord.z), chunk);
        return [chunk autorelease];
    }
}

/*
 NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
 [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"X",
 [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+4)))], @"Z",
 [NSNumber numberWithBool:((*(char*)(data+8)))], @"GroundUpContinuous",
 [NSNumber numberWithUnsignedShort:OSSwapInt16((*(short*)(data+9)))], @"PrimaryBit",
 [NSNumber numberWithUnsignedShort:OSSwapInt16((*(short*)(data+11)))], @"AddBit",
 [NSData dataWithBytes:(data+21) length:OSSwapInt32(*(int*)(data+13))], @"ChunkData",
 @"ChunkUpdate", @"PacketType",
 nil];
 NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
 [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"X",
 [NSNumber numberWithInt:OSSwapInt32(*(int*)(data+4))], @"Z",
 ((*(char*)(data+8)) == 0) ? @"DellocateColumn" : @"AllocateColumn", @"PacketType",
 nil];
 */

-(void)deallocateChunk:(NSDictionary*)infoDict
{
    @synchronized(self)
    {
        CFDictionaryRemoveValue((CFMutableDictionaryRef)chunkPool, (void*)(([[infoDict objectForKey:@"X"] intValue] << 16) | [[infoDict objectForKey:@"Z"] intValue]));
    }
}

-(void)allocateChunk:(NSDictionary*)infoDict
{
    @synchronized(self)
    {
        [self chunkAtCoord:MCChunkCoordMake([[infoDict objectForKey:@"X"] intValue], [[infoDict objectForKey:@"Z"] intValue]) allocate:YES];   
    }
}

-(void)updateChunk:(NSDictionary*)infoDict
{
    @synchronized(self)
    {
        [[self chunkAtCoord:MCChunkCoordMake([[infoDict objectForKey:@"X"] intValue], [[infoDict objectForKey:@"Z"] intValue]) allocate:YES] updateChunk:infoDict];
    }
}

-(void)removeChunkFromPool:(MCChunk *)chunk
{
    @synchronized(self)
    {
        CFDictionaryRemoveValue((CFMutableDictionaryRef)chunkPool, (void*)((chunk.x << 16) | chunk.z));
    }
}

- (MCSection*)getSection:(MCBlockCoord)coord
{
    @synchronized(self)
    {
        int ChunkX = coord.x      / 16;
        int ChunkY = coord.y      / 16;
        int ChunkZ = coord.z      / 16;
        MCChunk* chunk = [self chunkAtCoord:MCChunkCoordMake(ChunkX, ChunkZ) allocate:NO];
        MCSection* sct = [chunk sectionForYRel:ChunkY];
        return sct;
    }
}
- (MCBlock)getBlock:(MCBlockCoord)coord
{
    @synchronized(self)
    {
        int SctRlX = abs(coord.x) % 16;
        int SctRlY = abs(coord.y) % 16;
        int SctRlZ = abs(coord.z) % 16;
        MCSection* sct = [self getSection:coord];
        if (!sct) {
            return (MCBlock){0,0,0,0};
        }
        //NSLog(@"Parsing Anvil.. %d", ChunkY);
        return (MCBlock){(sct->typedata[MCAnvilIndex(((MCRelativeCoord){SctRlX, SctRlY, SctRlZ}))]) ,0,0,0};
    }
}

- (void)setBlock:(MCBlockCoord)coord to:(MCBlock)to
{
    @synchronized(self)
    {
        int ChunkX = coord.x      / 16;
        int ChunkY = coord.y      / 16;
        int ChunkZ = coord.z      / 16;
        if (coord.y > 0xFF) {
            return;
        }
        int SctRlX = abs(coord.x) % 16;
        int SctRlY = abs(coord.y) % 16;
        int SctRlZ = abs(coord.z) % 16;
        MCChunk* chunk = [self chunkAtCoord:MCChunkCoordMake(ChunkX, ChunkZ) allocate:YES];
        MCSection* sct = [chunk sectionForYRel:ChunkY];
        if (!sct) {
            sct = [chunk allocateSection:ChunkY];
            if (!sct) {
                return;
            }
        }
        MCSetBlockInSection(sct, (MCRelativeCoord){SctRlX, SctRlY, SctRlZ}, to);
        [chunk refresh];
    }
}

- (void)deallocateChunks
{
    @synchronized(self)
    {
        [chunkPool removeAllObjects];
    }
}
- (void)dealloc
{
    for (MCChunk* chunk in chunkPool) {
        [chunk release];
    }
    [self setChunkPool:nil];
    [super dealloc];
}
@end
