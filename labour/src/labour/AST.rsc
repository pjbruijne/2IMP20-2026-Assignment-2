module labour::AST

/*
 * Define the Abstract Syntax for LaBouR
 * - Hint: make sure there is an almost one-to-one correspondence with the grammar in Syntax.rsc
 */

data BoulderingWall(loc src=|unknown:///|)
  = BoulderingWall(str id, list[WallStatement] content);

data WallStatement = WallRouteStatement(list[Route] routes) | WallVolumeStatement(list[Volume] volumes);

data Route = Route(str grade, Position grid_base, RouteHolds holds);
data RouteStatement = RouteGrade(str grade) | RouteBase(Position base) | RouteHolds(RouteHolds holds);
data RouteHolds = RouteHolds(list[str] init, list[tuple[str, str]] split, list[str] merged);

data Volume 
  = Circle(list[CircleStatement] content)
  | Triangle(list[TriangleStatement] content)
  ;
data CircleStatement 
  = FrontHolds(list[Hold] front_holds) | SideHolds(list[Hold] side_holds) 
  | CirclePosition(Position pos) | CircleDepth(int depth) | CircleRadius(int radius)
  ;
data TriangleStatement
  = TriangleHolds(TriangleType ttype, list[Hold] holds) | TrianglePos(Position pos) 
  | TriangleDepth(int depth) | TriangleCorners(tuple[Position, Position, Position] corners) 
  | TriangleExtrusion(Position extrusion)
  ;
data Hold = Hold(str id, list[HoldStatement] content);
data HoldStatement
  = HoldPos(Position pos) | HoldShape(str shape) | HoldColours(list[Colour] colours) | HoldRotation(int rotation) | HoldTyping(HoldType holdtype)
  ;
data Position = Position(int x, int y) | Position(int angle);

// Constants
data Colour = \green() | \red() | \yellow() | \blue() | \orange() | \white() | \black() | \pink() | \purple();
data HoldType = \start1() | \start2() | \end();
data TriangleType = \left() | \right() | \bottom();

