//
//  main.m
//  SkeleKey-Updater
//
//  Created by Levi Muniz on 10/21/15.
//  Copyright © 2015 Mark Hedrick and Levi Muniz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
