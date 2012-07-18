//
//  UDTile.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRTile.h"


@implementation RRTile {
    BOOL        _backSideVisible;
    
    BOOL        _lookIs3D;
    CCSprite    *_look3DSprite;
    
    RRTileEdge  _edgeTop;
    RRTileEdge  _edgeLeft;
    RRTileEdge  _edgeBottom;
    RRTileEdge  _edgeRight;
    
    CCLabelTTF  *_debugLabel;
}


#pragma mark -
#pragma mark CCSprite


- (void)setOpacity:(GLubyte)opacity {
    [super setOpacity:opacity];
    for( CCSprite *child in self.children ){
        [child setOpacity: opacity];
    }
}


- (void)setRotation:(float)rotation {
    if( rotation >= 360.0f ) rotation -= 360.0f;
    if( rotation <= -360.0f) rotation += 360.0f;

    [_debugLabel setRotation: -rotation];
    
    [super setRotation:rotation];
}


- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    
    [_debugLabel setString: [NSString stringWithFormat:@"X:%.f Y:%.f", self.positionInGrid.x, self.positionInGrid.y]];
}


- (void)setScale:(float)scale {
    [super setScale:scale];

    [self setLookIs3D:(scale == 1.0f)];
    [self setZOrder:((scale == 1.0f)?100-(int)self.position.y:NSIntegerMax)];
}


#pragma mark -
#pragma mark UDTile


+ (const CGFloat)tileSize {
    return ((isDeviceIPad())?76.0f *2.0f:76.0f);
}


+ (id)tileWithEdgeTop:(RRTileEdge)top left:(RRTileEdge)left bottom:(RRTileEdge)bottom right:(RRTileEdge)right {
    return [[[self alloc] initWithEdgeTop:top left:left bottom:bottom right:right] autorelease];
}


- (id)initWithEdgeTop:(RRTileEdge)top left:(RRTileEdge)left bottom:(RRTileEdge)bottom right:(RRTileEdge)right {
    if( (self = [self initWithSpriteFrameName:@"RREmptyTile.png"]) ){

        _edgeTop    = top;
        _edgeLeft   = left;
        _edgeBottom = bottom;
        _edgeRight  = right;
        
        if( top != RRTileEdgeNone ){
            CCSprite *topSprite = [CCSprite spriteWithSpriteFrameName: ((top == RRTileEdgeBlack)?@"RRTileEdgeBlack.png":@"RRTileEdgeWhite.png")];
            [topSprite setRotation: -90];
            [topSprite setPosition:CGPointMake(self.textureRect.size.width /2, self.textureRect.size.height -topSprite.textureRect.size.width /2)];
            [self addChild:topSprite];
        }
        
        if( left != RRTileEdgeNone ){
            CCSprite *leftSprite = [CCSprite spriteWithSpriteFrameName: ((left == RRTileEdgeBlack)?@"RRTileEdgeBlack.png":@"RRTileEdgeWhite.png")];
            [leftSprite setRotation: 180];
            [leftSprite setPosition:CGPointMake(leftSprite.textureRect.size.width /2, self.textureRect.size.height /2)];
            [self addChild:leftSprite];
        }
        
        if( bottom != RRTileEdgeNone ){
            CCSprite *bottomSprite = [CCSprite spriteWithSpriteFrameName: ((bottom == RRTileEdgeBlack)?@"RRTileEdgeBlack.png":@"RRTileEdgeWhite.png")];
            [bottomSprite setRotation: 90];
            [bottomSprite setPosition:CGPointMake(self.textureRect.size.width /2, bottomSprite.textureRect.size.width /2)];
            [self addChild:bottomSprite];
        }
        
        if( right != RRTileEdgeNone ){
            CCSprite *rightSprite = [CCSprite spriteWithSpriteFrameName: ((right == RRTileEdgeBlack)?@"RRTileEdgeBlack.png":@"RRTileEdgeWhite.png")];
            [rightSprite setPosition:CGPointMake(self.textureRect.size.width -rightSprite.textureRect.size.width /2, self.textureRect.size.height /2)];
            [self addChild:rightSprite];
        }
        
#if TARGET_IPHONE_SIMULATOR
        _debugLabel = [CCLabelTTF labelWithString:@"" fontName:@"Courier-Bold" fontSize: (isDeviceIPad()?26:13)];
        [_debugLabel setColor: ccGREEN];
        [_debugLabel setPosition:CGPointMake(self.textureRect.size.width /2, self.textureRect.size.height /2)];
        [self addChild:_debugLabel];
#endif
    }
    return self;
}


