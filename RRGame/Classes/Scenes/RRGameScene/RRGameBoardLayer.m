//
//  UDGameBoardLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRGameBoardLayer.h"
#import "RRTile.h"


@implementation RRGameBoardLayer {
    RRGameMode          _gameMode;
    
    NSUInteger          _symbolsBlack;
    NSUInteger          _symbolsWhite;
    
    CGPoint             _activeTileLastPosition;
    
    RRTile              *_activeTile;
    CGPoint             _activeTileTouchOffset;
    BOOL                _activeTileMoved;

    CGRect              _gridBounds;
    RRTile              *_emptyTile;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_emptyTile release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark CCNode


#if DEBUG && __CC_PLATFORM_IOS
- (void)draw {
    glPushGroupMarkerEXT(0, "-[UDGameScene draw]");
    
	[super draw];
    
    /*
    ccDrawColor4B(255, 0, 0, 255);

    for( NSInteger x=-1056; x<=1000; x+=76 ){
        for( NSInteger y=-1056; y<=1000; y+=76 ){
            ccDrawLine(CGPointMake(x, y), CGPointMake(x +76, y));
            ccDrawLine(CGPointMake(x, y), CGPointMake(x, y +76));
        }
    }
    */

	glPopGroupMarkerEXT();
}
#endif


#pragma mark -
#pragma mark UDGameBoardLayer


- (id)initWithGameMode:(RRGameMode)gameMode {
	if( (self = [super init]) ) {
        [self setUserInteractionEnabled:YES];
                                      
        _gameMode   = gameMode;
        _gridBounds = CGRectNull;
        _emptyTile = [[RRTile tileWithEdgeTop:RRTileEdgeNone left:RRTileEdgeNone bottom:RRTileEdgeNone right:RRTileEdgeNone] retain];
        
        // Reset board
        [self resetBoardForGameMode:gameMode];
    }
    
    return self;
}


- (CGPoint)snapPoint:(CGPoint)point toGridWithTolerance:(CGFloat)tolerance {

    // Tile size
    const CGFloat tileSize = [RRTile tileSize];
    
    // Snaping
    CGFloat kHGridOffset = tileSize /2;
    CGFloat kVGridOffset = tileSize /2;
    
    CGFloat kHGridSpacing = tileSize;
    CGFloat kVGridSpacing = tileSize;
    
    CGPoint snapedPosition;
    snapedPosition.x = floor((point.x -kHGridOffset) /kHGridSpacing +0.5f) *kHGridSpacing +kHGridOffset;
    snapedPosition.y = floor((point.y -kVGridOffset) /kVGridSpacing +0.5f) *kVGridSpacing +kVGridOffset;
    
    if( abs(snapedPosition.x -point.x) <= tolerance ){
        point.x = snapedPosition.x;
    }
    
    if( abs(snapedPosition.y -point.y) <= tolerance ){
        point.y = snapedPosition.y;
    }
    
    return point;
}


- (BOOL)canPlaceTileAtGridLocation:(CGPoint)gridLocation {
    return [self canPlaceTileAtGridLocation:gridLocation gridBounds:NULL];
}


- (BOOL)canPlaceTileAtGridLocation:(CGPoint)gridLocation gridBounds:(CGRect *)gridBounds{
    NSInteger minX = gridLocation.x;
    NSInteger minY = gridLocation.y;
    NSInteger maxX = gridLocation.x;
    NSInteger maxY = gridLocation.y;
    BOOL foundTouchPoint = NO;
    
    for( RRTile *tile in self.children ){
        if ( [tile isEqual:_activeTile] ) continue;
        
        CGPoint positionInGrid = tile.positionInGrid;

        if ( CGPointEqualToPoint(positionInGrid, gridLocation) ) return NO;

        if( foundTouchPoint == NO ){
            foundTouchPoint = 
                    (positionInGrid.x +1 == gridLocation.x && positionInGrid.y == gridLocation.y)
                ||  (positionInGrid.x -1 == gridLocation.x && positionInGrid.y == gridLocation.y)
                ||  (positionInGrid.y +1 == gridLocation.y && positionInGrid.x == gridLocation.x)
                ||  (positionInGrid.y -1 == gridLocation.y && positionInGrid.x == gridLocation.x);
        }
        
        minX = MIN(minX, positionInGrid.x);
        minY = MIN(minY, positionInGrid.y);
        
        maxX = MAX(maxX, positionInGrid.x);
        maxY = MAX(maxY, positionInGrid.y);
    }

    if( foundTouchPoint == NO && self.children.count >= 2 ) return NO;

    if( (maxX -minX +1) > 4 ) return NO;
    if( (maxY -minY +1) > 4 ) return NO;

    // Cache some information about board
    if( gridBounds != NULL ){
        *gridBounds = CGRectMake(minX, minY, (maxX -minX +1), (maxY -minY +1));
    }
    
    return YES;
}


- (void)resetBoardForGameMode:(RRGameMode)gameMode {
    [self removeAllChildrenWithCleanup:YES];
    
    _symbolsBlack = _symbolsWhite = 0;
}


- (void)addTile:(RRTile *)tile animated:(BOOL)animated {
    _activeTile = tile;
    [self addChild:tile];
    
    if( animated ){
        [tile setOpacity:0];
        [tile runAction:[CCFadeIn actionWithDuration:0.3f]];
    }
}


- (BOOL)haltTilePlaces {
    [_activeTile setPosition: [self snapPoint:_activeTile.position toGridWithTolerance: CGFLOAT_MAX]];

    CGRect newGridBounds;        
    if( [self canPlaceTileAtGridLocation:_activeTile.positionInGrid gridBounds:&newGridBounds] ){
        [self checkForNewSymbols];
        
        [_activeTile setScale: 1.0f];
        _activeTile = nil;
        _gridBounds = newGridBounds;
        
        [self centerBoardAnimated:(self.children.count >1)];        
        
        return YES;
    }

    return NO;
}


- (void)checkForNewSymbols {
    NSUInteger white = 0;
    NSUInteger black = 0;
    
    [self countSymbolsAtTile:_activeTile white:&white black:&black];

    if( black ){
        [self willChangeValueForKey: @"symbolsBlack"];
        _symbolsBlack += black;
        [self didChangeValueForKey: @"symbolsBlack"];
    }
    
    if( white ){
        [self willChangeValueForKey: @"symbolsWhite"];
        _symbolsWhite += white;
        [self didChangeValueForKey: @"symbolsWhite"];
    }
}


- (void)countSymbolsAtTile:(RRTile *)tile white:(NSUInteger *)white black:(NSUInteger *)black {
    CGPoint gridLocation = _activeTile.positionInGrid;
    
    NSUInteger whiteSymbols = 0;
    NSUInteger blackSymbols = 0;
    
    for( RRTile *tile in self.children ){
        if( [tile isEqual:_activeTile] ) continue;
        
        CGPoint positionInGrid = tile.positionInGrid;
        
        if( positionInGrid.x +1 == gridLocation.x && positionInGrid.y == gridLocation.y ){
            if( _activeTile.edgeLeft == tile.edgeRight && _activeTile.edgeLeft != RRTileEdgeNone ){
                // | <-
                if( _activeTile.edgeLeft == RRTileEdgeWhite ){
                    whiteSymbols++;
                }else{
                    blackSymbols++;
                }
            }
        }
        
        if( positionInGrid.x -1 == gridLocation.x && positionInGrid.y == gridLocation.y ){
            if( _activeTile.edgeRight == tile.edgeLeft && _activeTile.edgeRight != RRTileEdgeNone ){
                // -> |
                if( _activeTile.edgeRight == RRTileEdgeWhite ){
                    whiteSymbols++;
                }else{
                    blackSymbols++;
                }
            }
        }
        
        if( positionInGrid.y +1 == gridLocation.y && positionInGrid.x == gridLocation.x ){
            if( _activeTile.edgeBottom == tile.edgeTop && _activeTile.edgeBottom != RRTileEdgeNone ){
                // __
                if( _activeTile.edgeBottom == RRTileEdgeWhite ){
                    whiteSymbols++;
                }else{
                    blackSymbols++;
                }
            }                            
        }
        
        if( positionInGrid.y -1 == gridLocation.y && positionInGrid.x == gridLocation.x ){
            if( _activeTile.edgeTop == tile.edgeBottom && _activeTile.edgeTop != RRTileEdgeNone ){
                // ^^
                if( _activeTile.edgeTop == RRTileEdgeWhite ){
                    whiteSymbols++;
                }else{
                    blackSymbols++;
                }
            }
        }
    }

    *white = whiteSymbols;
    *black = blackSymbols;
}


- (void)centerBoardAnimated:(BOOL)animated {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint newPosition;
    
    if( self.children.count == 0 ) {
        newPosition = CGPointMake(winSize.width /2, winSize.height /2);
    }else{
        CGRect tileBounds = CGRectMake(CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MIN, CGFLOAT_MIN);
        
        for( RRTile *tile in self.children ){
            if ( [tile isEqual:_activeTile] ) continue;
            
            tileBounds.origin.x     = MIN(tileBounds.origin.x, tile.position.x -tile.boundingBox.size.width  /2);
            tileBounds.origin.y     = MIN(tileBounds.origin.y, tile.position.y -tile.boundingBox.size.height /2);
            
            tileBounds.size.width   = MAX(tileBounds.size.width,  tile.position.x +tile.boundingBox.size.width  /2);
            tileBounds.size.height  = MAX(tileBounds.size.height, tile.position.y +tile.boundingBox.size.height /2);
        }
        
        tileBounds.size.width  -= tileBounds.origin.x;
        tileBounds.size.height -= tileBounds.origin.y;
        
        newPosition = CGPointMake((winSize.width  -tileBounds.size.width)  /2 -tileBounds.origin.x, 
                                  (winSize.height -tileBounds.size.height) /2 -tileBounds.origin.y);
    }

    // Offset
    newPosition.y += 30;
    
    if( animated ){
        [self runAction: [CCMoveTo actionWithDuration:0.3f position:newPosition]];
    }else{
        [self setPosition:newPosition];
    }
}


- (RRTile *)tileAtGridPosition:(CGPoint)gridPosition {
    
    if( _gridBounds.size.width == 4 && (gridPosition.x < _gridBounds.origin.x || (_gridBounds.origin.x +_gridBounds.size.width -1) < gridPosition.x) ){
        return _emptyTile;
    }
    
    if( _gridBounds.size.height == 4 && (gridPosition.y < _gridBounds.origin.y || (_gridBounds.origin.y +_gridBounds.size.height -1) < gridPosition.y) ){
        return _emptyTile;
    }

    for( RRTile *tile in self.children ){
        if( CGPointEqualToPoint(tile.positionInGrid, gridPosition) ) return tile;
    }
    return nil;
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( !_activeTile || [_activeTile numberOfRunningActions] || !CGRectContainsPoint(_activeTile.boundingBox, [self convertToNodeSpace:location])) return NO;
    
    [_activeTile setScale:1.1f];
    
    _activeTileMoved        = NO;
    _activeTileTouchOffset  = ccpRotateByAngle([_activeTile convertToNodeSpaceAR:location], CGPointZero, -CC_DEGREES_TO_RADIANS(_activeTile.rotation));
    _activeTileLastPosition = CGPointMake(location.x -_activeTileTouchOffset.x *_activeTile.scaleX, 
                                          location.y -_activeTileTouchOffset.y *_activeTile.scaleY);
    
    return YES;
}


- (void)touchMovedToLocation:(CGPoint)location {
    location = [self convertToNodeSpace:location];
    
    CGPoint newPosition = CGPointMake(location.x -_activeTileTouchOffset.x *_activeTile.scaleX, 
                                      location.y -_activeTileTouchOffset.y *_activeTile.scaleY);
    
    if( ccpDistance(_activeTileLastPosition, newPosition) >= 10 ){
        _activeTileMoved = YES;
    }
    
    if( [self canPlaceTileAtGridLocation:CGPointRound(_activeTile.positionInGrid)] ){
        newPosition = [self snapPoint: newPosition toGridWithTolerance: 10];
    }
    
    // Move tile
    [_activeTile setPosition: newPosition];    
}


- (void)touchEndedAtLocation:(CGPoint)location {
    
    if( !_activeTileMoved ){
        [_activeTile setScale:1.0f];
        
        [_activeTile runAction: [CCRotateBy actionWithDuration:0.2f angle:90]];
    }else if( [self canPlaceTileAtGridLocation:CGPointRound(_activeTile.positionInGrid)] ){
        [_activeTile setScale:1.0f];
        
        CGPoint snapPosition = [self snapPoint: _activeTile.position toGridWithTolerance: _activeTile.boundingBox.size.width];
        [_activeTile setPosition: snapPosition];  
    }
    
}


@synthesize symbolsBlack=_symbolsBlack, symbolsWhite=_symbolsWhite, activeTile=_activeTile;
@end
