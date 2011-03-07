//
//  AwesomeServerDelegate.mm
//  awesomesauce
//
//  Created by The Colonel on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AwesomeServerDelegate.h"
#import "JSON.h"

#define CUR_IP @"192.168.190.160"

@implementation AwesomeServerDelegate

-(id)init {
	self = [super init];
	if (self) {
		//TODO: DO STUFF
		//figure out if this device already has a user id
			//if not, get one from the server and store it (obviously this is the wrong way in the end game)
	}
	return self;
}


-(NSDictionary*)getCompositionListFromServer {
	//it's indistinguishable from magic!!!
	NSError *err;
	SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
	NSString *urlString = [NSString stringWithFormat:@"http://%@:3000/compositions.json", CUR_IP];
	NSArray *compositions = [[[parser objectWithString:[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString]
																			  encoding:NSASCIIStringEncoding error:&err]] retain] autorelease];
	
	NSMutableDictionary *comps = [[NSMutableDictionary alloc] init];
	
	for (NSDictionary *dict in compositions) {
		NSLog(@"%@", [dict description]);
		[comps setObject:[dict objectForKey:@"name"] forKey:[dict objectForKey:@"id"]];
	}
		
	return [comps autorelease];
}


-(NSDictionary*)getCompositionFromServerWithID:(int)comp_id {
	SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
	
	NSError *err;
	NSString *compURL = [NSString stringWithFormat:@"http://%@:3000/compositions/%d.json",CUR_IP, comp_id];
	NSLog(@"requesting from url: %@", compURL);
	NSDictionary *composition = [[parser objectWithString:[NSString stringWithContentsOfURL:[NSURL URLWithString:compURL]
																				  encoding:NSUTF8StringEncoding error:&err]] retain];
	
	NSLog(@"%@", [composition description]);
	
	return [composition autorelease];
}


-(bool)sendCompositionToServer:(NSDictionary*)composition withName:(NSString*)name {
	SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
	
	NSDictionary *data = [[[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",[NSNumber numberWithInt:2],@"user_id",composition,@"data",nil] retain] autorelease];
	
	NSString *compData = [[[writer stringWithObject:data] retain] autorelease];
	NSString *urlString = [NSString stringWithFormat:@"http://%@:3000/compositions", CUR_IP];
	NSLog(@"sending composition to url: %@", urlString);
	
	NSMutableURLRequest *req = [[[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]] retain] autorelease];
	[req setHTTPBody:[compData dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSLog(@"data sent: %@", compData);
	[req setHTTPMethod:@"POST"];
	
	NSLog(@"request: %@", [req description]);
	
	NSURLResponse *resp;
	NSError *err;
	NSData *respData = [[[NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&err] retain] autorelease];
	
	NSLog(@"response: %@", [[[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding] autorelease]);
	
	return NO;
}

@end
