//
//  MCChunk.h
//  CraftMii
//
//  Created by Luca "qwertyoruiop" Todesco on 14/07/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSocket.h"
@class MCWorld;

typedef enum MCBiome
{
    MCBiomeOcean,
    MCBiomePlains,
    MCBiomeDesert,
    MCBiomeExtremeHills,
    MCBiomeForest,
    MCBiomeTaiga,
    MCBiomeSwampland,
    MCBiomeRiver,
    MCBiomeHell,
    MCBiomeSky,
    MCBiomeFrozenOcean,
    MCBiomeFrozenRiver,
    MCBiomeIcePlains,
    MCBiomeIceMountains,
    MCBiomeMushroomIsland,
    MCBiomeMushroomIslandShore,
    MCBiomeBeach,
    MCBiomeDesertHills,
    MCBiomeForestHills,
    MCBiomeTaigaHills,
    MCBiomeExtremeHillsEdge,
    MCBiomeJungle,
    MCBiomeJungleHills,
    __INTERNAL_MCBiomeEnumEnd
} MCBiome;

extern NSString* __INTERNAL_MCBiomeNameStringMatrix[];
extern NSString* MCBiomeToNSString(MCBiome biome);
typedef struct MCChunkCoord
{
    int x;
    int z;
} MCChunkCoord;
typedef struct MCCoord
{
    double x;
    double y;
    double z;
} MCCoord;
typedef struct MCBlockCoord
{
    int x;
    int y;
    int z;
} MCBlockCoord;
typedef struct MCRelativeCoord
{
    char x;
    char y;
    char z;
} MCRelativeCoord;

#define MCChunkCoordMake(x,z) (MCChunkCoord){x,z}
#define MCCoordMake(x, y, z) (MCCoord){x,y,z}
#define MCBlockCoordMake(x, y, z) (MCBlockCoord){x,y,z}
#define MCSectionReadBlockType(section, blockcoord) section.typedata

struct MCVertex
{
    char x;
    char y;
    char z;
};

typedef struct MCSection
{
    unsigned char typedata[16*16*16];
    unsigned char metadata[16*16*8 ];
    unsigned char lightarr[16*16*8 ];
    unsigned char skylight[16*16*8 ];
    unsigned char addarray[16*16*8 ];
    int blk;
} MCSection;

#define __mod(a,b) ((a < 0) ? -a % b : a % b)
/*
 ((int)  (section->addarray[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] & (__mod(relativecoord.x, 2)  ? 0x0F : 0xF0)) >> (__mod(relativecoord.x, 2)  ? 0 : 4)) << 8) & 0xFFF, \
*/
// 

static inline short MCAnvilIndex(MCRelativeCoord coord)
{
    return coord.x + (coord.z * 16) + (coord.y * 16 * 16);
}

#define MCBlockInSection(section, relativecoord) MCGetBlockInSection(section, relativecoord)

typedef struct MCBlock
{
    unsigned short typedata;
    unsigned char metadata;
    unsigned char light;
    unsigned char skylight;
} MCBlock;
static inline void MCSetBlockInSection(MCChunk* chunk, MCSection* section, MCRelativeCoord relativecoord, MCBlock block)
{
    @synchronized(chunk)
    {
        if (!section) {
            return;
        }
        if (block.typedata == 0x0) {
            section->blk--;
        } else {
            section->blk++;
        }
        section->typedata[MCAnvilIndex(relativecoord)] = block.typedata;
        section->addarray[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] = ( block.typedata & 0xF00 ) >> (__mod(relativecoord.x, 2) ? 8 : 4);
        section->metadata[__mod(relativecoord.x, 2) ? (MCAnvilIndex(relativecoord)-1)/2 : MCAnvilIndex(relativecoord)/2] = ( block.metadata & 0x00F ) << (__mod(relativecoord.x, 2) ? 0 : 4);
    }
}

static inline MCBlock MCGetBlockInSection(MCChunk* chunk, MCSection* section, MCRelativeCoord relativecoord)
{
    @synchronized(chunk)
    {
        int aindex = MCAnvilIndex(relativecoord);
        int nshift = (aindex & 1) * 4;
        return (MCBlock)
        {
            (       (section->typedata[aindex])) + 
            (       (section->addarray[aindex/2] << nshift) << 8),
            (       (section->metadata[aindex/2] << nshift)     ),
            (       (section->lightarr[aindex/2] << nshift)     ),
            (       (section->skylight[aindex/2] << nshift)     ),
        };
    }
}

static inline MCBlockCoord absoluteCoordToSectionRelative(MCBlockCoord orig)
{
    register int x = orig.x;
    register int y = orig.y;
    register int z = orig.z;
    register int modx = __mod(x, 16);
    register int mody = __mod(y, 16);
    register int modz = __mod(z, 16);
    return MCBlockCoordMake(modx,mody,modz);
}

static inline MCBlockCoord entityCoordToChunkSectionCoord(MCBlockCoord orig)
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

static inline MCChunkCoord chunkCoordForEntityCoord(MCCoord orig)
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
@interface MCChunk : NSObject
{
    int x;
    int z;
    int sections_bitmask;
    MCSection* sections[16];
    char biomes[16*16];
    MCWorld* world;
    BOOL shouldBeRendered;
    BOOL hasBeenRendered;
    struct MCVertex* vertexData;
    int vertexSize;
    BOOL isRendering;
    BOOL isUpdating;
    BOOL hasToBeUpdated;
    GLuint vbo;
}
@property(assign) int x;
@property(assign) int z;
@property(assign) MCWorld* world;
@property(assign)  BOOL shouldBeRendered;
@property(readonly) BOOL hasBeenRendered;
@property(assign) GLuint vbo;
-(struct MCVertex*)vertexData;
-(int)vertexSize;
-(void)updateChunk:(NSDictionary*)infoDict;
-(MCSection*)sectionForBlockCoord:(MCBlockCoord)coord;
-(MCSection*)sectionForYRel:(short)y;
-(MCSection*)allocateSection:(char)index;
-(void)refresh;
-(void)purge;
@end
MCBlock getBlock(MCBlockCoord coord, MCSocket* socket);
