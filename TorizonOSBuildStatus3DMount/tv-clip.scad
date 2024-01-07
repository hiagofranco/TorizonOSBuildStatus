$fa = $preview ? 6 : 1;
$fs = $preview ? 0.4: 0.1;

include <BOSL2/std.scad>

mallow_width = 100;
mallow_height = 72;
mallow_depth = 5;
// the Mallow holes have radius 1.6mm and distance from hole to edge 1.4mm
// thus baord edge to hole center is 3mm
hole_padding = 3;
wall_padding = 2;
wall_thickness = 3;
// TV clip measurements
tvclip_front_tab = 10;
tvclip_back_tab = 45;
tvclip_height = 45;
connector_spacing_height = 15;
// width of this connector as a fraction of the Mallow
connector_spacing_width = mallow_width;
// very small value for good intersection
delta = 0.001;
// snap tolerance
snap_tolerance = 0.25;

module tvclip(){
    // base frame to attach to the TV
    diff("tvclip_remove")
    tvclip_frame(tvclip_height){
        tag("tvclip_remove") tvclip_carving();
    }
}

module tvclip_frame(lheight){
    rect_tube(
        size=[connector_spacing_width, tvclip_back_tab],
        // some arbitrary numbers that looked good
        wall = wall_thickness, rounding = 4, ichamfer = 4,
        height = lheight + mallow_depth / 2,
        anchor = BOTTOM){
            position(CENTER+BOTTOM) children(0); // carving area
            position(BACK+BOTTOM) {
                dovetail();
                join_dovetail_and_tvclip();
            }
            position(BACK+TOP) tvclip_front(mallow_depth / 2);
        }
}

module tvclip_front(lheight){
    translate([0, 0, -2 * lheight])
    cuboid(
        size = [
            connector_spacing_width,
            tvclip_front_tab,
            3 * lheight
        ],
        rounding = 4,
        except = [TOP, BOTTOM],
        anchor = BOTTOM+BACK);
}

module tvclip_carving(){
    translate([0, - wall_thickness, mallow_depth / 2]){
        diff("tvclip_carving_fillets")
        // base to carve all but the wall
        cuboid(
            size = [
                connector_spacing_width + delta,
                tvclip_back_tab,
                tvclip_height + delta],
            anchor = BOTTOM
        ){
            // fillets to make stronger joins
            // bottom fillet
            tag("tvclip_carving_fillets")
            position(BOTTOM+BACK) tvclip_carving_fillet(180);
            // top fillet
            tag("tvclip_carving_fillets")
            position(TOP+BACK) tvclip_carving_fillet(270);

            // over the wall carving
            position(BOTTOM+BACK) tvclip_carving_window(mallow_depth);
        }
    }
}

module tvclip_carving_fillet(fillet_spin){
    fillet(
        l = connector_spacing_width + 2 * delta,
        r = 3,
        orient = RIGHT,
        spin = fillet_spin
    );
}

module tvclip_carving_window(window_depth){
    translate([0, 0, window_depth])
    cuboid(
        size = [
            connector_spacing_width - 4 * wall_thickness + delta,
            3 * wall_thickness,
            tvclip_height - 2 * mallow_depth + delta
        ],
        rounding = 4,
        except = [FRONT, BACK],
        anchor = BOTTOM
    );
}

module dovetail(){
    // carving to insert and lock the dovetail
    rect_tube(
        // add extra height so that HDMI and power cables can go through it
        size=[connector_spacing_width, connector_spacing_height],
        h = mallow_depth + delta,
        // some arbitrary numbers that looked good
        wall = wall_thickness, ichamfer = 3,
        anchor = FRONT+BOTTOM
    ){
        // here are the dimensions of the carving
        // this is the part of the mount that slides into the dovetail
        diff("dovetail_snap")
        position(TOP+BACK)
        prismoid(
            size1=[mallow_width / 4 - 2 * wall_padding - snap_tolerance, mallow_height / 5],
            size2=[mallow_width / 4 - 4 * wall_padding - snap_tolerance, mallow_height / 5],
            h = mallow_depth / 2 + delta,
            anchor = FRONT+TOP
        ){
            position(BOTTOM) tag("dovetail_snap") cyl(
                length = mallow_width / 10,
                d = wall_padding / 2,
                rounding = wall_padding / 10,
                orient = LEFT
            );
        }
        // these two fillets fit the rounding borders of the board mount
        position(RIGHT+BACK)
        fillet(
            l = mallow_depth,
            r = 4,
            //orient = RIGHT,
            spin = 90
        );
        position(LEFT+BACK)
        fillet(
            l = mallow_depth,
            r = 4,
            orient = DOWN,
            spin = 90
        );
    }
    // fillet to make a stronger join with the tvclip
    translate([0, 0, mallow_depth - delta]) fillet(
        l = connector_spacing_width - 2 * 4,
        r = 3,
        orient = RIGHT,
        spin = 90
    );
}

module join_dovetail_and_tvclip(){
    // join the dovetail with the tvclip
    // without it, there are too many straigh edges
    // and finishing looks bad
    cube([
        connector_spacing_width,
        4 - delta,
        mallow_depth],
        anchor = BACK+BOTTOM
    );
}

tvclip();
