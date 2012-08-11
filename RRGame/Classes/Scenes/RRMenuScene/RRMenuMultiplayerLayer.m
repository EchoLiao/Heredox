//
//  RRMenuMultiplayerLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRMenuMultiplayerLayer.h"


@implementation RRMenuMultiplayerLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        
        [self setUserInteractionEnabled:YES];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self setPosition:CGPointMake(0, 0)];
        
        _colorBackground = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [self addChild:_colorBackground];
        
        _menu = [CCSprite spriteWithSpriteFrameName:@"RRMenuBG.png"];
        [_menu setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        [self addChild:_menu];

        // Local
        UDSpriteButton *buttonLocal = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMultiplayerLocal.png" highliteSpriteFrameName:@"RRButtonMultiplayerLocalSelected.png"];
        [buttonLocal addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate menuMultiplayerLayer:self didSelectButtonAtIndex:0]; } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonLocal];
        
        // GameCenter
        UDSpriteButton *buttonGameCenter = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMultiplayerGameCenter.png" highliteSpriteFrameName:@"RRButtonMultiplayerGameCenterSelected.png"];
        [buttonGameCenter addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate menuMultiplayerLayer:self didSelectButtonAtIndex:1]; } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonGameCenter];
        
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonLocal setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 570)];
            [buttonGameCenter setPosition:CGPointMake(_menu.boundingBox.size.width /2, 450)];
        } else {
            [buttonLocal setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 260)];
            [buttonGameCenter setPosition:CGPointMake(_menu.boundingBox.size.width /2, 205)];
        }
    }
    
    return self;
}


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
}


#pragma mark -
#pragma mark RRMenuMultiplayerLayer


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


@synthesize delegate=_delegate;
@end
