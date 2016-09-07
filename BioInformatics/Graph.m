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
    return [[super description] stringByAppendingFormat:@" %@->%@", self.from.label, self.to.label];
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

- (NSEnumerator *)edgeEnumerator {
    return self.edges.objectEnumerator;
}

- (NSEnumerator *)nodeEnumerator {
    return self.nodes.objectEnumerator;
}

- (NSString *)description {
    NSMutableString *str = [NSMutableString string];
    for (GraphNode *n in self.nodes) {
        if (str.length > 0) {
            [str appendString:@"->"];
        }
        [str appendString:[n label]];
    }
    return [[super description] stringByAppendingFormat:@" %@", str];
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
@property (nonatomic) GraphNode *start;
@end

@implementation EulerPathfinder


- (instancetype)initWithGraph:(Graph *)graph node:(GraphNode *)node {
    self = [super init];
    if (self) {
        self.start = node;
        self.graph = graph;
    }
    return self;
}

- (GraphPath *)find {
    if (![self.graph isBalanced]) {

    }

    return [self extendCycle:[GraphPath new] from:self.start];
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
