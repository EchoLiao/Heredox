//
//  RRAI.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/16/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRAIPlayer.h"
#import "RRGameBoardLayer.h"
#import "RRTile.h"


@implementation RRAIPlayer


#pragma mark -
#pragma mark RRPlayer


- (id)initWithPlayerColor:(RRPlayerColor)playerColor {
    if( (self = [super initWithPlayerColor:playerColor]) ){
        _dificultyLevel = RRAILevelDeacon;
    }
    return self;
}


#pragma mark -
#pragma mark RRAIPlayer


- (RRTileMove)bestMoveOnBoard:(RRGameBoardLayer *)gameBoard {
    RRTileMove tileMove = RRTileMoveZero;
    RRTile *activeTile  = gameBoard.activeTile;
    CGPoint activeTilePosition = activeTile.position;

    
    /*
        Wonder if it would make more sense to build kind of C matrix here
        board[x][y] = TRLB
     
        so you could query like board[x][y][0] = T
                                board[x][y][1] = R
                                board[x][y][2] = L
                                board[x][y][3] = B
     
        so if tile[x][y][T] == tile[x][y+1][B]
        
     
        or even TopWhie  | LeftBlack
                TopBlack | LeftWhite
     
        so if tile[x][y] & TopWhie == tile[x][y+1] & BottomWhie
     
        int (*boardRepresentation)[9] = calloc(9, sizeof(*boardRepresentation));
     */

    
    for ( RRTile *tile in gameBoard.children ) {
        if( [tile isEqual:activeTile] ) continue;

        CGPoint positionInGrid = tile.positionInGrid;

        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x +1, positionInGrid.y)] ){

            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x +1, positionInGrid.y)];
            if( bestMove.score > tileMove.score ){
                tileMove = bestMove;
            }
            
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x -1, positionInGrid.y)] ){

            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x -1, positionInGrid.y)];
            if( bestMove.score > tileMove.score ){
                tileMove = bestMove;
            }
            
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y +1)] ){

            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y +1)];
            if( bestMove.score > tileMove.score ){
                tileMove = bestMove;
            }
            
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y -1)] ){

            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y -1)];
            if( bestMove.score > tileMove.score ){
                tileMove = bestMove;
            }
            
        }
        
    }
    
    [activeTile setPosition:activeTilePosition];
    [activeTile setRotation:0];

    return tileMove;
}


