//
//  MCBoundingBox.m
//  CraftMii2
//
//  Created by qwertyoruiop on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCBoundingBox.h"

@implementation MCBoundingBox
@synthesize x,y,z,width,height,depth;
- (void)increaseNoCopy:(MCBoundingBoxArg)inc
{
    width = width + inc.width;
    height = height + inc.height;
    depth = depth + inc.depth;
}
- (MCBoundingBox*)increase:(MCBoundingBoxArg)inc
{
    MCBoundingBox* nw = [[self class] new];
    nw.x = x;
    nw.y = y;
    nw.z = z;
    nw.width = width + inc.width;
    nw.height = height + inc.height;
    nw.depth = depth + inc.depth;
    return [nw autorelease];
}
- (void)decreaseNoCopy:(MCBoundingBoxArg)inc
{
    width = width - inc.width;
    height = height - inc.height;
    depth = depth - inc.depth;
}
- (MCBoundingBox*)decrease:(MCBoundingBoxArg)inc
{
    MCBoundingBox* nw = [[self class] new];
    nw.x = x;
    nw.y = y;
    nw.z = z;
    nw.width = width - inc.width;
    nw.height = height - inc.height;
    nw.depth = depth - inc.depth;
    return [nw autorelease];
}
@end
