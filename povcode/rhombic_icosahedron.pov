#declare rot1=rand(rotation)*pi*2;
#declare rot2=acos(1-2*rand(rotation));
#declare rot3=(rand(rotation)+clock)*pi*2;
#macro dorot()
  rotate rot1*180/pi*y
  rotate rot2*180/pi*x
  rotate rot3*180/pi*y
#end

#declare C0 = sqrt(10 * (25 - 11 * sqrt(5))) / 20;
#declare C1 = sqrt(10 * (5 - sqrt(5))) / 20;
#declare C2 = sqrt(10 * (5 + sqrt(5))) / 20;
#declare C3 = sqrt(10 * (5 - sqrt(5))) / 10;
#declare C4 = sqrt(2 * (5 - sqrt(5))) / 4;
#declare C5 = sqrt(10 * (5 + sqrt(5))) / 10;
#declare C6 = sqrt(2 * (5 + sqrt(5))) / 4;
#declare C7 = sqrt(10 * (25 + 11 * sqrt(5))) / 20;
#declare C8 = sqrt(5 * (5 + 2 * sqrt(5))) / 5;

#declare Points = array[22] {
  < C2, -C1,  C8>,
  < C2, -C1, -C8>,
  <-C2,  C1,  C8>,
  <-C2,  C1, -C8>,
  < C2, -C7,  C5>,
  < C2, -C7, -C5>,
  <-C2,  C7,  C5>,
  <-C2,  C7, -C5>,
  < C2,  C4,  C5>,
  < C2,  C4, -C5>,
  <-C2, -C4,  C5>,
  <-C2, -C4, -C5>,
  < C6, -C1,  C3>,
  < C6, -C1, -C3>,
  <-C6,  C1,  C3>,
  <-C6,  C1, -C3>,
  < C6, -C7,   0>,
  <-C6,  C7,   0>,
  < C6,  C4,   0>,
  <-C6, -C4,   0>,
  < C0,  C7,   0>,
  <-C0, -C7,   0>,
};

// Moves the centre of gravity of the vertices to the origin
#local cog = <0,0,0>;
#local N = dimension_size(Points,1);
#for (i, 0, N-1)
  #local cog = cog + Points[i];
#end
#local cog = cog / N;
#local i=0;
#for (i, 0, N-1)
  #declare Points[i] = Points[i] - cog;
#end

// Scale to the unit sphere
#local b=0;
#local N = dimension_size(Points,1);
#for (a, 0, N-1)
  #local c = vlength(Points[a]);
  #if (c>b) #local b = c; #end
#end
#for (a, 0, N-1)
  #declare Points[a] = Points[a]/b;
#end
    
#declare Edges = array[40][2] {
 {07, 17}, {07, 20}, {18, 20}, {03, 07}, {12, 16}, {04, 21}, {00, 02}, {05, 16},
 {14, 19}, {08, 18}, {00, 08}, {01, 03}, {01, 09}, {19, 21}, {02, 14}, {06, 08},
 {15, 17}, {06, 20}, {06, 17}, {12, 18}, {03, 15}, {05, 21}, {00, 04}, {01, 05},
 {02, 10}, {11, 19}, {13, 16}, {07, 09}, {15, 19}, {03, 11}, {04, 10}, {04, 16},
 {05, 11}, {14, 17}, {00, 12}, {01, 13}, {02, 06}, {09, 18}, {10, 19}, {13, 18},
};

#declare Faces = array[20] {
  array[4] { 18,  8,  0, 12 },
  array[4] { 18, 12, 16, 13 },
  array[4] { 18, 13,  1,  9 },
  array[4] { 18,  9,  7, 20 },
  array[4] { 18, 20,  6,  8 },
  array[4] { 19, 10,  2, 14 },
  array[4] { 19, 14, 17, 15 },
  array[4] { 19, 15,  3, 11 },
  array[4] { 19, 11,  5, 21 },
  array[4] { 19, 21,  4, 10 },
  array[4] {  8,  6,  2,  0 },
  array[4] {  9,  1,  3,  7 },
  array[4] { 10,  4,  0,  2 },
  array[4] { 11,  3,  1,  5 },
  array[4] { 12,  0,  4, 16 },
  array[4] { 13, 16,  5,  1 },
  array[4] { 14,  2,  6, 17 },
  array[4] { 15, 17,  7,  3 },
  array[4] { 20,  7, 17,  6 },
  array[4] { 21,  5, 16,  4 },
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
  // In case limited precision causes points to be sufficiently noncoplanar that polygon{} fails,
  // we fan-triangulate each polygon and render those triangles.
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

#declare Standoff = 5;

camera {
  perspective
  location <0,0,-Standoff>
  right x * asin(1/Standoff) * 2.1
  up y * asin(1/Standoff) * 2.1
  sky <0,1,0>
  look_at <0,0,0>
}

global_settings {
  max_trace_level 40
  photons {
    count 200000
    autostop 0
  }
}
