//
//  Graph.m
//  BioInformatics
//
//  Created by E.J. Mablekos on 8/30/16.
//  Copyright © 2016 EJ Mablekos. All rights reserved.
//

#import "Graph.h"
#import "NSArray+CHCollectionUtils.h"

@interface GraphNode()
@property (nonatomic,readwrite) NSString *label;
@end

@implementation GraphNode

- (id)copyWithZone:(NSZone *)zone {
    GraphNode *node = [[[self class] allocWithZone:zone] init];
    node->_label = self->_label;
    return node;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@", self.label];
}


@end


@interface GraphEdge()

@end

@implementation GraphEdge

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@", [self stringValue]];
}

- (NSString *)stringValue {
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@" %@->%@", self.from.label, self.to.label];
    if (self.label) {
        [str appendFormat:@" (%@)", self.label];
    }
    return [str copy];
}

@end


@interface GraphPath()
@property (nonatomic) NSMutableArray *nodes;
@property (nonatomic) NSMutableArray *edges;
@end

@implementation GraphPath

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nodes = [NSMutableArray array];
        self.edges = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    self = [self init];
    if (self) {
        NSArray *arr = [string componentsSeparatedByString:@"->"];
        for (NSString *str in arr) {

            GraphNode *n = [[GraphNode alloc] init];
            n.label = str;

            if ([self.nodes lastObject]) {
                GraphEdge *e = [[GraphEdge alloc] init];
                e.from = [self.nodes lastObject];
                e.to = n;
                [self.edges addObject:e];
            }

            [self.nodes addObject:n];
        }
    }
    return self;
}

- (void)startAt:(GraphNode *)node {
    [self.nodes removeAllObjects];
    [self.edges removeAllObjects];
    [self.nodes addObject:node];
}

- (void)follow:(GraphEdge *)edge to:(GraphNode *)node {
    [self.nodes addObject:node];
    [self.edges addObject:edge];
}

- (BOOL)isCycle {
    return self.nodes.firstObject == self.nodes.lastObject && self.nodes.count > 1;
}

- (BOOL)snipCycle:(GraphEdge *)edge {
    if (![self isCycle]) {
        return NO;
    }

    NSUInteger index = [self.edges indexOfObject:edge];

    NSParameterAssert(index != NSNotFound);

    // Easy case last element, pop off end
    if (index == self.edges.count-1) {
        self.edges = [[self.edges subarrayWithRange:NSMakeRange(0, self.edges.count-1)] mutableCopy];
        self.nodes = [[self.nodes subarrayWithRange:NSMakeRange(0, self.nodes.count-1)] mutableCopy];
        return YES;
    }

    if (index == 0) {
        self.edges = [[self.edges subarrayWithRange:NSMakeRange(1, self.edges.count-1)] mutableCopy];
        self.nodes = [[self.nodes subarrayWithRange:NSMakeRange(1, self.nodes.count-1)] mutableCopy];
        return YES;
    }

    /*
     6->3->0->2->1->3->4->6->7->8->9->6

     6->3->0->2->1->3->4  6->7->8->9->6

     6->3->0->2->1->3->4  6->7->8->9->

     6->7->8->9->6->3->0->2->1->3->4
     */

    NSArray *e1 = [self.edges subarrayWithRange:NSMakeRange(0, index)];
    NSArray *e2 = [self.edges subarrayWithRange:NSMakeRange(index+1, self.edges.count-(index+1))];

    NSArray *n1 = [self.nodes subarrayWithRange:NSMakeRange(0, index+1)];
    NSArray *n2 = [self.nodes subarrayWithRange:NSMakeRange(index+1, self.nodes.count-(index+2))];

    [self.edges removeAllObjects];
    [self.edges addObjectsFromArray:e2];
    [self.edges addObjectsFromArray:e1];

    [self.nodes removeAllObjects];
    [self.nodes addObjectsFromArray:n2];
    [self.nodes addObjectsFromArray:n1];
    
    return YES;
}

- (NSEnumerator *)edgeEnumerator {
    return self.edges.objectEnumerator;
}

