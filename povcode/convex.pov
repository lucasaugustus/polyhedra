#declare phi = (1 + sqrt(5)) / 2;
#declare sq2 = sqrt(2);

#declare MaximumVerticesPerFace = 20;   // If a solid has a face with > 20 vertices, include a #declare to override this.

// Platonic:

#macro tetrahedron()
  addpointsevensgn(<1,1,1>)
  convex_hull()
#end

#macro hexahedron() // "cube" is a keyword.
  addpointssgn(<1,1,1>, <1,1,1>)
  convex_hull()
#end

#macro octahedron()
  addevenpermssgn(<1,0,0>, <1,0,0>)
  convex_hull()
#end

#macro dodecahedron()
  addpointssgn(<1,1,1>, <1,1,1>)
  addevenpermssgn(<0, phi-1, phi>, <0,1,1>)
  convex_hull()
#end

#macro icosahedron()
  addevenpermssgn(<0,1,phi>, <0,1,1>)
  convex_hull()
#end

// Archimedean:

#macro cuboctahedron()
  addevenpermssgn(<0,1,1>, <0,1,1>)
  convex_hull()
#end

#macro icosidodecahedron()
  addevenpermssgn(<0,0,2*phi>, <0,0,1>)
  addevenpermssgn(<1, phi, 1+phi>, <1,1,1>)
  convex_hull()
#end

#macro truncatedtetrahedron(augmentation)
  addevenpermsevensgn(<1,1,3>)
  #if (augmentation)
    augment(6, 0, 1, 4)
  #end
  convex_hull()
#end

#macro truncatedhexahedron(augmentation) // Truncated cube (n=0), J66 (n=1), J67 (n=2)
  addevenpermssgn(<sq2-1, 1, 1>, <1,1,1>)
  #switch (augmentation)
    #case(2) augment(8,  7, 23, 22)
    #case(1) augment(8, 16,  0,  1)
  #end
  convex_hull()
#end

#macro truncatedoctahedron()
  addpermssgn(<0,1,2>, <0,1,1>)
  convex_hull()
#end

#macro truncateddodecahedron(augmentation) // Truncated dodecahedron (n=0), J68 (n=1), J69 (n=-2), J70 (n=2), J71 (n=3)
  addevenpermssgn(<0, phi-1, 2+phi>, <0,1,1>)
  addevenpermssgn(<phi-1, phi, 2*phi>, <1,1,1>)
  addevenpermssgn(<phi, 2, 1+phi>, <1,1,1>)
  #if (augmentation)
    augment(10, 50, 58, 34)     // towards (phi,-1,0) -- common to all
    #switch (augmentation)
      #case( 3) augment(10, 54, 38, 14)   // towards (-1,0,phi) -- on tri
      #case( 2) augment(10, 40, 48, 24)   // towards (0,phi,-1) -- on metadi and tri
      #break
      #case(-2) augment(10, 32, 10,  9)   // towards (-phi,1,0) -- on paradi
    #end
  #end
  convex_hull()
#end

#macro truncatedicosahedron()
  addevenpermssgn(<0, 1      , 3*phi>, <0,1,1>)
  addevenpermssgn(<2, 1+2*phi,   phi>, <1,1,1>)
  addevenpermssgn(<1, 2+  phi, 2*phi>, <1,1,1>)
  convex_hull()
#end

#macro rhombicuboctahedron()
  addevenpermssgn(<1+sq2, 1, 1>, <1,1,1>)
  convex_hull()
#end

#macro truncatedcuboctahedron()
  addpermssgn(<1, 1+sq2, 1+sq2*2>, <1,1,1>)
  convex_hull()
#end

#macro rhombicosidodecahedron()
  addevenpermssgn(<   1 ,   1  , 1+2*phi>, <1,1,1>)
  addevenpermssgn(<  phi, 2*phi, 1+  phi>, <1,1,1>)
  addevenpermssgn(<2+phi,   0  , 1+  phi>, <1,0,1>)
  convex_hull()
#end

#macro truncatedicosidodecahedron()
  addevenpermssgn(<1/phi  , 1/phi, 3+  phi>, <1,1,1>)
  addevenpermssgn(<2/phi  ,   phi, 1+2*phi>, <1,1,1>)
  addevenpermssgn(<1/phi  , 1+phi, 3*phi-1>, <1,1,1>)
  addevenpermssgn(<2*phi-1,   2  , 2+phi  >, <1,1,1>)
  addevenpermssgn(<  phi  ,   3  , 2*phi  >, <1,1,1>)
  convex_hull()
#end

#macro snub_cube(s)
  #local xi = (pow(sqrt(297)+17, 1/3) - pow(sqrt(297)-17, 1/3) - 1)/3;
  // xi is the real root of x^3 + x^2 + x - 1.
  addpermsaltsgn(<1, 1/xi, xi> * s)
  convex_hull()
#end

#macro snubdodecahedron(s)
  #local sqweird = sqrt(phi - 5/27);
  #local ouch = pow((phi+sqweird)/2, 1/3) + pow((phi-sqweird)/2, 1/3);
  #local alfa = ouch - 1/ouch; // "alpha" is a keyword.
  #local beta = (ouch + phi + 1/ouch) * phi;
  // These constants are the greatest real roots of:
  // sqweird: 729x^4 - 459x^2 - 839
  //    ouch: x^6        -  4x^4 -   x^3 +  4x^2 + 2x - 1
  //    alfa: x^6 + 2x^5 -  2x^4         -   x^2 - 2x + 1
  //    beta: x^6 - 5x^5 - 11x^4 + 12x^3 + 24x^2 + 9x + 1
  addevenpermsevensgn(<2*alfa, 2, 2*beta> * s)
  addevenpermsevensgn(< beta/phi+alfa+phi  , -alfa*phi+beta+1/phi, alfa/phi+beta*phi-1> * s)
  addevenpermsevensgn(< beta/phi+alfa-phi  ,  alfa*phi-beta+1/phi, alfa/phi+beta*phi+1> * s)
  addevenpermsevensgn(<-alfa/phi+beta*phi+1, -alfa+beta/phi-phi  , alfa*phi+beta-phi+1> * s)
  addevenpermsevensgn(<-alfa/phi+beta*phi-1,  alfa-beta/phi-phi  , alfa*phi+beta+phi-1> * s)
  convex_hull()
#end

// Catalan:

