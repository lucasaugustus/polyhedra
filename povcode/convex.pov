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
  addevenpermssgn(<0, 1/phi, phi>, <0,1,1>)
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
    augment(6, points[0], points[1], points[4])
  #end
  convex_hull()
#end

#macro truncatedhexahedron(augmentation) // Truncated cube (n=0), J66 (n=1), J67 (n=2)
  addevenpermssgn(<sq2-1, 1, 1>, <1,1,1>)
  #switch (augmentation)
    #case(2) augment(8, points[ 7], points[23], points[22])
    #case(1) augment(8, points[16], points[ 0], points[ 1])
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
    augment(10, points[50], points[58], points[34])     // towards (phi,-1,0) -- common to all
    #switch (augmentation)
      #case( 3) augment(10, points[54], points[38], points[14])   // towards (-1,0,phi) -- on tri
      #case( 2) augment(10, points[40], points[48], points[24])   // towards (0,phi,-1) -- on metadi and tri
      #break
      #case(-2) augment(10, points[32], points[10], points[ 9])   // towards (-phi,1,0) -- on paradi
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

#macro augment(n, va, vb, vc) // On an n-face with 3 adjacent vertices, add a pyramid or a cupola
  #local veci = va-vb;
  #local vecj = vc-vb;
  #local veck = vlength(vc-vb) * vnormalize(vcross(vc-vb, va-vb));
  #switch(n)
    #case (3) addpoint( (va+vb+vc)/3 + sqrt(2/3) * veck ) #break
    #case (4) addpoint( (va +  vc)/2 + sqrt(1/2) * veck ) #break
    #case (5) addpoint( vb + (2+phi)*(veci+vecj)/5 + sqrt((3-phi)/5) * veck ) #break
    #case (6)
      addpoint( vb +   veci/3 + 2*vecj/3 + sqrt(2/3) * veck )
      addpoint( vb + 4*veci/3 + 2*vecj/3 + sqrt(2/3) * veck )
      addpoint( vb + 4*veci/3 + 5*vecj/3 + sqrt(2/3) * veck )
      #break
    #case (8)
      addpoint( vb + (  1/sq2)*veci +         vecj + sqrt(1/2)*veck )
      addpoint( vb + (1+1/sq2)*veci +         vecj + sqrt(1/2)*veck )
      addpoint( vb + (1+1/sq2)*veci + (1+sq2)*vecj + sqrt(1/2)*veck )
      addpoint( vb + (2+1/sq2)*veci + (1+sq2)*vecj + sqrt(1/2)*veck )
      #break
    #case (10)
      addpoint( vb+(1+3*phi)*veci/5 + (4+2*phi)*vecj/5 + sqrt((3-phi)/5)*veck )
      addpoint( vb+(6+3*phi)*veci/5 + (4+2*phi)*vecj/5 + sqrt((3-phi)/5)*veck )
      addpoint( vb+(6+8*phi)*veci/5 + (4+7*phi)*vecj/5 + sqrt((3-phi)/5)*veck )
      addpoint( vb+(6+8*phi)*veci/5 + (9+7*phi)*vecj/5 + sqrt((3-phi)/5)*veck )
      addpoint( vb+(6+3*phi)*veci/5 + (4+7*phi)*vecj/5 + sqrt((3-phi)/5)*veck )
      #break
  #end
#end
#macro rotateabout(raxis, rangle, va)   // raxis must be a unit vector
  (  vdot(raxis,va)*raxis  +  cos(rangle)*(va-vdot(raxis,va)*raxis)  +  sin(rangle)*(vcross(raxis,va))  )
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

// Johnson:

#macro square_pyramid() // J1
  addevenpermssgn(<1,0,0>, <1,0,0>)
  drop_vtx(99)
  autobalance()
  convex_hull()
#end

#macro pentagonal_pyramid() // J2
  addevenpermssgn(<0,1,phi>, <0,1,1>)
  drop_halfspace(points[0], 0)
  autobalance()
  convex_hull()
