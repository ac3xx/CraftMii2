//
//  MCViewController.m
//  CraftMii2
//
//  Created by qwertyoruiop on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCViewController.h"
#import "MCRespawnPacket.h"
#import "MCPacket.h"
#import "MCSocket.h"
#import "MCPlayer.h"
#import "MCWorld.h"
#import "MCChatPacket.h"
#define VIEW_DISTANCE 40
#define CHNK_SZ   16
#define YTOUCH_SPEED 0.01f
#define PTOUCH_SPEED 0.01f
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.

typedef struct 
{
    GLfloat x;
    GLfloat y;
    GLfloat z;
} Vertex3D;

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};


@interface MCViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation MCViewController

@synthesize context = _context;
@synthesize effect = _effect;
@synthesize socket;

- (void)dealloc
{
    free(vbz);
    [socket release];
    [_context release];
    [_effect release];
    [super dealloc];
}

#define RAD2DEG(x) (x * (180.0f / M_PI))
#define DEG2RAD(x) (x * (M_PI / 180.0f))

- (void)socketDidTick:(MCSocket*)socket_
{
    if (touchDistance) {
        float rel = RAD2DEG(touchAngle);
        [[socket_ player] setZ:[[socket_ player] z]+(0.5f*sin(DEG2RAD(fmod(rel + [[socket_ player] yaw], 360))))];
        [[socket_ player] setX:[[socket_ player] x]+(0.5f*cos(DEG2RAD(fmod(rel + [[socket_ player] yaw], 360))))];
    }
    if (touchHash2)
    {
        [[socket_ player] setYaw:fmod([[socket_ player] yaw] + RAD2DEG(sAngle), 360.0f)];
        float pt = [[socket_ player] pitch] + RAD2DEG(mAngle);
        if (pt > 89.0f) {
            pt = 89.0f;
        }
        if (pt < -89.0f) {
            pt = -89.0f;
        }
        [[socket_ player] setPitch:pt];
        mAngle = 0;
        sAngle = 0;
    }
    [self updateChunks];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    CGRect sz = [[UIScreen mainScreen] bounds];
    joypadCap = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"joypadCap.png"]] autorelease];
    joypad = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"joypad.png"]] autorelease];
    [joypad setFrame:CGRectMake(20, sz.size.width-160, 140, 140)];
    [joypadCap setCenter:[joypad center]];
    joypadCenterX = joypad.center.x;
    joypadCenterY = joypad.center.y;
    joypadRadius=60;
    expview = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar] autorelease];
    [expview setFrame:CGRectMake(10, 10, sz.size.height-20, 10)];
    lifeview = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar] autorelease];
    [lifeview setFrame:CGRectMake(10, 30, (sz.size.height/2)-15, 10)];
    foodview = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar] autorelease];
    [foodview setFrame:CGRectMake((sz.size.height/2)+5, 30, (sz.size.height/2) - 30, 10)];
    satview_ = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar] autorelease];
    [satview_ setFrame:CGRectMake(((sz.size.height) - 20), 30, 10, 10)];
    levelview = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    [levelview setBackgroundColor:[UIColor clearColor]];
    [levelview setFont:[UIFont boldSystemFontOfSize:24]];
    [levelview setText:@"0"];
    [levelview sizeToFit];
    [levelview setCenter:[expview center]];
    [levelview setTextColor:[UIColor greenColor]];
    [levelview setShadowOffset:CGSizeMake(1, 1)];
    [levelview setShadowColor:[UIColor blackColor]];
    [expview setHidden:YES];
    [lifeview setHidden:YES];
    [foodview setHidden:YES];
    [satview_ setHidden:YES];
    [view addSubview:expview];
    [view addSubview:lifeview];
    [view addSubview:foodview];
    [view addSubview:satview_];
    [view addSubview:levelview];
    [view addSubview:joypad];
    [view addSubview:joypadCap];
    [self setupGL];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches) {
        CGPoint touchLocation = [touch locationInView:self.view];
        CGRect sz = [[UIScreen mainScreen] bounds];
        if (CGRectContainsPoint(CGRectMake(0, sz.size.width-200.0f, 200.0f, 200.0f), touchLocation) && !joypadMoving) {
            NSLog(@"Valid!");
            joypadMoving = YES;
            touchHash = [touch hash];
        } else {
            touchHash2 = [touch hash];
            sPoint = touchLocation;
        }
    }
    [self touchesMoved:touches withEvent:event];
}


- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches) {
        CGPoint touchLocation = [touch locationInView:self.view];
		if ([touch hash] == touchHash && joypadMoving) {
			float dx = (float)joypadCenterX - (float)touchLocation.x;
			float dy = (float)joypadCenterY - (float)touchLocation.y;
            touchDistance = sqrtf(dx*dx + dy*dy);
            touchAngle = atan2(dy, dx);
			if (touchDistance > joypadRadius) {
                joypadCap.center = CGPointMake(joypadCenterX - cosf(touchAngle) * joypadRadius, 
                                               joypadCenterY - sinf(touchAngle) * joypadRadius);
			} else {
				joypadCap.center = touchLocation;
			}
		} 
        if ([touch hash] == touchHash2)
        {
            float x = sinf((sPoint.x - touchLocation.x) * YTOUCH_SPEED) * cosf((sPoint.x - touchLocation.x) * YTOUCH_SPEED);
            float y = sinf((sPoint.y - touchLocation.y) * PTOUCH_SPEED);
            float z = cosf((sPoint.x - touchLocation.x) * YTOUCH_SPEED) * cosf((sPoint.y - touchLocation.y) * PTOUCH_SPEED);
            sPoint = touchLocation;
            float distance = sqrtf(z*z + x*x);
            sAngle += -atan2(x, z);
            mAngle += -atan2(y, distance);
        }
	}
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	for (UITouch *touch in touches) {
		if ([touch hash] == touchHash) {
			joypadMoving = NO;
			touchHash = 0;
			touchDistance = 0;
			touchAngle = 0;
			joypadCap.center = CGPointMake(joypadCenterX, joypadCenterY);
			return;
		} 
        if ([touch hash] == touchHash2)
        {
            sPoint = CGPointMake(0, 0);
            touchHash2 = 0;
        }
	}
}


- (void)metadata:(MCMetadata *)metadata hasFinishedParsing:(NSArray *)infoArray
{
    
}