- (RRTileMove)bestMoveOnGameBoard:(RRGameBoardLayer *)gameBoard positionInGrid:(CGPoint)positionInGrid {
    RRTileMove tileMove = RRTileMoveZero;
    RRTile *activeTile = gameBoard.activeTile;
    
    [activeTile setPositionInGrid:positionInGrid];

    CGFloat edgeBlockModifyer = [self edgeBlockModifyerForMoveOnGameBoard:gameBoard positionInGrid:positionInGrid];
    
    for( NSUInteger angle=0; angle<=270; angle += 90 ){
        [activeTile setRotation:angle];

        NSUInteger white, black;
        [gameBoard countSymbolsAtTile:activeTile white:&white black:&black];

        // Count how much points you gain
        CGFloat moveValue;
        if( self.playerColor == RRPlayerColorBlack ){
            moveValue = (float)black -(float)white;
        }else if( self.playerColor == RRPlayerColorWhite ){
            moveValue = (float)white -(float)black;
        }

        // Count how bad this move is in other means
        RRTile *tileOnTop, *tileOnRight, *tileOnBottom, *tileOnLeft;
        if( (tileOnTop = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x, positionInGrid.y +1)]) ) {
            
            // Can block active tile edge
            if(   tileOnTop.edgeBottom == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeTop != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeTop != self.playerColor ){
                moveValue += 0.3f;
            }
            
            // Can block above tile edge with active tile?
            if(   tileOnTop.edgeBottom != RRTileEdgeNone 
               && tileOnTop.edgeBottom != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeTop == RRTileEdgeNone ){
                moveValue += 0.3f;
            }
            
            // Will I block my own edge?
            if(   (RRPlayerColor)activeTile.edgeTop == self.playerColor
               && (RRPlayerColor)tileOnTop.edgeBottom != self.playerColor ){
                moveValue -= 0.5f;
            }
        }
        
        
        if( (tileOnRight = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x +1, positionInGrid.y)]) ) {
            
            // Can block active tile edge
            if(   tileOnRight.edgeLeft == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeRight != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeRight != self.playerColor ){
                moveValue += 0.3f;
            }
            
            // Can block above tile edge with active tile?
            if(   tileOnRight.edgeLeft != RRTileEdgeNone 
               && tileOnRight.edgeLeft != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeRight == RRTileEdgeNone ){
                moveValue += 0.3f;
            }
            
            // Will I block my own edge?
            if(   (RRPlayerColor)activeTile.edgeRight == self.playerColor
               && (RRPlayerColor)tileOnRight.edgeLeft != self.playerColor ){
                moveValue -= 0.5f;
            }
        }
        
        
        if( (tileOnBottom = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x, positionInGrid.y -1)]) ) {
            
            // Can block active tile edge
            if(   tileOnBottom.edgeTop == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeBottom != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeBottom != self.playerColor ){
                moveValue += 0.3f;
            }
            
            // Can block above tile edge with active tile?
            if(   tileOnBottom.edgeTop != RRTileEdgeNone 
               && tileOnBottom.edgeTop != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeBottom == RRTileEdgeNone ){
                moveValue += 0.3f;
            }
            
            // Will I block my own edge?
            if(   (RRPlayerColor)activeTile.edgeBottom == self.playerColor
               && (RRPlayerColor)tileOnBottom.edgeTop  != self.playerColor ){
                moveValue -= 0.5f;
            }
        }
        
        
        if( (tileOnLeft = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x -1, positionInGrid.y)]) ) {
            
            // Can block active tile edge
            if(   tileOnLeft.edgeRight == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeLeft != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeLeft != self.playerColor ){
                moveValue += 0.3f;
            }
            
            // Can block above tile edge with active tile?
            if(   tileOnLeft.edgeRight != RRTileEdgeNone 
               && tileOnLeft.edgeRight != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeLeft == RRTileEdgeNone ){
                moveValue += 0.3f;
            }
            
            // Will I block my own edge?
            if(   (RRPlayerColor)activeTile.edgeLeft  == self.playerColor
               && (RRPlayerColor)tileOnLeft.edgeRight != self.playerColor ){
                moveValue -= 0.5f;
            }
        }

        if( _dificultyLevel > RRAILevelNovice ){
            moveValue += [self activeTileEdgeBlockModifyerForMoveOnGameBoard:gameBoard positionInGrid:positionInGrid];
            if( _dificultyLevel > RRAILevelDeacon ){
                moveValue += edgeBlockModifyer;
                moveValue += [self nextTurnEdgeBlockModifyerForMoveOnGameBoard:gameBoard positionInGrid:positionInGrid];
                moveValue += [self nextTurnPointsScoreModifyerForMoveOnGameBoard:gameBoard positionInGrid:positionInGrid];
            }
        }
        
        if( moveValue >= tileMove.score ){
            tileMove.score    = moveValue;
            tileMove.rotation = angle;
            tileMove.positionInGrid = activeTile.positionInGrid;
        }
    }
    
    return tileMove;
}


- (CGFloat)edgeBlockModifyerForMoveOnGameBoard:(RRGameBoardLayer *)gameBoard positionInGrid:(CGPoint)positionInGrid {
    CGFloat edgeBlockModifyer = 0.0f;

    if( gameBoard.gridBounds.size.height == 3 ){
        
        NSInteger upperGridBoundY = gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height -1;
        NSInteger lowerGridBoundY = gameBoard.gridBounds.origin.y;
        
        if( positionInGrid.y > upperGridBoundY ){

            for( NSInteger x=gameBoard.gridBounds.origin.x; x<gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width; x++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(x, lowerGridBoundY)];
                
                if( edgeTile.edgeBottom == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.5f;
                }else if( edgeTile.edgeBottom != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                }
            }
            
        }else if( positionInGrid.y < lowerGridBoundY ){

            for( NSInteger x=gameBoard.gridBounds.origin.x; x<gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width; x++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(x, upperGridBoundY)];
                
                if( edgeTile.edgeTop == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.5f;
                }else if( edgeTile.edgeTop != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                }
            }
            
        }
    }
    
    if( gameBoard.gridBounds.size.width == 3 ){
        
        NSInteger leftGridBoundX = gameBoard.gridBounds.origin.x;
        NSInteger rightGridBoundX = gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width -1;
        
        if( positionInGrid.x < leftGridBoundX ){

            for( NSInteger y=gameBoard.gridBounds.origin.y; y<gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height; y++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(rightGridBoundX, y)];
                
                if( edgeTile.edgeRight == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.5f;
                }else if( edgeTile.edgeRight != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                }
            }     
            
        }else if( positionInGrid.x > rightGridBoundX ){

            for( NSInteger y=gameBoard.gridBounds.origin.y; y<gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height; y++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(leftGridBoundX, y)];
                
                if( edgeTile.edgeLeft == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.5f;
                }else if( edgeTile.edgeLeft != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                }
            }

        }
    }
    
    return edgeBlockModifyer;
}


