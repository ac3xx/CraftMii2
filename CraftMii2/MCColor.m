//
//  MCColor.m
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 24/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import "MCColor.h"

@implementation UIColor (MCColor)
+(UIColor*)colorWithCode:(char)code
{
    switch (code) {
        case '0':
            return [UIColor colorWithRed:((float)0)/(255.0) green:((float)0)/(255.0) blue:((float)0)/(255.0) alpha:1];
        case '1':
            return [UIColor colorWithRed:((float)0)/(255.0) green:((float)0)/(255.0) blue:((float)170)/(255.0) alpha:1];
        case '2':
            return [UIColor colorWithRed:((float)0)/(255.0) green:((float)170)/(255.0) blue:((float)0)/(255.0) alpha:1];
        case '3':
            return [UIColor colorWithRed:((float)0)/(255.0) green:((float)170)/(255.0) blue:((float)170)/(255.0) alpha:1];
        case '4':
            return [UIColor colorWithRed:((float)170)/(255.0) green:((float)0)/(255.0) blue:((float)0)/(255.0) alpha:1];
        case '5':
            return [UIColor colorWithRed:((float)170)/(255.0) green:((float)0)/(255.0) blue:((float)170)/(255.0) alpha:1];
        case '6':
            return [UIColor colorWithRed:((float)255)/(255.0) green:((float)170)/(255.0) blue:((float)0)/(255.0) alpha:1];
        case '7':
            return [UIColor colorWithRed:((float)170)/(255.0) green:((float)170)/(255.0) blue:((float)170)/(255.0) alpha:1];
        case '8':
            return [UIColor colorWithRed:((float)85)/(255.0) green:((float)85)/(255.0) blue:((float)85)/(255.0) alpha:1];
        case '9':
            return [UIColor colorWithRed:((float)85)/(255.0) green:((float)85)/(255.0) blue:((float)255)/(255.0) alpha:1];
        case 'a':
            return [UIColor colorWithRed:((float)85)/(255.0) green:((float)255)/(255.0) blue:((float)85)/(255.0) alpha:1];
        case 'b':
            return [UIColor colorWithRed:((float)85)/(255.0) green:((float)255)/(255.0) blue:((float)255)/(255.0) alpha:1];
        case 'c':
            return [UIColor colorWithRed:((float)255)/(255.0) green:((float)85)/(255.0) blue:((float)85)/(255.0) alpha:1];
        case 'd':
            return [UIColor colorWithRed:((float)255)/(255.0) green:((float)85)/(255.0) blue:((float)255)/(255.0) alpha:1];
        case 'e':
            return [UIColor colorWithRed:((float)255)/(255.0) green:((float)255)/(255.0) blue:((float)85)/(255.0) alpha:1];
        case 'f':
        default:
            return [UIColor colorWithRed:((float)255)/(255.0) green:((float)255)/(255.0) blue:((float)255)/(255.0) alpha:1];
            break;
    }
    return nil;
}
+(UIColor*)shadowForCode:(char)code
{
    return [UIColor colorWithRed:((float)63)/(255.0) green:((float)63)/(255.0) blue:((float)63)/(255.0) alpha:1]; // fixme
}
@end
