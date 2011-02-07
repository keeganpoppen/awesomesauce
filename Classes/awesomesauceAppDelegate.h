//
//  awesomesauceAppDelegate.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class awesomesauceViewController;

@interface awesomesauceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    awesomesauceViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet awesomesauceViewController *viewController;

@end

