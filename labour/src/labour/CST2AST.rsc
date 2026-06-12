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

public labour::AST::BoulderingWall cst2ast(start[BoulderingWall] wall) = parseWall(wall);

labour::AST::BoulderingWall parseWall(labour::Syntax::BoulderingWall w) {
    id = w.id;
    content = for(s <- w.content) {
        append parseWallS(s);
    }
    return BoulderingWall(id, content);
}

labour::AST::WallStatement parseWallS(labour::Syntax::WallStatement s) {
    switch(s) {
        case \volumes(v): return WallVolumeStatement([parseVolume(x) | x <- v.volumes]);
        case \routes(v): return WallRouteStatement([parseRoute(x) | x <- v.routes]);
    }
    return WallVolumeStatement([]);
}

labour::AST::Route parseRoute(labour::Syntax::Route r) {
    id = r.id;
    content = for(s <- r.content) {
        append parseRouteS(s);
    }
    return Route(id, content);
}

labour::AST::RouteStatement parseRouteS(labour::Syntax::RouteStatement s) {
    switch(s) {
        case \grade(g): return RouteGrade("<g.grade>");
        case \holds(h): return RouteHolds(
            ["<x>" | x <- h.first],  
            [x | x <- h.does_split] == [] ? [<"<x.first>", "<x.second>"> | x <- h.split] : [], 
            [x | x <- h.does_split] == [] && [x | x <- h.does_split] == [] ? ["<x>" | x <- h.merged] : []);
        case \base(b): return RouteBase(parsePosition(b.pos));
    }
    return RouteHolds([], [], []);
}

labour::AST::Volume parseVolume(labour::Syntax::Volume v) {
    switch(v) {
        case triangle(t): return parseTriangle(t);
        case circle(c): return parseCircle(c);
    }
    return Circle([]);
}

labour::AST::Volume parseTriangle(labour::Syntax::Triangle t) {
    content = for(s <- t.content) {
        append parseTriangleS(s);
    };
    return Triangle(content);
}

labour::AST::Volume parseCircle(labour::Syntax::Circle c) {
    content = for(s <- c.content) {
        append parseCircleS(s);
    };
    return Circle(content);
}

labour::AST::TriangleStatement parseTriangleS(labour::Syntax::TriangleStatement s) {
    switch (s) {
        case \pos(p):
            return TrianglePos(parsePosition(p.val));
        case \depth(d):
            return TriangleDepth(toInt("<d.depth>"));
        case \corners(c): 
            return TriangleCorners(<parsePosition(c.first), parsePosition(c.second), parsePosition(c.third)>);
        case \ext(e):
            return TriangleExtrusion(parsePosition(e.val));
        case \holds(h):
            return TriangleHolds(parseTriangleType(h.holdType), [parseHold(x) | x <- h.holds]);
    };
    return TrianglePos(Position(0, 0));
}

labour::AST::TriangleType parseTriangleType(labour::Syntax::TriangleHoldType t) {
    switch(t) {
        case \left: return TriangleType::left();
        case \right: return TriangleType::right();
        case \bottom: return TriangleType::bottom();
    }
    return bottom;
}

CircleStatement parseCircleS(CircleStatement s) {
    switch (s) {
        case \pos(p):
            return CirclePosition(parsePosition(p.val));
        case \depth(d):
            return CircleDepth(toInt("<d.depth>"));
        case \radius(r):
            return CircleRadius(toInt("<r.radius>"));
        case \side(side):
            return SideHolds([parseHold(x) | x <- side.side]);
        case \front(f):
            return SideHolds([parseHold(x) | x <- f.front]);
    };
    return CirclePosition(Position(0, 0));
}

labour::AST::Hold parseHold(labour::Syntax::Hold hold) {
    content = for(s <- hold.content) {
        append parseHoldS(s);
    };
    return Hold(hold.id, content);
}

labour::AST::HoldStatement parseHoldS(labour::Syntax::HoldStatement s) {
    switch (s) {
        case \pos(p):
            return HoldPos(parsePosition(p.val));
        case \shape(shape):
            return HoldShape("<shape>");
        case \colours(c):
            return HoldColours([parseColour(x) | x <- c.colours]);
        case \type(t):
            return HoldTyping(parseHoldType(t));
        case \rotation(r):
            return HoldRotation(toInt("<r.rotation>"));
    }
    return HoldPos(Position(0, 0));
}

labour::AST::Position parsePosition(labour::Syntax::Position pos) {
    switch (pos) {
        case \rel(a): return Position(toInt("<a>"));
        case \abs(x, y): return Position(toInt("<x>"), toInt("<y>"));
    }
    return Position(0, 0);
}

labour::AST::Colour parseColour(labour::Syntax::Colour c) {
    switch (c) {
        case \green: return Colour::green; 
        case \red: return Colour::red;
        case \blue: return Colour::blue;
        case \white: return Colour::white;
        case \black: return Colour::black;
        case \pink: return Colour::pink;
        case \orange: return Colour::orange;
        case \yellow: return Colour::yellow;
        case \purple: return Colour::purple; 
    }
    return Colour::red;
}

labour::AST::HoldType parseHoldType(labour::Syntax::HoldSpecialStatement t) {
    switch(t) {
        case \start_hold: return toInt("<t.val>") == 1 ? start1() : start2();
        case \end_hold: return end();
    }
    return end;
}