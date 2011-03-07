//
//  AwesomeServerDelegate.h
//  awesomesauce
//
//  Created by The Colonel on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AwesomeServerDelegate : NSObject {

}

-(id)init;
-(NSDictionary*)getCompositionListFromServer;
-(NSDictionary*)getCompositionFromServerWithID:(int)comp_id;
-(bool)sendCompositionToServer:(NSDictionary*)composition withName:(NSString*)name;

@end
