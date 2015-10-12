//
//  main.m
//  SkeleKey-Client
//
//  Created by Mark Hedrick on 10/11/15.
//  Copyright © 2015 SEBS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
