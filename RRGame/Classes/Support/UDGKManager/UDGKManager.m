//
//  UDGKManager.m
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGKManager.h"
#import "UDGKPlayer.h"


NSString * const UDGKManagerGotInviteNotification            = @"UDGKManagerGotInviteNotification";
NSString * const UDGKManagerAllPlayersConnectedNotification  = @"UDGKManagerAllPlayersConnectedNotification";


@implementation UDGKManager


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        _players        = [[NSMutableDictionary alloc] initWithCapacity:5];
        _packetObservers= [[NSMutableDictionary alloc] initWithCapacity:5];
        
        [self addPacketObserver:self forType:UDGKPacketTypePickHost];
    }
    return self;
}


#pragma mark -
#pragma mark UDGKManager


+ (UDGKManager *)sharedManager {
    static UDGKManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[UDGKManager alloc] init];
    });
    return _sharedManager;
}


- (BOOL)isHost {
    return (!_match || [self.playerID isEqualToString:self.hostPlayerID]);
}


- (NSString *)playerID {
    return [[GKLocalPlayer localPlayer] playerID];
}


- (void)setMatch:(GKMatch *)match {
    if ( ![_match isEqual:match] ) {
        // Destroy match
        [_match disconnect];
        [_match setDelegate:nil];
        [_match release], _match = nil;
        
        [_hostPlayerID release], _hostPlayerID = nil;
        
        // Disconnect players
        for( UDGKPlayer *player in [_players allValues] ){
            [self playerID:player.playerID didChangeState:GKPlayerStateDisconnected];
        }
        [_players removeAllObjects];
        
        // Set new match
        if( match ){
            _match = [match retain];
            
            // If match already have connected players
            [self playerID:[self playerID] didChangeState:GKPlayerStateConnected];
            for( NSString *playerID in [_match playerIDs] ){
                [self match:_match player:playerID didChangeState:GKPlayerStateConnected];
            }

            [_match setDelegate:self];
        }
    }
}


- (void)packet:(const void *)packet fromPlayerID:(NSString *)playerID {
    UDGKPlayer *player = [_players valueForKey:playerID];
    
    NSAssert1(player, @"No player for playerID: %@", playerID);
    
    NSMutableSet *observers = [_packetObservers objectForKey: [NSNumber numberWithInt:(*(UDGKPacket *)packet).type]];
    for( id <UDGKManagerPacketObserving>observer in observers ){
        [observer observePacket:packet fromPlayer:player];
    }
}


- (BOOL)sendPacketToAllPlayers:(const void *)packet length:(NSUInteger)length {
    [self packet:packet fromPlayerID: [self playerID]];

    return [_match sendDataToAllPlayers: [NSData dataWithBytes:packet length:length]
                           withDataMode: GKMatchSendDataReliable
                                  error: NULL];
}


- (BOOL)sendPacket:(const void *)packet length:(NSUInteger)length toPlayers:(NSArray *)playerIDs {
    if ( [playerIDs containsObject: [self playerID]] ) {
        [self packet:packet fromPlayerID: [self playerID]];
    }

    return [_match sendData: [NSData dataWithBytes:packet length:length]
                  toPlayers: playerIDs
               withDataMode: GKMatchSendDataReliable
                      error: NULL];
}