#end

#macro triangular_cupola() // J3 (9 vertices of a cuboctahedron)
  polygon_vtx(6)
  augment(6, points[0], points[1], points[2])
  autobalance()
  convex_hull()
#end

#macro rhombicuboctahedron_mod(j_number) // J4, J19, J23, J28, J29, J37, and J45
  addevenpermssgn(<1+sq2,1,1>, <1,1,1>)
  #local raxis = <1,0,0>;
  #local edgelen = 2;
  #local oct_radius = sqrt(2*sq2 + 4);
  // drop hemisphere for 6, 21, 25 (have single rotunda)
  #if (j_number = 4) drop_halfspace(raxis, 1) #end
  #if (j_number<=23) drop_halfspace(raxis,-1) #end
  // stretch and twist
  #local stretch=0;
  #local twist=0;
  #switch(j_number)
    #case(29) #local twist = 45;
    #case(28) #local stretch = -edgelen; #break
    #case(37) #local twist = 45; #break
    #case(23)
    #case(45)
      #local twist = 22.5;
      #local stretch = oct_radius * 2 * sqrt((cos(pi/8)-cos(2*pi/8))/2) - edgelen; // borrowed from antiprism_vtx
  #end
  #if (stretch != 0)    // lower northern hemisphere
    #local i=0;
    #while (i<npoints-.5)
      #if ((stretch = -2) & (vdot(points[i],raxis) = 1))
        drop_vtx(i)
      #else
        #if (vdot(points[i],raxis) > 0)
          #declare points[i] = points[i] + stretch*raxis;
        #end
        #local i = i + 1;
      #end
    #end // while
  #end // if
  #if (twist != 0)  // rotate southern hemisphere (incl equator)
    rotate_vtxs(raxis, twist, -1)
  #end
  autobalance()
  convex_hull()
#end

#macro pentagonal_cupola() // J5
  addevenpermssgn(<1, 1, 1+2*phi>, <1,1,1>)
  addevenpermssgn(<phi, 2*phi, 1+phi>, <1,1,1>)
  addevenpermssgn(<2+phi, 0, 1+phi>, <1,0,1>)
  #local raxis = vnormalize(<phi,-1,0>);
  drop_halfspace(raxis, 3.077)
  autobalance()
  convex_hull()
#end

#macro icosidodecahedron_mod(j_number) // J6, J21, J25, J32, J33, J34, J40, J41, J42, J43, J47, J48
  addevenpermssgn(<0,0,2*phi>, <0,0,1>)
  addevenpermssgn(<1,phi,1+phi>, <1,1,1>)
  #local raxis = vnormalize(<phi,1,0>);
  #local edgelen = vlength(<0,0,2*phi> - <1,phi,1+phi>);
  #local id_radius = 2*phi;
  // drop hemisphere for 6, 21, 25 (have single rotunda)
  #if((j_number<=33) | (j_number=40) | (j_number=41) | (j_number=47))
    drop_halfspace(raxis, 0)
    #if (j_number >= 32) // form a cupolarotunda
      augment(10, points[0], points[7], points[15])
    #end
  #end
  // stretch and twist
  #local stretch = 0;
  #local twist = 0;
  #switch(j_number)
    #case(41) #case(42)
      #local stretch = edgelen;
    #case(33) #case(34)
      #local twist = 36;
      #break
    #case(21) #case(40) #case(43)
      #local stretch = edgelen;
      #break
    #case(25) #case(47) #case(48)
      #local twist = 18;
      #local stretch = id_radius * 2 * sqrt((cos(pi/10)-cos(2*pi/10))/2); // borrowed from antiprism_vtx
  #end // switch
  #if (stretch > 0) // raise northern hemisphere, duplicate equator
    #local np = npoints;
    #for (i, 0, np-1)
      #switch (vdot(points[i], raxis))
        #range(-0.01, 0.01)
          //#debug concat("Dupl. vtx ",str(i,0,0)," of ",str(npoints,0,0)," <",str(points[i].x,0,3),",",str(points[i].y,0,3),",",str(points[i].z,0,3),">\n")
          addpoint(points[i] + stretch*raxis)
          #break
        #range(0.01, 999)
        //#debug concat("Raise vtx ",str(i,0,0)," of ",str(npoints,0,0)," <",str(points[i].x,0,3),",",str(points[i].y,0,3),",",str(points[i].z,0,3),">\n")
          #declare points[i] = points[i] + stretch*raxis;
          #break
      #end // switch
    #end // while
  #end  // if
  #if (twist != 0) // rotate southern hemisphere (incl equator)
    rotate_vtxs(raxis, twist, 0)
  #end
  showvtxs()
  autobalance()
  convex_hull()
