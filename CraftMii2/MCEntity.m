//
//  MCEntity.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 24/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCEntity.h"

@implementation MCEntity
@synthesize eid,x,y,z,vx,vy,vz,pitch,yaw,item,actions,animations,count,itemid,rotation,damage,type,headyaw,direction,status,veichle,metadata,effect,name,stance,onGround,level,gamemode;
+(MCEntity*)entityWithIdentifier:(unsigned int)eid
{
    static NSMutableDictionary* entityPool=nil;
    if (!entityPool) {
        entityPool=[NSMutableDictionary new];
    }
    NSNumber* nseid = [NSNumber numberWithUnsignedInt:eid];
    MCEntity* entity = [entityPool objectForKey:nseid];
    if (entity) {
        return entity;
    }
    entity = [self new];
    [entity setEid:eid];
    [entityPool setObject:entity forKey:nseid];
    return entity;
}
-(NSString*)description
{
    return [[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:eid], @"EID", name, @"Name", [super description], @"Description", nil] description];
}

-(void)dealloc
{
    self.veichle=nil;
    self.metadata=nil;
    self.effect=nil;
    self.name=nil;
    self.gamemode=nil;
    [super dealloc];
}
@end
