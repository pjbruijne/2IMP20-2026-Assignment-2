module labour::Check

import labour::AST;
import labour::Parser;
import labour::CST2AST;

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
  bool numberOfHolds = checkNumberOfHolds(wall);

  bool startingLabelLimit = checkStartingHoldsTotalLimit(wall);
  bool unique_end_hold = checkUniqueEndHold(wall);

  return (numberOfHolds && startingLabelLimit && unique_end_hold);
}


// Check that there are at least two holds in the wall
bool checkNumberOfHolds(BoulderingWall wall) {
  return size(getAllHolds(wall)) >= 2;
}

// Check that routes have between zero and two hand start holds
bool checkStartingHoldsTotalLimit(BoulderingWall wall) {
  holds = getAllHolds(wall);
  for (route <- wall.routes) {
    N = 0;
    for (id <- route.holds.init) {
      hold = lookup(holds, id);
      if (hold.holdtype == start1 || hold.holdtype == start2) {
        N = N + 1;
      };
    };
    for (double <- route.holds.split) {
      hold = lookup(holds, double[0]);
      if (hold.holdtype == start1 || hold.holdtype == start2) {
        N = N + 1;
      };
      hold = lookup(holds, double[1]);
      if (hold.holdtype == start1 || hold.holdtype == start2) {
        N = N + 1;
      };
    };
    for (id <- route.holds.merged) {
      hold = lookup(holds, id);
      if (hold.holdtype == start1 || hold.holdtype == start2) {
        N = N + 1;
      };
    };
    if (N > 2) {
      return false;
    };
  };
  return true;
}

// This function will insure that there is only one hold assign to end hold
bool checkUniqueEndHold(BoulderingWall wall){
  holds = getAllHolds(wall);
  for (route <- wall.routes) {
    found = false;
    for (id <- route.holds.init) {
      hold = lookup(holds, id);
      if (hold.holdtype == end) {
        if (found) {
          return false;
        };
        found = true;
      };
    };
    for (double <- route.holds.split) {
      hold = lookup(holds, double[0]);
      if (hold.holdtype == end) {
        if (found) {
          return false;
        };
        found = true;
      };
      hold = lookup(holds, double[1]);
      if (hold.holdtype == end) {
        if (found) {
          return false;
        };
        found = true;
      };
    };
    for (id <- route.holds.merged) {
      hold = lookup(holds, id);
      if (hold.holdtype == end) {
        if (found) {
          return false;
        };
        found = true;
      };
    };
  };
  return true;
}

list[Hold] getAllHolds(BoulderingWall wall) {
  result = for (volume <- wall.volumes) {
    visit(volume) {
      case Circle(f, s, _, _, _): {
        for (hold <- f) {
          append hold;
        };
        for (hold <- s) {
          append hold;
        };
      }
      case Triangle(_, h, _, _, _, _): {
        for (hold <- h) {
          append hold;
        };
      }
    };
  };
  return result;
}

Hold lookup(list[Hold] holds, str id) {
  for (hold <- holds) {
    if (hold.id == id) {
      return hold;
    };
  };
  return Hold("", Position(0), "", [], 0, none);
}