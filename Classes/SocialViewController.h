//
//  SocialViewController.h
//  awesomesauce
//
//  Created by Ravi Parikh on 3/6/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocialViewProtocol;
@protocol FlipViewProtocol;

@interface SocialViewController : UIViewController {
	id <FlipViewProtocol, SocialViewProtocol> delegate;

}

@property (nonatomic, retain) id <FlipViewProtocol, SocialViewProtocol> delegate;

- (IBAction)returnToMain:(id)sender;

@end

@protocol SocialViewProtocol
@end
