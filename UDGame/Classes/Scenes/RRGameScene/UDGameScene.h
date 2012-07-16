//
//  UDGameScene.h
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "CCScene.h"


@interface UDGameScene : CCScene

+ (id)sceneWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(RRPlayerColor)playerColor;
- (id)initWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(RRPlayerColor)playerColor;

@end