#macro        rhombicdodecahedron( )              cuboctahedron( ) dual() #end
#macro     rhombictriacontahedron( )          icosidodecahedron( ) dual() #end
#macro         triakistetrahedron( )       truncatedtetrahedron(0) dual() #end
#macro          triakisoctahedron( )        truncatedhexahedron(0) dual() #end
#macro         tetrakishexahedron( )        truncatedoctahedron( ) dual() #end
#macro         triakisicosahedron( )      truncateddodecahedron(0) dual() #end
#macro       pentakisdodecahedron( )       truncatedicosahedron( ) dual() #end
#macro  deltoidalicositetrahedron( )        rhombicuboctahedron( ) dual() #end
#macro      disdyakisdodecahedron( )     truncatedcuboctahedron( ) dual() #end
#macro   deltoidalhexecontahedron( )     rhombicosidodecahedron( ) dual() #end
#macro   disdyakistriacontahedron( ) truncatedicosidodecahedron( ) dual() #end
#macro pentagonalicositetrahedron(s)                  snub_cube(s) dual() #end
#macro  pentagonalhexecontahedron(s)           snubdodecahedron(s) dual() #end

// Prisms, biprisms, antiprisms, and trapezohedra:

#macro polygon_vtx(n)
  #for (i, 0, n-1)
    addpoint(<cos(i*2*pi/n), sin(i*2*pi/n), 0>)
  #end
#end
#macro rprism_vtx(n)
  #local a = sqrt((1 - cos(2*pi/n)) / 2);
  #for (b, 0, n-1)
    addpointssgn(<sin(2*pi*b/n), cos(2*pi*b/n), a>, <0,0,1>)
  #end
#end
#macro antiprism_vtx(n)
  #local a = sqrt((cos(pi/n) - cos(2*pi/n)) / 2);
  #for (b, 0, 2*n-1)
    addpoint(<sin(pi*b/n), cos(pi*b/n), a>)
    #local a = -a;
  #end
#end
#macro        rprism(n)    rprism_vtx(n) convex_hull() #end
#macro     antiprism(n) antiprism_vtx(n) convex_hull() #end
#macro     bipyramid(n)        rprism(n)        dual() #end
#macro trapezohedron(n)     antiprism(n)        dual() #end

// Helper macros for the Johnson solids:

#macro augment(n, a, b, c) // On an n-face with 3 adjacent vertices, add a pyramid or a cupola
  #local A = points[a];
  #local B = points[b];
  #local C = points[c];
  #local I = A - B;
  #local J = C - B;
  #local K = vlength(C-B) * vnormalize(vcross(C-B, A-B));
  #switch(n)
    #case (3) addpoint( (A+B+C)/3 + sqrt(2/3) * K ) #break
    #case (4) addpoint( (A + C)/2 + sqrt(1/2) * K ) #break
    #case (5) addpoint( B + (2+phi)*(I+J)/5 + sqrt((3-phi)/5) * K ) #break
    #case (6)
      addpoint( B +   I/3 + 2*J/3 + sqrt(2/3) * K )
      addpoint( B + 4*I/3 + 2*J/3 + sqrt(2/3) * K )
      addpoint( B + 4*I/3 + 5*J/3 + sqrt(2/3) * K )
      #break
    #case (8)
      addpoint( B + (  1/sq2)*I +         J + K/sq2 )
      addpoint( B + (1+1/sq2)*I +         J + K/sq2 )
      addpoint( B + (1+1/sq2)*I + (1+sq2)*J + K/sq2 )
      addpoint( B + (2+1/sq2)*I + (1+sq2)*J + K/sq2 )
      #break
    #case (10)
      addpoint( B + (1+3*phi)*I/5 + (4+2*phi)*J/5 + sqrt((3-phi)/5)*K )
      addpoint( B + (6+3*phi)*I/5 + (4+2*phi)*J/5 + sqrt((3-phi)/5)*K )
      addpoint( B + (6+8*phi)*I/5 + (4+7*phi)*J/5 + sqrt((3-phi)/5)*K )
      addpoint( B + (6+8*phi)*I/5 + (9+7*phi)*J/5 + sqrt((3-phi)/5)*K )
      addpoint( B + (6+3*phi)*I/5 + (4+7*phi)*J/5 + sqrt((3-phi)/5)*K )
      #break
  #end
#end
#macro rotateabout(raxis, rangle, A)   // raxis must be a unit vector
  (  vdot(raxis,A)*raxis  +  cos(rangle)*(A-vdot(raxis,A)*raxis)  +  sin(rangle)*(vcross(raxis,A))  )
#end
#macro rotate_vtxs(raxis, rangle, thresh)   // all points in the halfspace v.raxis <= thresh.  rangle is in degrees.
  #for (i, 0, npoints-1)
    #if (vdot(points[i], raxis) < thresh + 1e-6)
      #declare points[i] = rotateabout(raxis, pi*rangle/180, points[i]);
    #end
  #end
#end
#macro drop_vtx(n)
  #declare npoints=npoints-1;
  #if (n < npoints)
    #declare points[n] = points[npoints];
  #end
#end
#macro drop_halfspace(normalvector, thresh) // all points in the halfspace v.raxis < thresh
  #local i = 0;
  #while (i < npoints-.5)
    #if (vdot(points[i], normalvector) < thresh - 1e-6)
      #debug concat("Drop vtx ", str(i,0,0), " of ", str(npoints,0,0), " <", str(points[i].x,0,3), ",",
                    str(points[i].y,0,3), ",", str(points[i].z,0,3), "> (", str(vdot(points[i],normalvector),0,7), ")\n")
      drop_vtx(i)
    #else
      #debug concat("Keep vtx ", str(i,0,0), " of ", str(npoints,0,0), " <", str(points[i].x,0,3), ",",
                    str(points[i].y,0,3), ",", str(points[i].z,0,3), "> (", str(vdot(points[i],normalvector),0,7), ")\n")
      #local i=i+1;
    #end
  #end
#end
#macro autobalance()    // Moves the average of the vertices to the origin
  #local cog = <0,0,0>;
  #for (i, 0, npoints-1)
    #local cog = cog + points[i];
  #end
  #local cog = cog / npoints;
  #for (i, 0, npoints-1)
    #declare points[i] = points[i] - cog;
  #end
#end

#macro showvtxs()
  #for (i, 0, npoints-1)
    #debug concat("Vtx ", str(i,0,0), " of ", str(npoints,0,0), "= <",
                  str(points[i].x,0,15), ",", str(points[i].y,0,15), ",", str(points[i].z,0,15), ">\n")
  #end
#end

