//
//  GlobeViewController.h
//  awesomesauce
//
//  Created by Ravi Parikh on 3/7/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialViewController.h"

@interface GlobeViewController : UIViewController {
	SocialViewController *parent;
}

@property(nonatomic, retain) SocialViewController *parent;

- (IBAction)returnToMain:(id)sender;

@end