- (void)slot:(MCSlot *)slot hasFinishedParsing:(NSDictionary *)infoDict
{
    NSDictionary* ench = [[[infoDict objectForKey:@"EnchantmentData"] objectForKey:@"tag"] objectForKey:@"ench"];
    if (ench) {
        for (NSDictionary* enchantment in ench) {
            MCEnchantment idt = [[enchantment objectForKey:@"id"] intValue];
            MCEnchantmentLevel lvl = [[enchantment objectForKey:@"lvl"] intValue];
            NSLog(@"%@: %@", MCEnchantmentName(idt), MCEnchantmentLevelName(lvl));
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Respawning");
            [[MCRespawnPacket packetWithInfo:nil] sendToSocket:[self socket]];
            break;
            
        default:
            [[self socket] disconnect];
            break;
    }
    [alertView release];
    if (alertView == respawnAlert) respawnAlert = nil;
}

- (void)packet:(MCPacket*)packet gotParsed:(NSDictionary *)infoDict
{
    if (((unsigned char)[packet identifier]) == 0x0D) {
        canSendPackets = YES;
        tickCount = 1;
        add = 1;
    } 
    else if (((unsigned char)[packet identifier] == 0x2B)) {
        [expview setProgress:[[infoDict objectForKey:@"ExpBar"] floatValue]];
        [[[packet sock] player] setLevel:[[infoDict objectForKey:@"Level"] shortValue]];
        [levelview setText:[[infoDict objectForKey:@"Level"] description]];
        [levelview sizeToFit];
        [levelview setCenter:[expview center]];
        [respawnAlert setMessage:[NSString stringWithFormat:@"You scored %d points", [[[packet sock] player] level]]];
        NSLog(@"%f", [[infoDict objectForKey:@"ExpBar"] floatValue]);
    } else if (((unsigned char)[packet identifier] == 0x08)) {
        [lifeview setProgress:[[infoDict objectForKey:@"Health"] floatValue]/20.0];
        [foodview setProgress:[[infoDict objectForKey:@"Food"] floatValue]/20.0];
        [satview_ setProgress:[[infoDict objectForKey:@"Food Saturation"] floatValue]/5.0];
        if ([[infoDict objectForKey:@"Health"] shortValue] <= 0) {
            NSLog(@"Asking to respawn..");
            respawnAlert = [UIAlertView new];
            [respawnAlert setTitle:@"You have died!"];
            [respawnAlert setMessage:[NSString stringWithFormat:@"You scored %d points", [[[packet sock] player] level]]];
            [respawnAlert addButtonWithTitle:@"Respawn"];
            [respawnAlert addButtonWithTitle:@"Disconnect"];
            [respawnAlert setDelegate:self];
            [respawnAlert show];
        }
    } else if (((unsigned char)[packet identifier]) == 0xFF) {
        [expview removeFromSuperview];
        [lifeview removeFromSuperview];
        [levelview removeFromSuperview];
        [foodview removeFromSuperview];
        [satview_ removeFromSuperview];
    } else if (((unsigned char)[packet identifier]) == 0x46 || ((unsigned char)[packet identifier]) == 0x01 || ((unsigned char)[packet identifier]) == 0x09)
    {
        NSLog(@"Updating Hidden Status: GameMode is %@", [[[packet sock] player] gamemode]);
        [expview setHidden:![[[[packet sock] player] gamemode] isEqualToString:@"Survival"]];
        [lifeview setHidden:![[[[packet sock] player] gamemode] isEqualToString:@"Survival"]];
        [lifeview setHidden:![[[[packet sock] player] gamemode] isEqualToString:@"Survival"]];
        [foodview setHidden:![[[[packet sock] player] gamemode] isEqualToString:@"Survival"]];
        [satview_ setHidden:![[[[packet sock] player] gamemode] isEqualToString:@"Survival"]];
        //[[[packet sock] player] setFlying:![[[[packet sock] player] gamemode] isEqualToString:@"Survival"]];
    }
    else if (((unsigned char)[packet identifier]) == 0x03) {
        NSString* msg = [[infoDict objectForKey:@"Message"] string];
        if ([msg hasSuffix:@"!login"]) {
            [[MCChatPacket packetWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"/login ciao", @"Message", nil]] sendToSocket:socket];
        }
        else if ([msg hasSuffix:@"!register"]) {
            [[MCChatPacket packetWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"/register ciao ciao", @"Message", nil]] sendToSocket:socket];
        }
        else if ([msg hasSuffix:@"!prova"]) {
            [[MCChatPacket packetWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Lexino Shoppino.", @"Message", nil]] sendToSocket:socket];
        }
        NSLog(@"%@", msg);
    }/*
      else if (((unsigned char)[packet identifier]) == 0x82) {
      }*/
}



- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)setupGL
{
    
    //[self updateChunks];
    /*
     glEnable(GL_DEPTH_TEST);
     glEnable(GL_TEXTURE_2D);
     glEnable(GL_BLEND);
     glEnable(GL_CULL_FACE);
     
     glGenVertexArraysOES(1, &_vertexArray);
     glBindVertexArrayOES(_vertexArray);
     
     glGenBuffers(1, &_vertexBuffer);
     glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
     glBufferData(GL_ARRAY_BUFFER, verts*sizeof(struct MCVertex), vertexes, GL_DYNAMIC_DRAW);
     
     glEnableVertexAttribArray(GLKVertexAttribPosition);
     glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
     glEnableVertexAttribArray(GLKVertexAttribNormal);
     glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
     
     glBindVertexArrayOES(0);*/
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    self.effect = [[[GLKBaseEffect alloc] init] autorelease];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    glEnable(GL_CULL_FACE);
    //glBufferData(GL_ARRAY_BUFFER, vbd, vbz, GL_STATIC_DRAW);
    
    //glEnableVertexAttribArray(GLKVertexAttribNormal);
    //glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_BYTE, GL_FALSE, 24, BUFFER_OFFSET(12));    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    socket = nil;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)updateChunks
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        [self updateChunksSync];
    });
}

