//
//  GraphTests.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/30/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Graph.h"

@interface GraphTests : XCTestCase

@end

@implementation GraphTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGraph {

    Graph *g = [Graph new];

    GraphNode *na = [g addNodeForLabel:@"A"];
    GraphNode *nb = [g addNodeForLabel:@"B"];
    GraphNode *nc = [g addNodeForLabel:@"C"];

    [g addEdge:na to:nb];
    [g addEdge:nb to:nc];
    [g addEdge:nc to:na];
    [g addEdge:nc to:nb];

    XCTAssertEqual([g edgesFrom:na].count, 1);
    XCTAssertEqual([g edgesFrom:nc].count, 2);
    XCTAssertEqual([g edgesTo:na].count, 1);

}

@end