- (NSEnumerator *)nodeEnumerator {
    return self.nodes.objectEnumerator;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@", [self stringValue]];
}

- (NSString *)stringValue {

    NSMutableString *str = [NSMutableString string];
    for (GraphNode *n in self.nodes) {
        if (str.length > 0) {
            [str appendString:@"->"];
        }
        [str appendString:[n label]];
    }
    return [str copy];
}

@end


@interface Graph()
@property (nonatomic) NSMutableArray *nodes;
@property (nonatomic) NSMutableDictionary *edges;
@property (nonatomic) NSMapTable *labelNodeMap;
@end

@implementation Graph

- (instancetype)init {
    self = [super init];
    if (self) {
        self.nodes = [NSMutableArray array];
        self.edges = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithAdjacencyList:(NSString *)list {
    self = [self init];
    if (self) {
        NSArray *lines = [list componentsSeparatedByString:@"\n"];
        NSArray *nodes = [lines CH_map:^id(NSString *obj) {
            return [[obj componentsSeparatedByString:@" -> "] firstObject];
        }];
        NSArray *edges = [lines CH_map:^id(NSString *obj) {
            return [[[obj componentsSeparatedByString:@" -> "] lastObject] componentsSeparatedByString:@","];
        }];

        for (NSString *node in nodes) {
            [self addNodeForLabel:node];
        }

        for (NSInteger i = 0; i<nodes.count; ++i) {
            GraphNode *n1 = [[self nodesForLabel:[nodes objectAtIndex:i]] firstObject];

            for (NSString *e in [edges objectAtIndex:i]) {
                GraphNode *n2 = [[self nodesForLabel:e] firstObject];
                if (!n2) {
                    n2 = [self addNodeForLabel:e];
                }
                [self addEdge:n1 to:n2];
            }
        }
    }
    return self;
}

- (GraphNode *)addNodeForLabel:(NSString *)label {
    GraphNode *node = [GraphNode new];
    node.label = label;
    [self addNode:node];
    return node;
}

- (GraphNode *)addNode:(GraphNode *)node {
    [self.nodes addObject:node];
    return node;
}

- (void)removeEdge:(GraphEdge *)edge {
    NSMutableArray *edgeList = [self.edges objectForKey:@(edge.from.hash)];
    [edgeList removeObject:edge];
}

- (GraphEdge *)addEdge:(GraphNode *)from to:(GraphNode *)to {
    GraphEdge *edge = [GraphEdge new];
    edge.from = from;
    edge.to = to;

    NSMutableArray *edgeList = [self.edges objectForKey:@(from.hash)];
    if (!edgeList) {
        edgeList = [NSMutableArray arrayWithCapacity:4];
        [self.edges setObject:edgeList forKey:@(from.hash)];
    }

    [edgeList addObject:edge];

    return edge;
}

- (GraphNode *)nodeForLabel:(NSString *)label {
    NSArray *ns = [self nodesForLabel:label];
    NSAssert(ns.count <= 1, @"Dont use this API unless you ensure nodes are uniquely labeled");
    return [ns firstObject];
}

- (NSArray *)nodesForLabel:(NSString *)label {
   return [self.nodes CH_filter:^BOOL(GraphNode * obj) {
        return [obj.label isEqualToString:label];
   }];
}

- (NSArray *)edgesFrom:(GraphNode *)from {
    NSMutableArray *edgeList = [self.edges objectForKey:@(from.hash)];
    return [edgeList copy];
}

- (NSArray *)edgesTo:(GraphNode *)to {
    NSMutableArray *res = [NSMutableArray array];
    NSArray *edges = [[self.edges allValues] CH_flatten];
    for (GraphEdge *edge in edges) {
        if (edge.to == to) {
            [res addObject:edge];
        }
    }
    return [res copy];
}

- (NSEnumerator *)nodeEnumerator {
    return [self.nodes objectEnumerator];
}

- (NSEnumerator *)edgeEnumerator {
    return [[[self.edges allValues] CH_flatten] objectEnumerator];
}

- (BOOL)node:(GraphNode *)from isAdjacent:(GraphNode *)to {
    NSArray *es = [self edgesFrom:from];
    NSArray *ns = [es CH_map:^id(GraphEdge * obj) {
        return obj.to;
    }];
    return [ns containsObject:to];
}

- (BOOL)isBalanced {
    for (GraphNode *node in self.nodes) {
        NSArray *f = [self edgesFrom:node];
        NSArray *t = [self edgesTo:node];

        if (f.count != t.count) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)isNearlyBalancedFromStart:(GraphNode * __autoreleasing *)start end:(GraphNode * __autoreleasing *)end {

    NSUInteger tsurplus = 0;
    NSUInteger fsurplus = 0;

    GraphNode *startCandidate = nil;
    GraphNode *endCandidate = nil;

    for (GraphNode *node in self.nodes) {
        NSArray *f = [self edgesFrom:node];
        NSArray *t = [self edgesTo:node];

        if (f.count == t.count + 1) {
            startCandidate = node;
            fsurplus++;
        } else if (t.count == f.count + 1) {
            endCandidate = node;
            tsurplus++;
        }
    }

    if (tsurplus == fsurplus == 1) {
        if (start)
            *start = startCandidate;

        if (end)
            *end = endCandidate;

        return YES;
    }

    return NO;
}

- (BOOL)isNearlyBalanced {

    GraphNode *start = nil;
    GraphNode *end = nil;

    return [self isNearlyBalancedFromStart:&start end:&end];
}

- (NSString *)description {

    NSMutableString *s = [[super description] mutableCopy];

    NSUInteger ni = 0;
    for (GraphNode *n in self.nodes) {
        [s appendString:@"\n"];

        [s appendString:n.label];

        NSArray *edgeList = [self.edges objectForKey:@(n.hash)];
        if (edgeList.count) {

            [s appendString:@" -> "];
            NSUInteger ei = 0;
            for (GraphEdge *e in edgeList) {
                if (ei != 0) {
                    [s appendString:@","];
                }
                [s appendString:e.to.label];

                ei++;
            }
        }

        ni++;
    }

    return [s copy];
}

- (NSString *)adjacencyDescription {

    NSMutableString *s = [[super description] mutableCopy];

    NSUInteger ni = 0;
    for (GraphNode *n in self.nodes) {


        NSArray *edgeList = [self.edges objectForKey:@(n.hash)];
        if (edgeList.count) {

            [s appendString:@"\n"];

            [s appendString:n.label];

            [s appendString:@" -> "];
            NSUInteger ei = 0;
            for (GraphEdge *e in edgeList) {
                if (ei != 0) {
                    [s appendString:@","];
                }
                [s appendString:e.to.label];

                ei++;
            }
        }
        
        ni++;
    }
    
    return [s copy];

}

- (NSArray *)hamiltonianPaths:(GraphNode *)from {

    NSMutableArray *paths = [NSMutableArray array];
    NSArray *path = [NSArray arrayWithObject:from];
    [self hamiltonianDepth:path paths:paths];

    NSMutableArray *hams = [NSMutableArray array];
    for (NSArray *path in paths) {
        if (path.count == self.nodes.count) {
            for (GraphEdge *e in [self edgesFrom:[path lastObject]]) {
                if (e.to == path.firstObject) {
                    [hams addObject:path];
                }
            }
        }
    }

    return [hams copy];
}

- (NSArray *)hamiltonianDepth:(NSArray *)path paths:(NSMutableArray *)paths {
    GraphNode *start = [path lastObject];
    NSArray *edgeList = [self.edges objectForKey:@(start.hash)];
    BOOL remove = NO;
    for (GraphEdge *e in edgeList) {
        if (![path containsObject:e.to]) {
            NSArray *nupath = [path arrayByAddingObject:e.to];
            [self hamiltonianDepth:nupath paths:paths];
            remove = YES;
            [paths addObject:nupath];
        }
    }
    if (remove) {
        [paths removeObject:path];
    }

    return nil;
}


@end



@interface EulerPathfinder()
@property (nonatomic) Graph *graph;
@end

@implementation EulerPathfinder


- (instancetype)initWithGraph:(Graph *)graph {
    self = [super init];
    if (self) {
        self.graph = graph;
    }
    return self;
}

- (GraphPath *)findCycle {
    if (![self.graph isBalanced]) {
        NSAssert(NO, @"Graph not balanced");
        return nil;
    }

    GraphNode *start = self.start ?: self.graph.nodeEnumerator.nextObject;

    return [self extendCycle:[GraphPath new] from:start];
}

- (GraphPath *)findPath {

    GraphNode *start;
    GraphNode *end;

    if (![self.graph isNearlyBalancedFromStart:&start end:&end]) {
        NSAssert(NO, @"Graph not nearly");
        return nil;
    }

    GraphEdge *temp = [self.graph addEdge:end to:start];

    GraphPath *p = [self extendCycle:[GraphPath new] from:start];

    [p snipCycle:temp];

    [self.graph removeEdge:temp];

    return p;
}

- (GraphPath *)extendCycle:(GraphPath *)oldPath from:(GraphNode *)start {

    GraphPath *path = [GraphPath new];
    [path startAt:start];

    // Follow old path
    NSUInteger i = [oldPath.nodes indexOfObject:start];
    while (path.nodes.count < oldPath.nodes.count) {
        GraphEdge *edge = [oldPath.edges objectAtIndex:i];
        [path follow:edge to:edge.to];

        i++;
        if (i >= oldPath.edges.count) {
            i = 0;
        }
    }

    // Randomly walk
    [self buildPath:path];

    if (path.edges.count >= [[self.graph edgeEnumerator] allObjects].count) {
        return path;
    }

    GraphNode *hasOptions = nil;
    for (GraphNode *n in path.nodes) {
        if (n == path.nodes.firstObject) {
            continue;
        }
        NSArray *edges = [self.graph edgesFrom:n];
        for (GraphEdge *e in edges) {
            if (![path.edges containsObject:e]) {
                hasOptions = n;
                break;
            }
        }
        if (hasOptions)
            break;
    }

    if (!hasOptions) {
        return nil;
    }

    return [self extendCycle:path from:hasOptions];
}

- (void)buildPath:(GraphPath *)path {

    NSArray *adj = [self.graph edgesFrom:[path.nodes lastObject]];

    for (GraphEdge *e in adj) {

        if (![path.edges containsObject:e]) {
            [path follow:e to:e.to];
            return [self buildPath:path];
        }
    }
}


@end




@interface MaximalNonBranchingPathsFinder()
@property (nonatomic) Graph *graph;
@property (nonatomic) NSMutableArray *visitedEdges;
@property (nonatomic) NSMutableArray *paths;
@end

@implementation MaximalNonBranchingPathsFinder
- (instancetype)initWithGraph:(Graph *)g {
    self = [super init];
    if (self) {
        self.graph = g;
    }
    return self;
}

- (NSArray *)search {
    self.visitedEdges = [NSMutableArray array];
    self.paths = [NSMutableArray array];

    for (GraphNode *n in self.graph.nodes) {
        NSArray *from = [self.graph edgesFrom:n];
        NSArray *to = [self.graph edgesTo:n];

        if (to.count == from.count && from.count == 1) {
            continue;
        }

        for (GraphEdge *e in from) {
            GraphPath *p = [GraphPath new];
            [p startAt:n];
            [p follow:e to:e.to];
            [self dfs:p];
            [self.paths addObject:p];
        }
    }

    return [self.paths copy];
}

- (void)dfs:(GraphPath *)path {
    NSArray *from = [self.graph edgesFrom:[path.nodes lastObject]];
    NSArray *to = [self.graph edgesTo:[path.nodes lastObject]];
    if (from.count == 1 && to.count == 1) {
        GraphEdge *e = from.firstObject;
        [path follow:e to:[e to]];
        [self dfs:path];
    }
}

@end


