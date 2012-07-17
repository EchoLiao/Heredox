//
//  UDPickColorLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRPickColorLayer.h"
#import "UDSpriteButton.h"
#import "RRGameScene.h"
#import "RRMenuScene.h"


@implementation RRPickColorLayer {
    NSUInteger _numberOfPlayers;
    
    CGRect     _upperRect;
    UDTriangle _upperTriangle;
    CGRect     _lowerRect;
    UDTriangle _lowerTriangle;
}


#pragma mark -
#pragma mark UDPickColorLayer


+ (id)layerWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    return [[[self alloc] initWithNumberOfPlayers:numberOfPlayers] autorelease];
}


- (id)initWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    if( (self = [self init]) ){
        [self setUserInteractionEnabled:YES];
        
        _numberOfPlayers = numberOfPlayers;
        
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        _upperRect     = CGRectMake(0, winSize.height -315, winSize.width, 315);
        _upperTriangle = UDTriangleMake( CGPointMake(0, 260), CGPointMake(winSize.width, winSize.height -315), CGPointMake(0, winSize.height -315) );
        
        _lowerRect     = CGRectMake(0, 0, winSize.width, 260);
        _lowerTriangle = UDTriangleMake( CGPointMake(0, 260), CGPointMake(winSize.width, 260), CGPointMake(winSize.width, winSize.height -315) );
        
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:@"RRBackgroundPlayerColor.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];

        
        // Add menu button
        /*
        UDSpriteButton *buttonHome = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonHome.png"];
        [buttonHome setPosition:CGPointMake(655, 915)];
        [buttonHome addBlock: ^{ [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
        */
    }
    return self;
}


- (void)startGameWithFirstPlayerColor:(RRPlayerColor)playerColor {
 
    RRGameScene *gameScene = [[RRGameScene alloc] initWithGameMode:RRGameModeClosed numberOfPlayers:_numberOfPlayers firstPlayerColor:playerColor];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:gameScene]];
    [gameScene release];
    
}


- (void)showMenu {
    
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
    
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {

    return YES;
}


- (void)touchEndedAtLocation:(CGPoint)location {

    if( CGRectContainsPoint(_upperRect, location) || UDTriangleContainsPoint(_upperTriangle, location) ){
        [self startGameWithFirstPlayerColor: RRPlayerColorWhite];
        return;
    }
    if( CGRectContainsPoint(_lowerRect, location) || UDTriangleContainsPoint(_lowerTriangle, location) ){
        [self startGameWithFirstPlayerColor: RRPlayerColorBlack];
        return;
    }

}


@end