- (void)playerID:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    NSAssert(playerID, @"Player Without ID");
    
    UDGKPlayer *player = nil;
    
    switch ( state ) {
        case GKPlayerStateConnected: {
            if( !(player = [_players objectForKey:playerID]) ){
                player = [[UDGKPlayer alloc] init];
                [player setPlayerID:playerID];
                [_players setObject:player forKey:playerID];
                [player release];
                
                if( [playerID isEqualToString: [self playerID]] ){
                    [player setAlias: [[GKLocalPlayer localPlayer] alias]];
                }
            }
            break;
        }
        case GKPlayerStateDisconnected: {
            if( (player = [_players objectForKey:playerID]) ){
                [[player retain] autorelease];
                [_players removeObjectForKey:playerID];
            }
            break;
        }
    }

    // Do we expect any more players?
    if( state == GKPlayerStateConnected && [_match expectedPlayerCount] == 0 && ![playerID isEqualToString: [self playerID]] ){
        [[_players objectForKey:[self playerID]] setAlias: [[GKLocalPlayer localPlayer] alias]];
        
        [GKPlayer loadPlayersForIdentifiers: [_match playerIDs]
                      withCompletionHandler: ^(NSArray *players, NSError *error){
                          @synchronized( self ){
                              if( !error ){
                                  // Set Aliases
                                  for( GKPlayer *player in players ){
                                      [(UDGKPlayer *)[_players objectForKey:[player playerID]] setAlias:[player alias]];
                                  }
                              }
                              
                              if( _hostPlayerID ){
                                  [[NSNotificationCenter defaultCenter] postNotificationName:UDGKManagerAllPlayersConnectedNotification object:self];
                              }
                          }
                      }];

        NSMutableArray *allPlayers = [NSMutableArray arrayWithArray: [_match playerIDs]];
        [allPlayers addObject: self.playerID];
        [allPlayers sortUsingSelector:@selector(compare:)];

        if( [[allPlayers objectAtIndex:0] isEqualToString:self.playerID] ){
            UDGKPacketPickHost packet = UDGKPacketPickHostMake( arc4random() %[allPlayers count] );
            [[UDGKManager sharedManager] sendPacketToAllPlayers: &packet
                                                         length: sizeof(UDGKPacketPickHost)];
        }
    }
}

- (void)allPlayersConnected {
}

#pragma mark -
#pragma mark Packet Observing


- (void)addPacketObserver:(id <UDGKManagerPacketObserving>)observer forType:(UDGKPacketType)packetType {
    NSNumber *packetTypeToObserver = [NSNumber numberWithInt:packetType];
    NSMutableSet *observers = [_packetObservers objectForKey:packetTypeToObserver];
    
    if( observers ){
        [observers addObject:observer];
    }else{
        [_packetObservers setObject:[NSMutableSet setWithObject:observer] forKey:packetTypeToObserver];
    }
}


- (void)removePacketObserver:(id <UDGKManagerPacketObserving>)observer forType:(UDGKPacketType)packetType {
    NSNumber *packetTypeToObserver = [NSNumber numberWithInt:packetType];
    [[_packetObservers objectForKey:packetTypeToObserver] removeObject:observer];
    
    if( ![[_packetObservers objectForKey:packetTypeToObserver] count] ){
        [_packetObservers removeObjectForKey:packetTypeToObserver];
    }
}


- (void)removePacketObserver:(id <UDGKManagerPacketObserving>)observer {
    for ( NSNumber *packetType in [[_packetObservers allKeys] reverseObjectEnumerator] ) {
        [self removePacketObserver:observer forType: [packetType intValue]];
    }
}


#pragma mark -
#pragma mark UDGKManagerPacketObserving


- (void)observePacket:(const void *)packet fromPlayer:(UDGKPlayer *)player {
    UDGKPacketType packetType = (*(UDGKPacket *)packet).type;

    if ( packetType == UDGKPacketTypePickHost ) {
        UDGKPacketPickHost newPacket = *(UDGKPacketPickHost *)packet;

        @synchronized( self ){
            NSMutableArray *allPlayers = [NSMutableArray arrayWithArray: [_match playerIDs]];
            [allPlayers addObject: self.playerID];
            [allPlayers sortUsingSelector:@selector(compare:)];
            
            [_hostPlayerID release];
            _hostPlayerID = [[allPlayers objectAtIndex:newPacket.hostIndex] copy];

            // Check if all pears got aliases
            BOOL playersHasAliases = YES;
            for( UDGKPlayer *player in [_players allValues] ){
                if( !player.alias ){
                    playersHasAliases = NO;
                    break;
                }
            }
            
            // If all pears got aliases
            if( playersHasAliases ){
                [[NSNotificationCenter defaultCenter] postNotificationName:UDGKManagerAllPlayersConnectedNotification object:self];
            }
        }
    }
}


#pragma mark -
#pragma mark GKMatchDelegate


- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    [self packet:[data bytes] fromPlayerID:playerID];
}


- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    [self playerID:playerID didChangeState:state];
}


- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
    UDLog(@"match:didFailWithError: %@", error);
}


- (BOOL)match:(GKMatch *)match shouldReinvitePlayer:(NSString *)playerID {
    return YES;
}


@end