#macro rotundify(a, b, c)
  // Construct the non-decagonal vertices of a rotunda.  Three consecutive vertices of its decagon are points[a,b,c],
  // and AB x BC points from the decagon's center to the rotunda's interior.
  #local A = points[a];
  #local B = points[b];
  #local C = points[c];
  #local S = vlength(A-B); // side length
  #local O = B + phi * S * vnormalize((A+C)/2 - B); // center of decagon
  #local N = vnormalize(vcross(B-A, C-B)); // unit normal from O to interior of rotunda
  #local U = vnormalize(A-O);
  #local V = vcross(N, U);
  #local alfa = S * sqrt((5+2*sqrt(5))/ 5);
  #local beta = S * sqrt((5+  sqrt(5))/10);
  #for (i, 0, 4)
    addpoint(O + beta*N + alfa * (cos((4*i+1)*pi/10) * U + sin((4*i+1)*pi/10) * V));
    addpoint(O + alfa*N + beta * (cos((4*i+3)*pi/10) * U + sin((4*i+3)*pi/10) * V));
  #end
#end

// Johnson:

#macro pyracupolarotunda(N, E, A, B, G) // J1-25 and J27-48
  // The ((gyro)elongated) N-gonal (ortho,gyro)(bi)(pyramid,cupola,rotunda).
  // N: the number of sides for the "core".  For cupolae and rotundae, this is twice the number implied by the English name.
  // E: Elongation type.  0: None.  1: Ordinary.  2: Gyroelongation.
  // A,B: cap type for each side of the elongation.  0: Flat.  1: Pyramid or cupola.  2: Rotunda.
  // G: Gyration type.  0: None.  1: Gyrate.
  // Examples:
  // * pyracupolarotunda( 8, 2, 1, 1, 0) makes the gyroelongated square bicupola.
  // * pyracupolarotunda( 8, 1, 1, 1, 1) makes the elongated square gyrobicupola.
  // * pyracupolarotunda( 3, 0, 1, 1, 0) makes the triangular bipyramid.
  // * pyracupolarotunda(10, 0, 1, 2, 1) makes the pentagonal gyrocupolarotunda.
  
  // The core.
  // We could use polygon_vtx, rprism_vtx, and antiprism_vtx for this, but I want a different point numbering.
  #for (i, 0, N-1)
    addpoint(<cos(2*pi*i/N), sin(2*pi*i/N), 0>)
  #end
  #if (E > 0)
    #local H = sqrt(2 - 2*cos(2*pi/N));
    #local J = 0;
    #if (E = 2)
      #local J = 1/2;
      #local H = sqrt(2*cos(pi/N) - 2*cos(2*pi/N));
    #end
    #for (i, 0, N-1)
      addpoint(<cos(2*pi*(i+J)/N), sin(2*pi*(i+J)/N), H>)
    #end
  #end
  
  // Cap A
  #if ((N < 10) & (A != 0)) augment(N, 2, 1, 0) #end
  #if ((N = 10) & (A  = 1)) augment(N, 2, 1, 0) #end
  #if ((N = 10) & (A  = 2)) rotundify( 2, 1, 0) #end
  
  // Cap B
  #local J = 1 - G;
  #if (N = 3) #local J = 0    ; #end
  #if (E > 0) #local J = J + N; #end
  #if ((N < 10) & (B != 0)) augment(N, J, J+1, J+2) #end
  #if ((N = 10) & (B  = 1)) augment(N, J, J+1, J+2) #end
  #if ((N = 10) & (B  = 2)) rotundify( J, J+1, J+2) #end
  
  autobalance()
  convex_hull()
#end

#macro gyrobifastigium() // J26
  addpointssgn(<1,1,0>, <1,1,0>)
  addpointssgn(<1,0, sqrt(3)>, <1,0,0>)
  addpointssgn(<0,1,-sqrt(3)>, <0,1,0>)
  autobalance()
  convex_hull()
#end

#macro augmented_prisms(n, facelist) // J49-57
  // n = prism base, facelist = string with faces to cap
  rprism_vtx(n)
  #for (i, 1, strlen(facelist))
    #local facenum = mod(val(substr(facelist,i,1)), n); // convert ith char given to a number 0..(n-1)
    augment(4, 2*facenum+1, 2*facenum, mod(2*facenum+2, 2*n))
    //#debug concat("Augment face ",str(facenum,0,0)," of ",str(n,0,0), " <",str(points[npoints-1].x,0,3),",",str(points[npoints-1].y,0,3),",",str(points[npoints-1].z,0,3),"> \n")
  #end
  autobalance()
  convex_hull()
#end

#macro dodecahedron_mod(j) // J58-61
  addpointssgn(<1,1,1>, <1,1,1>)
  addevenpermssgn(<0, phi-1, phi>, <0,1,1>)
  augment(5, 4, 13, 12)
  #if (j = 59)
    addpoint(-points[npoints-1])
  #end
  #if (j >= 60)
    #local a = points[npoints-1];
    #if (j = 60)
      addpoint(<a.y,a.z,a.x>)
    #else
      drop_vtx(999)
      addevenperms(a)
    #end
  #end
  autobalance()
  convex_hull()
#end

#macro icosahedron_mod(j) // J62-64
  addevenpermssgn(<0,1,phi>, <0,1,1>) // The icosahedral vertices
  drop_vtx(99)
  #if (j >= 62) drop_vtx(6) #end
  #if (j >= 63) drop_vtx(0) #end
  #if (j  = 64) augment(3, 1, 7, 8) #end
  convex_hull()
#end

#macro rhombicosidodecahedron_mod(mods) // J72-83
  // mods is a 4-character string of D (drop), G (gyrate), and other (leave alone)
  addevenpermssgn(<1    , 1    , 1+2*phi>, <1,1,1>)
  addevenpermssgn(<  phi, 2*phi, 1+  phi>, <1,1,1>)
  addevenpermssgn(<2+phi, 0    , 1+  phi>, <1,0,1>)
  #local raxis = array[5];
  #local raxis[1] = vnormalize(<phi,-1,0>);
  #local raxis[2] = vnormalize(<-1,0,phi>);
  #local raxis[3] = vnormalize(<-1,0,-phi>);
  #local raxis[4] = -raxis[1];
  #for (i, 1, min(4,strlen(mods)))
    #local modchar = substr(mods, i, 1);
    #if (strcmp(modchar,"D") = 0) drop_halfspace(-raxis[i],     -3.077) #end
    #if (strcmp(modchar,"G") = 0)    rotate_vtxs(-raxis[i], 36, -3.077) #end
  #end
  autobalance()
  convex_hull()
#end

#macro casus_irreducibilis(A,B,C,D)
  // Given the cubic polynomial Ax^3 + Bx^2 + Cx + D in the casus irreducibilis,
  // return a 3-vector whose components are the roots of the polynomial, in ascending order.
  #local P = (3*A*C - B*B) / (3*A*A);
  #local Q = (2*B*B*B - 9*A*B*C + 27*A*A*D) / (27*A*A*A);
  #local R = sqrt(-P/3);
  #local S = acos( (3*Q) / (2*P*R) ) / 3;
  (2 * R * <cos(S - 4*pi/3), cos(S - 2*pi/3), cos(S)> - B/(3*A))