#end

#macro elongated_pyramid(n) // J7, J8, J9 (n = 3,4,5)
  rprism_vtx(n)
  augment(n, points[4], points[2], points[0])
  autobalance()
  convex_hull()
#end

#macro gyroelongated_square_pyramid() // J10
  antiprism_vtx(4)
  #local va = points[1];
  addpoint(<0, 0, -1 - abs(va.z)>)
  convex_hull()
#end

#macro gyroelongated_pentagonal_pyramid() // J11
  // Drop 1 vertex from an icosahedron
  addevenpermssgn(<0,1,phi>, <0,1,1>)
  drop_vtx(99)
  convex_hull()
#end

#macro bipyramid_j(n) // J12, J13 (n = 3,5)
  polygon_vtx(n)
  augment(n, points[0], points[1], points[2])
  augment(n, points[2], points[1], points[0])
  autobalance()
  convex_hull()
#end

#macro elongated_bipyramid(n) // J14, J15, J16 (n = 3,4,5)
  rprism_vtx(n)
  augment(n, points[4], points[2], points[0])
  augment(n, points[1], points[3], points[5])
  autobalance()
  convex_hull()
#end

#macro gyroelongated_square_bipyramid() // J17
  antiprism_vtx(4)
  #local va = points[1];
  addpoint(<0, 0,  1 + abs(va.z)>)
  addpoint(<0, 0, -1 - abs(va.z)>)
  convex_hull()
#end

#macro elongated_triangular_cupola() // J18
  rprism_vtx(6)
  augment(6, points[1], points[3], points[5])
  autobalance()
  convex_hull()
#end

#macro elongated_pentagonal_cupola() // J20
  rprism_vtx(10)
  augment(10, points[4], points[2], points[0])
  autobalance()
  convex_hull()
#end

#macro gyroelongated_triangular_cupola() // J22
  antiprism_vtx(6)
  augment(6, points[1], points[3], points[5])
  autobalance()
  convex_hull()
#end

#macro gyroelongated_pentagonal_cupola() // J24
  antiprism_vtx(10)
  augment(10, points[4], points[2], points[0])
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

#macro triangular_orthobicupola() // J27
  polygon_vtx(6)
  augment(6, points[0], points[1], points[2])
  augment(6, points[3], points[2], points[1])
  autobalance()
  convex_hull()
#end

#macro pentagonal_orthobicupola()  // J30
  polygon_vtx(10)
  augment(10, points[0], points[1], points[2])
  augment(10, points[3], points[2], points[1])
  autobalance()
  convex_hull()
#end

#macro pentagonal_gyrobicupola()   // J31
  polygon_vtx(10)
  augment(10, points[0], points[1], points[2])
  augment(10, points[2], points[1], points[0])
  autobalance()
  convex_hull()
#end

#macro elongated_triangular_orthobicupola() // J35
  rprism_vtx(6)
  augment(6, points[1], points[3], points[5])
  augment(6, points[6], points[4], points[2])
  autobalance()
  convex_hull()
#end

#macro elongated_triangular_gyrobicupola() // J36
  rprism_vtx(6)
  augment(6, points[1], points[3], points[5])
  augment(6, points[4], points[2], points[0])
  autobalance()
  convex_hull()
