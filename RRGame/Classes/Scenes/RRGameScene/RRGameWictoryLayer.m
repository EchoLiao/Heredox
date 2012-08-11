//
//  RRGameWictoryLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 27/07/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRGameWictoryLayer.h"
#import "UDSpriteButton.h"


static RRPlayerColorWictorious lastPlayerColorWictorious = RRPlayerColorWictoriousNo;


@implementation RRGameWictoryLayer


#pragma mark -
#pragma mark CCNode


- (NSInteger)mouseDelegatePriority {
	return -99;
}


- (void)onEnter {
    [super onEnter];

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_menu setPosition:CGPointMake(winSize.width /2, winSize.height +_menu.boundingBox.size.height)];
    
    [_colorBackground setOpacity:0];

    
    [_colorBackground runAction: [CCFadeTo actionWithDuration:0.27f opacity:190]];
    [_menu runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2 -_menu.boundingBox.size.height *0.1f)],
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2)],
                      nil]];
    
    
    [[RRAudioEngine sharedEngine] stopAllEffects];
    [[RRAudioEngine sharedEngine] replayEffect:[NSString stringWithFormat:@"RRPlayerColorWictorious%u.mp3", _playerColorWictorious]];
}


+ (RRPlayerColorWictorious)lastPlayerColorWictorious {
    return lastPlayerColorWictorious;
}


#pragma mark -
#pragma mark CCLayer


+ (id)layerForColor:(RRPlayerColorWictorious)playerColorWictorious {
    return [[(RRGameWictoryLayer *)[self alloc] initWithColor: playerColorWictorious] autorelease];
}


- (id)initWithColor:(RRPlayerColorWictorious)playerColorWictorious {

    if( (self = [self init]) ){
        [self setUserInteractionEnabled:YES];
        
        _playerColorWictorious = playerColorWictorious;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self setPosition:CGPointMake(0, 0)];
        
        _colorBackground = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [self addChild:_colorBackground];
        
        
        _menu = [CCSprite spriteWithSpriteFrameName:@"RRMenuBG.png"];
        [_menu setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        [self addChild:_menu];
       
        
        // RRButtonQuit
        UDSpriteButton *buttonContinue = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonContinue.png" highliteSpriteFrameName:@"RRButtonContinueSelected.png"];
        [buttonContinue addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate gameWictoryLayer:self didSelectButtonAtIndex:0];  } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonContinue];
        
        
        CCSprite *winningBanner;
        CCSprite *winningBanner2 = nil;
        switch ( playerColorWictorious ) {
            case RRPlayerColorWictoriousNo: {
                winningBanner = [CCSprite spriteWithSpriteFrameName:@"RRBannerWinNo.png"];
                break;
            }
            case RRPlayerColorWictoriousWhite: {
                winningBanner = [CCSprite spriteWithSpriteFrameName:@"RRBannerWinWhite.png"];
                if( lastPlayerColorWictorious == playerColorWictorious ){
                    winningBanner2 = [CCSprite spriteWithSpriteFrameName:@"RRTextWinWhiteConsecutively.png"];
                }
                break;
            }
            case RRPlayerColorWictoriousBlack: {
                winningBanner = [CCSprite spriteWithSpriteFrameName:@"RRBannerWinBlack.png"];
                if( lastPlayerColorWictorious == playerColorWictorious ){
                    winningBanner2 = [CCSprite spriteWithSpriteFrameName:@"RRTextWinBlackConsecutively.png"];
                }
                break;
            }
        }
        [_menu addChild:winningBanner];
        
        lastPlayerColorWictorious = playerColorWictorious;
        
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [winningBanner setPosition:CGPointMake(_menu.boundingBox.size.width  /2, _menu.boundingBox.size.height /2 +80)];
            if( winningBanner2 ){
                [_menu addChild:winningBanner2];
                [winningBanner2 setAnchorPoint:CGPointMake(0.5, 1)];
                [winningBanner2 setPosition:CGPointMake(winningBanner.position.x, winningBanner.position.y -winningBanner.boundingBox.size.height /2 +40)];
            }
            
            [buttonContinue setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 80)];
        }else{
            [winningBanner setPosition:CGPointMake(_menu.boundingBox.size.width  /2, _menu.boundingBox.size.height /2 +40)];
            if( winningBanner2 ){
                [_menu addChild:winningBanner2];
                [winningBanner2 setAnchorPoint:CGPointMake(0.5, 1)];
                [winningBanner2 setPosition:CGPointMake(winningBanner.position.x, winningBanner.position.y -winningBanner.boundingBox.size.height /2 +15)];
            }
            
            [buttonContinue setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 45)];
        }

    }
    return self;
}


#pragma mark -
#pragma mark RRGameWictoryLayer


- (void)dismiss {
    [_colorBackground stopAllActions];
    [_menu stopAllActions];
    
    [_colorBackground runAction:[CCFadeOut actionWithDuration:0.31f]];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_menu setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
    
    [_menu runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height +_menu.boundingBox.size.height)],
                      [UDActionDestroy actionWithTarget:self],
                      nil]];
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    return YES;
}


@synthesize delegate=_delegate;
@end
