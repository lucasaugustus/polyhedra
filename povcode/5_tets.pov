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

#macro tetrahedron(A,B,C,D)
  union {
    sphere {A, 0.01}
    sphere {B, 0.01}
    sphere {C, 0.01}
    sphere {D, 0.01}
    cylinder {A, B, 0.01}
    cylinder {A, C, 0.01}
    cylinder {A, D, 0.01}
    cylinder {B, C, 0.01}
    cylinder {B, D, 0.01}
    cylinder {C, D, 0.01}
    dorot()
    pigment { colour <.3,.3,.3> } finish { ambient 0 diffuse 1 phong 1 }
  }
  union {
    triangle {A, B, C}
    triangle {A, B, D}
    triangle {A, C, D}
    triangle {B, C, D}
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
#end

tetrahedron(  <  0, c0,-c1>  ,  < c0,-c1,  0>  ,  <-c1,  0, c0>  ,  < c2, c2, c2>  )
tetrahedron(  < c1,  0,-c0>  ,  <-c0,-c1,  0>  ,  <-c2, c2,-c2>  ,  <  0, c0, c1>  )
tetrahedron(  <-c2,-c2, c2>  ,  <  0,-c0,-c1>  ,  <-c0, c1,  0>  ,  < c1,  0, c0>  )
tetrahedron(  <-c1,  0,-c0>  ,  < c2,-c2,-c2>  ,  <  0,-c0, c1>  ,  < c0, c1,  0>  )
tetrahedron(  < c2,-c2, c2>  ,  <-c2,-c2,-c2>  ,  <-c2, c2, c2>  ,  < c2, c2,-c2>  )

#for (a, 0, 11)
  light_source { <4*sin(a*pi*2/11), 5*cos(a*pi*6/11), -4*cos(a*pi*2/11)> colour (1+<sin(a*pi*2/11),sin(a*pi*2/11+pi*2/3),sin(a*pi*2/11+pi*4/3)>)*2/11 }
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
