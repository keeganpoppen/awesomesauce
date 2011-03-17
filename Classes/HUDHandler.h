//
//  HUDHandler.h
//  awesomesauce
//
//  Created by Keegan Poppen on 3/17/11.
//  Copyright 2011 Lord Keeganus Industries. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface HUDHandler : NSObject <MBProgressHUDDelegate> {
	UIWindow *window;
	MBProgressHUD *HUD;
}

-(void)registerListeners;
-(void)unregisterListeners;

-(void)setConnecting:(NSNotification*)notification;
-(void)setSynchronizing:(NSNotification*)notification;
-(void)setLoadingData:(NSNotification*)notification;
-(void)hide:(NSNotification*)notification;

@property(nonatomic,retain) UIWindow *window;
@property(nonatomic, retain) MBProgressHUD *HUD;

@end
