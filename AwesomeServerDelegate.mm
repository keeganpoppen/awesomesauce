//
//  AwesomeServerDelegate.mm
//  awesomesauce
//
//  Created by The Colonel on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AwesomeServerDelegate.h"
#import "JSON.h"
#import "MatrixHandler.h"
#import "awesomesauceAppDelegate.h"

#define BACKEND_URL @"awesomeserver.heroku.com"

@implementation AwesomeServerDelegate

-(id)init {
	self = [super init];
	if (self) {
		
		//figure out if this device already has a user id
		//if not, get one from the server and store it (obviously this is the wrong way in the end game)
		user_id = [[NSUserDefaults standardUserDefaults] integerForKey:@"user_id"];
		if (user_id == 0) {
			
			//get a user id from the server
			[self performSelectorInBackground:@selector(getUserIdFromServer) withObject:nil];
		}
		
	}
	return self;
}


-(void)getUserIdFromServer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *udid = [UIDevice currentDevice].uniqueIdentifier;
	NSString *name = [UIDevice currentDevice].name;
	
	NSDictionary *request_obj = [NSDictionary dictionaryWithObjectsAndKeys:udid,@"udid",name,@"name",nil];

	SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
	NSString *compData = [[[writer stringWithObject:request_obj] retain] autorelease];
	
	NSString *urlString = [NSString stringWithFormat:@"http://%@/users", BACKEND_URL];
	NSLog(@"posting user creation junk to url: %@", urlString);
	
	NSMutableURLRequest *req = [[[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]] retain] autorelease];
	[req setHTTPBody:[compData dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSLog(@"data sent: %@", compData);
	[req setHTTPMethod:@"POST"];
	
	NSLog(@"request: %@", [req description]);
	
	NSURLResponse *resp;
	NSError *err;
	NSData *respData = [[[NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&err] retain] autorelease];
	
	SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
	NSDictionary *response = [parser objectWithString:[[[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding] autorelease]];
	
	NSLog(@"response: %@", [response description]);
	
	if ([[response objectForKey:@"success"] boolValue]) {
		user_id = [[response objectForKey:@"id"] integerValue];
		
		//save that user id
		[[NSUserDefaults standardUserDefaults] setInteger:user_id forKey:@"user_id"];
		NSLog(@"set user id to: %d", user_id);
		
		if ([[NSUserDefaults standardUserDefaults] synchronize]) {
			NSLog(@"id synchro'd");
		} else {
			NSLog(@"id synchdo'h'd");
		}

	}
	
	[pool release];
}


//public-facing version that turns around and asynchronously performs said action
-(void)requestCompositionListFromServer {
	[self performSelectorInBackground:@selector(getCompositionListFromServer) withObject:nil];
}


-(void)getCompositionListFromServer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//it's indistinguishable from magic!!!
	NSError *err;
	SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
	NSString *urlString = [NSString stringWithFormat:@"http://%@/compositions.json", BACKEND_URL];
	NSArray *compositions = [[[parser objectWithString:[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString]
																			  encoding:NSASCIIStringEncoding error:&err]] retain] autorelease];
	
	NSMutableDictionary *comps = [[[NSMutableDictionary alloc] init] autorelease];
	
	for (NSDictionary *dict in compositions) {
		NSLog(@"%@", [dict description]);
		[comps setObject:[dict objectForKey:@"name"] forKey:[dict objectForKey:@"id"]];
	}
		
	[[NSNotificationCenter defaultCenter] postNotificationName:@"composition_list_loaded" object:self userInfo:comps];
	
	[pool release];
}


//public-facing version that turns around and asynchronously performs said action
-(void)requestCompositionFromServerWithID:(int)comp_id {
	[self performSelectorInBackground:@selector(getCompositionFromServerWithID:) withObject:[NSNumber numberWithInt:comp_id]];
}


//fires a "composition_loaded" notification when the action has completed... easier than passing a selector and all that jazz
-(void)getCompositionFromServerWithID:(NSNumber*)number {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	int comp_id = [number intValue];
	
	SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
	
	NSError *err;
	NSString *compURL = [NSString stringWithFormat:@"http://%@/compositions/%d.json",BACKEND_URL, comp_id];
	NSLog(@"requesting from url: %@", compURL);
	NSDictionary *composition = [[[parser objectWithString:[NSString stringWithContentsOfURL:[NSURL URLWithString:compURL]
																					encoding:NSUTF8StringEncoding error:&err]] retain] autorelease];
	
	NSLog(@"comp: %@", [composition description]);
	
	//NSDictionary *data = [parser objectWithString:[composition objectForKey:@"data"]];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"composition_loaded" object:self userInfo:composition];
	
	[pool release];
}


//public-facing version that turns around and asynchronously performs said action
-(void)requestSendCompositionToServerWithName:(NSString*)name {
	[self performSelectorInBackground:@selector(sendCompositionToServerWithName:) withObject:name];
}


//fires a "composition_uploaded" message when it's done
-(void)sendCompositionToServerWithName:(NSString*)name {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"encoding current composition");
	
	MatrixHandler *handler = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	NSDictionary *composition = handler->encode();
	
	NSDictionary *data = [[[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",[NSNumber numberWithInt:user_id],@"user_id",composition,@"data",nil] retain] autorelease];
	
	SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
	
	NSString *compData = [[[writer stringWithObject:data] retain] autorelease];
	NSString *urlString = [NSString stringWithFormat:@"http://%@/compositions", BACKEND_URL];
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
	
	//let those interested know that the upload has completed
	[[NSNotificationCenter defaultCenter] postNotificationName:@"composition_uploaded" object:self];
	
	[pool release];
}


@end
