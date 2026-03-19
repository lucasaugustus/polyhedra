#declare rot1=rand(rotation)*pi*2;
#declare rot2=acos(1-2*rand(rotation));
#declare rot3=(rand(rotation)+clock)*pi*2;
#macro dorot()
  rotate rot1*180/pi*y
  rotate rot2*180/pi*x
  rotate rot3*180/pi*y
#end

#declare twist = pi/12;
#declare A = <cos(      twist), sin(      twist),  1>;
#declare B = <cos(2*pi/3 + twist), sin(2*pi/3 + twist),  1>;
#declare C = <cos(4*pi/3 + twist), sin(4*pi/3 + twist),  1>;
#declare D = <cos(    - twist), sin(    - twist), -1>;
#declare E = <cos(2*pi/3 - twist), sin(2*pi/3 - twist), -1>;
#declare F = <cos(4*pi/3 - twist), sin(4*pi/3 - twist), -1>;

union {
  sphere{A, 0.01}
  sphere{B, 0.01}
  sphere{C, 0.01}
  sphere{D, 0.01}
  sphere{E, 0.01}
  sphere{F, 0.01}
  cylinder {A, B, 0.01}
  cylinder {B, C, 0.01}
  cylinder {C, A, 0.01}
  cylinder {D, E, 0.01}
  cylinder {E, F, 0.01}
  cylinder {F, D, 0.01}
  
  cylinder {A, D, 0.01}
  cylinder {B, E, 0.01}
  cylinder {C, F, 0.01}
  cylinder {D, B, 0.01}
  cylinder {E, C, 0.01}
  cylinder {F, A, 0.01}
  dorot()
  pigment { colour <.3,.3,.3> } finish { ambient 0 diffuse 1 phong 1 }
}

union {
  triangle {A, B, C}
  triangle {D, E, F}
  triangle {A, B, D}
  triangle {B, C, E}
  triangle {A, C, F}
  triangle {A, D, F}
  triangle {B, E, D}
  triangle {C, F, E}
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

#for (a, 0, 11)
  light_source { <4*sin(a*pi*2/11), 5*cos(a*pi*6/11), -4*cos(a*pi*2/11)> colour (1+<sin(a*pi*2/11),sin(a*pi*2/11+pi*2/3),sin(a*pi*2/11+pi*4/3)>)*2/11 }
#end

background { color <1,1,1> }

camera {
  perspective
  location <0,0,0>
  direction <0,0,1>
  right x*2/3
  up y*2/3
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
