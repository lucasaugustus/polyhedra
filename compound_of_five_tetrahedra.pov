//Picture   ***  Use flashiness=1 !!! ***
//
//   +w1024 +h1024 +a0.3 +am2
//   +w512 +h512 +a0.3 +am2
//
//Movie   ***  Use flashiness=0.25 !!! ***
//
//   +kc +kff120 +w256 +h256 +a0.3 +am2
//   +kc +kff60 +w256 +h256 +a0.3 +am2
//"Fast" preview
//   +w128 +h128
#declare notwireframe=1;
#declare withreflection=0;
#declare flashiness=1; //Still pictures use 1, animated should probably be about 0.25.

#declare rotation=seed(22113);

#declare rot1=rand(rotation)*pi*2;
#declare rot2=acos(1-2*rand(rotation));
#declare rot3=(rand(rotation)+clock)*pi*2;
#macro dorot()
  rotate rot1*180/pi*y
  rotate rot2*180/pi*x
  rotate rot3*180/pi*y
#end

#declare c0 = (sqrt(5) - 1) / (2 * sqrt(3));    // 0.356822089773
#declare c1 = (sqrt(5) + 1) / (2 * sqrt(3));    // 0.934172358963
#declare c2 = c1 - c0;                          // 0.577350269190; 1 / sqrt(3)

#declare pt00 = <  0, c0,-c1>;
#declare pt01 = < c0,-c1,  0>;
#declare pt02 = < c1,  0,-c0>;
#declare pt03 = <-c0,-c1,  0>;
#declare pt04 = <-c2,-c2, c2>;
#declare pt05 = <  0,-c0,-c1>;
#declare pt06 = <-c1,  0,-c0>;
#declare pt07 = < c2,-c2,-c2>;
#declare pt08 = < c2,-c2, c2>;
#declare pt09 = <-c2,-c2,-c2>;
#declare pt10 = <  0,-c0, c1>;
#declare pt11 = <-c1,  0, c0>;
#declare pt12 = <-c2, c2,-c2>;
#declare pt13 = <-c2, c2, c2>;
#declare pt14 = <-c0, c1,  0>;
#declare pt15 = < c2, c2,-c2>;
#declare pt16 = < c2, c2, c2>;
#declare pt17 = < c0, c1,  0>;
#declare pt18 = < c1,  0, c0>;
#declare pt19 = <  0, c0, c1>;

// Tetrahedron #1 uses vertices 0, 1, 11, and 16.
// Tetrahedron #2 uses vertices 2, 3, 12, and 19.
// Tetrahedron #3 uses vertices 4, 5, 14, and 18.
// Tetrahedron #4 uses vertices 6, 7, 10, and 17.
// Tetrahedron #5 uses vertices 8, 9, 13, and 15.

union {
  sphere { pt00, .01 }
  sphere { pt01, .01 }
  sphere { pt11, .01 }
  sphere { pt16, .01 }
  cylinder { pt00, pt01, .01 }
  cylinder { pt00, pt11, .01 }
  cylinder { pt00, pt16, .01 }
  cylinder { pt01, pt11, .01 }
  cylinder { pt01, pt16, .01 }
  cylinder { pt11, pt16, .01 }
  sphere { pt02, .01 }
  sphere { pt03, .01 }
  sphere { pt12, .01 }
  sphere { pt19, .01 }
  cylinder { pt02, pt03, .01 }
  cylinder { pt02, pt12, .01 }
  cylinder { pt02, pt19, .01 }
  cylinder { pt03, pt12, .01 }
  cylinder { pt03, pt19, .01 }
  cylinder { pt12, pt19, .01 }
  sphere { pt04, .01 }
  sphere { pt05, .01 }
  sphere { pt14, .01 }
  sphere { pt18, .01 }
  cylinder { pt04, pt05, .01 }
  cylinder { pt04, pt14, .01 }
  cylinder { pt04, pt18, .01 }
  cylinder { pt05, pt14, .01 }
  cylinder { pt05, pt18, .01 }
  cylinder { pt14, pt18, .01 }
  sphere { pt06, .01 }
  sphere { pt07, .01 }
  sphere { pt10, .01 }
  sphere { pt17, .01 }
  cylinder { pt06, pt07, .01 }
  cylinder { pt06, pt10, .01 }
  cylinder { pt06, pt17, .01 }
  cylinder { pt07, pt10, .01 }
  cylinder { pt07, pt17, .01 }
  cylinder { pt10, pt17, .01 }
  sphere { pt08, .01 }
  sphere { pt09, .01 }
  sphere { pt13, .01 }
  sphere { pt15, .01 }
  cylinder { pt08, pt09, .01 }
  cylinder { pt08, pt13, .01 }
  cylinder { pt08, pt15, .01 }
  cylinder { pt09, pt13, .01 }
  cylinder { pt09, pt15, .01 }
  cylinder { pt13, pt15, .01 }
  dorot()
  pigment { colour <.3,.3,.3> } finish { ambient 0 diffuse 1 phong 1 }
}

union {
  triangle { pt00, pt01, pt11 }
  triangle { pt00, pt01, pt16 }
  triangle { pt00, pt11, pt16 }
  triangle { pt01, pt11, pt16 }
  triangle { pt02, pt03, pt12 }
  triangle { pt02, pt03, pt19 }
  triangle { pt02, pt12, pt19 }
  triangle { pt03, pt12, pt19 }
  triangle { pt04, pt05, pt14 }
  triangle { pt04, pt05, pt18 }
  triangle { pt04, pt14, pt18 }
  triangle { pt05, pt14, pt18 }
  triangle { pt06, pt07, pt10 }
  triangle { pt06, pt07, pt17 }
  triangle { pt06, pt10, pt17 }
  triangle { pt07, pt10, pt17 }
  triangle { pt08, pt09, pt13 }
  triangle { pt08, pt09, pt15 }
  triangle { pt08, pt13, pt15 }
  triangle { pt09, pt13, pt15 }
  dorot()
  pigment { colour rgbt <.8,.8,.8,.4> }
  finish { ambient 0 diffuse 1 phong flashiness #if(withreflection) reflection { .2 } #end }
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
  right x/2
  up y/2
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
