//
//  MCColor.h
//  Craftplayer
//
//  Created by Luca "qwertyoruiop" Todesco on 24/04/12.
//  Copyright (c) 2012 Evolse Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCColor : UIColor
+(UIColor*)colorWithCode:(char)code;
+(UIColor*)shadowForCode:(char)code;
@end
