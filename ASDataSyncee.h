/**
 *
 * Protocol implemented by all event handlers that deal with awesome networking
 *
 */

#import <UIKit/UIKit.h>

@class AwesomeNetworker;

@protocol ASDataSyncee

-(void)receiveData:(NSDictionary*)data fromTime:(NSTimeInterval)updateTime;

@property(nonatomic, retain) AwesomeNetworker *networker;

@end
