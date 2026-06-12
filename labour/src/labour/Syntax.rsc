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
lexical Angle = "0"* "3" [0-5] Digit | "0"*[1-2] Digit Digit | "0"* Digit Digit | [0-9];
lexical StringLiteral = "\"" Char* "\"";
lexical HoldID = "\"" Digit Digit Digit Digit "\"";
lexical WallID = StringLiteral;
lexical RouteID = StringLiteral;

// Simple keywords
keyword Colour
    = \green: "green" | \red: "red"
    | \blue: "blue" | \white: "white"
    | \black: "black" | \pink: "pink"
    | \orange: "orange" | \yellow: "yellow" | \purple: "purple";
keyword TriangleHoldType = \left: "left_holds" | \right: "right_holds" | \bottom: "bottom_holds";
keyword ObjectType = "bouldering_wall" | "hold" | "circle" | "triangle";
keyword ObjectKey = "pos" | "routes" | "volumes" | "depth" | "extrusion"
    | "side_holds" | "front_holds" | "left_holds" | "right_holds" | "bottom_holds"
    | "radius" | "angle" | "x" | "y" | "grade" | "corners" | "colours" | "shape" | "rotation"
    | "start_hold" | "end_hold"
    ;

// Simple data definitions
syntax Position = \rel: "{" "angle" ":" Angle a "}" | \abs: "{" "x" ":" SInt x "," "y" ":" SInt y "}";
syntax DoubleHold =  "{" HoldID first "," HoldID second "}";
syntax List[&T] = "[" {&T val ","}* values "]";

// Wall Definition
start syntax BoulderingWall = "bouldering_wall" WallID id "{" {WallStatement ","}* content "}";
syntax WallStatement = \routes: WallRoutesStatement r | \volumes: WallVolumesStatement v;
syntax WallRoutesStatement = "routes" "[" {Route ","}* routes "]";
syntax WallVolumesStatement = "volumes" "[" {Volume ","}* volumes "]";

// Route Definition
syntax Route = "bouldering_route" RouteID id "{" {RouteStatement ","}* content "}";
syntax RouteStatement = \grade: RouteGradeStatement | \base: RouteGridBaseStatement | \holds: RouteHoldsStatement;
syntax RouteGradeStatement = "grade" ":" StringLiteral grade;
syntax RouteGridBaseStatement = "grid_base_point" Position pos;
syntax RouteHoldsStatement = "holds" "[" {RouteHoldItem ","}+ items "]";
syntax RouteHoldItem = HoldID | DoubleHold;

// Shared statements
syntax PosStatement = "pos" ":"? Position val;
syntax VolumeDepthStatement = "depth" ":" SInt depth;

// Volume Definitions
syntax Volume = \circle: Circle c | \triangle: Triangle t;
// Circle Definitions
syntax Circle = "circle" "{" {CircleStatement ","}* content "}";
syntax CircleStatement 
    = \pos: PosStatement
    | \depth: VolumeDepthStatement
    | \radius: CircleRadiusStatement
    | \side: CircleSideStatement
    | \front: CircleFrontStatement;
syntax CircleSideStatement = "side_holds" "[" {Hold ","}* side "]";
syntax CircleFrontStatement = "front_holds" "[" {Hold ","}* front "]";
syntax CircleRadiusStatement = "radius" ":" Int radius;
// Triangle Definitions
syntax Triangle = "triangle"  "{" TriangleContent content "}";
syntax TriangleContent = TriangleStatement first "," TriangleStatement second "," TriangleStatement third "," TriangleStatement fourth "," TriangleStatement fifth;
syntax TriangleStatement
    = \pos: PosStatement 
    | \depth: VolumeDepthStatement
    | \corners: TriangleCornersStatement
    | \ext: TriangleExtrusionStatement
    | \holds: TriangleHoldsStatement
    ;
syntax TriangleExtrusionStatement = "extrusion" ":" Position val;
syntax TriangleCornersStatement = "corners" "[" Position first "," Position second "," Position third "]";
syntax TriangleHoldsStatement = TriangleHoldType holdType "[" {Hold ","}* holds "]";

syntax Hold = "hold" HoldID id "{" {HoldStatement ","}* content "}";
syntax HoldStatement
    = \pos: PosStatement
    | \shape: ShapeStatement
    | \colours: ColourStatement
    | \type: HoldSpecialStatement
    | \rotation: RotationStatement
    ;

syntax ColourStatement = "colours" "[" {Colour ","}* colours "]";
syntax ShapeStatement = "shape" ":" StringLiteral;
syntax HoldSpecialStatement
    = \start_hold: "start_hold" ":" [1-2] val
    | \end_hold: "end_hold";
syntax RotationStatement = "rotation" ":" Angle rotation;