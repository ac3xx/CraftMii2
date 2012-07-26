//
//  MCChunk.m
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 14/07/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCChunk.h"
#import "MCSocket.h"
#import "MCWorld.h"
#import "NSData+UserAdditions.h"

static NSObject* buflock = nil;

NSString* MCBiomeToNSString(MCBiome biome)
{
    if (biome < __INTERNAL_MCBiomeEnumEnd) {
        return __INTERNAL_MCBiomeNameStringMatrix[biome];
    }
    return @"MCBiomeInvalid";
}
NSString* __INTERNAL_MCBiomeNameStringMatrix[__INTERNAL_MCBiomeEnumEnd] =
{
    @"MCBiomeOcean",
    @"MCBiomePlains",
    @"MCBiomeDesert",
    @"MCBiomeExtremeHills",
    @"MCBiomeForest",
    @"MCBiomeTaiga",
    @"MCBiomeSwampland",
    @"MCBiomeRiver",
    @"MCBiomeHell",
    @"MCBiomeSky",
    @"MCBiomeFrozenOcean",
    @"MCBiomeFrozenRiver",
    @"MCBiomeIcePlains",
    @"MCBiomeIceMountains",
    @"MCBiomeMushroomIsland",
    @"MCBiomeMushroomIslandShore",
    @"MCBiomeBeach",
    @"MCBiomeDesertHills",
    @"MCBiomeForestHills",
    @"MCBiomeTaigaHills",
    @"MCBiomeExtremeHillsEdge",
    @"MCBiomeJungle",
    @"MCBiomeJungleHills"
};

@implementation MCChunk
@synthesize x,z,world,vbo;

- (BOOL)shouldBeRendered
{
    return shouldBeRendered;
}

