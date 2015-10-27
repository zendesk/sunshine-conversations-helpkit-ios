//
//  main.m
//  Smooch
//
//  Created by Mike Spensieri on 2015-10-11.
//  Copyright © 2015 Smooch Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface TestsAppDelegate: NSObject<UIApplicationDelegate>
@property(nonatomic) UIWindow* window;
@end
@implementation TestsAppDelegate
@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        if(NSClassFromString(@"XCTest")){
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([TestsAppDelegate class]));
        }else{
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
    }
}