- (void)setBackSideVisible:(BOOL)backSideVisible {
    if( _backSideVisible == backSideVisible ) return;

    for( CCSprite *child in self.children ){
        if( [child isEqual:_look3DSprite] ) continue;
        [child setVisible: !backSideVisible];
    }    
    
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:((backSideVisible==YES)?@"RRTileBack.png":@"RREmptyTile.png")];

    [self setTexture:spriteFrame.texture];
    [self setTextureRect:spriteFrame.rect];

    _backSideVisible = backSideVisible;
}


- (CGPoint)positionInGrid {
    return CGPointMake((self.position.x -self.textureRect.size.width  /2) /self.textureRect.size.width,
                       (self.position.y -self.textureRect.size.height /2) /self.textureRect.size.height);
}


- (void)setPositionInGrid:(CGPoint)positionInGrid {
    [self setPosition: CGPointMake(positionInGrid.x *self.textureRect.size.width  +self.textureRect.size.width  /2,
                                   positionInGrid.y *self.textureRect.size.height +self.textureRect.size.height /2)];
}


- (RRTileEdge)edgeTop {
    switch ( (int)roundf(self.rotation) ) {
        case    0: return _edgeTop;
        case -270:
        case   90: return _edgeLeft;
        case -180:
        case  180: return _edgeBottom;
        case  -90:
        case  270: return _edgeRight;
    }
    
    return RRTileEdgeNone;
}


- (RRTileEdge)edgeLeft {
    switch ( (int)roundf(self.rotation) ) {
        case    0: return _edgeLeft;
        case -270:
        case   90: return _edgeBottom;
        case -180:
        case  180: return _edgeRight;
        case  -90:
        case  270: return _edgeTop;
    }
    
    return RRTileEdgeNone;
}


- (RRTileEdge)edgeBottom {
    switch ( (int)roundf(self.rotation) ) {
        case    0: return _edgeBottom;
        case -270:
        case   90: return _edgeRight;
        case -180:
        case  180: return _edgeTop;
        case  -90:
        case  270: return _edgeLeft;
    }
    
    return RRTileEdgeNone;
}


- (RRTileEdge)edgeRight {
    switch ( (int)roundf(self.rotation) ) {
        case    0: return _edgeRight;
        case -270:
        case   90: return _edgeTop;
        case -180:
        case  180: return _edgeLeft;
        case  -90:
        case  270: return _edgeBottom;
    }
    
    return RRTileEdgeNone;
}


- (void)setLookIs3D:(BOOL)lookIs3D {
    if( _lookIs3D == lookIs3D ) return;

    if( lookIs3D ){
        if( !_look3DSprite ){
            _look3DSprite = [CCSprite spriteWithSpriteFrameName:@"RREmptyTile3D.png"];
            [_look3DSprite setAnchorPoint:CGPointMake(0, 1)];
            [self addChild:_look3DSprite z:-1];
        }
        [_look3DSprite setRotation: -self.rotation];

        switch ( (int)roundf(self.rotation) ) {
            case    0: {
                [_look3DSprite setPosition:CGPointMake(0, 0)];
                break;
            }
            case -270:
            case   90: {
                [_look3DSprite setPosition:CGPointMake(self.textureRect.size.height, 0)];
                break;
            }
            case -180:
            case  180: {
                [_look3DSprite setPosition:CGPointMake(self.textureRect.size.width, self.textureRect.size.height)];
                break;
            }
            case  -90:
            case  270: {
                [_look3DSprite setPosition:CGPointMake(0, self.textureRect.size.width)];
                break;
            }
        }

        [_look3DSprite setVisible:YES];
    }else{
        [_look3DSprite setVisible:NO];
    }
    
    _lookIs3D = lookIs3D;
}


@synthesize backSideVisible=_backSideVisible, lookIs3D=_lookIs3D;
@end
