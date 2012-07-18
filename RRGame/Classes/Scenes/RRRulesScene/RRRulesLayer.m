//
//  RRRulesLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRRulesLayer.h"
#import "UDSpriteButton.h"
#import "RRMenuScene.h"


@implementation RRRulesLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:@"RRBackgroundWhite.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonCherubHome.png"];
        [buttonHome setPosition:CGPointMake(635, 935)];
        [buttonHome addBlock: ^{ [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
    }
    
    return self;
}


#pragma mark -
#pragma mark RRRulesLayer


- (void)showMenu {
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
}


@end
