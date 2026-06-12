module labour::Syntax

/*
 * Define a concrete syntax for LaBouR. The language's specification is available in the PDF (Section 2)
 */

/*
 * Note, the Server expects the language base to be called BoulderingWall.
 * You are free to change this name, but if you do so, make sure to change everywhere else to make sure the
 * plugin works accordingly.
 */

// General Layout to ignore whitespace
layout Whitespace = [\ \n\r\t]*;

// List of lexicals to be used
lexical UpperCase = [A-Z];
lexical LowerCase = [a-z];
lexical Letter = LowerCase | UpperCase;
lexical Digit = [0-9];
lexical Int = Digit+;
lexical SInt = "-"?Int;
lexical Decimal = Digit* "." Int;
lexical SDecimal = "-"?Decimal;
lexical Char = Letter | Digit | [\ ];
lexical Angle = "0"* "3" [0-5] Digit | "0"*[1-2] Digit Digit | "0"* Digit Digit;
lexical StringLiteral = "\"" Char* "\"";
lexical HoldID = "\"" Digit Digit Digit Digit "\"";
lexical WallID = StringLiteral;
lexical RouteID = StringLiteral;

// Simple keywords
keyword Colour = "green" | "red" | "blue" | "white" | "black" | "pink" | "orange" | "yellow" | "purple";
keyword TriangleHoldType = "left_holds" | "right_holds" | "bottom_holds";

// Simple data definitions
syntax Position = Position_Rel rel | Position_Abs abs;
syntax Position_Rel =  "{" "angle" ":" Angle a "}";
syntax Position_Abs =  "{" "x" ":" SInt x "," "y" ":" SInt y "}";
syntax DoubleHold =  "{" HoldID first "," HoldID second "}";
syntax RouteHoldsList =  "[" {HoldID init ","}+ ("," {DoubleHold split ","}+ ("," {HoldID merged ","}+)? )? "]";
syntax PositionTriple =  "[" Position_Abs first "," Position_Abs second "," Position_Abs third "]";
syntax List[&T] = "[" {&T val ","}* values "]";

// Wall Definition
start syntax BoulderingWall = "bouldering_wall" WallID id "{" WallContent content "}";
syntax WallContent = WallRoutesStatement routes "," WallVolumesStatement volumes | WallVolumesStatement volumes "," WallRoutesStatement routes;
syntax WallRoutesStatement = "routes" List[Route] routes;
syntax WallVolumesStatement = "volumes" List[Volume] volumes;

// Route Definition
syntax Route = "bouldering_route" RouteID "{" RouteContent "}";
syntax RouteContent
    = RouteGradeStatement "," RouteGridBaseStatement "," RouteHoldsList
    | RouteGradeStatement "," RouteHoldsList "," RouteGridBaseStatement
    | RouteGridBaseStatement "," RouteGradeStatement "," RouteHoldsList
    | RouteGridBaseStatement "," RouteHoldsList "," RouteGradeStatement
    | RouteHoldsList "," RouteGridBaseStatement "," RouteGradeStatement
    | RouteHoldsList "," RouteGradeStatement "," RouteGridBaseStatement
    ;
syntax RouteGradeStatement = "grade" ":" StringLiteral;
syntax RouteGridBaseStatement = "grid_base_point" Position;
syntax RouteHoldsStatement = "holds" RouteHoldsList;

// Shared statements
syntax PosStatement = "pos" Position val;
syntax VolumeDepthStatement = "depth" ":" SInt;

// Volume Definitions
syntax Volume = Circle c | Triangle t;
// Circle Definitions
syntax Circle = "circle" "{" CircleContent "}";
syntax CircleContent = CircleStatement first "," CircleStatement second "," CircleStatement third "," CircleStatement fourth "," CircleStatement fifth;
syntax CircleStatement = PosStatement | VolumeDepthStatement | CircleRadiusStatement | CircleSideStatement | CircleFrontStatement;
syntax CircleSideStatement = "side_holds" List[Hold] side;
syntax CircleFrontStatement = "front_holds" List[Hold] front;
syntax CircleRadiusStatement = "radius" ":" Int radius;
// Triangle Definitions
syntax Triangle = "triangle"  "{" TriangleContent content "}";
syntax TriangleContent = TriangleStatement first "," TriangleStatement second "," TriangleStatement third "," TriangleStatement fourth "," TriangleStatement fifth;
syntax TriangleStatement = PosStatement | VolumeDepthStatement | TriangleCornersStatement | TriangleExtrusionStatement | TriangleHoldsStatement;
syntax TriangleExtrusionStatement = "extrusion" ":" Position_Abs val;
syntax TriangleCornersStatement = "corners" PositionTriple;
syntax TriangleHoldsStatement = TriangleHoldType List[Hold] list;

syntax Hold = "hold" HoldID  "{" HoldContent "}";
syntax HoldContent = {HoldStatement ","}+;
syntax HoldStatement = PosStatement | ShapeStatement | ColourStatement | HoldSpecialStatement | RotationStatement;

syntax ColourStatement = "colours" List[Colour] colours;
syntax ShapeStatement = "shape" ":" StringLiteral;
syntax HoldSpecialStatement = "start_hold" ":" [1-2] | "end_hold";
syntax RotationStatement = "rotation" ":" Angle;