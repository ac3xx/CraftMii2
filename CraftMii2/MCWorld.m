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
        [self setChunkPool:[[NSMutableDictionary new] autorelease]];
    }
    return self;
}


- (MCChunk*)chunkAtCoord:(MCChunkCoord)coord allocate:(BOOL)alloc
{
    NSString* ckeid = [NSString stringWithFormat:@"%d-%d", coord.x, coord.z];
    MCChunk* chunk = [chunkPool objectForKey:ckeid];
    if (chunk || !alloc) {
        return chunk;
    }
    chunk = [MCChunk new];
    [chunk setX:coord.x];
    [chunk setZ:coord.z];
    [chunk setWorld:self];
    [chunkPool setObject:chunk forKey:ckeid];
    return [chunk autorelease];
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
    [chunkPool removeObjectForKey:[NSString stringWithFormat:@"%d-%d", [[infoDict objectForKey:@"X"] intValue], [[infoDict objectForKey:@"Z"] intValue]]];
}

-(void)allocateChunk:(NSDictionary*)infoDict
{
    [self chunkAtCoord:MCChunkCoordMake([[infoDict objectForKey:@"X"] intValue], [[infoDict objectForKey:@"Z"] intValue]) allocate:YES];   
}

-(void)updateChunk:(NSDictionary*)infoDict
{
    [[self chunkAtCoord:MCChunkCoordMake([[infoDict objectForKey:@"X"] intValue], [[infoDict objectForKey:@"Z"] intValue]) allocate:YES] updateChunk:infoDict];
}

-(void)removeChunkFromPool:(MCChunk *)chunk
{
    [chunkPool removeObjectForKey:[NSString stringWithFormat:@"%d-%d", chunk.x, chunk.z]];
}

- (MCBlock)getBlock:(MCBlockCoord)coord
{
    int ChunkX = coord.x      / 16;
    int ChunkY = coord.y      / 16;
    int ChunkZ = coord.z      / 16;
    int SctRlX = abs(coord.x) % 16;
    int SctRlY = abs(coord.y) % 16;
    int SctRlZ = abs(coord.z) % 16;
    MCChunk* chunk = [self chunkAtCoord:MCChunkCoordMake(ChunkX, ChunkZ) allocate:NO];
    MCSection* sct = [chunk sectionForYRel:ChunkY];
    if (!sct) {
        return (MCBlock){0,0,0,0};
    }
    NSLog(@"Parsing Anvil.. %d", ChunkY);
    return (MCBlock){(sct->typedata[MCAnvilIndex(((MCRelativeCoord){SctRlX, SctRlY, SctRlZ}))]) ,0,0,0};
}

- (void)setBlock:(MCBlockCoord)coord to:(MCBlock)to
{
    int ChunkX = coord.x      / 16;
    int ChunkY = coord.y      / 16;
    int ChunkZ = coord.z      / 16;
    int SctRlX = abs(coord.x) % 16;
    int SctRlY = abs(coord.y) % 16;
    int SctRlZ = abs(coord.z) % 16;
    MCChunk* chunk = [self chunkAtCoord:MCChunkCoordMake(ChunkX, ChunkZ) allocate:NO];
    MCSection* sct = [chunk sectionForYRel:ChunkY];
    if (!sct) {
        return;
    }
    MCSetBlockInSection(sct, MCBlockCoordMake(SctRlX, SctRlY, SctRlZ), to);
}

- (void)deallocateChunks
{
    [chunkPool removeAllObjects];
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