#end

#macro snub_disphenoid() // J84
  #local q = casus_irreducibilis(2,11,4,-1).z;  // 0.169022229...
  #local a = sqrt(q);                           // 0.411120420...
  #local b = sqrt((1-q) / (2*q));               // 1.567874291...
  #local c = 2*a*b;                             // 1.289170275...
  addpointssgn(<c, 0, -a>, <1,0,0>)
  addpointssgn(<0, c,  a>, <0,1,0>)
  addpointssgn(<1, 0,  b>, <1,0,0>)
  addpointssgn(<0, 1, -b>, <0,1,0>)
  autobalance()
  convex_hull()
#end

#macro snub_square_antiprism() // J85
  #local A = casus_irreducibilis(1,sq2-1,2*sq2-6,2-2*sq2).z; // Minimal polynomial: x^6 - 2x^5 - 13x^4 + 8x^3 + 32x^2 - 8x - 4
  #local B = sqrt(1 - (1-1/sq2) * A * A);
  #local C = sqrt(2 + 2*sq2*A - 2*A*A) + B;
  addpointssgn(<  1  ,   1  ,  C>, <1,1,0>)
  addpointssgn(<A*sq2,   0  ,  B>, <1,0,0>)
  addpointssgn(<  0  , A*sq2,  B>, <0,1,0>)
  addpointssgn(<  A  ,   A  , -B>, <1,1,0>)
  addpointssgn(< sq2 ,   0  , -C>, <1,0,0>)
  addpointssgn(<  0  ,  sq2 , -C>, <0,1,0>)
  autobalance()
  convex_hull()
#end

#macro sphenocoronae(n) // J86, J87
  #local k = (6 + sqrt(6) + 2 * sqrt(213 - 57*sqrt(6))) / 30; // Minimal polynomial: 60x^4 - 48x^3 - 100x^2 + 56x + 23
  #local j = sqrt(1 - k*k);
  addpointssgn(< 0 , 1, 2*j>, <0,1,0>)
  addpointssgn(<2*k, 1, 0>, <1,1,0>)
  addpointssgn(< 1 , 0, -2*sqrt(1/2 + k - k*k)>, <1,0,0>)
  addpointssgn(< 0 , 1 + sqrt((3-4*k*k)/(j*j)), (1-2*k*k)/j>, <0,1,0>)
  #if(n=87)
    #local a = k - sqrt(2-2*k*k);
    addpoint(<2*k - a, 0, sqrt(3 - a*a)>)
  #end
  showvtxs()
  autobalance()
  convex_hull()
#end

#macro sphenomegacorona() // J88
  #local k = 0.5946333356326385300524244;
  // k is the smallest positive root of
  // 1680x^16 - 4800x^15 - 3712x^14 + 17216x^13 + 1568x^12 - 24576x^11 + 2464x^10 + 17248x^9
  // - 3384x^8 - 5584x^7 + 2000x^6 + 240x^5 - 776x^4 + 304x^3 + 200x^2 - 56x - 23
  #local j = sqrt(1-k*k);
  addpointssgn(<1, 0, 2*j>, <1,0,0>)
  addpointssgn(<1, 2*k, 0>, <1,1,0>)
  addpointssgn(<sqrt(3-4*k*k)/j + 1, 0, (1-2*k*k) / j>, <1,0,0>)
  addpointssgn(<0, 1, -sqrt(2+4*k-4*k*k)>, <0,1,0>)
  addpointssgn(<1 - sqrt(3-4*k*k)*(2*k*k-1) / (j*j*j), 0, (2*k*k*k*k-1) / (j*j*j)>, <1,0,0>)
  autobalance()
  showvtxs()
  convex_hull()
#end

#macro hebesphenomegacorona() // J89
  #local k = 0.18377570557055179182109963;
  // k is the smallest positive root of
  // 26880x^10 + 35328x^9 - 25600x^8 - 39680x^7 + 6112x^6 + 13696x^5 + 2128x^4 - 1808x^3 - 1119x^2 + 494x - 47
  #local a = sqrt(1 - k*k);
  #local b = sqrt(2 - 2*k - 4*k*k);
  #local c = sqrt(3 - 4*k*k);
  addpointssgn(<1, 1, 2*a>, <1,1,0>)
  addpointssgn(<1+2*k, 1, 0>, <1,1,0>)
  addpointssgn(<1, 0, -c>, <1,0,0>)
  addpointssgn(<0, 1 + b/a, b*b/(2*a)>, <0,1,0>)
  addpointssgn(<0, (b*c + k + 1) / (2*a*a), (2*k-1)*c / (2 - 2*k) - b / (2*a*a)>, <0,1,0>)
  autobalance()
  showvtxs()
  convex_hull()
#end

#macro disphenocingulum() // J90
  #local B = 1.5342622279669230038363354;
  // B is the second-smallest postive root of
  // x^12 - 4x^11 - 26x^10 + 116x^9 + 97x^8 - 824x^7 + 312x^6 + 2176x^5 - 2024x^4 - 1888x^3 + 2688x^2 - 192x - 368
  #local C = sqrt((1 + 2*B - B*B) / 2);
  #local A = C + sqrt(4 - B*B);
  #local E = (A*A - B*B - C*C) / (2 * sqrt(4 - B*B));
  #local D = 1 + sqrt(4 - (A-E)*(A-E));
  addpointssgn(<0, 1,  A>, <0,1,0>)
  addpointssgn(<B, 1,  C>, <1,1,0>)
  addpointssgn(<0, D,  E>, <0,1,0>)
  addpointssgn(<D, 0, -E>, <1,0,0>)
  addpointssgn(<1, B, -C>, <1,1,0>)
  addpointssgn(<1, 0, -A>, <1,0,0>)
  autobalance()
  showvtxs()
  convex_hull()
#end

#macro bilunabirotunda() // J91
  // start with icosahedron
  addevenpermssgn(<0,1,phi>, <0,1,1>)
  //showvtxs()
  // trim back to 8 vertices
  drop_halfspace(<-1,-phi,0>, -phi)
  drop_halfspace(<-1, phi,0>, -phi)
  drop_halfspace(< 1,  0 ,0>, -1  )
  // now shift all vertices into halfspace x >= 0, and mirror
  #local minx = 999;
  #for (i, 0, npoints-1)
    #local minx = min(minx, points[i].x);
    //#if (minx > points[i].x) #local minx = points[i].x; #end
  #end
  #local np = npoints;
  #for (i, 0, np-1)
    #declare points[i] = points[i] + <-minx,0,0>;
    #if (points[i].x > 0) addpoint(<-points[i].x, points[i].y, points[i].z>) #end
  #end
  convex_hull()
