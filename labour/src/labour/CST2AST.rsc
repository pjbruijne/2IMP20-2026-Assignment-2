module labour::CST2AST

// This provides println which can be handy during debugging.
import IO;

// These provide useful functions such as toInt, keep those in mind.
import Prelude;
import String;

import labour::AST;
import labour::Syntax;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 * Hint: Use switch to do case distinction with concrete patterns
 * Map regular CST arguments (e.g., *, +, ?) to lists
 * Map lexical nodes to Rascal primitive types (bool, int, str)
 */

labour::AST::BoulderingWall parseWall(labour::Syntax::BoulderingWall w) {
    id = w.id;
    routes = w.content.routes.routes.values;
    volumes = w.content.volumes.volumes.values;
    volumes_ast = for (volume <- volumes) {
        append parseVolume(volume);
    };
    routes_ast = for (route <- routes) {
        append parseRoute(route);
    };
    return BoulderingWall(id, volumes_ast, routes_ast);
}

labour::AST::Volume parseVolume(labour::Syntax::Volume v) {
    // if (v := Triangle t) {
    //     return parseTriangle(t);
    // };
    switch (v) {
        case labour::Syntax::Triangle t:
            return parseTriangle(t);
        case labour::Syntax::Circle c:
            return parseCircle(c);
    }
}

labour::AST::Route parseRoute(labour::Syntax::Route r) {

}

labour::AST::Volume parseTriangle(labour::Syntax::Triangle t) {
    content = t.content;
    s1 = content.first;
    s2 = content.second;
    s3 = content.third;
    s4 = content.fourth;
    s5 = content.fifth;
    empty = Triangle(none, [], nowhere, 0, <nowhere, nowhere, nowhere>, nowhere);

}

labour::AST::Volume augmentTriangle(labour::AST::Volume t, TriangleStatement s) {
    switch (s) {
        case PosStatement p :
            return Triangle(t.ttype, t.holds, Position(p.val.x, p.val.y), t.depth, t.corners, t.extrusion);
    };
}

labour::AST::Volume parseCircle(labour::Syntax::Circle c) {

}

Hold parseHold(Hold_Rel h) {

}

Hold parseHold(Hold_Abs h) {
    
}