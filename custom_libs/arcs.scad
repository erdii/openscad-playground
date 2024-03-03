/* Explanation of arc() module:
    This module is for creating 2D arcs. 

   arc( a               = angle of arc, 
        r1 or r         = radius 1, 
        r2              = radius 2,
        fragFixed or ff = set a fixed number of fragments in arc
        fragRound or fr = round number of fragments to an integer)

Key Feature:
    Rather than cutting shapes out of a circle, this arc() module 
    creates the arc from scratch by calculates the vectors of each 
    point, this means radius at the open ends of the arc is always 
    true and all the fragments are of equal size.

Parameters:
a: 
    Angle of the arc. Value range = [-360 : 360]
    If undefined the default value = 360 
 
r1 or r: 
    Sets the radius of the arc. 
    If undefined the default value = 0 


r2: 
    Gives the option of a second radius to turn the circle    
    section into a ring section.
    If undefined the default value = 0        

fragFixed or ff: 
    Gives the option of setting a fixed number of fragments in the arc, irrespective of the angle size. 
    fragFixed=0 or fragFixed=undef deactivates this parameter, so undef is the default state.
    If, for some reason, you put both fragFixed and ff in the argument, fragFixed will override ff.

    By default, the number of fragments is set by $fn or $fa, this value will determine the number of fragments in a full circle. The number of fragments in the arc is proportional to the size of its angle, so, an arc of 180° will have half as many fragments as an arc of 360°. This keeps the fragments as close to a constant size as possible.

    If $fn=undef or $fn=0, which it is by default, the number of figments is set by $fa (minimum angle), which has a default value of 12°.  (360°/12° = 30 figments in a circle)

fragRound or fr: 
    The number of fragments has to be an integer, however dividing the angle by $fn will more often than not return a floating-point number which has to be rounded up or down.
    If fragRound=undef  or fragRound="down" or fragRound=0 it will round down (default). Rounding down is the default because this will match segments with rotate_extrude.
    If fragRound="near" or fragRound=1 it will round to the nearest integer.
    If fragRound="up"   or fragRound=2 it will round up.
    If, for some reason, you put both fragRound and fr in the argument, fragRound will override fr.
*/




//>>>>>>>>>>>>> Call arc module <<<<<<<<<<<<< 
//arc(a=270, r1=10, r2=8, fragFixed=undef, fragRound=undef);
arc(a=270, r1=10, r2=8);

//>>>>>>>>>>>> Declair arc module <<<<<<<<<<<< 
module arc(a, r1, r2, fragFixed, fragRound, r, ff, fr){

//variable lable r or r1 bothe acceptable, r1 will overide 
r1 = r1==undef && r==undef   ? undef  :
     r1==undef && is_num(r)  ? r      : r1;

//fragFixed can accept ether lable fragFixed or ff, 
ff = fragFixed!=undef ? fragFixed : (ff !=undef ? ff  : 0);
//disable fragFixed if undef
fragFixed = ff==undef || ff<=0 ? undef : ff;

//fragRound can accept ether lable "fragRound" or "fr"
fragRound = fragRound!=undef ? fragRound : (fr !=undef ? fr  : 0);

//Prevent the arc from intersecting itsef and make negative angle values positive.
angCap  =  (a == undef || a >   360) ? 360  : 
           (a <  0     && a >= -360) ? a*-1 : 
                          a <  -360  ? 360  : a; 
             
//set number of fragments 
frag = min_frag( // if below threshold apply munimum value cap 
fragFixed==undef ? ($fn==undef || $fn==0 ? ((360/($fa==undef ? 90:$fa))/360)*angCap : (($fn/360)*angCap)) : fragFixed);

//Round the number of fragments ether up or down too an intager. min num frag=1
fragNum = fragRound==undef || fragRound=="down" || fragRound==0 ? (floor(frag)<1?1:floor(frag))://round down (defult)
                              fragRound=="near" || fragRound==1 ? (round(frag)<1?1:round(frag))://round  
                              fragRound=="up"   || fragRound==2 ?  ceil (frag)://round up 
                                                                  (floor(frag)<1?1:floor(frag));//round down


//number of vectors
l=len(points(r1));

color("gold")
mirror([0, (a==undef || a>0) ? 1 : 0])//flip arc if angle < 0 
rotate([0,0,-90])
if(((r1==undef || r1<=0) && (r2==undef || r2<=0)) || r1==r2 || angCap==undef || angCap==0 ){
    //The shape has no dimentions so do nothing.
}
else{
    if( r2==undef || r2<=0){
    //Outer radeus defined by r1, No inner radius.
    polygon(concat([for (i=[0:l-1]) points(r1)[i]], [[0,0]]));
}
else{
    if( r1==undef || r1<=0){
    //Outer radeus defined by r2, No inner radius.
    polygon(concat([for (i=[0:l-1]) points(r2)[i]], [[0,0]]));
}
else{
    //Inner and outer radiuses
    polygon([for (i=[0:(l*2)-1]) i<l ? points(r1)[i] : points(r2)[(l*2)-(i+1)]]);
}
}
}


//FUNCTIONS
//calculate the postion of the points.
function points (r) = [ for (a = [0 : angCap/round(fragNum) : angCap]) [ r * sin(a), r * cos(a) ] ];

//set a minimum number of Number_of_fragments to a given angle size.
function min_frag(fragIn)=
(fragIn==undef || fragIn<4) && angCap>=270 ? 3 :
(fragIn==undef || fragIn<3) && angCap>=180 ? 2 : 
(fragIn==undef || fragIn<2) && angCap>= 90 ? 1 : fragIn;
//(fragIn==undef || fragIn<1) && angCap>=  0 ? 1 : fragIn;
}

/* Publication Notes 

arc() Module for OpenSCAD (vertion 01) by SavageRodent
https://www.thingiverse.com/thing:5186085
Last updated: 20/07/2022
Published under: the Creative Commons CC - BY 3.0 licence
Licence details here: https://creativecommons.org/licenses/by/3.0/
*/