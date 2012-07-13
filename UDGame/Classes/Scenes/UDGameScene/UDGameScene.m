//
//  UDGameScene.m
//  UDBloodyFlight
//
//  Created by Rolandas Razma on 04/04/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "UDGameScene.h"
#import "UDGameLayer.h"


@implementation UDGameScene


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        [self addChild: [UDGameLayer node]];
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


#if DEBUG && __CC_PLATFORM_IOS
- (void)draw {
    glPushGroupMarkerEXT(0, "-[UDGameScene draw]");
    
	[super draw];
    
	glPopGroupMarkerEXT();
}
#endif


@end
