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

#declare c0 = sqrt(0.5 + sqrt(0.05));   // 0.850651
#declare c1 = sqrt(0.5 - sqrt(0.05));   // 0.525731

#declare pt00 = <-c0, c1,  0>; // 05
#declare pt01 = <  0, c0,-c1>; // 08
#declare pt02 = < c1,  0, c0>; // 11
#declare pt03 = <-c1,  0, c0>; // 06
#declare pt04 = < c0, c1,  0>; // 09
#declare pt05 = < c0,-c1,  0>; // 00
#declare pt06 = < c1,  0,-c0>; // 03
#declare pt07 = <  0, c0, c1>; // 10
#declare pt08 = <  0,-c0, c1>; // 01
#declare pt09 = <-c0,-c1,  0>; // 04
#declare pt10 = <  0,-c0,-c1>; // 07
#declare pt11 = <-c1,  0,-c0>; // 02

// This solid has point symmetry through the origin, so we build half the structures and mirror them.

#for (s, -1, 1, 2)
  union {
    sphere { pt00, .01 }
    sphere { pt01, .01 }
    sphere { pt02, .01 }
    sphere { pt03, .01 }
    sphere { pt04, .01 }
    sphere { pt07, .01 }
    cylinder { pt00, pt02, .01 }
    cylinder { pt00, pt04, .01 }
    cylinder { pt01, pt02, .01 }
    cylinder { pt01, pt03, .01 }
    cylinder { pt03, pt04, .01 }
    cylinder { pt00, pt06, .01 }
    cylinder { pt00, pt08, .01 }
    cylinder { pt00, pt10, .01 }
    cylinder { pt01, pt09, .01 }
    cylinder { pt01, pt10, .01 }
    cylinder { pt02, pt06, .01 }
    cylinder { pt02, pt09, .01 }
    cylinder { pt02, pt10, .01 }
    cylinder { pt03, pt10, .01 }
    cylinder { pt04, pt10, .01 }
    dorot()
    pigment { colour <.3,.3,.3> } finish { ambient 0 diffuse 1 phong 1 }
    scale <s,s,s>
  }
  union {
    triangle { pt00, pt02, pt06 }
    triangle { pt00, pt02, pt10 }
    triangle { pt00, pt04, pt08 }
    triangle { pt00, pt04, pt10 }
    triangle { pt00, pt06, pt08 }
    triangle { pt01, pt02, pt09 }
    triangle { pt01, pt02, pt10 }
    triangle { pt01, pt03, pt10 }
    triangle { pt02, pt06, pt09 }
    triangle { pt03, pt04, pt10 }
    dorot()
    pigment { colour rgbt <.8,.8,.8,.4> } finish { ambient 0 diffuse 1 phong flashiness #if(withreflection) reflection { .2 } #end }
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