#end

#macro triangular_hebesphenorotunda() // J92
  // Coords found by taking 7 vtxs of an icosahedron, placing one vtx
  // at origin, which is centre of the one hexagonal face.
  addevenperms(<  1 , phi,  0 > - <phi,0,1>)
  addevenperms(<  0 ,  1 , phi> - <phi,0,1>)
  addevenperms(< -1 , phi,  0 > - <phi,0,1>)
  addevenperms(<-phi,  0 ,  1 > - <phi,0,1>)
  addevenperms(<  0 ,  1 ,-phi> - <phi,0,1>)
  addevenperms(< -1 ,-phi,  0 > - <phi,0,1>)
  autobalance()
  convex_hull()
#end

// Miscellaneous:

#macro herschel_enneahedron()
  // https://aperiodical.com/2013/10/an-enneahedron-for-herschel/
  #local c = sqrt(3);
  addpoint(    < 0, 0  , 0>)
  addpoint(    < 6, 6*c, 0>)
  addpoint(    <12, 0  , 0>)
  addpointssgn(< 3, 3*c, 6>, <0,0,1>)
  addpointssgn(< 6, 0  , 6>, <0,0,1>)
  addpointssgn(< 6, 2*c, 8>, <0,0,1>)
  addpointssgn(< 9, 3*c, 6>, <0,0,1>)
  autobalance()
  convex_hull()
#end

#macro triakistruncatedtetrahedron()
  addpointssgn(<4,2,  -sq2>, <1,1,0>)
  addpointssgn(<2,4,   sq2>, <1,1,0>)
  addpointssgn(<4,0,-2*sq2>, <1,0,0>)
  addpointssgn(<0,4, 2*sq2>, <0,1,0>)
  addpointssgn(<2,0,-3*sq2>, <1,0,0>)
  addpointssgn(<0,2, 3*sq2>, <0,1,0>)
  autobalance()
  convex_hull()
#end

#macro trapezo_rhombic_dodecahedron()
  pyracupolarotunda(6,0,1,1,0) // triangular orthobicupola
  dual()
#end

#macro elongated_dodecahedron()
  #local c = sqrt(3);
  addpointssgn(<2, 2, c+2>, <1,1,1>)
  addpointssgn(<4, 0, c  >, <1,0,1>)
  addpointssgn(<0, 4, c  >, <0,1,1>)
  addpointssgn(<0, 0, c+4>, <0,0,1>)
  autobalance()
  convex_hull()
#end

#macro rhombic_icosahedron()
  addpointssgn(<0,0,5>, <0,0,1>)
  #local P = <4, 0, 3>;
  #local Q = <2 + 2 * phi, sqrt(10 + 2*sqrt(5)), 1>;
  #for (i, 1, 5)
    #local P = rotateabout(<0,0,1>, 2*pi/5, P);
    #local Q = rotateabout(<0,0,1>, 2*pi/5, Q);
    addpoint(P) addpoint(-P)
    addpoint(Q) addpoint(-Q)
  #end
  autobalance()
  convex_hull()
#end

#macro trunc_triakis_tet()
  addevenpermsevensgn(< 3,  3, 15>)
  addevenpermsevensgn(<11, -1, 11>)
  addpointsevensgn(   <-9, -9, -9>)
  autobalance()
  convex_hull()
#end

#macro truncated_trapezohedron(N)
  #declare MaximumVerticesPerFace = max(5,N);
  
  // A pair of nearest-neighbour points on the middle rings is
  //    A == <     1    ,     0    ,  c >    and    C == < cos(pi/N), sin(pi/N), -c >,
  // using the labels that we will give them below.  The distance between these points is
  // sqrt((1 - cos(pi/N))^2 + sin(pi/N)^2 + 4c^2)
  // == sqrt( 4c^2 + 2 - 2 * cos(pi/N) ).                       (1)
  // The apex will be at z == c * cot(pi/(2*N))^2.
  // The neighbour of A on the upper main ring will be
  // A * q + (0,0,z) * (1-q)
  // == < q , 0 , c + z - z*q >.
  // The distance bewteen these points is
  // sqrt( (q-1)^2 + (0-0)^2 + (c + z - z*q - c)^2 )
  // == sqrt( 1 + c^2 * cot(pi/(2*N))^4 )  *  ( 1 - q )         (2)
  // For aesthetics, I want (1) and (2) to be equal:
  // sqrt( 4c^2 + 2 - 2 * cos(pi/N) )    ==    sqrt( 1 + c^2 * cot(pi/(2*N))^4 )  *  ( 1 - q )
  // q == 1  -  sqrt( 4c^2 + 2 - 2 * cos(pi/N) )  /  sqrt( 1 + c^2 * cot(pi/(2*N))^4 )
  
  // As below, let A == <1, 0, c> be a point on the upper middle ring.
  // Then C == <cos(pi/N), sin(pi/N), -c> (as below) and D == <cos(pi/N), -sin(pi/N), -c>
  // are its nearest neighbours in the lower middle ring.  For aesthetics, I want angle CAD to be 90 degrees.
  // AC  ==  < 1 - cos(pi/N) , -sin(pi/N) , 2c >
  // AD  ==  < 1 - cos(pi/N) ,  sin(pi/N) , 2c >
  // For the angle to be right, we need AC (dot) AD == 0:
  // 0 == (1 - cos(pi/N))^2 - sin(pi/N)^2 + 4c^2
  // c == sqrt(2 * cos(pi/N) - cos(2*pi/N) - 1) / 2
  
  #local c = sqrt(2 * cos(pi/N) - cos(2*pi/N) - 1) / 2;
  #local p = 1 / tan(pi/(2*N));
  // I actually want the upper and lower rings to be a bit closer than I described above.
  #local q = 1 - sqrt( 4*c*c + 2 - 2 * cos(pi/N) )  /  sqrt( 1 + c*c * p*p*p*p ) * 0.75;
  
  #for (I, 0, 2*N-1)    // The points on the middle rings.  Even indices are upper middle; odd indices are lower middle.
    addpoint(<cos(I * pi/N), sin(I * pi/N),  c * cos(I * pi)>)
  #end
  
  #local A = points[0];
  #local B = points[1];
  #local C = points[2];
  #local ABxAC = vcross(B-A, C-A);
  
  // Face ABC is embedded in the plane
  // ABxAC.x * (x -  1 )  +  ABxAC.y * (y -  0 )  +  ABxAC.z * (z -  c )  == 0.
  // The +z apex of the solid is this plane's z-intercept, c + ABxAC.x / ABxAC.z.
  
  #local Apex = <0, 0, c + ABxAC.x / ABxAC.z>;
  // The upper upper ring will be the weighted average of the upper middle ring and Apex,
  // with the ring weighted by q and Apex weighted by 1-q, and similarly for the lower lower ring.
  
  #for (I, 0, 2*N-1)    // The points on the upper upper and lower lower rings.
    addpoint(points[I] * q + Apex * (1-q) * cos(I * pi))
  #end
  
  convex_hull()
