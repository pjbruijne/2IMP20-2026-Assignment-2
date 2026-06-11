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
syntax Position_Rel =  "{" "angle" ":" Angle "}";
syntax Position_Abs =  "{" "x" ":" SInt "," "y" ":" SInt "}";
syntax DoubleHold =  "{" HoldID "," HoldID "}";
syntax HoldsList_Abs =  "[" {Hold_Abs ","}* "]";
syntax HoldsList_Rel =  "[" {Hold_Rel ","}* "]";
syntax RouteHoldsList =  "[" {HoldID ","}+ ("," {DoubleHold ","}+ ("," {HoldID ","}+)? )? "]";
syntax ColoursList =  "[" {Colour ","}* "]";
syntax RoutesList =  "[" {Route ","}* "]";
syntax VolumesList =  "[" {Volume ","}* "]";
syntax PositionTriple =  "[" Position_Abs "," Position_Abs "," Position_Abs "]";

// Wall Definition
start syntax BoulderingWall = "bouldering_wall" WallID "{" WallContent "}";
syntax WallContent = WallRoutesStatement "," WallVolumesStatement | WallVolumesStatement "," WallRoutesStatement;
syntax WallRoutesStatement = "routes" RoutesList;
syntax WallVolumesStatement = "volumes" VolumesList;

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
syntax RouteGridBaseStatement = "grid_base_point" Position_Abs;
syntax RouteHoldsStatement = "holds" RouteHoldsList;

// Shared statements
syntax PosStatement_Abs = "pos" Position_Abs;
syntax PosStatement_Rel = "pos" Position_Rel;
syntax VolumeDepthStatement = "depth" ":" SInt;

// Volume Definitions
syntax Volume = Circle | Triangle;
// Circle Definitions
syntax Circle = "circle" "{" CircleContent "}";
syntax CircleContent = CircleStatement "," CircleStatement "," CircleStatement "," CircleStatement "," CircleStatement;
syntax CircleStatement = PosStatement_Abs | VolumeDepthStatement | CircleRadiusStatement | CircleSideStatement | CircleFrontStatement;
syntax CircleSideStatement = "side_holds" HoldsList_Rel;
syntax CircleFrontStatement = "side_holds" HoldsList_Abs;
syntax CircleRadiusStatement = "radius" ":" Int;
// Triangle Definitions
syntax Triangle = "triangle"  "{" TriangleContent "}";
syntax TriangleContent = TriangleStatement "," TriangleStatement "," TriangleStatement "," TriangleStatement "," TriangleStatement;
syntax TriangleStatement = PosStatement_Abs | VolumeDepthStatement | TriangleCornersStatement | TriangleExtrusionStatement | TriangleHoldsStatement;
syntax TriangleExtrusionStatement = "extrusion" ":" Position_Abs;
syntax TriangleCornersStatement = "corners" PositionTriple;
syntax TriangleHoldsStatement = TriangleHoldType HoldsList_Abs;

syntax Hold_Abs = "hold" HoldID  "{" HoldContent_Abs "}";
syntax HoldContent_Abs = {HoldStatement_Abs ","}+;
syntax Hold_Rel = "hold" HoldID  "{" HoldContent_Rel "}";
syntax HoldContent_Rel = {HoldStatement_Rel ","}+;
syntax HoldStatement_Abs = Position_Abs | ShapeStatement | ColourStatement | HoldSpecialStatement | RotationStatement;
syntax HoldStatement_Rel = Position_Rel | ShapeStatement | ColourStatement | HoldSpecialStatement | RotationStatement;

syntax ColourStatement = "colours" ColoursList;
syntax ShapeStatement = "shape" ":" StringLiteral;
syntax HoldSpecialStatement = "start_hold" ":" [1-2] | "end_hold";
syntax RotationStatement = "rotation" ":" Angle;