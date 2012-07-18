//
//  MCBoundingBox.h
//  CraftMii2
//
//  Created by qwertyoruiop on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef struct MCBoundingBoxArg {
    double width;
    double height;
    double depth;
} MCBoundingBoxArg;
@interface MCBoundingBox : NSObject
{
    double x;
    double y;
    double z;
    double width;
    double height;
    double depth;
}
@property(assign) double x;
@property(assign) double y;
@property(assign) double z;
@property(assign) double width;
@property(assign) double height;
@property(assign) double depth;
-(MCBoundingBox*)increase:(MCBoundingBoxArg)inc;
@end
