#declare rot1=rand(rotation)*pi*2;
#declare rot2=acos(1-2*rand(rotation));
#declare rot3=(rand(rotation)+clock)*pi*2;
#macro dorot()
  rotate rot1*180/pi*y
  rotate rot2*180/pi*x
  rotate rot3*180/pi*y
#end

#declare Points = array[28] {
  < 0.61576, 0.61576,-0.61576>,
  <-0.61576, 0.61576, 0.61576>,
  < 0.61576,-0.61576, 0.61576>,
  <-0.61576,-0.61576,-0.61576>,
  < 0.25352, 1.02723, 0.25352>,
  <-0.00043, 0.77132, 0.77132>,
  < 0.25352, 0.25352, 1.02723>,
  < 0.77132,-0.00043, 0.77132>,
  < 1.02723, 0.25352, 0.25352>,
  < 0.77132, 0.77132,-0.00043>,
  < 1.02723,-0.25352,-0.25352>,
  < 0.77132,-0.77132, 0.00043>,
  < 0.25352,-1.02723,-0.25352>,
  <-0.00043,-0.77132,-0.77132>,
  < 0.25352,-0.25352,-1.02723>,
  < 0.77132, 0.00043,-0.77132>,
  < 0.00043, 0.77132,-0.77132>,
  <-0.25352, 0.25352,-1.02723>,
  <-0.77132,-0.00043,-0.77132>,
  <-1.02723, 0.25352,-0.25352>,
  <-0.77132, 0.77132, 0.00043>,
  <-0.25352, 1.02723,-0.25352>,
  <-0.77132, 0.00043, 0.77132>,
  <-1.02723,-0.25352, 0.25352>,
  <-0.77132,-0.77132,-0.00043>,
  <-0.25352,-1.02723, 0.25352>,
  < 0.00043,-0.77132, 0.77132>,
  <-0.25352,-0.25352, 1.02723>,
};

#declare Edges = array[42][2] {
  {00, 16}, {16, 21}, {04, 09}, {00, 09}, {08, 10}, {10, 15},
  {00, 15}, {14, 17}, {01, 22}, {22, 27}, {01, 05}, {04, 21},
  {01, 20}, {19, 23}, {02, 11}, {02, 07}, {06, 27}, {02, 26},
  {03, 18}, {03, 13}, {12, 25}, {03, 24}, {04, 05}, {05, 06},
  {06, 07}, {07, 08}, {08, 09}, {10, 11}, {11, 12}, {12, 13},
  {13, 14}, {14, 15}, {16, 17}, {17, 18}, {18, 19}, {19, 20},
  {20, 21}, {22, 23}, {23, 24}, {24, 25}, {25, 26}, {26, 27},
};

// Due to the limited precision of the points above, the vertices of these faces are not close enough to coplanar for
// POV-Ray to be willing to draw the faces as single polygons, so we will instead triangulate them.
// The faces are all convex, so fan-triangulation is good enough.

#declare Faces = array[16] {
  array[5] {16, 21, 04, 09, 00},
  array[5] {09, 08, 10, 15, 00},
  array[5] {15, 14, 17, 16, 00},
  array[5] {22, 27, 06, 05, 01},
  array[5] {05, 04, 21, 20, 01},
  array[5] {20, 19, 23, 22, 01},
  array[5] {11, 10, 08, 07, 02},
  array[5] {07, 06, 27, 26, 02},
  array[5] {26, 25, 12, 11, 02},
  array[5] {18, 17, 14, 13, 03},
  array[5] {13, 12, 25, 24, 03},
  array[5] {24, 23, 19, 18, 03},
  array[6] {05, 06, 07, 08, 09, 04},
  array[6] {11, 12, 13, 14, 15, 10},
  array[6] {17, 18, 19, 20, 21, 16},
  array[6] {23, 24, 25, 26, 27, 22},
};

union {
  #for (I, 0, dimension_size(Points,1) - 1)
    sphere{Points[I], 0.01}
  #end
  #for (I, 0, dimension_size(Edges,1) - 1)
    cylinder {Points[Edges[I][0]], Points[Edges[I][1]], 0.01}
  #end
  dorot()
  pigment { colour <.3,.3,.3> } finish { ambient 0 diffuse 1 phong 1 }
}

union {
  #for (I, 0, dimension_size(Faces,1) - 1)
    #for (J, 1, dimension_size(Faces[I],1) - 2)
      triangle {Points[Faces[I][0]], Points[Faces[I][J]], Points[Faces[I][J+1]]}
    #end
  #end
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
  light_source { <4*sin(a*pi*2/11), 5*cos(a*pi*6/11), -4*cos(a*pi*2/11)>colour (1+<sin(a*pi*2/11),sin(a*pi*2/11+pi*2/3),sin(a*pi*2/11+pi*4/3)>)*2/11 }
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