#end

#macro elongated_pentagonal_orthobicupola() // J38
  rprism_vtx(10)
  augment(10, points[4], points[2], points[0])
  augment(10, points[3], points[5], points[7])
  autobalance()
  convex_hull()
#end

#macro elongated_pentagonal_gyrobicupola() // J39
  rprism_vtx(10)
  augment(10, points[4], points[2], points[0])
  augment(10, points[1], points[3], points[5])
  showvtxs()
  autobalance()
  convex_hull()
#end

#macro gyroelongated_triangular_bicupola() // J44
  antiprism_vtx(6)
  augment(6, points[1], points[3], points[5])
  augment(6, points[4], points[2], points[0])
  autobalance()
  convex_hull()
#end

#macro gyroelongated_pentagonal_bicupola() // J46
  antiprism_vtx(10)
  augment(10, points[4], points[2], points[0])
  augment(10, points[1], points[3], points[5])
  autobalance()
  convex_hull()
#end

#macro augmented_prisms(n, facelist) // J49, J50, J51, J52, J53, J54, J55, J56, J57
  // n = prism base, facelist = string with faces to cap
  rprism_vtx(n)
  #for (i, 1, strlen(facelist))
    #local facenum = mod(val(substr(facelist,i,1)), n); // convert ith char given to a number 0..(n-1)
    augment(4, points[2*facenum+1], points[2*facenum], points[mod(2*facenum+2, 2*n)])
    //#debug concat("Augment face ",str(facenum,0,0)," of ",str(n,0,0), " <",str(points[npoints-1].x,0,3),",",str(points[npoints-1].y,0,3),",",str(points[npoints-1].z,0,3),"> \n")
  #end
  autobalance()
  convex_hull()
#end

#macro augmented_dodecahedron() // J58
  addpointssgn(<1,1,1>, <1,1,1>)
  addevenpermssgn(<0, phi-1, phi>, <0,1,1>)
  augment(5, points[4], points[13], points[12])
  showvtxs()
  autobalance()
  convex_hull()
#end

#macro parabiaugmented_dodecahedron() // J59
  addpointssgn(<1,1,1>, <1,1,1>)
  addevenpermssgn(<0, phi-1, phi>, <0,1,1>)
  augment(5, points[4], points[13], points[12])
  addpoint(-points[npoints-1])
  showvtxs()
  autobalance()
  convex_hull()
#end

#macro metabiaugmented_dodecahedron() // J60
  addpointssgn(<1,1,1>, <1,1,1>)
  addevenpermssgn(<0, phi-1, phi>, <0,1,1>)
  augment(5, points[4], points[13], points[12])
  #local a = points[npoints-1];
  addpoint(<a.y,a.z,a.x>)
  showvtxs()
  autobalance()
  convex_hull()
#end

#macro triaugmented_dodecahedron() // J61
  addpointssgn(<1,1,1>, <1,1,1>)
  addevenpermssgn(<0, phi-1, phi>, <0,1,1>)
  augment(5, points[4], points[13], points[12])
  #local a = points[npoints-1];
  drop_vtx(999)
  addevenperms(a)
  showvtxs()
  autobalance()
  convex_hull()
#end

#macro metabidiminished_icosahedron() // J62
  addevenpermssgn(<0,1,phi>, <0,1,1>)
  drop_vtx(99)
  drop_vtx(6)
  convex_hull()
#end

#macro tridiminished_icosahedron() // J63
  addevenpermssgn(<0,1,phi>, <0,1,1>)
  drop_vtx(99)
  drop_vtx(6)
  drop_vtx(0)
  convex_hull()
#end

#macro augmented_tridiminished_icosahedron() // J64
  addevenpermssgn(<0,1,phi>, <0,1,1>)
  drop_vtx(99)
  drop_vtx(6)
  drop_vtx(0)
  augment(3, points[1], points[7], points[8])
  convex_hull()
#end

