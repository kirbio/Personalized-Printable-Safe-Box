// global spacing for moving parts
e = 1;

// design parameters
// disk
disk_amount = 4;
disk_segments = 10;
disk_width = 5;
disk_d = 30;

// rod
rod_d = 9.5;

// notch for disk and rod
notch_depth = 3;
notch_width = 3;

// rod latch
latch_length = 30;
latch_thickness = 10;

// appendage behind rod
app_thickness = 5;
app_length = 20;
app_pos = 10;

// pin between rod and appendage
app_pin_width = 5;
app_pin_depth = 7;

// misc
box_thickness = 5;
rod_tip = 2.5;
disk_offset = 40;

// display parameters
codes = [1, 3, 3, 7];
dist = 35;

module disk(seg = disk_segments, _chars = [], code_pos = 0, w = disk_width, outer_d = disk_d, inner_d = rod_d+e, notch_width = notch_width, notch_depth=notch_depth) {
    chars = _chars == [] ? [for(i=[0 : seg-1]) i] : _chars;
    ang = 360 / seg;
    difference() {
        linear_extrude(height=w) difference() {
            circle(d=outer_d);
            circle(d=inner_d);
            rotate([0, 0, -code_pos*ang])
                translate([inner_d/2, 0, 0])
                square([notch_depth*2, notch_width+e], true);
            for(i=[0:seg-1])
                rotate([0, 0, i*ang + ang/2])
                translate([outer_d/2, 0, 0])
                circle(1);
        }
        for(i = [0:seg-1]) {
            rotate([0, 0, -i*ang])
                translate([outer_d/2 - e, 0, w/2])
                rotate([0, 90, 0])
                linear_extrude(height=1)
                text(str(chars[i]), size=min(1.2*w, 2*outer_d/seg), halign="center", valign="center");
        }
    }
}

module rod(d=rod_d, rod_tip=rod_tip, box_thickness=box_thickness, disk_offset=disk_offset, disks=disk_amount, disk_width=disk_width, pin_width=app_pin_width, pin_depth=app_pin_depth, app_thickness=app_thickness, app_pos=app_pos, notch_width=notch_width, notch_depth=notch_depth, latch_thickness=latch_thickness, latch_length=latch_length) {
    //shaft
    cylinder(h=disk_offset+disks*disk_width*2+box_thickness+rod_tip, d=d);
    //notches
    translate([d/2, 0, disk_offset+e]) {
        for(i = [0 : disks-1]) {
            translate([0, 0, i*disk_width*2 + disk_width/2]) cube([notch_depth*2, notch_width, disk_width-2*e], true);
        }
    }
    //latch
    difference() {
        translate([latch_length/2, 0, latch_thickness/2])
            cube([latch_length, d, latch_thickness], true);
        translate([app_pos+app_thickness/2, 0, pin_depth/2])
            cube([pin_width/2, pin_width, pin_depth], true);
    }
}

module appendage(d=rod_d, pin_width=app_pin_width, pin_depth=app_pin_depth, app_thickness=app_thickness, app_length=app_length, app_pos=app_pos) {
    translate([app_pos+app_thickness/2, 0, -app_length/2]) {
        cube([app_thickness, d, app_length], true);
        translate([0, 0, app_length/2+pin_depth/2]) cube([pin_width/2, pin_width, pin_depth], true);
    }
}

module lock_mech(codes = [0, 0, 0, 0]) {
    disks = len(codes);
    rod();
    appendage();
    translate([0, 0, disk_offset-disk_width]) for(i = [0 : disks-1]) {
        translate([0, 0, i*disk_width*2]) disk(code_pos = codes[disks-i-1]);
    }
}

pos = [[0,0,0], [0,dist,0], [dist,0,0], [dist,dist,0]];

translate([0, 0, 10])
    rotate([-90, 0, 0])
    rotate([0, -90, 0])
    rod();
translate([10, 0, 10])
    rotate([0, 0, 90])
    rotate([-90, 0, 0])
    appendage();
translate([-70, 30, 0])
    for(i=[0 : 3]) {
        translate(pos[i]) disk(code_pos = codes[i]);
    }
translate([0, -30, 15])
    rotate([0, -90, 0])
    lock_mech(codes=codes);