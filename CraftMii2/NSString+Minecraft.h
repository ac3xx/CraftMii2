//
//  NSString+Minecraft.h
//  CraftMii2
//
//  Created by qwertyoruiop on 21/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define m_char_t_sizeof(x) (OSSwapInt16(x->len)*2+sizeof(x->len))

typedef struct m_char
{
    short len;
    char data[];
} m_char_t;

@interface NSString (Minecraft)
+(NSString*) stringWithMinecraftString:(m_char_t*)minestring;
-(m_char_t*) minecraftString;
-(NSAttributedString*) attributedString;
@end