#macro rhombicosidodecahedron_mod(mods) // J72, J73, J74, J75, J76, J77, J78, J79, J80, J81, J82, J83
  // mods is a 4-character string of D (drop), G (gyrate), and other (leave alone)
  addevenpermssgn(<1, 1, 1+2*phi>, <1,1,1>)
  addevenpermssgn(<phi, 2*phi, 1+phi>, <1,1,1>)
  addevenpermssgn(<2+phi, 0, 1+phi>, <1,0,1>)
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

#macro snub_disphenoid() // J84
  #local q = 0.1690222294241758308998888; // Positive root of 2x^3 + 11x^2 + 4x - 1 (casus irreducibilis)
  #local a = sqrt(q);               // 0.411120420... = 2 * 0.20556021...
  #local b = sqrt((1-q) / (2*q));   // 1.567874291... = 2 * 0.78393714...
  #local c = 2*a*b;                 // 1.289170275... = 2 * 0.64458513...
  addpoint(< c,  0, -a>)
  addpoint(< 0,  c,  a>)
  addpoint(<-c,  0, -a>)
  addpoint(< 0, -c,  a>)
  addpoint(< 1,  0,  b>)
  addpoint(<-1,  0,  b>)
  addpoint(< 0,  1, -b>)
  addpoint(< 0, -1, -b>)
  autobalance()
  convex_hull()
#end

#macro snub_square_antiprism() // J85
  #local A = 1.7157317369103943337370248; // Positive root of x^6 - 2x^5 - 13x^4 + 8x^3 + 32x^2 - 8x - 4
  #local B = sqrt(1 - (1-1/sq2) * A * A);
  #local C = sqrt(2 + 2*sq2*A - 2*A*A) + B;
  addpointssgn(< 1/2  , 1/2  ,  C/2>, <1,1,0>)
  addpointssgn(< A/sq2, 0    ,  B/2>, <1,0,0>)
  addpointssgn(< 0    , A/sq2,  B/2>, <0,1,0>)
  addpointssgn(< A/2  , A/2  , -B/2>, <1,1,0>)
  addpointssgn(< 1/sq2, 0    , -C/2>, <1,0,0>)
  addpointssgn(< 0    , 1/sq2, -C/2>, <0,1,0>)
  autobalance()
  convex_hull()
#end

#macro sphenocoronae(n) // J86, J87
  #local k = (6 + sqrt(6) + 2 * sqrt(213 - 57*sqrt(6))) / 30; // Minimal polynomial 60x^4 - 48x^3 - 100x^2 + 56x + 23
  addpointssgn(<0, 1/2, sqrt(1-k*k)>, <0,1,0>)
  addpointssgn(<k, 1/2, 0>, <1,1,0>)
  addpointssgn(<0, 1/2 + sqrt((3-4*k*k)/(1-k*k))/2, (1-2*k*k)/(2*sqrt(1-k*k))>, <0,1,0>)
  addpointssgn(<1/2, 0, -sqrt(1/2 + k - k*k)>, <1,0,0>)
  #if(n=87)
    #local a = (k - sqrt(2-2*k*k))/2;
    addpoint(<k - a, 0, sqrt(3/4 - a*a)>)
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
  // 26880x^10 + 35328x^9 - 25600x^8 - 39680x^7 + 6112x^6 + 13696x^5 + 2128x^4 - 1808x^3 - 1119x^2 + 494x - 47
  #local a = sqrt(1 - k*k);
  #local b = sqrt(2 - 2*k - 4*k*k);
  #local c = sqrt(3 - 4*k*k);
  addpointssgn(<1, 1, 2*a>/2, <1,1,0>)
  addpointssgn(<1+2*k, 1, 0>/2, <1,1,0>)
  addpointssgn(<1, 0, -c>/2, <1,0,0>)
  addpointssgn(<0, 1 + b/a, b*b/(2*a)>/2, <0,1,0>)
  addpointssgn(<0, (b*c + k + 1) / (2*a*a), (2*k-1)*c / (2 - 2*k) - b / (2*a*a)>/2, <0,1,0>)
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
  addpoint(< 6, 0  , -6>)
  addpoint(< 0, 0  ,  0>)
  addpoint(< 6, 0  ,  6>)
  addpoint(<12, 0  ,  0>)
  addpoint(< 6, 2*c, -8>)
  addpoint(< 3, 3*c, -6>)
  addpoint(< 3, 3*c,  6>)
  addpoint(< 6, 2*c,  8>)
  addpoint(< 9, 3*c,  6>)
  addpoint(< 9, 3*c, -6>)
  addpoint(< 6, 6*c,  0>)
  autobalance()
  convex_hull()
