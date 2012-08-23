//
//  UDPickColorLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRPickColorLayer.h"
#import "RRGameScene.h"
#import "RRMenuScene.h"
#import "RRDifficultyScene.h"
#import "RRPopupLayer.h"


@implementation RRPickColorLayer


#pragma mark -
#pragma mark UDPickColorLayer


+ (id)layerWithNumberOfPlayers:(uint)numberOfPlayers {
    return [[[self alloc] initWithNumberOfPlayers:numberOfPlayers] autorelease];
}


- (id)initWithNumberOfPlayers:(uint)numberOfPlayers {
    if( (self = [self init]) ){
        [self setUserInteractionEnabled:YES];
        
        _numberOfPlayers = numberOfPlayers;

        CGSize winSize = [[CCDirector sharedDirector] winSize];

        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((isDeviceIPad()||isDeviceMac())?@"RRBackgroundPlayerColor~ipad.png":@"RRBackgroundPlayerColor.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite];

        CCSprite *titleTextSprite = [CCSprite spriteWithSpriteFrameName:((numberOfPlayers==1 || [[UDGKManager sharedManager] isNetworkPlayActive])?@"RRTextChooseYourAllegiance.png":@"RRTextWhoMakesTheFirstMove.png")];
        [self addChild:titleTextSprite];
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMenu.png" highliteSpriteFrameName:@"RRButtonMenuSelected.png"];
        [buttonHome setAnchorPoint:CGPointMake(1.0f, 1.0f)];
        [buttonHome addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self showMenu]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonHome];
        
        
        // Selected images
        _backgroundPlayerWhiteSelectedSprite = [CCSprite spriteWithSpriteFrameName:@"RRBackgroundPlayerWhiteSelected.png"];
        [_backgroundPlayerWhiteSelectedSprite setVisible:NO];
        [self addChild:_backgroundPlayerWhiteSelectedSprite];
        
        _backgroundPlayerBlackSelectedSprite = [CCSprite spriteWithSpriteFrameName:@"RRBackgroundPlayerBlackSelected.png"];
        [_backgroundPlayerBlackSelectedSprite setVisible:NO];
        [self addChild:_backgroundPlayerBlackSelectedSprite];
        
        CGFloat leftBottomY;    // From bottom
        CGFloat rightTopY;      // From top
        CGFloat topTopY;        // Offset from top of upper rect
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
            [titleTextSprite setPosition:CGPointMake(315, 920)];

            [_backgroundPlayerWhiteSelectedSprite setPosition:CGPointMake(165, 702)];
            [_backgroundPlayerBlackSelectedSprite setPosition:CGPointMake(594, 185)];
            
            leftBottomY = 210;
            rightTopY   = 400;
            topTopY     = 170;
        }else{
            [buttonHome setPosition:CGPointMake(winSize.width -5, winSize.height -5)];
            [buttonHome setScale:0.9f];
            [titleTextSprite setPosition:CGPointMake(130, 435)];
            [titleTextSprite setScale:0.9f];
            
            [_backgroundPlayerWhiteSelectedSprite setPosition:CGPointMake(63, 326)];
            [_backgroundPlayerBlackSelectedSprite setPosition:CGPointMake(242, 93)];
            
            leftBottomY = 100;
            rightTopY   = 200;
            topTopY     = 80;
        }
        
        _upperRect     = CGRectMake(0, winSize.height -rightTopY, winSize.width, rightTopY -topTopY);
        _upperTriangle = UDTriangleMake( CGPointMake(0, leftBottomY), CGPointMake(winSize.width, winSize.height -rightTopY), CGPointMake(0, winSize.height -rightTopY) );
        
        _lowerRect     = CGRectMake(0, 0, winSize.width, leftBottomY);
        _lowerTriangle = UDTriangleMake( CGPointMake(0, leftBottomY), CGPointMake(winSize.width, leftBottomY), CGPointMake(winSize.width, winSize.height -rightTopY) );
        
        
        if( [[UDGKManager sharedManager] isNetworkPlayActive] ){
            [self setUserInteractionEnabled:NO];

            _bannerWaitingForPlayer = [RRPopupLayer layerWithMessage: @"RRTextWaitingForOtherPlayer"];
            [self addChild:_bannerWaitingForPlayer z:1000];
        }
    }
    return self;
}


- (void)startGameWithFirstPlayerColor:(RRPlayerColor)playerColor {

    [[RRAudioEngine sharedEngine] replayEffect: [NSString stringWithFormat:@"RRPlayerColor%u.mp3", playerColor]];
    
    if( [[UDGKManager sharedManager] isNetworkPlayActive] ){
        
        UDGKPacketPickColor packet = UDGKPacketPickColorMake( playerColor );
        [[UDGKManager sharedManager] sendPacketToAllPlayers: &packet
                                                     length: sizeof(UDGKPacketPickColor)];
        
        RRGameScene *gameScene = [[RRGameScene alloc] initWithGameMode:RRGameModeClosed numberOfPlayers:_numberOfPlayers playerColor:playerColor];
        [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:gameScene]];
        [gameScene release];
    }else{
        if( _numberOfPlayers == 1 ){
            RRDifficultyScene *difficultyScene = [[RRDifficultyScene alloc] initWithGameMode:RRGameModeClosed playerColor:playerColor];
            [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:difficultyScene]];
            [difficultyScene release];
        }else{
            RRGameScene *gameScene = [[RRGameScene alloc] initWithGameMode:RRGameModeClosed numberOfPlayers:_numberOfPlayers playerColor:playerColor];
            [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:gameScene]];
            [gameScene release];
        }
    }
}