#end

#macro diminished_trapezohedron(N)
  #declare MaximumVerticesPerFace = max(4,N);
  
  // TODO: This c is copied from truncated_tetrahedron.
  // Since we are reducing the radius of the upper ring, is that really the best c to use here?
  
  #local c = sqrt(2 * cos(pi/N) - cos(2*pi/N) - 1) / 2;
  #local r1 = 0.66;
  #local r2 = 1;
  
  // Points 0 through  N-1 are the upper ring.
  #for (I, 0, 2*N-2, 2)
    addpoint(<r1 * cos(I * pi/N), r1 * sin(I * pi/N),  c>)
  #end
  
  // Points N through 2N-1 are the lower ring.
  #for (I, 1, 2*N-1, 2)
    addpoint(<r2 * cos(I * pi/N), r2 * sin(I * pi/N), -c>)
  #end
  
  #local A = points[0]; // <r1, 0, c>
  #local B = points[1];
  #local C = points[N];
  #local ABxAC = vcross(B-A, C-A);
  
  // As with truncated_trapezohedron, the apex of the solid is z == c + ABxAC.x * r1 / ABxAC.z.
  
  addpoint(<0, 0, c + ABxAC.x * r1 / ABxAC.z>)
  
  convex_hull()
#end

#macro rhombic_enneacontahedron()
  addevenpermssgn(<  0  , 2*phi+1,   phi-1>, <0,1,1>)
  addevenpermssgn(<  0  ,   phi  , 2*phi+1>, <0,1,1>)
  addevenpermssgn(<  0  ,   phi+2, 2*phi-1>, <0,1,1>)
  addevenpermssgn(<phi  ,   phi  ,   phi+2>, <1,1,1>)
  addevenpermssgn(<  1  ,   phi+1, 2*phi  >, <1,1,1>)
  addpointssgn(   <phi+1,   phi+1,   phi+1>, <1,1,1>)
  
  autobalance()
  convex_hull()
#end

#macro elongated_gyrobifastigium()
  addpointssgn(<2,2, 1>, <1,1,1>)
  addpointssgn(<2,0, 2>, <1,0,0>)
  addpointssgn(<0,2,-2>, <0,1,0>)
  autobalance()
  convex_hull()
#end

#macro noperthedron()
  // https://arxiv.org/pdf/2508.18475v1
  #local P = < 152024884,          0,  210152163> / 259375205;
  #local Q = <6632738028, 6106948881, 3980949609> / 1e10;
  #local R = <8193990033, 5298215096, 1230614493> / 1e10;
  #for (i, 1, 15)
    #local P = rotateabout(<0,0,1>, 2*pi/15, P);
    #local Q = rotateabout(<0,0,1>, 2*pi/15, Q);
    #local R = rotateabout(<0,0,1>, 2*pi/15, R);
    addpoint(P)  addpoint(-P)
    addpoint(Q)  addpoint(-Q)
    addpoint(R)  addpoint(-R)
  #end
  autobalance()
  convex_hull()
#end

#macro BilinskiDodecahedron()
  addpointssgn(< 0 , 0, phi+1>, <0,0,1>)
  addpointssgn(<phi, 1,  0   >, <1,1,0>)
  addpointssgn(<phi, 0, phi  >, <1,0,1>)
  addpointssgn(< 0 , 1,  1   >, <0,1,1>)
  autobalance()
  convex_hull()
#end

#macro gyrate_deltoidal_icositetra()
  pyracupolarotunda(8,1,1,1,1) // elongated square gyrobicupola
  dual()
#end

#macro class1_geodesic(F, N)
  #if (F = 4)
    addpointsevensgn(<1/sq2,1/sq2,1/sq2>)   // The tetrahedral vertices, with edge length 2
    #local V = 4;
  #end
  #if (F = 8)
    addevenpermssgn(<sq2,0,0>, <1,0,0>)     // The  octahedral vertices, with edge length 2
    #local V = 6;
  #end
  #if (F = 20)
    addevenpermssgn(<0,1,phi>, <0,1,1>)     // The icosahedral vertices, with edge length 2
    #local V = 12;
  #end
  #for (a, 0, V-2)
    #local A = points[a];
    #for (b, a+1, V-1)
      #local B = points[b];
      #if (abs(vlength(A - B) - 2) < 1e-6)
       
        // We found an edge.  Subdivide it.
        #for (i, 1, N-1)
          addpoint((A*i + B*(N-i)) / N)
        #end
       
        #for (c, b+1, V-1)
          #local C = points[c];
          #if ((abs(vlength(A - C) - 2) < 1e-6) & (abs(vlength(B - C) - 2) < 1e-6))
           
            // We found a face.  Subdivide it.
            #for (d, 2, N-1)
              #local End1 = (B*d + A*(N-d)) / N;
              #local End2 = (C*d + A*(N-d)) / N;
              #for (e, 1, d-1)
                addpoint((End1*e + End2*(d-e)) / d)
              #end
            #end
           
          #end // if
        #end // for c
       
      #end // if
    #end // for b
  #end // for a
 
  // Finally, project all points onto the unit sphere.
  autobalance()
  #for (i, 0, npoints-1)
    #declare points[i] = vnormalize(points[i]);
  #end
  
  // TODO: For the octahedral and especially tetrahedral variants, we have rather poor spacing of points.
  // Maybe add an iterative-optimization-type step, where we treat them as electrons?
  // We would have to ensure that the topology does not change.
  
  showvtxs()
  convex_hull()
#end

#macro class1_goldberg(V, N)
  class1_geodesic(V, N)
  dual()
#end










