#declare rot1=rand(rotation)*pi*2;
#declare rot2=acos(1-2*rand(rotation));
#declare rot3=(rand(rotation)+clock)*pi*2;
#macro dorot()
  rotate rot1*180/pi*y
  rotate rot2*180/pi*x
  rotate rot3*180/pi*y
#end

#declare c = 6 * sqrt(2);

#declare Points = array[7] {
  < 12,  0, -c>,
  <-12,  0, -c>,
  <  0,  c,  0>,
  <  0, -c,  0>,
  <  3, -3, -3>,
  < -3,  3, -3>,
  <  0,  0,  c>,
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
    
#declare Edges = array[21][2] {
  {0, 1},
  {0, 2},
  {0, 3},
  {0, 4},
  {0, 5},
  {0, 6},
  {1, 2},
  {1, 3},
  {1, 4},
  {1, 5},
  {1, 6},
  {2, 3},
  {2, 4},
  {2, 5},
  {2, 6},
  {3, 4},
  {3, 5},
  {3, 6},
  {4, 5},
  {4, 6},
  {5, 6},
};

#declare Faces = array[14] {
  array[3] {0, 1, 2},
  array[3] {0, 2, 5},
  array[3] {0, 5, 4},
  array[3] {0, 4, 6},
  array[3] {0, 6, 3},
  array[3] {0, 3, 1},
  array[3] {1, 3, 4},
  array[3] {1, 4, 5},
  array[3] {1, 5, 6},
  array[3] {1, 6, 2},
  array[3] {2, 6, 4},
  array[3] {2, 4, 3},
  array[3] {2, 3, 5},
  array[3] {5, 3, 6},
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
  right x * asin(1/Standoff) * 2
  up y * asin(1/Standoff) * 2
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