- (CGFloat)activeTileEdgeBlockModifyerForMoveOnGameBoard:(RRGameBoardLayer *)gameBoard positionInGrid:(CGPoint)positionInGrid {
    RRTile *activeTile = gameBoard.activeTile;
    CGFloat edgeBlockModifyer = 0.0f;

    
    // Active tile blocking after move
    if( gameBoard.gridBounds.size.height == 3 ){
        
        NSInteger upperGridBoundY = gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height -1;
        NSInteger lowerGridBoundY = gameBoard.gridBounds.origin.y;
        
        if( positionInGrid.y > upperGridBoundY ){

            if( activeTile.edgeTop == (RRTileEdge)self.playerColor ){
                edgeBlockModifyer -= 0.5f;
            }else if( activeTile.edgeTop != RRTileEdgeNone ){
                edgeBlockModifyer += 0.3f;
            }
            
        }else if( positionInGrid.y < lowerGridBoundY ){

            if( activeTile.edgeBottom == (RRTileEdge)self.playerColor ){
                edgeBlockModifyer -= 0.5f;
            }else if( activeTile.edgeBottom != RRTileEdgeNone ){
                edgeBlockModifyer += 0.3f;
            }
            
        }
    }
    
    
    if( gameBoard.gridBounds.size.width == 3 ){
        
        NSInteger leftGridBoundX = gameBoard.gridBounds.origin.x;
        NSInteger rightGridBoundX = gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width -1;
        
        if( positionInGrid.x < leftGridBoundX ){

            if( activeTile.edgeLeft == (RRTileEdge)self.playerColor ){
                edgeBlockModifyer -= 0.5f;
            }else if( activeTile.edgeLeft != RRTileEdgeNone ){
                edgeBlockModifyer += 0.3f;
            }
            
        }else if( positionInGrid.x > rightGridBoundX ){

            if( activeTile.edgeRight == (RRTileEdge)self.playerColor ){
                edgeBlockModifyer -= 0.5f;
            }else if( activeTile.edgeRight != RRTileEdgeNone ){
                edgeBlockModifyer += 0.3f;
            }
            
        }
    }
    
    
    return edgeBlockModifyer;
}


- (CGFloat)nextTurnEdgeBlockModifyerForMoveOnGameBoard:(RRGameBoardLayer *)gameBoard positionInGrid:(CGPoint)positionInGrid {
    CGFloat edgeBlockModifyer = 0.0f;

    if( gameBoard.gridBounds.size.height == 3 ){
        
        NSInteger upperGridBoundY = gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height -1;
        NSInteger lowerGridBoundY = gameBoard.gridBounds.origin.y;

        // If I leave width == 3 this turn, how much damage can other player make on his turn?
        if( (positionInGrid.y <= upperGridBoundY) && (positionInGrid.y >= lowerGridBoundY) ){

            // If other player will block bottom
            for( NSInteger x=gameBoard.gridBounds.origin.x; x<gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width; x++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(x, lowerGridBoundY)];
                
                if( edgeTile.edgeBottom == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.3f;
                    //UDLog(@"-= 0.2 (YB @ %@)", NSStringFromCGPoint(edgeTile.positionInGrid));
                }else if( edgeTile.edgeBottom != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;   
                    //UDLog(@"+= 0.2 (YB @ %@)", NSStringFromCGPoint(edgeTile.positionInGrid));
                }
            }

            // If other player will block top
            for( NSInteger x=gameBoard.gridBounds.origin.x; x<gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width; x++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(x, upperGridBoundY)];
                
                if( edgeTile.edgeTop == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.3f;
                    //UDLog(@"-= 0.2 (YT @ %@)", NSStringFromCGPoint(edgeTile.positionInGrid));
                }else if( edgeTile.edgeTop != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                    //UDLog(@"+= 0.2 (YT @ %@)", NSStringFromCGPoint(edgeTile.positionInGrid));
                }
            }
        }
    }
    
    if( gameBoard.gridBounds.size.width == 3 ){
        
        NSInteger leftGridBoundX = gameBoard.gridBounds.origin.x;
        NSInteger rightGridBoundX = gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width -1;
        
        // If I leave height == 3 this turn, how much damage can other player make on his turn?
        if( (positionInGrid.x >= leftGridBoundX) && (positionInGrid.x <= rightGridBoundX) ){

            // If other player will block right
            for( NSInteger y=gameBoard.gridBounds.origin.y; y<gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height; y++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(rightGridBoundX, y)];

                if( edgeTile.edgeRight == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.3f;
                    //UDLog(@"-= 0.2 (XR @ %@)", NSStringFromCGPoint(edgeTile.positionInGrid));
                }else if( edgeTile.edgeRight != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                    //UDLog(@"+= 0.2 (XR @ %@)", NSStringFromCGPoint(edgeTile.positionInGrid));
                }
            }

            // If other player will block left
            for( NSInteger y=gameBoard.gridBounds.origin.y; y<gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height; y++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(leftGridBoundX, y)];
             
                if( edgeTile.edgeLeft == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.3f;
                    //UDLog(@"-= 0.2 (XL @ %@)", NSStringFromCGPoint(edgeTile.positionInGrid));
                }else if( edgeTile.edgeLeft != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                    //UDLog(@"+= 0.2 (XL @ %@)", NSStringFromCGPoint(edgeTile.positionInGrid));
                }
            }

        }
    }

    return edgeBlockModifyer;
}