#end

#macro triakistruncatedtetrahedron()
  addpoint(< 8/3, 1/3, 5/(3*sq2)>)
  addpoint(< 8/3, 2/3, 4/(3*sq2)>)
  addpoint(< 8/3, 1  , 5/(3*sq2)>)
  
  addpoint(< 3  , 0  , 7/(3*sq2)>)
  addpoint(< 3  , 2/3, 1/   sq2 >)
  addpoint(< 3  , 4/3, 7/(3*sq2)>)
  
  addpoint(<10/3, 0  , 8/(3*sq2)>)
  addpoint(<10/3, 1/3, 3/   sq2 >)
  addpoint(<10/3, 1  , 3/   sq2 >)
  addpoint(<10/3, 4/3, 8/(3*sq2)>)
  
  addpoint(<11/3, 0  , 7/(3*sq2)>)
  addpoint(<11/3, 2/3, 1/   sq2 >)
  addpoint(<11/3, 4/3, 7/(3*sq2)>)
  
  addpoint(< 4  , 1/3, 5/(3*sq2)>)
  addpoint(< 4  , 2/3, 4/(3*sq2)>)
  addpoint(< 4  , 1  , 5/(3*sq2)>)
  
  autobalance()
  convex_hull()
#end

#macro trapezo_rhombic_dodecahedron()
  triangular_orthobicupola()
  dual()
#end

#macro elongated_dodecahedron()
  #local c = sqrt(3) / 2;
  addpointssgn(<1, 1, c+1>, <1,1,1>)
  addpointssgn(<2, 0, c  >, <1,0,1>)
  addpointssgn(<0, 2, c  >, <0,1,1>)
  addpointssgn(<0, 0, c+2>, <0,0,1>)
  autobalance()
  convex_hull()
#end

#macro rhombic_icosahedron()
  #local A = sqrt((25 - 11 * sqrt(5)) / 40);
  #local B = sqrt(( 5 -      sqrt(5)) / 40);
  #local C = sqrt(( 5 +      sqrt(5)) / 40);
  #local D = sqrt(( 5 -      sqrt(5)) / 10);
  #local E = sqrt(( 5 -      sqrt(5)) /  8);
  #local F = sqrt(( 5 +      sqrt(5)) / 10);
  #local G = sqrt(( 5 +      sqrt(5)) /  8);
  #local H = sqrt((25 + 11 * sqrt(5)) / 40);
  #local I = sqrt(( 5 +  2 * sqrt(5)) /  5);
  addpoint(< C, -B,  I>)
  addpoint(< C, -B, -I>)
  addpoint(<-C,  B,  I>)
  addpoint(<-C,  B, -I>)
  addpoint(< C, -H,  F>)
  addpoint(< C, -H, -F>)
  addpoint(<-C,  H,  F>)
  addpoint(<-C,  H, -F>)
  addpoint(< C,  E,  F>)
  addpoint(< C,  E, -F>)
  addpoint(<-C, -E,  F>)
  addpoint(<-C, -E, -F>)
  addpoint(< G, -B,  D>)
  addpoint(< G, -B, -D>)
  addpoint(<-G,  B,  D>)
  addpoint(<-G,  B, -D>)
  addpoint(< G, -H,  0>)
  addpoint(<-G,  H,  0>)
  addpoint(< G,  E,  0>)
  addpoint(<-G, -E,  0>)
  addpoint(< A,  H,  0>)
  addpoint(<-A, -H,  0>)
  autobalance()
  convex_hull()
