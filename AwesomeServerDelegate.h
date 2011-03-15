//
//  AwesomeServerDelegate.h
//  awesomesauce
//
//  Created by The Colonel on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AwesomeServerDelegate : NSObject {
	NSInteger user_id;
}

-(id)init;

-(void)getUserIdFromServer;

-(void)requestCompositionListFromServer;
//-(NSDictionary*)getCompositionListFromServer;

-(void)requestCompositionFromServerWithID:(int)comp_id;
//-(NSDictionary*)getCompositionFromServerWithID:(int)comp_id;

-(void)requestSendCompositionToServerWithName:(NSString *)name;
//-(bool)sendCompositionToServer:(NSDictionary*)composition withName:(NSString*)name;

@end