- (void)setShouldBeRendered:(BOOL)shouldBeRendered_
{
    if (shouldBeRendered == YES) {
        if (hasToBeUpdated == NO) {
            return;
        }
    }
    if (isUpdating) {
        return;
    }
    if (isRendering) {
        return;
    }
    isRendering = YES;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(queue, ^{
        @synchronized(self)
        {
            hasToBeUpdated = NO;
            if (hasBeenRendered && !shouldBeRendered_)
            {
                glDeleteBuffers(1, &vbo);
            }
            else if (shouldBeRendered_ && !hasBeenRendered)
            {
                glGenBuffers(1, &vbo);
            }
            hasBeenRendered = NO;
            if (shouldBeRendered_ == NO) {
                if (vertexData) {
                    NSLog(@"Not rendering anymore :(");
                    free(vertexData);
                    vertexData = NULL;
                }
            } else {
                NSLog(@"Time to render!");
                int scts = 0;
                for (int section = 0; section < 16; section++) {
                    if ((sections_bitmask >> section) & 0x1) {
                        scts++;
                    }
                }
                if (vertexData) {
                    free(vertexData);
                    vertexData = NULL;
                }
                vertexData = malloc(scts * 16 * 16 * 16 * sizeof(struct MCVertex) * 12);
                vertexSize = 0;
                for (int section = 0; section < 16; section++) {
                    if ((sections_bitmask >> section) & 0x1) {
                        MCSection* sct = sections[section];
                        for (int cx = 0; cx < 16; cx++) {
                            int rx = (x * 16) + cx;
                            for (int cy = 0; cy < 16; cy++) {
                                int ry = (section * 16) + cy;
                                for (int cz = 0; cz < 16; cz++) {
                                    int rz = (z * 16) + cz;
                                    MCBlock blck =  MCGetBlockInSection(self, sct, (MCRelativeCoord){cx, cy, cz});
                                    MCBlock blck1 = MCGetBlockInSection(self, sct, (MCRelativeCoord){cx,cy+1,cz});
                                    MCBlock blck2 = MCGetBlockInSection(self, sct, (MCRelativeCoord){cx,cy-1,cz});
                                    MCBlock blck3 = MCGetBlockInSection(self, sct, (MCRelativeCoord){cx,cy,cz+1});
                                    MCBlock blck4 = MCGetBlockInSection(self, sct, (MCRelativeCoord){cx,cy,cz-1});
                                    MCBlock blck5 = MCGetBlockInSection(self, sct, (MCRelativeCoord){cx+1,cy,cz});
                                    MCBlock blck6 = MCGetBlockInSection(self, sct, (MCRelativeCoord){cx-1,cy,cz});
                                    if (getItem(blck.typedata, 0).value == blck.typedata && blck.typedata) {
#define tmpvx vertexData
#define verts vertexSize
                                        if (!getItem(blck2.typedata, 0).value == blck2.typedata && blck2.typedata) {
                                            /* x=M z=N y=0 face */
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                        }
                                        if (!getItem(blck1.typedata, 0).value == blck1.typedata && blck1.typedata) {
                                            /* x=M z=N y=1 face */
                                            NSLog(@"%@", getItem(blck.typedata, blck.metadata).name);
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 0+rz};
                                        }
                                        if (!getItem(blck6.typedata, 0).value == blck6.typedata && blck6.typedata) {
                                            /* x=0 z=N y=M face */
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 1+rz};
                                        }
                                        if (!getItem(blck5.typedata, 0).value == blck5.typedata && blck5.typedata) {
                                            /* x=1 z=N y=M face */
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 1+rz};
                                        }
                                        if (!getItem(blck4.typedata, 0).value == blck4.typedata && blck4.typedata) {
                                            /* x=N z=0 y=M face */
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                        }
                                        if (!getItem(blck3.typedata, 0).value == blck3.typedata && blck3.typedata) {
                                            /* x=N z=1 y=M face */
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 1+rz};
                                        }
                                    }
#undef sct
                                    
                                }
                            }
                        }
                    }
                }
                shouldBeRendered = shouldBeRendered_;
            }
        }
        @synchronized(buflock)
        {
            glBindBuffer(GL_ARRAY_BUFFER, vbo);
            glBufferData(GL_ARRAY_BUFFER, verts*3, tmpvx, GL_STATIC_DRAW);
        }
        hasBeenRendered = YES;
        isRendering = NO;
    });
}

- (int)vertexSize
{
    return vertexSize;
}

- (BOOL)hasBeenRendered
{
    @synchronized(self)
    {
        return hasBeenRendered;
    }
}

- (struct MCVertex*)vertexData
{
    @synchronized(self)
    {
        return vertexData;
    }
}

