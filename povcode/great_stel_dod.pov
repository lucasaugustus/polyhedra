#declare notwireframe=1;
#declare withreflection=0;
#declare flashiness=1; //Still pictures use 1, animated should probably be about 0.25.

#declare rot1=rand(rotation)*pi*2;
#declare rot2=acos(1-2*rand(rotation));
#declare rot3=(rand(rotation)+clock)*pi*2;
#macro dorot()
  rotate rot1*180/pi*y
  rotate rot2*180/pi*x
  rotate rot3*180/pi*y
#end

#declare c0 = 1 / sqrt(3);                      // 0.577350
#declare c1 = (sqrt(5) + 1) / (2 * sqrt(3));    // 0.934172
#declare c2 = c1 - c0;                          // 0.356822

#declare pt00 = <-c0,-c0,-c0>; // 07
#declare pt01 = < c0,-c0,-c0>; // 06
#declare pt02 = <-c0, c0,-c0>; // 05
#declare pt03 = < c0, c0,-c0>; // 04
#declare pt04 = <-c0,-c0, c0>; // 03
#declare pt05 = < c0,-c0, c0>; // 02
#declare pt06 = <-c0, c0, c0>; // 01
#declare pt07 = < c0, c0, c0>; // 00
#declare pt08 = <  0,-c1,-c2>; // 17
#declare pt09 = <-c1,-c2,  0>; // 18
#declare pt10 = <-c2,  0,-c1>; // 19
#declare pt11 = <  0, c1,-c2>; // 14
#declare pt12 = < c1,-c2,  0>; // 15
#declare pt13 = <-c2,  0, c1>; // 16
#declare pt14 = <  0,-c1, c2>; // 11
#declare pt15 = <-c1, c2,  0>; // 12
#declare pt16 = < c2,  0,-c1>; // 13
#declare pt17 = <  0, c1, c2>; // 08
#declare pt18 = < c1, c2,  0>; // 09
#declare pt19 = < c2,  0, c1>; // 10

// This solid has point symmetry through the origin, so we build half the structures and mirror them.

#for (s, -1, 1, 2)
  union {
    sphere { pt00, .01 }
    sphere { pt01, .01 }
    sphere { pt02, .01 }
    sphere { pt03, .01 }
    sphere { pt08, .01 }
    sphere { pt09, .01 }
    sphere { pt10, .01 }
    sphere { pt11, .01 }
    sphere { pt12, .01 }
    sphere { pt13, .01 }
    cylinder { pt00, pt17, .01 }
    cylinder { pt00, pt18, .01 }
    cylinder { pt00, pt19, .01 }
    cylinder { pt01, pt13, .01 }
    cylinder { pt01, pt15, .01 }
    cylinder { pt01, pt17, .01 }
    cylinder { pt02, pt12, .01 }
    cylinder { pt02, pt14, .01 }
    cylinder { pt02, pt19, .01 }
    cylinder { pt03, pt09, .01 }
    cylinder { pt03, pt13, .01 }
    cylinder { pt03, pt14, .01 }
    cylinder { pt08, pt11, .01 }
    cylinder { pt09, pt12, .01 }
    cylinder { pt10, pt13, .01 }
    dorot()
    pigment { colour <.3,.3,.3> } finish { ambient 0 diffuse 1 phong 1 }
    scale <s,s,s>
  }
  union {
    polygon { 6, pt00, pt17, pt01, pt15, pt18, pt00 }
    polygon { 6, pt00, pt17, pt14, pt02, pt19, pt00 }
    polygon { 6, pt00, pt18, pt04, pt16, pt19, pt00 }
    polygon { 6, pt01, pt13, pt03, pt14, pt17, pt01 }
    polygon { 6, pt01, pt13, pt10, pt05, pt15, pt01 }
    polygon { 6, pt02, pt12, pt09, pt03, pt14, pt02 }
    dorot()
    pigment { colour rgbt <.8,.8,.8,.2> } finish { ambient 0 diffuse 1 phong flashiness #if(withreflection) reflection { .2 } #end }
    photons {
      target on
      refraction on
      reflection on
      collect on
    }
    scale <s,s,s>
  }
#end

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
