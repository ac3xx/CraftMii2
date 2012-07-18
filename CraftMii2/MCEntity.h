//
//  MCEntity.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 24/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMetadata.h"
#import "MCEffect.h"
@class MCMetadata;
@interface MCEntity : NSObject
{
    unsigned int eid;
    double x;
    double y;
    double z;
    short vx;
    short vy;
    short vz;
    float pitch;
    float yaw;
    BOOL onGround;
    double stance;
    short level;
    unsigned short item;
    unsigned char* actions;
    unsigned char* animations;
    unsigned char count;
    unsigned short itemid;
    unsigned char rotation;
    unsigned short damage;
    unsigned char type;
    unsigned char headyaw;
    unsigned char direction;
    unsigned char status;
    NSString* gamemode;
    MCEntity* veichle;
    MCMetadata* metadata;
    MCEffect* effect;
    NSString* name;
}
@property(assign) double x;
@property(assign) double y;
@property(assign) double z;
@property(assign) short vx;
@property(assign) short vy;
@property(assign) short vz;
@property(assign) float pitch;
@property(assign) float yaw;
@property(assign) short level;
@property(assign) BOOL onGround;
@property(assign) double stance;
@property(assign) unsigned int eid;
@property(assign) unsigned short item;
@property(assign) unsigned char* actions;
@property(assign) unsigned char* animations;
@property(assign) unsigned char count;
@property(assign) unsigned short itemid;
@property(assign) unsigned char rotation;
@property(assign) unsigned short damage;
@property(assign) unsigned char type;
@property(assign) unsigned char headyaw;
@property(assign) unsigned char direction;
@property(assign) unsigned char status;
@property(retain) NSString* gamemode;
@property(retain) MCEntity* veichle;
@property(retain) MCMetadata* metadata;
@property(retain) MCEffect* effect;
@property(retain) NSString* name;
+(MCEntity*)entityWithIdentifier:(unsigned int)eid;
@end
