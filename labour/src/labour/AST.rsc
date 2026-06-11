module labour::AST

/*
 * Define the Abstract Syntax for LaBouR
 * - Hint: make sure there is an almost one-to-one correspondence with the grammar in Syntax.rsc
 */

data BoulderingWall(loc src=|unknown:///|)
  = BoulderingWall(list[Volume] volumes, list[Route] routes);

data Route = Route(str grade, Position grid_base, RouteHolds holds);
data RouteHolds = RouteHolds(list[str] init, list[tuple[str, str]] split, list[str] merged);

data Volume 
  = Circle(list[Hold] front_holds, list[Hold] side_holds, Position pos, int depth, int radius)
  | Triangle(TriangleType ttype, list[Hold] holds, Position pos, int depth, tuple[Position, Position, Position] corners, int extrusion)
  ;
data Hold = Hold(str id, Position pos, str shape, list[Colour] colours, int rotation, HoldType holdtype);
data Position = Position(int x, int y) | Position(int angle);

// Constants
data Colour = \green() | \red() | \yellow() | \blue() | \orange() | \white() | \black() | \pink() | \purple();
data HoldType = \none() | \start1() | \start2() | \end();
data TriangleType = \left() | \right() | \bottom();

