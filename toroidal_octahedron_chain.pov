#declare notwireframe=1;
#declare withreflection=0;
#declare flashiness=1;

#declare rotation=seed(0);

#declare rot1=rand(rotation)*pi*2;
#declare rot2=acos(1-2*rand(rotation));
#declare rot3=(rand(rotation)+clock)*pi*2;
#macro dorot()
    rotate rot1*180/pi*y
    rotate rot2*180/pi*x
    rotate rot3*180/pi*y
#end

#macro ReflectPointThroughPlane(D,A,B,C) // Reflect point D through the plane containing A, B, and C
    D + vcross(A - B, A - C) * 2 * vdot(vcross(A - B, A - C), A-D) / vdot(vcross(A - B, A - C), vcross(A - B, A - C))
#end

#declare nudge = <4/3, 0, 4/3>; // This puts the center of the solid at the origin.

// The points of the first octahedron
#declare pt00 =  z + nudge;
#declare pt01 =  x + nudge;
#declare pt02 = -y + nudge;
#declare pt03 = -x + nudge;
#declare pt04 =  y + nudge;
#declare pt05 = -z + nudge;

// The new points for the second octahedron
#declare pt06 = ReflectPointThroughPlane(pt00, pt02, pt03, pt05);
#declare pt07 = ReflectPointThroughPlane(pt01, pt02, pt03, pt05);
#declare pt08 = ReflectPointThroughPlane(pt04, pt02, pt03, pt05);

// The new points for the third octahedron
#declare pt09 = ReflectPointThroughPlane(pt02, pt06, pt07, pt08);
#declare pt10 = ReflectPointThroughPlane(pt03, pt06, pt07, pt08);
#declare pt11 = ReflectPointThroughPlane(pt05, pt06, pt07, pt08);

#declare pt12 = ReflectPointThroughPlane(pt00, pt03, pt04, pt05);
#declare pt13 = ReflectPointThroughPlane(pt01, pt03, pt04, pt05);
#declare pt14 = ReflectPointThroughPlane(pt02, pt03, pt04, pt05);

#declare pt15 = ReflectPointThroughPlane(pt03, pt12, pt13, pt14);
#declare pt16 = ReflectPointThroughPlane(pt04, pt12, pt13, pt14);
#declare pt17 = ReflectPointThroughPlane(pt05, pt12, pt13, pt14);

#declare pt18 = ReflectPointThroughPlane(pt12, pt14, pt15, pt17);
#declare pt19 = ReflectPointThroughPlane(pt13, pt14, pt15, pt17);
#declare pt20 = ReflectPointThroughPlane(pt16, pt14, pt15, pt17);

#declare pt21 = ReflectPointThroughPlane(pt09, pt08, pt10, pt11);

#declare pt22 = ReflectPointThroughPlane(pt10, pt18, pt19, pt21);
#declare pt23 = ReflectPointThroughPlane(pt11, pt18, pt19, pt21);

