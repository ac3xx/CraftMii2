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
void MCSetBlockInSection(MCSection* section, MCBlockCoord relativecoord, MCBlock block)
{
    section->typedata[MCAnvilIndex(relativecoord)] = block.typedata;
    section->addarray[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] = ( block.typedata & 0xF00 ) >> (__mod(relativecoord.x, 2) ? 8 : 4);
    section->metadata[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] = ( block.metadata & 0x00F ) << (__mod(relativecoord.x, 2) ? 0 : 4);
}

MCBlock MCGetBlockInSection(MCSection* section, MCBlockCoord relativecoord)
{
    return (MCBlock)
    {
        (       section->typedata[MCAnvilIndex(relativecoord)]) + 
        (((     (section->addarray[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F) << 8),
        (       (section->metadata[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F, 
        (       (section->lightarr[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F, 
        (       (section->skylight[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) & 0x0F, 
    };
}

MCBlockCoord absoluteCoordToSectionRelative(MCBlockCoord orig)
{
    register int x = orig.x;
    register int y = orig.y;
    register int z = orig.z;
    register int modx = __mod(x, 16);
    register int mody = __mod(y, 16);
    register int modz = __mod(z, 16);
    return MCBlockCoordMake(modx,mody,modz);
}

MCBlockCoord entityCoordToChunkSectionCoord(MCBlockCoord orig)
{
    register int x = orig.x;
    register int y = orig.y;
    register int z = orig.z;/*
                             register int modx = __mod(x, 16);
                             register int mody = __mod(y, 16);
                             register int modz = __mod(z, 16);
                             x -= modx;
                             y -= mody;
                             z -= modz;*/
    return MCBlockCoordMake(x/16,y/16,z/16);
}

MCChunkCoord chunkCoordForEntityCoord(MCCoord orig)
{
    register int x = orig.x;
    register int z = orig.z;/*
                             register int modx = __mod(x, 16);
                             register int mody = __mod(y, 16);
                             register int modz = __mod(z, 16);
                             x -= modx;
                             y -= mody;
                             z -= modz;*/
    return MCChunkCoordMake(x/16, z/16);
}

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
@synthesize x,z,world;

- (BOOL)shouldBeRendered
{
    return shouldBeRendered;
}

- (void)setShouldBeRendered:(BOOL)shouldBeRendered_
{
    hasBeenRendered = NO;
    if (shouldBeRendered_ == NO) {
        if (vertexData) {
            NSLog(@"Not rendering anymore :(");
            free(vertexData);
            vertexData = NULL;
        }
    } else {
        if (isUpdating) {
            return;
        }
        if (isRendering) {
            return;
        }
        isRendering = YES;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
        dispatch_async(queue, ^{
            NSLog(@"Time to render!");
            @synchronized(self)
            {
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
                        for (int cx = 0; cx < 16; cx++) {
                            int rx = (x * 16) + cx;
                            for (int cy = 0; cy < 16; cy++) {
                                int ry = (section * 16) + cy;
                                for (int cz = 0; cz < 16; cz++) {
                                    int rz = (z * 16) + cz;
#define sct sections[section]
                                    unsigned char btype  = sct->typedata[MCAnvilIndex(((MCRelativeCoord){cx,cy,cz}))];
                                    unsigned char btype2 = (cy)         ? sct->typedata[MCAnvilIndex(((MCRelativeCoord){cx,cy-1,cz}))] : 1;
                                    unsigned char btype3 = (cy < 16)    ? sct->typedata[MCAnvilIndex(((MCRelativeCoord){cx,cy+1,cz}))] : 1;
                                    unsigned char btype4 = (cx)         ? sct->typedata[MCAnvilIndex(((MCRelativeCoord){cx-1,cy,cz}))] : 1;
                                    unsigned char btype5 = (cx < 16)    ? sct->typedata[MCAnvilIndex(((MCRelativeCoord){cx+1,cy,cz}))] : 1;
                                    unsigned char btype6 = (cz)         ? sct->typedata[MCAnvilIndex(((MCRelativeCoord){cx,cy,cz-1}))] : 1;
                                    unsigned char btype7 = (cz < 16)    ? sct->typedata[MCAnvilIndex(((MCRelativeCoord){cx,cy,cz+1}))] : 1;
                                    if (btype) {
#define tmpvx vertexData
#define verts vertexSize
                                        if (!btype2) {
                                            /* x=M z=N y=0 face */
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                        }
                                        if (!btype3) {
                                            /* x=M z=N y=1 face */
                                            //NSLog(@"type is %@[%d] [%d|%d|%d]", getItem(btype, 0).name, btype, rx, ry, rz);
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 0+rz};
                                        }
                                        if (!btype4) {
                                            /* x=0 z=N y=M face */
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 1+rz};
                                        }
                                        if (!btype5) {
                                            /* x=1 z=N y=M face */
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 1+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 1+rz};
                                        }
                                        if (!btype6) {
                                            /* x=N z=0 y=M face */
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){0+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 1+ry, 0+rz};
                                            tmpvx[verts++] = (struct MCVertex){1+rx, 0+ry, 0+rz};
                                        }
                                        if (!btype7) {
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
                hasBeenRendered = YES;
                isRendering = NO;
            }
        });
    }
    shouldBeRendered = shouldBeRendered_;
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
                            if (rpoint+sizeof(MCSection) > [dt length]) {
                                NSLog(@"[Critical] [%s:%d] Size of chunk data is wrong. Either the world is corrupt or the server's implementation of chunk updates is wrong. Disconnecting.", __FILE__, __LINE__);
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    [[world socket] disconnectWithReason:@"Chunk Error"];                 
                                    [infoDict release];
                                });
                                NSLog(@"%d - %d - %ld", rpoint, [dt length], sizeof(biomes));
                                isUpdating = NO;
                                return;
                            }
                            memcpy(sections[i], (char*)(int)[dt bytes]+(rpoint), sizeof(MCSection));
                            rpoint += sizeof(MCSection);
                        } else {
                            if (rpoint+sizeof(MCSection)-2048 > [dt length]) {
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
                            memcpy(sections[i], (char*)(int)[dt bytes]+(rpoint), sizeof(MCSection)-2048);
                            rpoint += sizeof(MCSection)-2048;
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
                    MCSetBlockInSection(sc, MCBlockCoordMake(xcoord, yrelcoord, zcoord), ((MCBlock){blockid, metadata, 0, 0}));
                    rpoint += 4;
                }
            }
            [infoDict release];
            isUpdating = NO;
            [self refresh];
        }
    });
}

-(void)refresh
{
    if ([self shouldBeRendered]) {
        [self setShouldBeRendered:YES];
    }
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
