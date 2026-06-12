module labour::Check

import labour::AST;

import IO;
import List;
import Set;
import Prelude;
import String;


/*
 * Implement a well-formedness checker for the LaBouR language. For this you must use the AST.
 * - Hint: Map regular CST arguments (e.g., *, +, ?) to lists
 * - Hint: Map lexical nodes to Rascal primitive types (bool, int, str)
 * - Hint: Use switch to do case distinction with concrete patterns
 */

/*
 * Define a function per each verification defined in the PDF (Section 2.2.)
 * Some examples are provided below.
 */

bool checkBoulderWallConfiguration(BoulderingWall wall){
  bool wallHasVolumeAndRoute = checkWallHasVolumeAndRoute(wall);
  bool numberOfHolds = checkNumberOfHolds(wall);
  bool startingLabelLimit = checkStartingHoldsTotalLimit(wall);
  bool unique_end_hold = checkUniqueEndHold(wall);
  bool grade_grid_base_point_identifier = checkRouteHasGradeGridBasePointAndIdentifier(wall);
  bool grid_base_point_has_x_and_y = checkGridBasePointHasXAndY(wall);
  bool circle_has_radius_depth_position = checkCircleHasRadiusDepthAndPosition(wall);
  bool triangle_has_position_depth_extrude_and_corners = checkTriangleHasPositionDepthExtrudeAndCorners(wall);
  bool hold_has_position_shape_and_colour = checkHoldHasPositionShapeAndColour(wall);

  return (
    wallHasVolumeAndRoute &&
    numberOfHolds &&
    startingLabelLimit &&
    unique_end_hold &&
    grade_grid_base_point_identifier &&
    grid_base_point_has_x_and_y &&
    circle_has_radius_depth_position && 
    triangle_has_position_depth_extrude_and_corners &&
    hold_has_position_shape_and_colour
  );
}

// Helpers
list[Volume] getVolumes(BoulderingWall w) = [*vs | WallVolumeStatement(vs) <- w.content];
list[Route]  getRoutes(BoulderingWall w)  = [*rs | WallRouteStatement(rs)  <- w.content];
list[Hold] volumeHolds(Circle(cs))   = [*hs | FrontHolds(hs) <- cs] + [*hs | SideHolds(hs) <- cs];
list[Hold] volumeHolds(Triangle(ts)) = [*hs | TriangleHolds(_, hs) <- ts];
list[Hold] getAllHolds(BoulderingWall w) = [*volumeHolds(v) | v <- getVolumes(w)];

RouteHolds routeHolds(Route r) {
  for (s <- r.content) if (RouteHolds(rh) := s) return rh;
  return RouteHolds([], [], []);
}

bool isStart(Hold h) = any(s <- h.content, HoldTyping(t) := s, t == start1() || t == start2());
bool isEnd(Hold h)   = any(s <- h.content, HoldTyping(\end()) := s);

// 1. Every wall must have at least one volume and one route.
bool checkWallHasVolumeAndRoute(BoulderingWall wall) {
  return size(getVolumes(wall)) > 0 && size(getRoutes(wall)) > 0;
}

// 2. Every route must have two or more holds. 
bool checkNumberOfHolds(BoulderingWall wall) {
  return size(getAllHolds(wall)) >= 2;
}

// 3. Every route must have between zero and two hand start holds. 
bool checkStartingHoldsTotalLimit(BoulderingWall wall) {
  holds = getAllHolds(wall);
  for (route <- getRoutes(wall)) {
    rh = routeHolds(route);
    N = 0;
    for (id <- rh.init) {
      hold = lookup(holds, id);
      if (isStart(hold)) {
        N = N + 1;
      };
    };
    for (double <- rh.split) {
      hold = lookup(holds, double[0]);
      if (isStart(hold)) {
        N = N + 1;
      };
      hold = lookup(holds, double[1]);
      if (isStart(hold)) {
        N = N + 1;
      };
    };
    for (id <- rh.merged) {
      hold = lookup(holds, id);
      if (isStart(hold)) {
        N = N + 1;
      };
    };
    if (N > 2) {
      return false;
    };
  };
  return true;
}

// 4. Every route must have at most one splitting hold where sub-routes start (no more than two sub-routes).
// Done in grammar

// 5. Every route must have a grade, a grid_base_point, and an identifier.
bool checkRouteHasGradeGridBasePointAndIdentifier(BoulderingWall wall) {
  for (route <- getRoutes(wall)) {
    bool hasGrade = false;
    bool hasBase  = false;
    for (s <- route.content) {
      if (RouteGrade(_) := s) {
        hasGrade = true;
      };
      if (RouteBase(_) := s) {
        hasBase = true;
      };
    }
    bool hasId = route.id != "";
    if (!(hasGrade && hasBase && hasId)) {
      return false;
    };
  };
  return true;
}

