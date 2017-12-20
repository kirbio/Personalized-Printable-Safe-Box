//=======Customizable Parameter=======
width = 150;    //Container Width
height = 80;    //Container Height
depth = 90;     //Container "Depth"
off = 5;        //Border Thickness
numshelf = 2;   //Number of Shelf inside   
//==================================

//=======Constant, Do not edit========
doorOff=0.5;
hingeOffset=1.2;
//==================================

//Container Outline
module container_comp(width=200,height=80,depth=80,off=5){
difference() {
cube([width,depth,height]);
translate([off+10-doorOff,off-doorOff,off-doorOff]) cube([width-off*2-15+2*doorOff,depth-off+2*doorOff,height-off*2+2*doorOff]);
}
for (i=[1:numshelf-1]){
    divider((height)*i/numshelf,width,depth,off-doorOff);
}
}

//Shelf Divider
module divider(y=50,width=200,depth=80,thickness=5){
    translate([thickness+10,thickness,y]) cube([width-thickness*2-10,depth-45+doorOff,thickness]);
}

//Hinge
module hinge(x,y,z,hingeHeight){
    translate([x,y,z])
    rotate([0,0,180])
    
    union(){
       translate ([-5,0,0])cube([10-doorOff,5,hingeHeight]); 
       cylinder(hingeHeight,5,5,false);
    }
       
    
}
//Hinge Position Calculation
module addhinge(x,y,z,hingeHeight,totalHeight){
    totalhinge= floor(totalHeight/(2*hingeHeight));
    echo(totalhinge);
    for (i = [0:totalhinge-1]){
        z2 = z + i*hingeHeight*2;
        hinge(x,y,z2+hingeOffset,hingeHeight-hingeOffset*2);
    }

}

//Container with hinge added
module container_solid(width=150,height=80,depth=80,off=5){
    difference() {
container_comp(width,height,depth,off);
    union(){
translate([5,depth-15,height/2]) rotate([0,90,0]) cylinder(15,6,6,false);
       translate([width-off-5,depth-10,off-doorOff]) cube([off+5,10,height-off*2+2*doorOff]);
        translate([15-3,depth-40,off-doorOff])cube([off-2,40,height-off*2+doorOff*2]);
    }
}
totalHeight = height-off*2;
    hingeHeight = 10;
    x = width-5;
    y = depth-5;
    z = 10+off;
addhinge(x,y,z,hingeHeight,totalHeight);

}

//Actual Container Module. Rotated to printing-ready position
module container(width=150,height=80,depth=80,off=5){
rotate([90,0,0])difference(){
    container_solid(width,height,depth,off);
    translate([width-5,depth-5,0])cylinder(height,3,3,false);
}
}

container(width,height,depth,off);