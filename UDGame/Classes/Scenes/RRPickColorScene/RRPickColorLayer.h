//
//  UDPickColorLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCLayer.h"


@interface RRPickColorLayer : CCLayer

+ (id)layerWithNumberOfPlayers:(NSUInteger)numberOfPlayers;
- (id)initWithNumberOfPlayers:(NSUInteger)numberOfPlayers;

@end
