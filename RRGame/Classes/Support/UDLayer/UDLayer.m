//
//  UDLayer.m
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import "UDLayer.h"
#import "cocos2d.h"


@implementation UDLayer


#pragma mark -
#pragma mark UDLayer


- (void)setUserInteractionEnabled:(BOOL)enabled {
    if( [self isUserInteractionEnabled] == enabled ) return;
    
#ifdef __CC_PLATFORM_IOS
    [self setIsTouchEnabled: enabled];
    if( isRunning_ ){
        if( enabled ){
            [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:[self mouseDelegatePriority] swallowsTouches:YES];
        }else{
            [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
        }
    }
#elif defined(__CC_PLATFORM_MAC)
    [self setIsMouseEnabled: enabled];
#endif
}


- (BOOL)isUserInteractionEnabled {
#ifdef __CC_PLATFORM_IOS
    return [self isTouchEnabled];
#elif defined(__CC_PLATFORM_MAC)
    return [self isMouseEnabled];
#endif
    return NO;
}


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    // Overwrite me
    return NO;
}
    

- (void)touchMovedToLocation:(CGPoint)location {
    // Overwrite me
}


- (void)touchEndedAtLocation:(CGPoint)location {
    // Overwrite me
}


#pragma mark -
#pragma mark CCNode


- (NSInteger)mouseDelegatePriority {
	return 0;
}


#ifdef __CC_PLATFORM_IOS


- (void)onEnter {
    if( [self isUserInteractionEnabled] ){
        [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate: self
                                                                priority: [self mouseDelegatePriority]
                                                         swallowsTouches: YES];
    }
    [super onEnter];
}


- (void)onExit {
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    [super onExit];
}


#pragma mark -
#pragma mark CCTargetedTouchDelegate


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if( !visible_ ) return NO;
	
	for( CCNode *c = self.parent; c != nil; c = c.parent ){
		if( c.visible == NO ) return NO;
    }

    _touchActive = [self touchBeganAtLocation: [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]]];
    return _touchActive;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [self touchMovedToLocation: [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]]];
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self touchEndedAtLocation: [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]]];
}


#elif defined(__CC_PLATFORM_MAC)


#pragma mark -
#pragma mark CCMouseEventDelegate


- (BOOL)ccMouseDown:(NSEvent *)event {
    if( !visible_ ) return NO;

    _touchActive = [self touchBeganAtLocation: [(CCDirectorMac *)[CCDirector sharedDirector] convertEventToGL:event]];
    return _touchActive;
}


- (BOOL)ccMouseDragged:(NSEvent *)event {
    if( !visible_ || !_touchActive ) return NO;
    
    [self touchMovedToLocation: [(CCDirectorMac *)[CCDirector sharedDirector] convertEventToGL:event]];
    return YES;
}


- (BOOL)ccMouseUp:(NSEvent *)event {
    if( !visible_ || !_touchActive ) return NO;
    
    [self touchEndedAtLocation: [(CCDirectorMac *)[CCDirector sharedDirector] convertEventToGL:event]];
    _touchActive = NO;
    return YES;
}


#endif


@end
