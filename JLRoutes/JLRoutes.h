/*
 Copyright (c) 2015, Joel Levin
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of JLRoutes nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import "JLURLRouter.h"


static NSString *__nonnull const JLRoutesDefaultRouterScheme = @"JLRoutesDefaultRouterScheme";


typedef NS_ENUM(NSUInteger, JLRoutesLogLevel)
{
    /// No logging
    JLRoutesLogLevelNone = 0,
    
    /// Basic logging of events as they happen
    JLRoutesLogLevelInfo,
    
    /// Verbose logging, only intended for debugging
    JLRoutesLogLevelVerbose
};

/// Logs the formatted message with the given level
extern void JLRoutesLog(JLRoutesLogLevel level, NSString *__nonnull format, ...);


@interface JLRoutes : NSObject

/**
 @class JLRoutes
 JLRoutes is a way to manage URL routes and invoke them from a URL.
 */


// -- Router management -----------------

/// The default (global) router
+ (nonnull __kindof JLURLRouter *)defaultRouter;

/// Returns (or creates) a router for the given URL scheme
+ (nonnull __kindof JLURLRouter *)routerForScheme:(nonnull NSString *)scheme;

/// Unregister and delete a router
+ (void)unregisterRouterForScheme:(nonnull NSString *)scheme;

/// Unregister a specific router instance
+ (void)unregisterRouter:(nonnull __kindof JLURLRouter *)router;


// -- Convenience -----------------

/// Tries to find a valid router for this URL.
+ (BOOL)canRouteURL:(nonnull NSURL *)URL;

/// Route the given URL, if possible.
+ (BOOL)routeURL:(nonnull NSURL *)URL;

/// Route the given URL, if possible. Appends userInfo, if passed.
+ (BOOL)routeURL:(nonnull NSURL *)URL userInfo:(nullable NSDictionary *)userInfo;


// -- Global settings -----------------

/// Allows configuration of verbose logging. Default is NO. This is mostly just helpful with debugging.
+ (void)setLogLevel:(JLRoutesLogLevel)logLevel;
+ (JLRoutesLogLevel)logLevel;

/// Tells JLRoutes that it should manually replace '+' in parsed values to ' '. Defaults to YES.
+ (void)setShouldDecodePlusSymbols:(BOOL)shouldDeecode;
+ (BOOL)shouldDecodePlusSymbols;

/// Customize the router class
+ (void)setURLRouterClass:(nonnull Class)routerClass;
+ (nonnull Class)URLRouterClass;

@end
