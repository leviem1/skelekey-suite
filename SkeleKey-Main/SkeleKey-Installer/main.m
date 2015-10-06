//
//  main.m
//  SkeleKey-Installer
//
//  Created by Mark Hedrick on 9/29/15.
//  Copyright (c) 2015 Mark Hedrick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