// 6. The grid_base_point must have an x and a y component.
bool checkGridBasePointHasXAndY(BoulderingWall wall) {
  for (route <- getRoutes(wall)) {
    for (s <- route.content) {
      if (RouteBase(base) := s) {
        if (!(Position(_, _) := base)) {
          return false;
        };
      };
    };
  };
  return true;
}

// 7. A route has at most two end_holds if it splits, and at most one end_hold if it does not split.
bool checkUniqueEndHold(BoulderingWall wall){
  holds = getAllHolds(wall);
  for (route <- getRoutes(wall)) {
    rh = routeHolds(route);
    found = false;
    for (id <- rh.init) {
      hold = lookup(holds, id);
      if (isEnd(hold)) {
        if (found) {
          return false;
        };
        found = true;
      };
    };
    for (double <- rh.split) {
      hold = lookup(holds, double[0]);
      if (isEnd(hold)) {
        if (found) {
          return false;
        };
        found = true;
      };
      hold = lookup(holds, double[1]);
      if (isEnd(hold)) {
        if (found) {
          return false;
        };
        found = true;
      };
    };
    for (id <- rh.merged) {
      hold = lookup(holds, id);
      if (isEnd(hold)) {
        if (found) {
          return false;
        };
        found = true;
      };
    };
  };
  return true;
}

// 8. In a route, after a split, there should be no new split if there was a merge before.
// TODO

// 9. Hold IDs are always defined with four digits, for example, ”0025“.
// Done in grammar

// 10. Wall and route IDs can be any alphanumeric character.
// Done in grammar

// 11. All holds in a route must share the same colour; for multicoloured holds, 
// the intersection of colour lists must be non-empty (order irrelevant). The order of 
// the colours in a multicoloured hold is not relevant.
// TODO

// 12. Every hold must have a position (defined by x and y, or by and angle), a shape, and colour.
bool checkHoldHasPositionShapeAndColour(BoulderingWall wall) {
  for (hold <- getAllHolds(wall)) {
    bool hasPosition = false;
    bool hasShape    = false;
    bool hasColour   = false;
    for (s <- hold.content) {
      switch (s) {
        case HoldPos(_):     hasPosition = true;
        case HoldShape(_):   hasShape    = true;
        case HoldColours(_): hasColour   = true;
      }
    }
    if (!(hasPosition && hasShape && hasColour)) {
      return false;
    };
  };
  return true;
}

// 13. If a hold position is defined by an angle, the angle must be between 0 and 359.
// Done in grammar

// 14. Holds may have a rotation property. If a hold has a rotation, its value must be between 0 and 359.
// Done in grammar

// 15. The colour values used must be valid. For now, we assume valid colours to 
// be white, yellow, green, blue, red, purple, pink, black, and orange.
// Done in grammar

// 16. There are only two volume types: circle and triangle.
// Done in grammar

// 17. A circular volume must have a radius, a depth and a position.
bool checkCircleHasRadiusDepthAndPosition(BoulderingWall wall) {
  for (volume <- getVolumes(wall)) {
    if (Circle(cs) := volume) {
      bool hasRadius   = false;
      bool hasDepth    = false;
      bool hasPosition = false;
      for (s <- cs) {
        switch (s) {
          case CircleRadius(_):   hasRadius   = true;
          case CircleDepth(_):    hasDepth    = true;
          case CirclePosition(_): hasPosition = true;
        }
      }
      if (!(hasRadius && hasDepth && hasPosition)) {
        return false;
      };
    };
  };
  return true;
}

// 18. A circular volume may only contain holds in the front_holds or side_holds lists.
// Done in grammar

// 19. A triangular volume must have a position, depth, an extrude point, and a corner
// array, with three items that defines the corners of the triangle.
bool checkTriangleHasPositionDepthExtrudeAndCorners(BoulderingWall wall) {
  for (volume <- getVolumes(wall)) {
    if (Triangle(ts) := volume) {
      bool hasPosition = false;
      bool hasDepth    = false;
      bool hasExtrude  = false;
      bool hasCorners  = false;
      for (s <- ts) {
        switch (s) {
          case TrianglePos(_):       hasPosition = true;
          case TriangleDepth(_):     hasDepth    = true;
          case TriangleExtrusion(_): hasExtrude  = true;
          case TriangleCorners(c):   hasCorners  = size(c) == 3;
        }
      }
      if (!(hasPosition && hasDepth && hasExtrude && hasCorners)) {
        return false;
      };
    };
  };
  return true;
}

// 20. A triangular volume may only contain holds in the left_holds, right_holds, or
// bottom_holds lists.
// Done in grammar

Hold lookup(list[Hold] holds, str id) {
  for (hold <- holds) {
    if (hold.id == id) {
      return hold;
    };
  };
  return Hold("", []);
}
