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

  return (wallHasVolumeAndRoute && numberOfHolds && startingLabelLimit && unique_end_hold);
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

Hold lookup(list[Hold] holds, str id) {
  for (hold <- holds) {
    if (hold.id == id) {
      return hold;
    };
  };
  return Hold("", []);
}
