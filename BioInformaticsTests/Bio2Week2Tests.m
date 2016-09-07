//
//  Bio2Week2Tests.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 9/6/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestConfig.h"
#import "Graph.h"

@interface Bio2Week2Tests : XCTestCase

@end

@implementation Bio2Week2Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testEulerCycle {

    NSString *adj = @"\
0 -> 3\n\
1 -> 0\n\
2 -> 1,6\n\
3 -> 2\n\
4 -> 2\n\
5 -> 4\n\
6 -> 5,8\n\
7 -> 9\n\
8 -> 7\n\
9 -> 6";

    GraphPath *test = [[GraphPath alloc] initWithString:@"6->8->7->9->6->5->4->2->1->0->3->2->6"];

    Graph *g = [[Graph alloc] initWithAdjacencyList:adj];

    EulerPathfinder *pf = [[EulerPathfinder alloc] initWithGraph:g node:[[g nodesForLabel:@"1"] firstObject]];
    GraphPath *find = [pf find];

    XCTAssert(test.edgeEnumerator.allObjects.count == find.edgeEnumerator.allObjects.count);


    NSString * lines = [NSString stringWithContentsOfFile:[PROJECT_PATH stringByAppendingPathComponent:@"b2w2_euler1.txt"] encoding:NSUTF8StringEncoding error:nil];

    g = [[Graph alloc] initWithAdjacencyList:lines];
    pf = [[EulerPathfinder alloc] initWithGraph:g node:g.nodeEnumerator.nextObject];
    find = [pf find];
}

@end
