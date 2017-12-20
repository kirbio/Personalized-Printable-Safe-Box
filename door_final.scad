//--CUSTOMIZABLE PARAMETER-----           <<< ONLY CUSTOMIZE HERE
//------------------------------
doorLength=125;
doorWidth=37;                           
doorHeight=70;
//------------------------------

//-----CONSTANTS (NOT CUSTOMIXABLE)-------
doorOpeningOffset = 1;
lockLength = 105;
lockBase = 18;
lockHeight = 36;
lockWidth = 32;
latchBaseLength = 40;
latchRad = 5;
latchHoleOffset = 1;
latchHoleRad = latchRad + latchHoleOffset;
latchHoleDia = 2*latchHoleRad;
latchHoleCenter = 10+latchRad;
latchHeight = 2*latchHoleRad;
latchSlotHeight = 2*latchHoleRad;
appendageLength = 15;
thickness = 5;
latchDisplace = 10;
diskCoverLength = 65;
diskCoverWidth = 5;
spinOffset = 3;
teethGap = 5;

//base block of the door
module baseBlock(length, width, height){
    difference(){
        translate([-length+lockLength,0,lockBase-height/2])cube([length-doorOpeningOffset*2,width,height]);
        translate([0,0,0])cube([lockLength,lockWidth,lockHeight]);
    }
    cube([latchBaseLength,lockWidth,lockHeight]);
    translate([100,0,0])cube([thickness-doorOpeningOffset*2,lockWidth,lockHeight]);
     
}

//the real door
module lock_door(length, width, height){
    //latch slot
   difference(){
       baseBlock(length, width, height);
       union(){
           translate([100,latchHoleCenter,latchHeight+latchHoleRad])rotate([0,90,0])cylinder(thickness,d=latchHoleDia,center=false);
           translate([appendageLength+(latchDisplace+latchRad*2),latchHoleCenter-latchHoleRad,latchHeight])cube([10,latchSlotHeight,latchSlotHeight]);
           translate([appendageLength,0,latchHeight])cube([(latchDisplace+latchRad*2),latchHoleCenter+latchHoleRad,latchSlotHeight]);
           translate([0,0,latchHeight])cube([appendageLength,5,latchSlotHeight]);
       }
    }
    //disk slots
    difference(){
        translate([40,0,0])cube([diskCoverLength-doorOpeningOffset*2,diskCoverWidth,lockHeight]);
        union(){
            translate([55,0,spinOffset])cube([100-55,spinOffset,lockHeight-spinOffset*2]);
            for(i = [1:4]){
               translate([50+10*i,spinOffset,spinOffset])cube([teethGap+1,diskCoverWidth-spinOffset,lockHeight-spinOffset*2]); 
            }
            
        }
    }
    //cube to cover door's end    //translate([100,0,18-doorHeight/2])cube([5+doorOpeningOffset*2,5,doorHeight]);
    doorAddhinge(lockLength-length-5,5,lockBase-height/2,height/7,height);
}

//pin used in assembling
module pin(of){
    cube([8+of,7+of,7+of]);
}

//use to seperate a assemble piece
module intersect_cube(of, length, width, height){
    of2 = (of>0)?of/2:0;
    union(){
        translate([100,0,0])cube([5,width,height/2+lockBase]);
        translate([15,latchHoleCenter+latchHoleRad,latchHeight])cube([25,width-(latchHoleCenter+latchHoleRad),latchSlotHeight]);
        translate([15,width-5,0])cube([lockLength-15,5,lockHeight]);
        translate([15-8-of2,22+4-of2,11+3-of2])pin(of);
        translate([100-8-of2,0+4-of2,36+4-of2])pin(of);
        translate([100-8-of2,width-4-7-of2,36+4-of2])pin(of);
    }
    
}

//a piece that can be disassembled to insert latch
module lock_cover(length, width, height){
   intersection(){
    lock_door(length, width, height);
    intersect_cube(0, length, width, height);
   }
   
}

//the remaining door after remove piece
module lock_door_partial(length, width, height){
    difference(){
        lock_door(length, width, height);
        intersect_cube(1, length, width, height);
    }
}

//hinge similar to container's
module doorHinge(x,y,z,hingeHeight){
    translate([x,y,z])
    rotate([0,0,-90])
    difference(){
        union(){
           translate ([-5,0,0])cube([10,5,hingeHeight]); 
           cylinder(hingeHeight,5,5,false);
        }
        cylinder(hingeHeight,3,3,false);
    }
}

//use to add hignes
module doorAddhinge(x,y,z,hingeHeight,totalHeight){
    totalhinge= ceil(doorHeight/(2*hingeHeight));
    for (i = [0:totalhinge-1]){
        z2 = z + i*hingeHeight*2;
        doorHinge(x,y,z2,hingeHeight);
    }
}

//the main module to generate the door
module disassembled_door(doorLength=125, doorWidth=37, doorHeight=70){
    if(doorLength < 125) {doorLength = 125;}
    if(doorWidth < 37) {doorWidth = 37;}
    if(doorHeight < 70) {doorHeight = 70;}
    //reduce door length by offset
    reducedDoorLength = doorLength-doorOpeningOffset;
    
    rotate([90,0,0])lock_door_partial(reducedDoorLength,doorWidth,doorHeight);
    
    translate([100,0,0])lock_cover(reducedDoorLength,doorWidth,doorHeight);
}

disassembled_door(doorLength,doorWidth,doorHeight);
