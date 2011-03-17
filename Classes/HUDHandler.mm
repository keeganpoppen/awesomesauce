//
//  HUDHandler.m
//  awesomesauce
//
//  Created by Keegan Poppen on 3/17/11.
//  Copyright 2011 Lord Keeganus Industries. All rights reserved.
//

#import "HUDHandler.h"
#import "graphics.h"


@implementation HUDHandler

@synthesize window;
@synthesize HUD;

-(void)registerListeners {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setConnecting:) name:@"connection_start" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSynchronizing:) name:@"synchronizing_clocks" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSynchronizing:) name:@"loading_data" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hide:) name:@"synchronizing_done" object:nil];
}

-(void)unregisterListeners {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setConnecting:(NSNotification*)notification {
	HUD = [[MBProgressHUD alloc] initWithWindow:window];
	
	setMainScreen(false);
	
	NSLog(@"HUD got connecting message");
	
	NSString *username = [[notification userInfo] objectForKey:@"username"];
	
	HUD.mode = MBProgressHUDModeIndeterminate;
	//HUD.delegate = self;
	HUD.labelText = @"reticulating splines";
	HUD.detailsLabelText = [@"connecting with user: " stringByAppendingString:username];
	HUD.removeFromSuperViewOnHide = YES;
	
	[window addSubview:HUD];
	
	[HUD show:YES];
}

-(void)setSynchronizing:(NSNotification*)notification {
	NSLog(@"HUD got clock sync message");
	
	HUD.detailsLabelText = @"synchronizing clocks";
	
}

-(void)setLoadingData:(NSNotification*)notification {
	NSLog(@"HUD got data loading message");
	
	HUD.detailsLabelText = @"loading matrix data";
	
}

-(void)hide:(NSNotification*)notification {
	NSLog(@"HUD got hide message");
	
	setMainScreen(true);
	
	[HUD hide:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	NSLog(@"hud was hidden");
	
	[HUD release];
	HUD = nil;
}

@end