#macro convex_hull()
  // This is an incremental convex-hull algorithm.  It should run in O(N^2) time.
  #local N    = npoints;
  #local EPS  = 1e-9;
  #local Face              = array[2*N];    // Enough for a triangulated 3D convex hull with N points.
  #local AffectedEdges     = array[3*N];
  #local MarkedForDeletion = array[2*N];
  #local EdgeMarks         = array[N][N];   // The contents will be 0s and 1s.
  
  // Initialize Mark[][] to all zeros.  Only elements with first index < second index will be used.
  #for (i, 0, N-1)
    #for (j, i+1, N-1)
      #local EdgeMarks[i][j] = 0;
    #end
  #end
  
  // Find 4 non-coplanar points.  Step 1: Find 3 non-collinear points.
  #local i0 = 0; #local I0 = points[i0];
  #local i1 = 1; #local I1 = points[i1];
  #local i2 = 2;
  #while (vlength(vcross(I1-I0, points[i2]-I0)) < EPS)
    #local i2 = i2 + 1;
  #end
  #local I2 = points[i2];
  // Now find a fourth point that is non-coplanar with the first 3.
  #local I01xI02 = vcross(I1-I0, I2-I0);
  #local i3 = i2 + 1;
  #while (abs(vdot(points[i3] - I0, I01xI02)) < EPS)
    #local i3 = i3 + 1;
  #end
  #local I3 = points[i3];
  
  // The current hull is points i0, i1, i2, and i3.  We will incrementally expand this.
  // The point "Inside" could be any point inside the current hull; it will stay inside the hull as it expands.
  #local Inside = (I0 + I1 + I2 + I3) / 4;
  
  // Now we build the initial tetrahedron by storing its faces in "Face".
  // A face ABC is stored in "Face" as a vector, whose elements are the indices of A, B, and C.
  // The orientation of the face is recorded by the order of the indices:
  // face <a,b,c> is oriented in the direction of the cross product AB x AC.
  #local A = array[4] {I0, I0, I0, I1}; #local a = array[4] {i0, i0, i0, i1}
  #local B = array[4] {I1, I3, I2, I3}; #local b = array[4] {i1, i3, i2, i3}
  #local C = array[4] {I2, I1, I3, I2}; #local c = array[4] {i2, i1, i3, i2}
  #for (i, 0, 3)
    #if (vdot(vcross(B[i]-A[i], C[i]-A[i]), A[i]-Inside) > 0)
      #local Face[i] = <a[i],b[i],c[i]>;
    #else
      #local Face[i] = <a[i],c[i],b[i]>;
    #end
  #end
  
  #local Facecount = 4; // The number of faces stored in "Face".
  
  // We now select a new point P and expand the hull to it.
  // We do this by finding those faces that P can see, deleting them, figuring out what the new faces are, and adding those.
  
  #local MFD = 0;   // The number of faces that get marked for deletion.  This will return to zero during each deletion pass.
  #for (p, 0, N-1)
    #if ((p != i0) & (p != i1) & (p != i2) & (p != i3))
      #local P = points[p];
      
      // Find those faces that P can see.
      // Recall that faces are stored with an orientation, pointing outward.
      // Build a plane's normal vector in that orientation, with its tail on the plane.
      // Then P can see the face iff it is on the same side of the plane as the vector's head.
      #for (f, 0, Facecount-1)
        #local F = Face[f];
        #local A = points[F.x];
        #local B = points[F.y];
        #local C = points[F.z];
        // We are now examining the face with index f, which is through points A, B, and C.
        // The vector AB x AC is normal to it and pointed outwards.
        // Point P can see face F iff the projection of AP onto AB x AC is positive.
        #local Side = vdot(P-A, vcross(B-A, C-A));
        #if (Side > EPS)
          #local MarkedForDeletion[MFD] = f;
          #local MFD = MFD + 1;
        #end
        // If a side has > 3 vertices, then we can have Side == 0.
        // If we treat this case as if we had Side < 0, then everything works out fine.
      #end // for f.  Thus endeth the face-finding phase.
      
      // Delete the marked faces, and track how many times each edge gets affected.
      #local MarkedEdges = 0;
      #while (MFD > 0)
        #local f = MarkedForDeletion[MFD-1];
        // Face f needs to be removed.  It suffices to overwrite Face[f] with Face[F-1], and then decrement F.
        
        // Before removing face f, record which edges are affected.
        // For each affected edge ab, toggle EdgeMarks[a][b] between 0 and 1.
        // Each edge is used by exactly two faces.  Therefore,
        // when the deletion pass is done, the exposed edges will have their EdgeMarks entries at 1,
        //    while the unaffected and totally-deleted edges will have their EdgeMarks entries at 0.
        #local F = Face[f];
        #local xyzx = array[4] {F.x, F.y, F.z, F.x};
        #for (i, 0, 2)
          #local a = min(xyzx[i], xyzx[i+1]);
          #local b = max(xyzx[i], xyzx[i+1]);
          #local EdgeMarks[a][b] = 1 - EdgeMarks[a][b];
          #local AffectedEdges[MarkedEdges] = <a,b>;
          #local MarkedEdges = MarkedEdges + 1;
        #end
        
        #local Face[f] = Face[Facecount-1];
        #local Facecount = Facecount - 1;
        #local MFD = MFD - 1;
      #end // while.  Thus endeth the deletion pass.
      
      // Figure out what the new faces are.
      // Each new triangle will use point P, and the opposite side will be one of the exposed edges.
      #for (i, 0, MarkedEdges-1)
        
        #local Edge = AffectedEdges[i];
        #local a = Edge.u;
        #local b = Edge.v;
        
        #if (EdgeMarks[a][b])
          
          #local A = points[a];
          #local B = points[b];
          
          // Triangle ABP is part of the new increment of the convex hull.
          // We need to figure out its orientation and store it.
          // It needs to be stored with the orientation that puts "Inside" on the negative side.
          
          #if (vdot(Inside - A, vcross(B-A, P-A)) < 0)
            #local Face[Facecount] = <a,b,p>;
          #else
            #local Face[Facecount] = <b,a,p>;
          #end
          #local Facecount = Facecount + 1;
          
          #local EdgeMarks[a][b] = 0; // Unmark the no-longer-exposed edge.
        #end // if
        
      #end // for i.  Thus endeth the new-face-construction phase.
      
    #end // if p != i0,i1,i2,i3
  #end // for p
  
  // Emit planes.  Deduplication is handled by addplane().
  #for (f, 0, Facecount-1)
    #local F = Face[f];
    addplane(F.x, F.y, F.z)
  #end
#end




#declare  points = array[1000];
#declare tpoints = array[1000];
#declare npoints = 0;
#declare   faces = array[1000];
#declare  nfaces = 0;
#macro addpoint(a)
  #declare points[npoints] = a;
  #declare npoints = npoints + 1;
#end
#macro addevenperms(a)
  addpoint(a)
  addpoint(<a.y, a.z, a.x>)
  addpoint(<a.z, a.x, a.y>)
#end
#macro addperms(a)
  addevenperms(a)
  addevenperms(<a.x, a.z, a.y>)