union {
    sphere {pt00, 0.01}
    sphere {pt01, 0.01}
    sphere {pt02, 0.01}
    sphere {pt03, 0.01}
    sphere {pt04, 0.01}
    sphere {pt05, 0.01}
    cylinder {pt00, pt01, 0.01}
    cylinder {pt00, pt02, 0.01}
    cylinder {pt00, pt03, 0.01}
    cylinder {pt00, pt04, 0.01}
    cylinder {pt01, pt02, 0.01}
    cylinder {pt02, pt03, 0.01}
    cylinder {pt03, pt04, 0.01}
    cylinder {pt01, pt04, 0.01}
    cylinder {pt01, pt05, 0.01}
    cylinder {pt02, pt05, 0.01}
    cylinder {pt03, pt05, 0.01}
    cylinder {pt04, pt05, 0.01}
    sphere {pt06, 0.01}
    sphere {pt07, 0.01}
    sphere {pt08, 0.01}
    cylinder {pt02, pt06, 0.01}
    cylinder {pt03, pt06, 0.01}
    cylinder {pt02, pt07, 0.01}
    cylinder {pt05, pt07, 0.01}
    cylinder {pt03, pt08, 0.01}
    cylinder {pt05, pt08, 0.01}
    cylinder {pt06, pt07, 0.01}
    cylinder {pt07, pt08, 0.01}
    cylinder {pt08, pt06, 0.01}
    sphere {pt09, 0.01}
    sphere {pt10, 0.01}
    sphere {pt11, 0.01}
    cylinder {pt06, pt10, 0.01}
    cylinder {pt08, pt10, 0.01}
    cylinder {pt06, pt09, 0.01}
    cylinder {pt07, pt09, 0.01}
    cylinder {pt07, pt11, 0.01}
    cylinder {pt08, pt11, 0.01}
    cylinder {pt09, pt10, 0.01}
    cylinder {pt10, pt11, 0.01}
    cylinder {pt09, pt11, 0.01}
    sphere {pt12, 0.01}
    sphere {pt13, 0.01}
    sphere {pt14, 0.01}
    cylinder {pt04, pt12, 0.01}
    cylinder {pt04, pt13, 0.01}
    cylinder {pt03, pt12, 0.01}
    cylinder {pt03, pt14, 0.01}
    cylinder {pt05, pt13, 0.01}
    cylinder {pt05, pt14, 0.01}
    cylinder {pt12, pt13, 0.01}
    cylinder {pt12, pt14, 0.01}
    cylinder {pt13, pt14, 0.01}
    sphere {pt15, 0.01}
    sphere {pt16, 0.01}
    sphere {pt17, 0.01}
    cylinder {pt12, pt15, 0.01}
    cylinder {pt12, pt16, 0.01}
    cylinder {pt13, pt16, 0.01}
    cylinder {pt13, pt17, 0.01}
    cylinder {pt14, pt15, 0.01}
    cylinder {pt14, pt17, 0.01}
    cylinder {pt15, pt16, 0.01}
    cylinder {pt16, pt17, 0.01}
    cylinder {pt15, pt17, 0.01}
    sphere {pt18, 0.01}
    sphere {pt19, 0.01}
    sphere {pt20, 0.01}
    cylinder {pt15, pt20, 0.01}
    cylinder {pt17, pt20, 0.01}
    cylinder {pt14, pt18, 0.01}
    cylinder {pt15, pt18, 0.01}
    cylinder {pt14, pt19, 0.01}
    cylinder {pt17, pt19, 0.01}
    cylinder {pt18, pt19, 0.01}
    cylinder {pt19, pt20, 0.01}
    cylinder {pt18, pt20, 0.01}
    sphere {pt21, 0.01}
    cylinder {pt10, pt21, 0.01}
    cylinder {pt11, pt21, 0.01}
    cylinder {pt08, pt18, 0.01}
    cylinder {pt10, pt18, 0.01}
    cylinder {pt08, pt19, 0.01}
    cylinder {pt11, pt19, 0.01}
    cylinder {pt18, pt21, 0.01}
    cylinder {pt19, pt21, 0.01}
    sphere {pt22, 0.01}
    sphere {pt23, 0.01}
    cylinder {pt18, pt22, 0.01}
    cylinder {pt20, pt22, 0.01}
    cylinder {pt21, pt22, 0.01}
    cylinder {pt19, pt23, 0.01}
    cylinder {pt20, pt23, 0.01}
    cylinder {pt21, pt23, 0.01}
    cylinder {pt22, pt23, 0.01}
    sphere {<0,0,0>, 0.1}
    dorot()
    pigment { colour <.3,.3,.3> } finish { ambient 0 diffuse 1 phong 1 }
}
union {
    triangle {pt00, pt01, pt02}
    triangle {pt00, pt02, pt03}
    triangle {pt00, pt03, pt04}
    triangle {pt00, pt01, pt04}
    triangle {pt01, pt02, pt05}
    triangle {pt01, pt04, pt05}
    triangle {pt02, pt03, pt06}
    triangle {pt02, pt05, pt07}
    triangle {pt03, pt05, pt08}
    triangle {pt02, pt06, pt07}
    triangle {pt03, pt06, pt08}
    triangle {pt05, pt07, pt08}
    triangle {pt06, pt08, pt10}
    triangle {pt06, pt07, pt09}
    triangle {pt07, pt08, pt11}
    triangle {pt06, pt09, pt10}
    triangle {pt07, pt09, pt11}
    triangle {pt09, pt10, pt11}
    triangle {pt04, pt12, pt13}
    triangle {pt03, pt12, pt14}
    triangle {pt05, pt13, pt14}
    triangle {pt03, pt04, pt12}
    triangle {pt04, pt05, pt13}
    triangle {pt03, pt05, pt14}
    triangle {pt12, pt15, pt16}
    triangle {pt13, pt16, pt17}
    triangle {pt12, pt14, pt15}
    triangle {pt12, pt13, pt16}
    triangle {pt13, pt14, pt17}
    triangle {pt15, pt16, pt17}
    triangle {pt15, pt18, pt20}
    triangle {pt14, pt18, pt19}
    triangle {pt17, pt19, pt20}
    triangle {pt14, pt15, pt18}
    triangle {pt14, pt17, pt19}
    triangle {pt15, pt17, pt20}
    triangle {pt10, pt18, pt21}
    triangle {pt08, pt18, pt19}
    triangle {pt08, pt10, pt18}
    triangle {pt10, pt11, pt21}
    triangle {pt08, pt11, pt19}
    triangle {pt11, pt19, pt21}
    triangle {pt18, pt20, pt22}
    triangle {pt18, pt21, pt22}
    triangle {pt19, pt20, pt23}
    triangle {pt19, pt21, pt23}
    triangle {pt20, pt22, pt23}
    triangle {pt21, pt22, pt23}
    dorot()
    pigment { colour rgbt <.8,.8,.8,.4> } finish { ambient 0 diffuse 1 phong flashiness #if(withreflection) reflection { .2 } #end }
    photons {
        target on
        refraction on
        reflection on
        collect on
    }
}

#local a=0;
#while(a<11.0001)
  light_source { <4*sin(a*pi*2/11), 5*cos(a*pi*6/11), -4*cos(a*pi*2/11)> colour (1+<sin(a*pi*2/11),sin(a*pi*2/11+pi*2/3),sin(a*pi*2/11+pi*4/3)>)*2/11 }
  #local a=a+1;
#end

background { color <1,1,1> }

camera {
  perspective
  location <0,0,0>
  direction <0,0,1>
  right x*2
  up y*2
  sky <0,1,0>
  location <0,0,-4.8>
  look_at <0,0,0>
}

global_settings {
  max_trace_level 40
  photons {
    count 200000
    autostop 0
  }
}
