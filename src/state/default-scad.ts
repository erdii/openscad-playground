export default `
height = 4;
bar_thickness = 3;
total_length = 80;
diameter = 25;
hook_angle = 210;

$fn = 64;

radius = diameter/2;
distance = total_length - (diameter + 2 * bar_thickness);

use <custom/arcs.scad>

translate([radius+bar_thickness, radius + bar_thickness, 0])
linear_extrude(height)
union() {
    radiusInner = radius;
    radiusOuter = radius + bar_thickness;

    // calculate some things about the tangent between the two hook circles
    a = radius + bar_thickness/2;
    c = distance/2;
    alpha = asin(a/c); // rotation angle to line between circle centers
    b = c * cos(alpha); // half length of tangent       
    beta = 90 - alpha;
    
    for(i = [0, 1]) {
        translate([i * distance, 0, 0])
        rotate([0,0, i * 180])
        union() {
            rotate([0, 0, -beta]) {
                // hook
                arc(-hook_angle, radiusInner, radiusOuter);
                // tip
                rotate([0, 0, -hook_angle])
                translate([a, 0, 0])
                    circle(bar_thickness/2);
            }
            
            // half tangent
            rotate([0, 0, 90 + alpha])
            translate([-a, -(b/2), 0])
                square([bar_thickness, b], center = true);
        }
    }
}
`;