- (oneway void)dealloc
{
    if (vertexData) {
        free(vertexData);
    }
    for (short i=0;i<16;i++) {
        if (((sections_bitmask >> i ) & 0x1) && sections[i]) {
            free(sections[i]);
            sections[i] = NULL;
        }
    }
    [self setWorld:nil];
    [super dealloc];
}
+(MCBlockCoord)absoluteCoordToSectionRelative:(MCBlockCoord)orig
{
    return absoluteCoordToSectionRelative(orig);
}
+(MCBlockCoord)entityCoordToChunkSectionCoord:(MCBlockCoord)orig
{
    return entityCoordToChunkSectionCoord(orig);
}
-(id)init
{
    if ((self = [super init])) {
        if (!buflock) {
            buflock = [NSObject new];
        }
    }
    return self;
}
-(void)updateChunk:(NSDictionary*)infoDict
{
    isUpdating = YES;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    [infoDict retain];
    dispatch_async(queue, ^{
        @synchronized(self)
        {
            /*
             NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"ChunkX",
             [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+4)))], @"ChunkY",
             [NSNumber numberWithShort:OSSwapInt16((*(int*)(data+8)))], @"RecordCount",
             [NSData dataWithBytes:(data+14) length:dsize], @"Records",
             @"MultiBlockChange", @"PacketType",
             nil];
             */
            if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"ChunkUpdate"]) {
                short primary = [[infoDict objectForKey:@"PrimaryBit"] shortValue];
                short add = [[infoDict objectForKey:@"AddBit"] shortValue];
                NSData* dt = [[infoDict objectForKey:@"ChunkData"] zlibInflate];
                if (!dt) {
                    NSLog(@"== Error. Well, Fuck. ==");
                    return;
                }
                const char* db = [dt bytes];
                BOOL guc = [[infoDict objectForKey:@"GroundUpContinuous"] boolValue];
                if(guc)
                {
                    for (short i=0;i<16;i++) {
                        if (((sections_bitmask >> i ) & 0x1) && sections[i]) {
                            free(sections[i]);
                            sections[i] = NULL;
                        }
                    }
                    sections_bitmask = 0;
                }
                int rpoint=0;
                for (short i=0;i<16;i++) {
                    if ((primary >> i ) & 0x1) {
                        sections_bitmask |= 1 << i;
                        if (!(sections[i])) {
                            [self allocateSection:i];
                        }
                        if ((add >> i ) & 0x1) {
                            if (rpoint+4096+2048+2048+2048+2048 > [dt length]) {
                                NSLog(@"[Critical] [%s:%d] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.", __FILE__, __LINE__);
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    [[world socket] disconnectWithReason:@"Chunk Error"];                 
                                    [infoDict release];
                                });
                                NSLog(@"%d - %d - %ld", rpoint, [dt length], sizeof(biomes));
                                isUpdating = NO;
                                return;
                            }
                            short cnt = 0;
                            while (cnt-4096) {
                                *(char*)(((char*)sections[i])+cnt) = *((char*)[dt bytes]+(rpoint));
                                if(*(char*)(((char*)sections[i])+cnt))
                                    sections[i]->blk++;
                                rpoint++;
                                cnt++;
                            }
                            memcpy((((char*)(sections[i]))+4096), (char*)((char*)[dt bytes]+(rpoint)), 2048+2048+2048+2048);
                            rpoint += 2048+2048+2048+2048;
                        } else {
                            if (rpoint+4096+2048+2048+2048 > [dt length]) {
                                NSLog(@"[Critical] [%s:%d] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.", __FILE__, __LINE__);
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    [[world socket] disconnectWithReason:@"Chunk Error"];                 
                                    [infoDict release];
                                });
                                NSLog(@"%d - %d - %ld", rpoint, [dt length], sizeof(biomes));
                                isUpdating = NO;
                                return;
                            }
                            bzero(sections[i]->addarray, 2048);
                            short cnt = 0;
                            while (cnt-4096) {
                                *(char*)(((char*)sections[i])+cnt) = *((char*)[dt bytes]+(rpoint));
                                if(*(char*)(((char*)sections[i])+cnt))
                                    sections[i]->blk++;
                                rpoint++;
                                cnt++;
                            }
                            memcpy((((char*)sections[i])+4096), (char*)((char*)[dt bytes]+(rpoint)), 2048+2048+2048);
                            rpoint += 2048+2048+2048;
                        }
                    }
                }
                if(guc)
                {
                    if (rpoint+sizeof(biomes) > [dt length]) {
                        NSLog(@"[Critical] [%s:%d] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.", __FILE__, __LINE__);
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            [[world socket] disconnectWithReason:@"Chunk Error"];                 
                            [infoDict release];
                        });
                        NSLog(@"%d - %d - %ld", rpoint, [dt length], sizeof(biomes));
                        isUpdating = NO;
                        return;
                    }
                    memcpy(biomes, db+rpoint, sizeof(biomes));
                    rpoint += sizeof(biomes);
                }
                if (rpoint != [dt length]) {
                    NSLog(@"[Critical] [%s:%d] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.", __FILE__, __LINE__);
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [[world socket] disconnectWithReason:@"Chunk Error"];                 
                        [infoDict release];
                    });
                    NSLog(@"%d - %d - %ld", rpoint, [dt length], sizeof(biomes));
                    isUpdating = NO;
                    return;
                }
                [[world socket] chunkDidUpdate:self];
            } else if ([[infoDict objectForKey:@"PacketType"] isEqualToString:@"MultiBlockChange"]) {
                NSData* dt = [[infoDict objectForKey:@"Records"] zlibInflate];
                const char* db = [dt bytes];
                int rpoint = 0;
                while ([dt length] != rpoint) {
                    int parse = *(int*)(db + rpoint);
                    char metadata = parse & 0x0000000F;
                    short blockid = ( parse & 0x0000FFF0 ) >> 4;
                    char   ycoord = ( parse & 0x00FF0000 ) >> 16;
                    char   zcoord = ( parse & 0x0F000000 ) >> 24;
                    char   xcoord = ( parse & 0xF0000000 ) >> 28;
                    char yrelcoord = abs(ycoord) % 16;
                    char ysection = ycoord / 16;
                    MCSection* sc = [self allocateSection:ysection];
                    MCSetBlockInSection(self, sc, (MCRelativeCoord){xcoord, yrelcoord, zcoord}, ((MCBlock){blockid, metadata, 0, 0}));
                    rpoint += 4;
                }
            }
            [infoDict release];
            isUpdating = NO;
            [self refresh];
        }
    });
}