#end

#macro trunc_triakis_tet()
  #local C0 =  1 / sqrt(243);
  #local C1 =  1 / sqrt( 27);
  #local C2 = -1 / sqrt(  3);
  #local C3 = 11 / sqrt(243);
  #local C4 =  5 / sqrt( 27);
  addevenpermsevensgn(<C1,  C1, C4>)
  addevenpermsevensgn(<C3, -C0, C3>)
  addpointsevensgn(   <C2,  C2, C2>)
  autobalance()
  convex_hull()
#end

#macro truncated_trapezohedron(N)
  #declare MaximumVerticesPerFace = max(5,N);
  
  // A pair of nearest-neighbour points on the middle rings is
  //    A == <     1    ,     0    ,  c >
  // and
  //    C == < cos(pi/N), sin(pi/N), -c >,
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
  #local C0 = (-1 + sqrt(5)) / sqrt(12);
  #local C1 =   1            / sqrt( 3);
  #local C2 = ( 1 + sqrt(5)) / sqrt(12);
  #local C3 =       sqrt(5)  / sqrt( 3);
  #local C4 = ( 3 + sqrt(5)) / sqrt(12);
  #local C5 = ( 1 + sqrt(5)) / sqrt( 3);
  #local C6 = ( 5 + sqrt(5)) / sqrt(12);
  #local C7 = ( 2 + sqrt(5)) / sqrt( 3);
  
  addevenpermssgn(< 0, C7, C0>, <0,1,1>)
  addevenpermssgn(< 0, C2, C7>, <0,1,1>)
  addevenpermssgn(< 0, C6, C3>, <0,1,1>)
  addevenpermssgn(<C2, C2, C6>, <1,1,1>)
  addevenpermssgn(<C1, C4, C5>, <1,1,1>)
  addpointssgn(   <C4, C4, C4>, <1,1,1>)
  
  autobalance()
  convex_hull()
#end

#macro elongated_gyrobifastigium()
  addpointssgn(<1,1,1/2>, <1,1,1>)
  addpoint(< 1, 0, 1>)
  addpoint(<-1, 0, 1>)
  addpoint(< 0, 1,-1>)
  addpoint(< 0,-1,-1>)
  autobalance()
  convex_hull()
#end

#macro noperthedron()
  // https://arxiv.org/pdf/2508.18475v1
  #declare MaximumVerticesPerFace = 30;
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
  
  #local MFD = 0;   // The number of points that get marked for deletion.  This will return to zero during each deletion pass.
  #for (p, 0, N-1)
    #if ((p != i0) & (p != i1) & (p != i2) & (p != i3))
      #local P = points[p];
      
      // Find those faces that P can see.
      // Recall that faces are stored with an orientation, pointing outward.
      // Build a plane's normal vector in that orientation, with its tail on the plane.
      // Then P can see the plane iff it is on the same side of the plane as the vector's head.
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

#if (1)
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
#end

#macro addp(a)
  #declare p[np] = a;
  #declare np = np + 1;
#end
union {
  //Draw edges
  #for (a, 0, nfaces-1)
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
  #end
  //Draw points
  #for (a, 0, npoints-1)
    sphere { points[a], .01 }
  #end
  dorot()
  pigment { colour <.3,.3,.3> }
  finish { ambient 0 diffuse 1 phong 1 }
}


#if(notwireframe)
//Draw planes
object {
  intersection {
    #for (a, 0, nfaces-1)
      plane { faces[a], 1 / vlength(faces[a]) }
    #end
    dorot()
  }
  pigment { colour rgbt <.8,.8,.8,.4> }
  finish { ambient 0 diffuse 1 phong flashiness #if(withreflection) reflection { .2 } #end }
  //interior { ior 1.5 }
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