// What is possibility to gain 2 points next turn?
- (CGFloat)nextTurnPointsScoreModifyerForMoveOnGameBoard:(RRGameBoardLayer *)gameBoard positionInGrid:(CGPoint)positionInGrid {
    if( !_tilesInDeck || !_tilesInDeck.count ) return 0.0f;
    
    CGFloat pointsScoreModifyer = 0.0f;
    
    float (^possibilityToGetTileOfType)(RRTileType) = ^(RRTileType type) {
        NSUInteger numberOfTiles = 0;
        for( RRTile *tile in _tilesInDeck ){
            if( tile.tileType & type ) numberOfTiles++;
        }
        return (float)numberOfTiles /(float)_tilesInDeck.count;
    };
    
    
    for ( RRTile *tile in gameBoard.children ) {
        
        if( tile.edgeRight == (RRTileEdge)self.oponentColor ){
            
            if( ![gameBoard tileAtGridPosition:CGPointMake(tile.positionInGrid.x +1, tile.positionInGrid.y)] ){
                
                // <->
                RRTile *tileXX = [gameBoard tileAtGridPosition:CGPointMake(tile.positionInGrid.x +2, tile.positionInGrid.y)];
                if( tileXX && tileXX.edgeLeft == (RRTileEdge)self.oponentColor ){
                    if( possibilityToGetTileOfType(RRTileTypeWBWB) >= 0.5f ){
                        pointsScoreModifyer = -0.5f;
                    }
                }
                
                // <_
                RRTile *tileLY = [gameBoard tileAtGridPosition:CGPointMake(tile.positionInGrid.x +1, tile.positionInGrid.y -1)];
                if( tileLY && tileLY.edgeTop == (RRTileEdge)self.oponentColor ){
                    if( possibilityToGetTileOfType(RRTileTypeWWBB) >= 0.5f ){
                        pointsScoreModifyer = -0.5f;
                    }
                }
                
                // <^
                RRTile *tileUY = [gameBoard tileAtGridPosition:CGPointMake(tile.positionInGrid.x +1, tile.positionInGrid.y +1)];
                if( tileUY && tileUY.edgeBottom == (RRTileEdge)self.oponentColor ){
                    if( possibilityToGetTileOfType(RRTileTypeWWBB) >= 0.5f ){
                        pointsScoreModifyer = -0.5f;
                    }
                }
                
            }

        }else if( tile.edgeLeft == (RRTileEdge)self.oponentColor ){
            
            if( ![gameBoard tileAtGridPosition:CGPointMake(tile.positionInGrid.x -1, tile.positionInGrid.y)] ){
                
                // <->
                RRTile *tileXX = [gameBoard tileAtGridPosition:CGPointMake(tile.positionInGrid.x -2, tile.positionInGrid.y)];
                if( tileXX && tileXX.edgeRight == (RRTileEdge)self.oponentColor ){
                    if( possibilityToGetTileOfType(RRTileTypeWBWB) >= 0.5f ){
                        pointsScoreModifyer = -0.5f;
                    }
                }
                
                // _>
                RRTile *tileLY = [gameBoard tileAtGridPosition:CGPointMake(tile.positionInGrid.x -1, tile.positionInGrid.y -1)];
                if( tileLY && tileLY.edgeTop == (RRTileEdge)self.oponentColor ){
                    if( possibilityToGetTileOfType(RRTileTypeWWBB) >= 0.5f ){
                        pointsScoreModifyer = -0.5f;
                    }
                }
                
                // ^>
                RRTile *tileUY = [gameBoard tileAtGridPosition:CGPointMake(tile.positionInGrid.x -1, tile.positionInGrid.y +1)];
                if( tileUY && tileUY.edgeBottom == (RRTileEdge)self.oponentColor ){
                    if( possibilityToGetTileOfType(RRTileTypeWWBB) >= 0.5f ){
                        pointsScoreModifyer = -0.5f;
                    }
                }
                
            }
            
        }
    }
    
    
    return pointsScoreModifyer;
}


- (RRPlayerColor)oponentColor {
    return ((self.playerColor == RRPlayerColorBlack)?RRPlayerColorWhite:RRPlayerColorBlack);
}


@synthesize dificultyLevel=_dificultyLevel;
@end
