//
//  UDGameLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"

@class RRPlayer;


@interface RRGameLayer : UDLayer

@property (nonatomic, retain) RRPlayer *player1;
@property (nonatomic, retain) RRPlayer *player2;

+ (id)layerWithGameMode:(RRGameMode)gameMode firstPlayerColor:(RRPlayerColor)playerColor;
- (id)initWithGameMode:(RRGameMode)gameMode firstPlayerColor:(RRPlayerColor)playerColor;

@end
