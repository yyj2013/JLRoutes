/*
 Copyright (c) 2013, Joel Levin
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of JLRoutes nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import "JLRoute.h"


@interface JLRoutes : NSObject

/** @class JLRoutes
 JLRoutes is a way to manage URL routes and invoke them from a URL.
 */


// Schemes


/// Returns the global routing namespace
+ (nonnull instancetype)defaultRoutes;

/// Returns a routing namespace for the given scheme
+ (nonnull instancetype)routesForScheme:(nonnull NSString *)scheme;

/// Unregister and delete an entire scheme namespace
+ (void)unregisterRouteScheme:(nonnull NSString *)scheme;


// Setting up routes


/// Registers a routePattern with default priority (0) in the receiving scheme namespace.
- (void)addRoute:(nonnull NSString *)routePattern handler:(nonnull BOOL (^)(NSDictionary *__nonnull parameters))handlerBlock;

/// Registers multiple routePatterns for one handler with default priority (0) in the receiving scheme namespace.
- (void)addRoutes:(nonnull NSArray<NSString *> *)routePatterns handler:(nonnull BOOL (^)(NSDictionary *__nonnull parameters))handlerBlock;

/// Removes a routePattern from the receiving scheme namespace.
- (void)removeRoute:(nonnull NSString *)routePattern;

/// Removes all routes from the receiving scheme namespace.
- (void)removeAllRoutes;

/// Registers a routePattern with default priority (0) using dictionary-style subscripting.
- (void)setObject:(nonnull BOOL (^)(NSDictionary *__nonnull parameters))handlerBlock forKeyedSubscript:(nonnull NSString *)routePatten;

/// Registers a routePattern in the global scheme namespace with a handlerBlock to call when the route pattern is matched by a URL.
/// The block returns a BOOL representing if the handlerBlock actually handled the route or not. If
/// a block returns NO, JLRoutes will continue trying to find a matching route.
- (void)addRoute:(nonnull NSString *)routePattern priority:(NSUInteger)priority handler:(nonnull BOOL (^)(NSDictionary *__nonnull parameters))handlerBlock; // instance method


// Routing


/// Routes a URL, calling handler blocks (for patterns that match URL) until one returns YES.
- (BOOL)routeURL:(nonnull NSURL *)URL;

/// Routes a URL, calling handler blocks (for patterns that match URL) until one returns YES, optionally specifying add'l parameters
- (BOOL)routeURL:(nonnull NSURL *)URL withParameters:(nullable NSDictionary *)parameters;

/// Returns whether a route exists for a URL
- (BOOL)canRouteURL:(nonnull NSURL *)URL;

/// Prints the entire routing table
+ (nonnull NSString *)description;


// Global settings


/// Allows configuration of verbose logging. Default is NO. This is mostly just helpful with debugging.
+ (void)setVerboseLoggingEnabled:(BOOL)loggingEnabled;
+ (BOOL)isVerboseLoggingEnabled;

/// Tells JLRoutes that it should manually replace '+' in parsed values to ' '. Defaults to YES.
+ (void)setShouldDecodePlusSymbols:(BOOL)shouldDeecode;
+ (BOOL)shouldDecodePlusSymbols;


// Instance settings


/// Controls whether or not this routes controller will try to match a URL with global routes if it can't be matched in the current namespace. Default is NO.
@property (nonatomic, assign) BOOL shouldFallbackToGlobalRoutes;

/// Called any time routeURL returns NO. Respects shouldFallbackToGlobalRoutes.
@property (nonatomic, copy) void (^__nullable unmatchedURLHandler)(JLRoutes *__nonnull routes, NSURL *__nonnull URL, NSDictionary *__nonnull parameters);

@end