-(void)purge
{
    /*
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^()
     {
     @synchronized(self)
     {
     int pr = 0;
     for (int i = 0; i < 16; i++) {
     if (((sections_bitmask >> i ) & 0x1)) {
     if (sections[i]) {
     if ((sections[i]->blk) == 0) {
     pr++;
     sections_bitmask -= 1 << i;
     free(sections[i]);
     sections[i] = NULL;
     }
     }
     }
     }
     if (pr != 0) {
     NSLog(@"Purged %d sections", pr);
     } 
     }
     });
     */
}

-(void)refresh
{
    hasToBeUpdated = YES;
}

-(MCSection*)allocateSection:(char)index
{
    if (index > 16) {
        return NULL;
    }
    if (!((sections_bitmask >> index) & 0x1)) {
        return sections[index];
    }
    sections_bitmask |= 1 << index;
    sections[index] = malloc(sizeof(MCSection));
    bzero(sections[index], sizeof(MCSection));
    return sections[index];
}

-(MCSection*)sectionForBlockCoord:(MCBlockCoord)coord
{
    short y = entityCoordToChunkSectionCoord(coord).y;
    if (y > 16) {
        return NULL;
    }
    return sections[y];
}

-(MCSection*)sectionForYRel:(short)y
{
    if (!((sections_bitmask >> y) & 0x1)) {
        return NULL;
    }
    return sections[y];
}

@end

MCBlock getBlock(MCBlockCoord coord, MCSocket* socket)
{
    /*
     MCBlockCoord chunkCoord = entityCoordToChunkSectionCoord(coord);
     MCBlockCoord relativeCoord = absoluteCoordToSectionRelative(coord);
     MCChunk* chunk = [MCChunk chunkAtCoord:MCChunkCoordMake(chunkCoord.x, chunkCoord.z)  forSocket:socket];
     MCSection* sect = [chunk sectionForYRel:chunkCoord.y];
     if (!sect) {
     return (MCBlock){0,0,0,0};
     }
     MCBlock ret = MCBlockInSection(sect, relativeCoord);
     NSLog(@"ID of (X: [%d|%d|%d] Y: [%d|%d|%d] Z: [%d|%d|%d]) is: %d [%ld]", relativeCoord.x, chunkCoord.x, coord.x, relativeCoord.y, chunkCoord.y, coord.y, relativeCoord.z, chunkCoord.z, coord.z, ret.typedata, sizeof(MCBlock));
     return ret;
     */
    return (MCBlock){0,0,0,0};
}
