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

#declare rotation=seed(11404);

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

#declare pt00 = <  0,-c0,-c1>;
#declare pt01 = <-c0,-c1,  0>;
#declare pt02 = <-c1,  0,-c0>;
#declare pt03 = <  0, c0,-c1>;
#declare pt04 = < c0,-c1,  0>;
#declare pt05 = <-c1,  0, c0>;
#declare pt06 = <  0,-c0, c1>;
#declare pt07 = <-c0, c1,  0>;
#declare pt08 = < c1,  0,-c0>;
#declare pt09 = <  0, c0, c1>;
#declare pt10 = < c0, c1,  0>;
#declare pt11 = < c1,  0, c0>;


union {
  sphere { pt00, .01 }
  sphere { pt01, .01 }
  sphere { pt02, .01 }
  sphere { pt03, .01 }
  sphere { pt04, .01 }
  sphere { pt05, .01 }
  sphere { pt06, .01 }
  sphere { pt07, .01 }
  sphere { pt08, .01 }
  sphere { pt09, .01 }
  sphere { pt10, .01 }
  sphere { pt11, .01 }
  cylinder { pt00, pt03, .01 }
  cylinder { pt00, pt05, .01 }
  cylinder { pt00, pt07, .01 }
  cylinder { pt00, pt10, .01 }
  cylinder { pt00, pt11, .01 }
  cylinder { pt01, pt03, .01 }
  cylinder { pt01, pt04, .01 }
  cylinder { pt01, pt08, .01 }
  cylinder { pt01, pt09, .01 }
  cylinder { pt01, pt11, .01 }
  cylinder { pt02, pt04, .01 }
  cylinder { pt02, pt05, .01 }
  cylinder { pt02, pt06, .01 }
  cylinder { pt02, pt09, .01 }
  cylinder { pt02, pt10, .01 }
  cylinder { pt03, pt04, .01 }
  cylinder { pt03, pt05, .01 }
  cylinder { pt03, pt11, .01 }
  cylinder { pt04, pt05, .01 }
  cylinder { pt04, pt09, .01 }
  cylinder { pt05, pt10, .01 }
  cylinder { pt06, pt07, .01 }
  cylinder { pt06, pt08, .01 }
  cylinder { pt06, pt09, .01 }
  cylinder { pt06, pt10, .01 }
  cylinder { pt07, pt08, .01 }
  cylinder { pt07, pt10, .01 }
  cylinder { pt07, pt11, .01 }
  cylinder { pt08, pt09, .01 }
  cylinder { pt08, pt11, .01 }
  dorot()
  pigment { colour <.3,.3,.3> } finish { ambient 0 diffuse 1 phong 1 }
}

union {
  polygon { 6, pt01, pt08, pt06, pt02, pt04, pt01 }
  polygon { 6, pt00, pt07, pt06, pt02, pt05, pt00 }
  polygon { 6, pt00, pt07, pt08, pt01, pt03, pt00 }
  polygon { 6, pt02, pt09, pt08, pt07, pt10, pt02 }
  polygon { 6, pt00, pt11, pt08, pt06, pt10, pt00 }
  polygon { 6, pt01, pt11, pt07, pt06, pt09, pt01 }
  polygon { 6, pt00, pt05, pt04, pt01, pt11, pt00 }
  polygon { 6, pt01, pt03, pt05, pt02, pt09, pt01 }
  polygon { 6, pt00, pt03, pt04, pt02, pt10, pt00 }
  polygon { 6, pt03, pt05, pt10, pt07, pt11, pt03 }
  polygon { 6, pt03, pt11, pt08, pt09, pt04, pt03 }
  polygon { 6, pt04, pt05, pt10, pt06, pt09, pt04 }
  dorot()
  pigment { colour rgbt <.8,.8,.8,.2> } finish { ambient 0 diffuse 1 phong flashiness #if(withreflection) reflection { .2 } #end }
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