- (void)showMenu {
    
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:[RRMenuScene node] backwards:YES]];
    
}


- (void)onEnter {
    [super onEnter];
    
    [[UDGKManager sharedManager] addPacketObserver:self forType:UDGKPacketTypePickColor];
    [[UDGKManager sharedManager] addPacketObserver:self forType:UDGKPacketTypeEnterScene];
    
    [[UDGKManager sharedManager] addPlayerObserver:self forConnectionState:GKPlayerStateDisconnected];
}


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    UDGKPacketEnterScene packet = UDGKPacketEnterSceneMake( 2 );
    [[UDGKManager sharedManager] sendPacketToAllPlayers: &packet
                                                 length: sizeof(UDGKPacketEnterScene)];
}


- (void)onExitTransitionDidStart {
    [super onExitTransitionDidStart];
    
    [[UDGKManager sharedManager] removePacketObserver:self];
    [[UDGKManager sharedManager] removePlayerObserver:self];
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( CGRectContainsPoint(_upperRect, location) || UDTriangleContainsPoint(_upperTriangle, location) ){
        [self touchMovedToLocation:location];
        return YES;
    }else if( CGRectContainsPoint(_lowerRect, location) || UDTriangleContainsPoint(_lowerTriangle, location) ){
        [self touchMovedToLocation:location];
        return YES;
    }
    
    return NO;
}


- (void)touchMovedToLocation:(CGPoint)location {
    [_backgroundPlayerWhiteSelectedSprite setVisible:NO];
    [_backgroundPlayerBlackSelectedSprite setVisible:NO];

    if( CGRectContainsPoint(_upperRect, location) || UDTriangleContainsPoint(_upperTriangle, location) ){
        [_backgroundPlayerWhiteSelectedSprite setVisible:YES];
    }else if( CGRectContainsPoint(_lowerRect, location) || UDTriangleContainsPoint(_lowerTriangle, location) ){
        [_backgroundPlayerBlackSelectedSprite setVisible:YES];
    }
    
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

    [_backgroundPlayerWhiteSelectedSprite setVisible:NO];
    [_backgroundPlayerBlackSelectedSprite setVisible:NO];
}


#pragma mark -
#pragma mark UDGKManagerPacketObserving


- (void)observePacket:(const void *)packet fromPlayer:(id <UDGKPlayerProtocol>)player {
    if( [player.playerID isEqualToString: [[UDGKManager sharedManager] playerID]] ) return;

    UDGKPacketType packetType = (*(UDGKPacket *)packet).type;
    
    if ( packetType == UDGKPacketTypePickColor ) {
        UDGKPacketPickColor newPacket = *(UDGKPacketPickColor *)packet;

        // Show what color player selected
        [_backgroundPlayerWhiteSelectedSprite setVisible:(newPacket.color == RRPlayerColorWhite)];
        [_backgroundPlayerBlackSelectedSprite setVisible:(newPacket.color == RRPlayerColorBlack)];
        
        // Push game scene
        RRGameScene *gameScene = [[RRGameScene alloc] initWithGameMode:RRGameModeClosed numberOfPlayers:_numberOfPlayers playerColor:((newPacket.color==RRPlayerColorWhite)?RRPlayerColorBlack:RRPlayerColorWhite)];
        [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:gameScene]];
        [gameScene release];
    } else if( packetType == UDGKPacketTypeEnterScene && !_allPlayersInScene ){
        UDGKPacketEnterScene newPacket = *(UDGKPacketEnterScene *)packet;
        
        if( newPacket.sceneID == 2 ){
            _allPlayersInScene = YES;

            [[UDGKManager sharedManager] sendPacketToAllPlayers: &newPacket
                                                         length: sizeof(UDGKPacketEnterScene)];

            if( [[UDGKManager sharedManager] isHost] ){
                [_bannerWaitingForPlayer removeFromParentAndCleanup:YES];
                _bannerWaitingForPlayer = nil;
                
                [self setUserInteractionEnabled:YES];
            }
        }
    }
}


#pragma mark -
#pragma mark UDGKManagerPlayerObserving


- (void)observePlayer:(id <UDGKPlayerProtocol>)player state:(GKPlayerConnectionState)state {

    if( state == GKPlayerStateDisconnected ){
        [_bannerWaitingForPlayer removeFromParentAndCleanup:YES];
        _bannerWaitingForPlayer = nil;
        
        RRPopupLayer *popupLayer = [RRPopupLayer layerWithMessage: @"RRTextPlayerDisconnected"
                                                 cancelButtonName: @"RRButtonEndGame"
                                               cancelButtonAction: ^{
                                                   [self showMenu];
                                               }];
        [self addChild:popupLayer z:1000];
    }
    
}



@end