#end
#macro addpointssgn(a, s)
  addpoint(a)
  #if(s.x) addpointssgn(a*<-1, 1, 1>, s*<0,1,1>) #end
  #if(s.y) addpointssgn(a*< 1,-1, 1>, s*<0,0,1>) #end
  #if(s.z) addpoint(    a*< 1, 1,-1>           ) #end
#end
#macro addevenpermssgn(a,s)
  addpointssgn(a,s)
  addpointssgn(<a.y, a.z, a.x>, <s.y, s.z, s.x>)
  addpointssgn(<a.z, a.x, a.y>, <s.z, s.x, s.y>)
#end
#macro addpermssgn(a,s)
  addevenpermssgn(a,s)
  addevenpermssgn(<a.x, a.z, a.y>, <s.x, s.z, s.y>)
#end
#macro addpointsevensgn(a)
  addpoint(a)
  addpoint(a*<-1,-1, 1>)
  addpoint(a*<-1, 1,-1>)
  addpoint(a*< 1,-1,-1>)
#end
#macro addevenpermsevensgn(a)
  addevenperms(a)
  addevenperms(a*<-1,-1, 1>)
  addevenperms(a*<-1, 1,-1>)
  addevenperms(a*< 1,-1,-1>)
#end
#macro addpermsaltsgn(a)
  addevenpermsevensgn(a)
  addevenpermsevensgn(<a.x, a.z, -a.y>)
#end
/*#macro addevenpermssgn(a,s) //Calls addevenperms with, for each 1 in s, a.{x,y,z} replaced with {+,-}a.{x,y,z}
  addevenperms(a)
  #if(s.x) addevenpermssgn(a*<-1, 1, 1>, s*<0,1,1>) #end
  #if(s.y) addevenpermssgn(a*< 1,-1, 1>, s*<0,0,1>) #end
  #if(s.z) addevenperms(   a*< 1, 1,-1>           ) #end
#end*/
#macro addplane(a,b,c)
  #local n = vnormalize(vcross(points[b]-points[a], points[c]-points[a]));
  #local d = vdot(n, points[a]);
  addface(n,d)
#end
#macro addface(d,l)
  #local a = vnormalize(d) / l;
  #local f=1;
  #for (n, 0, nfaces-1)
    #if(vlength(faces[n]-a) < 1e-5) #local f = 0; #end
  #end
  #if (f)
    #declare faces[nfaces] = a;
    #declare nfaces = nfaces + 1;
  #end
#end
#macro dual()
  #declare   temp = faces;
  #declare  faces = points;
  #declare points = temp;
  #declare    temp = nfaces;
  #declare  nfaces = npoints;
  #declare npoints = temp;
#end

This_shape_will_be_drawn()

//Random rotations are (hopefully) equally distributed...
#declare rot1 = rand(rotation) * pi * 2;
#declare rot2 = acos(1 - 2*rand(rotation));
#declare rot3 = (rand(rotation) + clock) * pi * 2;
#macro dorot()
  rotate rot1 * 180 / pi * y
  rotate rot2 * 180 / pi * x
  rotate rot3 * 180 / pi * y
#end

//Scale shape to fit in unit sphere
#local b=0;
#for (a, 0, npoints-1)
  #local c = vlength(points[a]);
  #if (c > b)
    #local b = c;
  #end
#end
#for (a, 0, npoints-1)
  #local points[a] = points[a] / b;
#end
#for (a, 0, nfaces-1)
  #local faces[a] = faces[a] * b;
#end

#macro addp(a)
  #declare p[np] = a;
  #declare np = np + 1;
#end
union {
  //Draw points
  #for (a, 0, npoints-1)
    sphere { points[a], .01 }
  #end
  //Draw edges
  #for (a, 0, nfaces-1) // TODO: This can be done more efficiently.
    #declare p = array[MaximumVerticesPerFace];
    #declare np = 0;
    #for (b, 0, npoints-1)
      #if(vdot(faces[a],points[b]) > 1 - 1e-5) addp(b) #end
    #end
    #for (c, 0, np-1)
      #for (d, 0, np-1)
        #if(p[c] < p[d] - .5)
          #local f = 1;
          #for (e, 0, np-1)
            #if ((e != c) & (e != d) & (vdot(vcross(points[p[c]],points[p[d]]),points[p[e]]) < 0))
              #local f = 0;
            #end
          #end
          #if (f)
            cylinder { points[p[c]], points[p[d]], .01 }
          #end
        #end // if
      #end // for d
    #end // for c
  #end // for a
  dorot()
  pigment { colour <.3,.3,.3> }
  finish { ambient 0 diffuse 1 phong 1 }
}

#if(notwireframe)
//Draw planes
intersection {
  #for (a, 0, nfaces-1)
    plane { faces[a], 1 / vlength(faces[a]) }
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
#end

#for (a, 0, 11)
  light_source {
    <4*sin(a*pi*2/11), 5*cos(a*pi*6/11), -4*cos(a*pi*2/11)>
    colour (1 + <sin(a*pi*2/11), sin(a*pi*2/11+pi*2/3), sin(a*pi*2/11+pi*4/3)>) * 2 / 11
  }
#end

background { color <1,1,1> }

#if (0)    // default framing vs auto-framing
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
#else
  // some auto-framing.  Not for animated versions.
  #declare camera_loc = <0,0,-4.8>;
  #declare max_elevation = 0;
  #declare max_bearing = 0;
  #for (i, 0, npoints-1)
    #declare sighting = points[i];
    #declare sighting = vaxis_rotate(sighting, y, rot1*180/pi);
    #declare sighting = vaxis_rotate(sighting, x, rot2*180/pi);
    #declare sighting = vaxis_rotate(sighting, y, rot3*180/pi);
    #declare sighting = sighting - camera_loc;
    #declare elevation = sighting.y / sighting.z;
    #declare bearing = sighting.x / sighting.z;
    #declare max_elevation = max(max_elevation, abs(elevation));
    #declare max_bearing = max(max_bearing, abs(bearing));
  #end
  #debug concat("Maximum: Elevation = ", str(max_elevation,4,4), "  Bearing = ", str(max_bearing,4,4), "\n")
  #if(1) // 1:1 aspect ratio
    #declare max_bearing = max(max_elevation, max_bearing);
    #declare max_elevation = max_bearing;
  #end
  #if(1) // 5% border
    #declare max_bearing = 1.05 * max_bearing;
    #declare max_elevation = 1.05 * max_elevation;
  #end
  camera {
    perspective
    location camera_loc
    direction <0,0,.5>
    right x*max_bearing
    up y*max_elevation
  }
#end
global_settings {
  max_trace_level 40
  photons {
    count 200000
    autostop 0
  }
}