- (void)updateChunksSync
{
    @synchronized([socket world])
    {
        if (socket) {
            int chunk_view_distance = 3;
            //int pl = chunk_view_distance * 2 + 1;
            //int i = 0;
            int ccx = [[socket player] x] / 16;
            int ccz = [[socket player] z] / 16;
            id world = [socket world];
            verts = 0;
            NSMutableArray* drawn = [[NSMutableArray alloc] initWithCapacity:[[world chunkPool] count]];
            for (int cx = -chunk_view_distance; cx < chunk_view_distance; cx++) {
                int crx = ccx + cx;
                for (int cz = -chunk_view_distance; cz < chunk_view_distance; cz++) {
                    int crz = ccz + cz;
                    MCChunk * chk = [world chunkAtCoord:MCChunkCoordMake(crx, crz) allocate:NO];
                    if (chk) {
                        [drawn addObject:chk];
                        // ergh, this used to be something useful. i am 12 and wat is dis
                        if ([chk shouldBeRendered]) {
                            glBindBuffer(GL_ARRAY_BUFFER, [chk vbo]);
                            glBufferData(GL_ARRAY_BUFFER, [chk vertexSize]*3, [chk vertexData], GL_STATIC_DRAW);
                            glEnableClientState(GL_VERTEX_ARRAY);
                            glVertexPointer([chk vertexSize], GL_BYTE, 0, (void*)0);
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
                            glDrawArrays(GL_TRIANGLES, 0, [chk vertexSize]);
                            glDisableClientState(GL_VERTEX_ARRAY);
                        }
                        [chk setShouldBeRendered:YES];
                    }
                }
            }
        draw:
            // FUK U
            for (id key in [world chunkPool]) {
                id obj = [[world chunkPool] objectForKey:key];
                if (![drawn containsObject:obj]) {
                    [obj setShouldBeRendered:NO];
                }
            }
            [drawn release];
        }
        
    }
}

- (void)chunkDidUpdate:(MCChunk *)chunk
{
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    /*
    if (lastChunkCoord.x != socket.player.x/16) {
        if (lastChunkCoord.z != socket.player.z/16) {
            [self updateChunks];
            lastChunkCoord = MCChunkCoordMake(socket.player.x/16, socket.player.z/16);
        }
    
    */
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
     GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 15.0f);
     self.effect.transform.projectionMatrix = projectionMatrix;
     
     GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
     baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, 0.0f, 0.0f, 1.0f, 0.0f);
     
     GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);    
     // Compute the model view matrix for the object rendered with ES2
     modelViewMatrix = GLKMatrix4MakeTranslation(socket.player.x, socket.player.y, socket.player.z);
    GLKMatrix4RotateZ(modelViewMatrix, DEG2RAD([[socket player] yaw]));
    GLKMatrix4RotateY(modelViewMatrix, DEG2RAD([[socket player] pitch]));
     //modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
     _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
     
     _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self updateChunksSync];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    /*
    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);*/
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, ATTRIB_VERTEX, "coord");
    //glBindAttribLocation(_program, ATTRIB_NORMAL, "normal");
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    //uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }    

    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end