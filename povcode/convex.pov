#declare notwireframe=1;
#declare withreflection=0;
#declare flashiness=1;

#declare tau=(1+sqrt(5))/2;
#declare sq2=sqrt(2);
#declare sq297=sqrt(297);
#declare xi=(pow(sq297+17,1/3)-pow(sq297-17,1/3)-1)/3;
#declare sqweird=sqrt(tau-5/27);
#declare ouch=pow((tau+sqweird)/2,1/3)+pow((tau-sqweird)/2,1/3);
#declare alfa=ouch-1/ouch;
#declare veta=(ouch+tau+1/ouch)*tau;

#declare MaximumVerticesPerFace = 20;   // If a solid has a face with > 20 vertices, include a #declare to override this.

#macro tetrahedron()
  addpointsevensgn(<1,1,1>)
  convex_hull()
#end

#macro hexahedron()
  addpointssgn(<1,1,1>,<1,1,1>)
  convex_hull()
#end

#macro octahedron()
  addevenpermssgn(<1,0,0>,<1,0,0>)
  convex_hull()
#end

#macro dodecahedron()
  addpointssgn(<1,1,1>,<1,1,1>)
  addevenpermssgn(<0,1/tau,tau>,<0,1,1>)
  convex_hull()
#end

#macro icosahedron()
  addevenpermssgn(<0,1,tau>,<0,1,1>)
  convex_hull()
#end


#macro weirdahedron()
  addpermssgn(<1,2,3>,<1,1,1>)
  convex_hull()
#end


#macro cuboctahedron()
  addevenpermssgn(<0,1,1>,<0,1,1>)
  convex_hull()
#end

#macro icosidodecahedron()
  addevenpermssgn(<0,0,2*tau>,<0,0,1>)
  addevenpermssgn(<1,tau,1+tau>,<1,1,1>)
  convex_hull()
#end


#macro truncatedtetrahedron(augmentation)
  addevenpermsevensgn(<1,1,3>)
  #if (augmentation)
// augment(6,points[3],points[0],points[1])
    augment(6,points[0],points[1],points[4])
  #end
  convex_hull()
#end

#macro truncatedhexahedron(augmentation)
  addevenpermssgn(<sq2-1,1,1>,<1,1,1>)
  #switch (augmentation)
    #case(2) augment(8,points[7],points[23],points[22])
    #case(1) augment(8,points[16],points[0],points[1])
  #end
  convex_hull()
#end

#macro truncated_cube()
  truncatedhexahedron(0)
#end

#macro augmented_truncated_cube()
  truncatedhexahedron(1)
#end

#macro biaugmented_truncated_cube()
  truncatedhexahedron(2)
#end

#macro truncatedoctahedron()
  addpermssgn(<0,1,2>,<0,1,1>)
  convex_hull()
#end

#macro truncateddodecahedron(augmentation)
    addevenpermssgn(<0,1/tau,2+tau>,<0,1,1>)
    addevenpermssgn(<1/tau,tau,2*tau>,<1,1,1>)
    addevenpermssgn(<tau,2,1+tau>,<1,1,1>)
    #if (augmentation)
        augment(10,points[50],points[58],points[34])   // towards (tau,-1,0) -- common to all
        #switch (augmentation)
            #case(3) augment(10,points[54],points[38],points[14])  // towards (-1,0,tau) -- on tri
            #case(2) augment(10,points[40],points[48],points[24])  // towards (0,phi,-1) -- on metadi and tri
            #break
            #case(-2) augment(10,points[32],points[10],points[9])  // towards (-tau,1,0) -- on paradi
        #end
    #end
    convex_hull()
#end

#macro truncatedicosahedron()
  addevenpermssgn(<0,1,3*tau>,<0,1,1>)
  addevenpermssgn(<2,1+2*tau,tau>,<1,1,1>)
  addevenpermssgn(<1,2+tau,2*tau>,<1,1,1>)
  convex_hull()
#end


#macro rhombicuboctahedron()
  addevenpermssgn(<1+sq2,1,1>,<1,1,1>)
  convex_hull()
#end

#macro truncatedcuboctahedron()
  addpermssgn(<1,1+sq2,1+sq2*2>,<1,1,1>)
  convex_hull()
#end

#macro rhombicosidodecahedron()
  addevenpermssgn(<1,1,1+2*tau>,<1,1,1>)
  addevenpermssgn(<tau,2*tau,1+tau>,<1,1,1>)
  addevenpermssgn(<2+tau,0,1+tau>,<1,0,1>)
  convex_hull()
#end

#macro truncatedicosidodecahedron()
  addevenpermssgn(<1/tau,1/tau,3+tau>,<1,1,1>)
  addevenpermssgn(<2/tau,tau,1+2*tau>,<1,1,1>)
  addevenpermssgn(<1/tau,1+tau,3*tau-1>,<1,1,1>)
  addevenpermssgn(<2*tau-1,2,2+tau>,<1,1,1>)
  addevenpermssgn(<tau,3,2*tau>,<1,1,1>)
  convex_hull()
#end


#macro snubhexahedron(s)
  addpermsaltsgn(<1,1/xi,xi>*s)
  convex_hull()
#end

#macro snub_cube(s)
  snubhexahedron(s)
#end

#macro snubdodecahedron(s)
  addevenpermsevensgn(<2*alfa,2,2*veta>*s)
  addevenpermsevensgn(<alfa+veta/tau+tau,-alfa*tau+veta+1/tau,alfa/tau+veta*tau-1>*s)
  addevenpermsevensgn(<-alfa/tau+veta*tau+1,-alfa+veta/tau-tau,alfa*tau+veta-1/tau>*s)
  addevenpermsevensgn(<-alfa/tau+veta*tau-1,alfa-veta/tau-tau,alfa*tau+veta+1/tau>*s)
  addevenpermsevensgn(<alfa+veta/tau-tau,alfa*tau-veta+1/tau,alfa/tau+veta*tau+1>*s)
  convex_hull()
#end

#macro rhombicdodecahedron()
  cuboctahedron() dual()
#end

#macro rhombictriacontahedron()
  icosidodecahedron() dual()
#end

#macro triakistetrahedron()
  truncatedtetrahedron(0) dual()
#end

#macro triakisoctahedron()
  truncatedhexahedron(0) dual()
#end

#macro tetrakishexahedron()
  truncatedoctahedron() dual()
#end

#macro triakisicosahedron()
  truncateddodecahedron(0) dual()
#end

#macro pentakisdodecahedron()
  truncatedicosahedron() dual()
#end

#macro deltoidalicositetrahedron()
  rhombicuboctahedron() dual()
#end

#macro disdyakisdodecahedron()
  truncatedcuboctahedron() dual()
#end

#macro deltoidalhexecontahedron()
  rhombicosidodecahedron() dual()
#end

#macro disdyakistriacontahedron()
  truncatedicosidodecahedron() dual()
#end

#macro pentagonalicositetrahedron(s)
  snubhexahedron(s) dual()
#end

#macro pentagonalhexecontahedron(s)
  snubdodecahedron(s) dual()
#end

//>>>>>>>>>>>>>>>>> changed AGK  [20041101]
#macro polygon_vtx(n)
    #local i=0;
    #while (i<n-.5)
        addpoint(<cos(i*2*pi/n),sin(i*2*pi/n),0>)
        #local i=i+1;
    #end
#end
#macro rprism_vtx(n)
  #local a=sqrt((1-cos(2*pi/n))/2);
  #local b=0; #while(b<n-.5)
    addpointssgn(<sin(2*pi*b/n),cos(2*pi*b/n),a>,<0,0,1>)
  #local b=b+1; #end
#end
#macro antiprism_vtx(n)
  #local a=sqrt((cos(pi/n)-cos(2*pi/n))/2);
  #local b=0; #while(b<2*n-.5)
    addpoint(<sin(pi*b/n),cos(pi*b/n),a>)
  #local a=-a; #local b=b+1; #end
#end
#macro rprism(n)
  rprism_vtx(n) convex_hull()
#end
#macro antiprism(n)
  antiprism_vtx(n)
  convex_hull()
#end
//<<<<<<<<<<<<<<<<< changed AGK  [20041101]

#macro bipyramid(n)
  rprism(n) dual()
#end

#macro trapezohedron(n)
  antiprism(n) dual()
#end

//>>>>>>>>>>>>>>>>> added AGK  [20041101]
#macro augment(n,va,vb,vc) // on an n-face with 3 adjacent vtxs, add a pyramid or a cupola
    #local veci=va-vb; #local vecj=vc-vb;  #local veck=vlength(vc-vb)*vnormalize(vcross(vc-vb,va-vb));
    #switch(n)
    #case (3) addpoint( (va+vb+vc)/3 + sqrt(2/3)*veck ) #break
    #case (4) addpoint( (va+vc)/2 + sqrt(1/2)*veck ) #break
    #case (5) addpoint( vb+(2+tau)/5*(veci+vecj) + sqrt((3-tau)/5)*veck ) #break
    #case (6)
        addpoint( vb+1/3*veci + 2/3*vecj + sqrt(2/3)*veck )
        addpoint( vb+4/3*veci + 2/3*vecj + sqrt(2/3)*veck )
        addpoint( vb+4/3*veci + 5/3*vecj + sqrt(2/3)*veck )
        #break
    #case (8)
        addpoint( vb + sqrt(1/2)*veci + vecj + sqrt(1/2)*veck )
        addpoint( vb + (1+sqrt(1/2))*veci + vecj + sqrt(1/2)*veck )
        addpoint( vb + (1+sqrt(1/2))*veci + (1+sq2)*vecj + sqrt(1/2)*veck )
        addpoint( vb + (2+sqrt(1/2))*veci + (1+sq2)*vecj + sqrt(1/2)*veck )
        #break
    #case (10)
        addpoint( vb+(0.2+0.6*tau)*veci + (0.8+0.4*tau)*vecj + sqrt((3-tau)/5)*veck )
        addpoint( vb+(1.2+0.6*tau)*veci + (0.8+0.4*tau)*vecj + sqrt((3-tau)/5)*veck )
        addpoint( vb+(1.2+1.6*tau)*veci + (0.8+1.4*tau)*vecj + sqrt((3-tau)/5)*veck )
        addpoint( vb+(1.2+1.6*tau)*veci + (1.8+1.4*tau)*vecj + sqrt((3-tau)/5)*veck )
        addpoint( vb+(1.2+0.6*tau)*veci + (0.8+1.4*tau)*vecj + sqrt((3-tau)/5)*veck )
        #break
    #end
#end
#macro rotateabout(raxis,rangle,va)    // raxis must be a unit vector
    (vdot(raxis,va)*raxis
        + cos(rangle)*(va-vdot(raxis,va)*raxis)
        + sin(rangle)*(vcross(raxis,va)))
#end
#macro rotate_vtxs(raxis,rangle,thresh) // all points in the halfspace v.raxis <= tresh
    #local i=0;
    #while (i<npoints-.5)
        #if (vdot(points[i],raxis) < thresh+0.01)
            #declare points[i]=rotateabout(raxis,pi*rangle/180,points[i]);
        #end   // if
    #local i=i+1;
    #end   //while
#end
#macro drop_vtx(n)
    #declare npoints=npoints-1;
    #if(n<npoints)
        #declare points[n]=points[npoints];
    #end
#end
#macro drop_halfspace(normalvector,thresh) // all points in the halfspace v.raxis < tresh
    #local i=0;
    #while (i<npoints-.5)
        #if (vdot(points[i],normalvector)<thresh-0.01)
            #debug concat("Drop vtx ",str(i,0,0)," of ",str(npoints,0,0)," <",str(points[i].x,0,3),",",str(points[i].y,0,3),",",str(points[i].z,0,3),"> (",str(vdot(points[i],normalvector),0,7),")\n")
            drop_vtx(i)
        #else
            #debug concat("Keep vtx ",str(i,0,0)," of ",str(npoints,0,0)," <",str(points[i].x,0,3),",",str(points[i].y,0,3),",",str(points[i].z,0,3),"> (",str(vdot(points[i],normalvector),0,7),")\n")
            #local i=i+1;
        #end
    #end
#end
#macro autobalance()   // moves the centre of gravity (cog) of the vertices to the origin
    #local cog=<0,0,0>;
    #local i=0;
    #while (i<npoints-.5)
        #local cog=cog+points[i];
        #local i=i+1;
    #end
    #local cog=cog/npoints;
    #local i=0;
    #while (i<npoints-.5)
        #declare points[i]=points[i] - cog;
        #local i=i+1;
    #end
#end


#macro showvtxs()
    #local i=0;
    #while (i<npoints-.5)
        #debug concat("Vtx ",str(i,0,0)," of ",str(npoints,0,0),"= <",str(points[i].x,0,7),",",str(points[i].y,0,7),",",str(points[i].z,0,7),">\n")
        #local i=i+1;
    #end
#end

//--------------- macros to find "sporadic" Johnson solids via iterative optimisation kludge
#declare el=1;
#declare edgelen=array[120][120];
#declare forces=array[120];
#macro addedge(a,b,len)
    #declare edgelen[a][b]=len;
    #declare edgelen[b][a]=len;
#end
#macro make_triangle(a,b,c)
    addedge(a,b,1)    addedge(a,c,1) addedge(b,c,1)
#end
#macro make_square(a,b,c,d)
    addedge(a,b,1) addedge(b,c,1) addedge(c,d,1) addedge(d,a,1) addedge(a,c,sq2*1) addedge(b,d,sq2*1)
#end
#macro make_lune(a,b,c,d,e,f)  // a and d are points of lune
    make_triangle(a,b,f) make_square(b,c,e,f) make_triangle(c,d,e)
#end
#macro optimise(gen_threshold,force_threshold)
    #local gen=0;  #local maxforce=force_threshold+1;
    #while ((gen<gen_threshold) & (maxforce>force_threshold))
        #debug concat("Gen ",str(gen,0,0)," ")
//     showvtxs()
        #local maxforce=-999;
        #local i=0;
        #while (i<npoints)
            #declare forces[i]=<0,0,0>;
            #local j=0;
            #while (j<npoints)
                #ifdef(edgelen[i][j])
                    #local dist=vlength(points[i]-points[j]);
                    #declare forces[i] = forces[i]+ (dist-edgelen[i][j])*(points[j]-points[i]);
//                 #debug concat("Edge ",str(i,0,0)," & ",str(j,0,0)," has length ",str(dist,5,5)," want length ",str(edgelen[i][j],5,5),"\n")
                #end
                #local j=j+1;
            #end
            #if (maxforce<vlength(forces[i])) #local maxforce=vlength(forces[i]); #end
            #local i=i+1;
        #end
        #debug concat("maxforce=",str(maxforce,9,9),"\n")
        #local i=0;
        #while (i<npoints)
            #declare points[i]=points[i]+.1*forces[i];
            #local i=i+1;
        #end
        #local gen=gen+1;
    #end
#end


// Johnson solids
// J1 = square_pyramid (octahedron with vtx dropped)
#macro square_pyramid()
  addevenpermssgn(<1,0,0>,<1,0,0>) drop_vtx(99)
  autobalance()  convex_hull()
#end
// J2 = pentagonal_pyramid (six vtxs of an icosahedron)
#macro pentagonal_pyramid()
    addevenpermssgn(<0,1,tau>,<0,1,1>) drop_halfspace(points[0],0)
    autobalance()  convex_hull()
#end
// ----------------- cuboctahedron modifications J - 3, 18, 22, 27, 35, 36, 44
// J3 = triangular_cupola (9 vtxs of a cuboctahedron)
#macro triangular_cupola()
    polygon_vtx(6)
    augment(6,points[0],points[1],points[2])
    autobalance()  convex_hull()
#end
#macro triangular_gyrobicupola()   //actually a cuboctahedron
    polygon_vtx(6)
    augment(6,points[0],points[1],points[2])
    augment(6,points[2],points[1],points[0])
    autobalance()  convex_hull()
#end
#macro elongated_triangular_cupola()   //J18
    rprism_vtx(6)
    augment(6,points[1],points[3],points[5])
    autobalance()  convex_hull()
#end
#macro gyroelongated_triangular_cupola()   //J22
    antiprism_vtx(6)
    augment(6,points[1],points[3],points[5])
    autobalance()  convex_hull()
#end
#macro triangular_orthobicupola()  //J27
    polygon_vtx(6)
    augment(6,points[0],points[1],points[2])
    augment(6,points[3],points[2],points[1])
    autobalance()  convex_hull()
#end
#macro elongated_triangular_orthobicupola()    //J35
    rprism_vtx(6)
    augment(6,points[1],points[3],points[5])
    augment(6,points[6],points[4],points[2])
    autobalance()  convex_hull()
#end
#macro elongated_triangular_gyrobicupola() //J36
    rprism_vtx(6)
    augment(6,points[1],points[3],points[5])
    augment(6,points[4],points[2],points[0])
    autobalance()  convex_hull()
#end
#macro gyroelongated_triangular_bicupola() //J44
    antiprism_vtx(6)
    augment(6,points[1],points[3],points[5])
    augment(6,points[4],points[2],points[0])
    autobalance()  convex_hull()
#end

// two triangular prisms
#macro gyrobifastigium() // J26
    addpointssgn(<1,1,0>,<1,1,0>)
    addpointssgn(<1,0,sqrt(3)>,<1,0,0>)
    addpointssgn(<0,1,-sqrt(3)>,<0,1,0>)
    autobalance()  convex_hull()
#end
//---------------- miscellaneous cut and pasting
#macro elongated_pyramid(n)    // J7-9 (for n=3,4,5)
    rprism_vtx(n)
    augment(n,points[4],points[2],points[0])
    autobalance()  convex_hull()
#end

#macro elongated_triangular_pyramid()
    elongated_pyramid(3)
#end

#macro elongated_square_pyramid()
    elongated_pyramid(4)
#end

#macro elongated_pentagonal_pyramid()
    elongated_pyramid(5)
#end

#macro dipyramid(n)    // J12 (n=3) and J13 (n=5)
    polygon_vtx(n)
    augment(n,points[0],points[1],points[2])
    augment(n,points[2],points[1],points[0])
    autobalance()  convex_hull()
#end
#macro elongated_dipyramid(n)  // J14-16 (for n=3,4,5)
    rprism_vtx(n)
    augment(n,points[4],points[2],points[0])
    augment(n,points[1],points[3],points[5])
    autobalance()  convex_hull()
#end
#macro elongated_triangular_dipyramid() elongated_dipyramid(3) #end    // J7
#macro elongated_square_dipyramid() elongated_dipyramid(4) #end    // J8
#macro elongated_pentagonal_dipyramid() elongated_dipyramid(5) #end    // J9

// ----------------- rhombicuboctahedron modifications J - 4, 19, 23, 28, 29, 37, 45
#macro rhombicuboctahedron_mod(j_number)
    addevenpermssgn(<1+sq2,1,1>,<1,1,1>)
    #local raxis=<1,0,0>;
    #local edgelen=2;
    #local oct_radius=sqrt(2*sq2+4);
    // drop hemisphere for 6, 21, 25 (have single rotunda)
    #if(j_number=4)    drop_halfspace(raxis,1) #end
    #if(j_number<=23)  drop_halfspace(raxis,-1)    #end
    // stretch and twist
    #local stretch=0;  #local twist=0;
    #switch(j_number)
        #case(29)
            #local twist=45;
        #case(28)
            #local stretch=-edgelen;
            #break
        #case(37)
            #local twist=45;
            #break
        #case(23) #case(45)
            #local twist=22.5;
            #local stretch=oct_radius*2*sqrt((cos(pi/8)-cos(2*pi/8))/2)-edgelen; // borrowed from antiprism_vtx
    #end   //switch
    #if (stretch!=0)       // lower northern hemisphere
        #local i=0;
        #while (i<npoints-.5)
            #if ((stretch = -2) & ( vdot(points[i],raxis)=1))
                drop_vtx(i)
            #else
                #if (vdot(points[i],raxis)>0)
                    #declare points[i]=points[i] + stretch*raxis;
                #end   // if
                #local i=i+1;
            #end //if
        #end   //while
    #end   //if
    #if (twist!=0)     // rotate southern hemisphere (incl equator)
        rotate_vtxs(raxis,twist,-1)
    #end
    autobalance()
#end
// Now the named macros of these modified rhombicuboctahedron
#macro square_cupola()                 rhombicuboctahedron_mod(4)  convex_hull() #end //  J4
#macro elongated_square_cupola()       rhombicuboctahedron_mod(19) convex_hull() #end //  J19
#macro gyroelongated_square_cupola()   rhombicuboctahedron_mod(23) convex_hull() #end //  J23
#macro square_orthobicupola()          rhombicuboctahedron_mod(28) convex_hull() #end //  J28
#macro square_gyrobicupola()           rhombicuboctahedron_mod(29) convex_hull() #end //  J29
#macro elongated_square_gyrobicupola() rhombicuboctahedron_mod(37) convex_hull() #end //  J37
#macro gyroelongated_square_bicupola() rhombicuboctahedron_mod(45) convex_hull() #end //  J45

#macro elongated_square_cupola_alt()   //  J19
    rprism_vtx(8)
    augment(8,points[4],points[2],points[0])
    convex_hull() #end

// J10.    (cap a square antiprism)
#macro gyroelongated_square_pyramid()
  antiprism_vtx(4)
  #local  va=points[1];
  addpoint(<0,0,-(abs(va.z)+1)>)
  convex_hull()
#end
// J17.    (bicap a square antiprism)
#macro gyroelongated_square_dipyramid()
  antiprism_vtx(4)
  #local  va=points[1];
  addpoint(<0,0,abs(va.z)+1>)
  addpoint(<0,0,-(abs(va.z)+1)>)
  convex_hull()
#end

// ----------------- icosahedron modifications
// J11.    (drop a vertex from an icosahedron)
#macro gyroelongated_pentagonal_pyramid()
  addevenpermssgn(<0,1,tau>,<0,1,1>)
  drop_vtx(99)
  convex_hull()
#end
// J62.    (drop 2 vertices from an icosahedron)
#macro metabidiminished_icosahedron()
  addevenpermssgn(<0,1,tau>,<0,1,1>)
  drop_vtx(99)
  drop_vtx(6)
  convex_hull()
#end
// J63.    (drop 3 vertices from an icosahedron)
#macro tridiminished_icosahedron()
  addevenpermssgn(<0,1,tau>,<0,1,1>)
  drop_vtx(99)
  drop_vtx(6)
  drop_vtx(0)  // 5 OK too
  convex_hull()
#end
// J64.    (drop 3 vertices from an icosahedron, add a tetrahedron)
#macro augmented_tridiminished_icosahedron()
  addevenpermssgn(<0,1,tau>,<0,1,1>)
  drop_vtx(99)
  drop_vtx(6)
  drop_vtx(0)
  augment(3,points[1],points[7],points[8])
  convex_hull()
#end

// -------------------- dodecahedron modifications: J58-61
#macro augmented_dodecahedron() //J58
  addpointssgn(<1,1,1>,<1,1,1>)
  addevenpermssgn(<0,1/tau,tau>,<0,1,1>)
  augment(5,points[4],points[13],points[12])
  showvtxs()
  autobalance() convex_hull()
#end
#macro parabiaugmented_dodecahedron() //J59
  addpointssgn(<1,1,1>,<1,1,1>)
  addevenpermssgn(<0,1/tau,tau>,<0,1,1>)
  augment(5,points[4],points[13],points[12])
  #local a=points[npoints-1];
  addpoint(-a)
  showvtxs()
  autobalance() convex_hull()
#end
#macro metabiaugmented_dodecahedron() //J60
  addpointssgn(<1,1,1>,<1,1,1>)
  addevenpermssgn(<0,1/tau,tau>,<0,1,1>)
  augment(5,points[4],points[13],points[12])
  #local a=points[npoints-1];
  addpoint(<a.y,a.z,a.x>)
  showvtxs()
  autobalance() convex_hull()
#end
#macro triaugmented_dodecahedron() //J61
  addpointssgn(<1,1,1>,<1,1,1>)
  addevenpermssgn(<0,1/tau,tau>,<0,1,1>)
  augment(5,points[4],points[13],points[12])
  #local a=points[npoints-1]; drop_vtx(999)
  addevenperms(a)
  showvtxs()
  autobalance() convex_hull()
#end

// ----------------- icosidodecahedron modifications
// Modified icosidodecahedron, for J- 6, 21, 25, 34, 42, 43, 48; J32,33,40,41,47
#macro icosidodecahedron_mod(j_number)
    addevenpermssgn(<0,0,2*tau>,<0,0,1>)
    addevenpermssgn(<1,tau,1+tau>,<1,1,1>)
    #local raxis=vnormalize(<tau,1,0>);
    #local edgelen=vlength(<0,0,2*tau>-<1,tau,1+tau>);
    #local id_radius=2*tau;
    // drop hemisphere for 6, 21, 25 (have single rotunda)
    #if((j_number<=33) | (j_number=40) | (j_number=41) | (j_number=47))
        drop_halfspace(raxis,0)
        #if (j_number>=32) // form a cupolarotunda
            augment(10,points[0],points[7],points[15])
        #end
    #end
    // stretch and twist
    #local stretch=0;  #local twist=0;
    #switch(j_number)
        #case(42) #case(40)
            #local stretch=edgelen;
        #case(34) #case(33)
            #local twist=36;
            #break
        #case(21) #case(43) #case(41)
            #local stretch=edgelen;
            #break
        #case(25) #case(48) #case(47)
            #local twist=18;
            #local stretch=id_radius*2*sqrt((cos(pi/10)-cos(2*pi/10))/2); // borrowed from antiprism_vtx
    #end   //switch
    #if (stretch>0)        // raise northern hemisphere, duplicate equator
        #local i=0;    #local np=npoints;
        #while (i<np-.5)
            #switch (vdot(points[i],raxis))
            #range(-0.01,0.01)
//             #debug concat("Dupl. vtx ",str(i,0,0)," of ",str(npoints,0,0)," <",str(points[i].x,0,3),",",str(points[i].y,0,3),",",str(points[i].z,0,3),">\n")
                addpoint(points[i] + stretch*raxis)
            #break
            #range(0.01,999)
//             #debug concat("Raise vtx ",str(i,0,0)," of ",str(npoints,0,0)," <",str(points[i].x,0,3),",",str(points[i].y,0,3),",",str(points[i].z,0,3),">\n")
                #declare points[i]=points[i] + stretch*raxis;
            #break
            #end   // switch
        #local i=i+1;
        #end   //while
    #end   //if
    #if (twist!=0)     // rotate southern hemisphere (incl equator)
        rotate_vtxs(raxis,twist,0)
    #end
    showvtxs()
    autobalance() convex_hull()
#end

#macro pentagonal_rotunda() icosidodecahedron_mod(6)    #end // J6. Half an icosidodecahedron
#macro elongated_pentagonal_rotunda() icosidodecahedron_mod(21)    #end // J21. Half an icosidodecahedron on a prism
#macro gyroelongated_pentagonal_rotunda() icosidodecahedron_mod(25)    #end // J25. Half an icosidodecahedron on an antiprism
#macro pentagonal_orthobirotunda() icosidodecahedron_mod(34)  #end // J34. Twisted icosidodecahedron
#macro elongated_pentagonal_gyrocupolarotunda() icosidodecahedron_mod(40) #end // J40.
#macro elongated_pentagonal_orthocupolarotunda() icosidodecahedron_mod(41) #end // J41.
#macro elongated_pentagonal_gyrobirotunda() icosidodecahedron_mod(43)  #end // J43. Elongated icosidodecahedron
#macro elongated_pentagonal_orthobirotunda() icosidodecahedron_mod(42)  #end // J42. Elongated twisted icosidodecahedron
#macro gyroelongated_pentagonal_cupolarotunda() icosidodecahedron_mod(47) #end // J47.
#macro gyroelongated_pentagonal_birotunda() icosidodecahedron_mod(48)  #end // J48. Elongated semitwisted icosidodecahedron

#macro pentagonal_orthocupolarotunda()  icosidodecahedron_mod(32)  #end    //J32
#macro pentagonal_gyrocupolarotunda()  icosidodecahedron_mod(33)  #end //J32

//---------------------- pentagonal cupolae, bicupolae
#macro elongated_pentagonal_cupola()   //J20
    rprism_vtx(10)
    augment(10,points[4],points[2],points[0])
    autobalance()  convex_hull()
#end
#macro gyroelongated_pentagonal_cupola()   //J24
    antiprism_vtx(10)
    augment(10,points[4],points[2],points[0])
    autobalance()  convex_hull()
#end

#macro pentagonal_orthobicupola()  //J30
    polygon_vtx(10)
    augment(10,points[0],points[1],points[2])
    augment(10,points[3],points[2],points[1])
    autobalance()  convex_hull()
#end

#macro pentagonal_gyrobicupola()   //J31
    polygon_vtx(10)
    augment(10,points[0],points[1],points[2])
    augment(10,points[2],points[1],points[0])
    autobalance()  convex_hull()
#end

#macro elongated_pentagonal_orthobicupola()    //J38
    rprism_vtx(10)
    augment(10,points[4],points[2],points[0])
    augment(10,points[3],points[5],points[7])
    autobalance()  convex_hull()
#end

#macro elongated_pentagonal_gyrobicupola() //J39
    rprism_vtx(10)
    augment(10,points[4],points[2],points[0])
    augment(10,points[1],points[3],points[5])
    showvtxs()
    autobalance()  convex_hull()
#end
#macro gyroelongated_pentagonal_bicupola() //J46
    antiprism_vtx(10)
    augment(10,points[4],points[2],points[0])
    augment(10,points[1],points[3],points[5])
    autobalance()  convex_hull()
#end

// -------------------- side-capped prisms : J49-57
#macro augmented_prisms(n,facelist)    // n=prism base, facelist=string with faces to cap
    rprism_vtx(n)
    #local i=1;
    #while(i<=strlen(facelist))
        #local facenum=mod(val(substr(facelist,i,1)),n);   // convert ith char given to a number 0..(n-1)
        augment(4,points[2*facenum+1],points[2*facenum],points[mod(2*facenum+2,2*n)])
//     #debug concat("Augment face ",str(facenum,0,0)," of ",str(n,0,0), " <",str(points[npoints-1].x,0,3),",",str(points[npoints-1].y,0,3),",",str(points[npoints-1].z,0,3),"> \n")
        #local i=i+1;
    #end
    autobalance()  convex_hull()
#end
#macro augmented_triangular_prism() augmented_prisms(3,"0") #end   // J49
#macro biaugmented_triangular_prism() augmented_prisms(3,"01") #end    // J50
#macro triaugmented_triangular_prism() augmented_prisms(3,"012") #end  // J51
#macro augmented_pentagonal_prism()    augmented_prisms(5,"0") #end    // J52
#macro biaugmented_pentagonal_prism() augmented_prisms(5,"02") #end    // J53
#macro augmented_hexagonal_prism() augmented_prisms(6,"0") #end    // J54
#macro parabiaugmented_hexagonal_prism()   augmented_prisms(6,"03")    #end    // J55
#macro metabiaugmented_hexagonal_prism()   augmented_prisms(6,"02")    #end    // J56
#macro triaugmented_hexagonal_prism()  augmented_prisms(6,"024")   #end    // J57

// ----------------- rhombicosidodecahedron modifications
#macro pentagonal_cupola() //J5
  addevenpermssgn(<1,1,1+2*tau>,<1,1,1>)
  addevenpermssgn(<tau,2*tau,1+tau>,<1,1,1>)
  addevenpermssgn(<2+tau,0,1+tau>,<1,0,1>)
  #local raxis=vnormalize(<tau,-1,0>);
  drop_halfspace(raxis,3.077)
  autobalance()  convex_hull()
#end
#macro mogrified_rhombicosidodecahedron(mods)  //J72-J83
    // mods is a 4-character string of D (drop), G (gyrate) and other (leave alone)
    addevenpermssgn(<1,1,1+2*tau>,<1,1,1>)
    addevenpermssgn(<tau,2*tau,1+tau>,<1,1,1>)
    addevenpermssgn(<2+tau,0,1+tau>,<1,0,1>)
    #local raxis=array[5];
    #local raxis[1]=vnormalize(<tau,-1,0>);
    #local raxis[2]=vnormalize(<-1,0,tau>);
    #local raxis[3]=vnormalize(<-1,0,-tau>);
    #local raxis[4]=-raxis[1];
    #local i=1;
    #while(i<=min(4,strlen(mods)))
        #local modchar=substr(mods,i,1);
        #if (strcmp(modchar,"D")=0) drop_halfspace(-raxis[i],-3.077) #end
        #if (strcmp(modchar,"G")=0) rotate_vtxs(-raxis[i],36,-3.077) #end
        #local i=i+1;
    #end
    autobalance()  convex_hull()
#end

// #macro diminished_rhombicosidodecahedron()  //J76
//   addevenpermssgn(<1,1,1+2*tau>,<1,1,1>)
//   addevenpermssgn(<tau,2*tau,1+tau>,<1,1,1>)
//   addevenpermssgn(<2+tau,0,1+tau>,<1,0,1>)
//   #local raxis=vnormalize(<tau,-1,0>);
//   drop_halfspace(-raxis,-3.077)
//   autobalance()  convex_hull()
// #end
// #macro tridiminished_rhombicosidodecahedron()   //J83
//   addevenpermssgn(<1,1,1+2*tau>,<1,1,1>)
//   addevenpermssgn(<tau,2*tau,1+tau>,<1,1,1>)
//   addevenpermssgn(<2+tau,0,1+tau>,<1,0,1>)
//   #local raxis=vnormalize(<tau,-1,0>);
//   drop_halfspace(-raxis,-3.077)
//   #local raxis=vnormalize(<-1,0,-tau>);
//   drop_halfspace(-raxis,-3.077)
//   #local raxis=vnormalize(<-1,0,tau>);
//   drop_halfspace(-raxis,-3.077)
//   autobalance()  convex_hull()
// #end
// #macro metabidiminished_rhombicosidodecahedron()    //J81
//   addevenpermssgn(<1,1,1+2*tau>,<1,1,1>)
//   addevenpermssgn(<tau,2*tau,1+tau>,<1,1,1>)
//   addevenpermssgn(<2+tau,0,1+tau>,<1,0,1>)
//   #local raxis=vnormalize(<tau,-1,0>);
//   drop_halfspace(-raxis,-3.077)
//   #local raxis=vnormalize(<-1,0,tau>);
//   drop_halfspace(-raxis,-3.077)
//   autobalance()  convex_hull()
// #end
// #macro parabidiminished_rhombicosidodecahedron()    //J80
//   addevenpermssgn(<1,1,1+2*tau>,<1,1,1>)
//   addevenpermssgn(<tau,2*tau,1+tau>,<1,1,1>)
//   addevenpermssgn(<2+tau,0,1+tau>,<1,0,1>)
//   #local raxis=vnormalize(<tau,-1,0>);
//   drop_halfspace(-raxis,-3.077)
//   drop_halfspace( raxis,-3.077)
//   autobalance()  convex_hull()
// #end
// #macro gyrate_rhombicosidodecahedron()  //J72
//   addevenpermssgn(<1,1,1+2*tau>,<1,1,1>)
//   addevenpermssgn(<tau,2*tau,1+tau>,<1,1,1>)
//   addevenpermssgn(<2+tau,0,1+tau>,<1,0,1>)
//   #local raxis=vnormalize(<tau,-1,0>);
//   rotate_vtxs(-raxis,36,-3.077)
//   autobalance()  convex_hull()
// #end
// #macro trigyrate_rhombicosidodecahedron()   //J75
//   addevenpermssgn(<1,1,1+2*tau>,<1,1,1>)
//   addevenpermssgn(<tau,2*tau,1+tau>,<1,1,1>)
//   addevenpermssgn(<2+tau,0,1+tau>,<1,0,1>)
//   #local raxis=vnormalize(<tau,-1,0>);
//   rotate_vtxs(-raxis,36,-3.077)
//   #local raxis=vnormalize(<-1,0,-tau>);
//   rotate_vtxs(-raxis,36,-3.077)
//   #local raxis=vnormalize(<-1,0,tau>);
//   rotate_vtxs(-raxis,36,-3.077)
//   autobalance()  convex_hull()
// #end

////////////// sporadics

#macro snub_disphenoid()   // J84
    addpoint(<1,0,0>)  #local EQTR1=npoints-1;
    addpoint(<0,1,0>)  #local EQTR2=npoints-1;
    addpoint(<-1,0,0>) #local EQTR3=npoints-1;
    addpoint(<0,-1,0>) #local EQTR4=npoints-1;
    addpoint(<1,0,1>)  #local NORTH1=npoints-1;
    addpoint(<-1,0,1>) #local NORTH2=npoints-1;
    addpoint(<0,1,-1>) #local SOUTH1=npoints-1;
    addpoint(<0,-1,-1>)    #local SOUTH2=npoints-1;
    make_triangle(EQTR1,EQTR2,NORTH1)  make_triangle(EQTR1,EQTR2,SOUTH1)
    make_triangle(EQTR1,EQTR4,NORTH1)  make_triangle(EQTR1,EQTR4,SOUTH2)
    make_triangle(EQTR2,EQTR3,NORTH2)  make_triangle(EQTR2,EQTR3,SOUTH1)
    make_triangle(EQTR3,EQTR4,NORTH2)  make_triangle(EQTR3,EQTR4,SOUTH2)
    addedge(NORTH1,NORTH2,1)
    addedge(SOUTH1,SOUTH2,1)
    optimise(100,0.000001)
    autobalance()  convex_hull()
#end

#macro snub_square_antiprism() // J85
    addpoint(<sq2,0,0>)    #local E1=npoints-1;
    addpoint(<1,1,0>)  #local E2=npoints-1;
    addpoint(<0,sq2,0>)    #local E3=npoints-1;
    addpoint(<-1,1,0>) #local E4=npoints-1;
    addpoint(<-sq2,0,0>)   #local E5=npoints-1;
    addpoint(<-1,-1,0>)    #local E6=npoints-1;
    addpoint(<0,-sq2,0>)   #local E7=npoints-1;
    addpoint(<1,-1,0>) #local E8=npoints-1;
    addpoint(<.5,.5,1>)    #local N1=npoints-1;
    addpoint(<-.5,.5,1>)   #local N2=npoints-1;
    addpoint(<-.5,-.5,1>)  #local N3=npoints-1;
    addpoint(<.5,-.5,1>)   #local N4=npoints-1;
    addpoint(<1/sq2,0,-1>) #local S1=npoints-1;
    addpoint(<0,1/sq2,-1>) #local S2=npoints-1;
    addpoint(<-1/sq2,0,-1>)    #local S3=npoints-1;
    addpoint(<0,-1/sq2,-1>)    #local S4=npoints-1;
    make_triangle(E1,E2,N1)    make_triangle(E1,E2,S1)
    make_triangle(E2,E3,N1)    make_triangle(E2,E3,S2)
    make_triangle(E3,E4,N2)    make_triangle(E3,E4,S2)
    make_triangle(E4,E5,N2)    make_triangle(E4,E5,S3)
    make_triangle(E5,E6,N3)    make_triangle(E5,E6,S3)
    make_triangle(E6,E7,N3)    make_triangle(E6,E7,S4)
    make_triangle(E7,E8,N4)    make_triangle(E7,E8,S4)
    make_triangle(E8,E1,N4)    make_triangle(E8,E1,S1)
    addedge(N1,N2,1)       addedge(N2,N3,1)    addedge(N1,N3,sq2)
    addedge(N3,N4,1)       addedge(N4,N1,1)    addedge(N2,N4,sq2)
    addedge(S1,S2,1)       addedge(S2,S3,1)    addedge(S1,S3,sq2)
    addedge(S3,S4,1)       addedge(S4,S1,1)    addedge(S2,S4,sq2)
    optimise(400,0.00000001)
    autobalance()
    convex_hull()
#end

#macro sphenocoronae(n)    // J86 & J87
    addpoint(<1,0,0>)  #local E1=npoints-1;
    addpoint(<.5,1,0>) #local E2=npoints-1;
    addpoint(<-.5,1,0>)    #local E3=npoints-1;
    addpoint(<-1,0,0>) #local E4=npoints-1;
    addpoint(<-.5,-1,0>)   #local E5=npoints-1;
    addpoint(<.5,-1,0>)    #local E6=npoints-1;
    addpoint(<.5,0,1>) #local N1=npoints-1;
    addpoint(<-.5,0,1>)    #local N2=npoints-1;
    addpoint(<0,.5,-1>)    #local S1=npoints-1;
    addpoint(<0,-.5,-1>)   #local S2=npoints-1;
    make_lune(E1,E2,E3,E4,N2,N1)
    make_lune(E4,E5,E6,E1,N1,N2)
    make_triangle(E1,E2,S1) make_triangle(E2,E3,S1) make_triangle(E3,E4,S1)
    make_triangle(E4,E5,S2) make_triangle(E5,E6,S2) make_triangle(E6,E1,S2)
    addedge(S1,S2,1)
    optimise(400,0.00000001)
    #if(n=87) augment(4,points[E2],points[E3],points[N2]) #end
    autobalance()
    convex_hull()
#end
#macro sphenocorona()  // J86
    sphenocoronae(86)
#end
#macro augmented_sphenocorona()    // J87
    sphenocoronae(87)
#end
#macro augmented_sphenocorona_old()    // J87
    addpoint(<1,0,0>)  #local E1=npoints-1;
    addpoint(<.5,1,0>) #local E2=npoints-1;
    addpoint(<-.5,1,0>)    #local E3=npoints-1;
    addpoint(<-1,0,0>) #local E4=npoints-1;
    addpoint(<-.5,-1,0>)   #local E5=npoints-1;
    addpoint(<.5,-1,0>)    #local E6=npoints-1;
    addpoint(<.5,0,1>) #local N1=npoints-1;
    addpoint(<-.5,0,1>)    #local N2=npoints-1;
    addpoint(<0,.5,-1>)    #local S1=npoints-1;
    addpoint(<0,-.5,-1>)   #local S2=npoints-1;
    make_lune(E1,E2,E3,E4,N2,N1)
    make_lune(E4,E5,E6,E1,N1,N2)
    make_triangle(E1,E2,S1) make_triangle(E2,E3,S1) make_triangle(E3,E4,S1)
    make_triangle(E4,E5,S2) make_triangle(E5,E6,S2) make_triangle(E6,E1,S2)
    addedge(S1,S2,1)
    addpoint(<0,1,1>)  #local A=npoints-1;
    make_triangle(A,E2,E3) make_triangle(A,N2,N1)
    optimise(400,0.00000001)
    autobalance()
    convex_hull()
#end
#macro sphenomegacorona()  // J88
    addpoint(< 1.3, 0  , 0.1>) #local E1=npoints-1;
    addpoint(< 0.5, 0.6, 0  >) #local E2=npoints-1;
    addpoint(<-0.5, 0.6, 0  >) #local E3=npoints-1;
    addpoint(<-1.3, 0  , 0.1>) #local E4=npoints-1;
    addpoint(<-0.5,-0.6, 0  >) #local E5=npoints-1;
    addpoint(< 0.5,-0.6, 0  >) #local E6=npoints-1;
    addpoint(< 0.5, 0  , 0.7>) #local N1=npoints-1;
    addpoint(<-0.5, 0  , 0.7>) #local N2=npoints-1;
    addpoint(< 0  , 0.5,-0.9>) #local S1=npoints-1;
    addpoint(<-0.8, 0  ,-0.8>) #local S2=npoints-1;
    addpoint(< 0  ,-0.5,-0.9>) #local S3=npoints-1;
    addpoint(< 0.8, 0  ,-0.8>) #local S4=npoints-1;
    make_lune(E1,E2,E3,E4,N2,N1)
    make_lune(E4,E5,E6,E1,N1,N2)
    make_triangle(E1,E2,S4) make_triangle(E2,E3,S1) make_triangle(E3,E4,S2)
    make_triangle(E4,E5,S2) make_triangle(E5,E6,S3) make_triangle(E6,E1,S4)
    make_triangle(S1,S2,S3) make_triangle(S3,S4,S1)
    optimise(400,0.000001)
// showvtxs()
    autobalance()
    convex_hull()
#end

#macro hebesphenomegacorona()  // J89
    addpoint(< 1.10, 0.00, 0.20>)  #local E1=npoints-1;
    addpoint(< 0.50, 0.72,-0.15>)  #local E2=npoints-1;
    addpoint(<-0.50, 0.72,-0.15>)  #local E3=npoints-1;
    addpoint(<-1.10, 0.00, 0.20>)  #local E4=npoints-1;
    addpoint(<-0.50,-0.72,-0.15>)  #local E5=npoints-1;
    addpoint(< 0.50,-0.72,-0.15>)  #local E6=npoints-1;
    addpoint(< 0.50, 0.50, 0.83>)  #local N1=npoints-1;
    addpoint(<-0.50, 0.50, 0.83>)  #local N2=npoints-1;
    addpoint(<-0.50,-0.50, 0.83>)  #local N3=npoints-1;
    addpoint(< 0.50,-0.50, 0.83>)  #local N4=npoints-1;
    addpoint(< 0.00, 0.50,-0.99>)  #local S1=npoints-1;
    addpoint(<-0.84, 0.00,-0.76>)  #local S2=npoints-1;
    addpoint(< 0.00,-0.50,-0.99>)  #local S3=npoints-1;
    addpoint(< 0.84, 0.00,-0.76>)  #local S4=npoints-1;
    make_lune(E1,E2,E3,E4,N2,N1)
    make_lune(E4,E5,E6,E1,N4,N3)
    make_lune(E1,N1,N2,E4,N3,N4)

    make_triangle(E1,E2,S4) make_triangle(E2,E3,S1) make_triangle(E3,E4,S2)
    make_triangle(E4,E5,S2) make_triangle(E5,E6,S3) make_triangle(E6,E1,S4)
    make_triangle(S1,S2,S3)
    make_triangle(S3,S4,S1)
    optimise(400,0.000001)
    showvtxs()
    autobalance()
    convex_hull()
#end

#macro disphenocingulum()  //  J90
    addpoint(< 0.00, 0.50, 1.10>)  #local NN1=npoints-1;
    addpoint(< 0.00,-0.50, 1.10>)  #local NN2=npoints-1;
    addpoint(< 0.00, 1.12, 0.33>)  #local N1=npoints-1;
    addpoint(< 0.77, 0.50, 0.46>)  #local N2=npoints-1;
    addpoint(< 0.77,-0.50, 0.46>)  #local N3=npoints-1;
    addpoint(< 0.00,-1.12, 0.33>)  #local N4=npoints-1;
    addpoint(<-0.77,-0.50, 0.46>)  #local N5=npoints-1;
    addpoint(<-0.77, 0.50, 0.46>)  #local N6=npoints-1;
    addpoint(< 0.50, 0.77,-0.46>)  #local S1=npoints-1;
    addpoint(< 1.12, 0.00,-0.33>)  #local S2=npoints-1;
    addpoint(< 0.50,-0.77,-0.46>)  #local S3=npoints-1;
    addpoint(<-0.50,-0.77,-0.46>)  #local S4=npoints-1;
    addpoint(<-1.12, 0.00,-0.33>)  #local S5=npoints-1;
    addpoint(<-0.50, 0.77,-0.46>)  #local S6=npoints-1;
    addpoint(< 0.50, 0.00,-1.10>)  #local SS1=npoints-1;
    addpoint(<-0.50, 0.00,-1.10>)  #local SS2=npoints-1;
    make_lune(N1,N2,N3,N4,NN2,NN1)
    make_lune(N4,N5,N6,N1,NN1,NN2)
    make_lune(S2,SS1,SS2,S5,S6,S1)
    make_lune(S2,S3,S4,S5,SS2,SS1)
    make_triangle(N1,S1,N2)
    make_triangle(N2,S2,N3)
    make_triangle(N3,S3,N4)
    make_triangle(N4,S4,N5)
    make_triangle(N5,S5,N6)
    make_triangle(N6,S6,N1)
    optimise(400,0.000001)
    showvtxs()
    autobalance()
    convex_hull()
#end

#macro bilunabirotunda() // J91
    // start with icosahedron
  addevenpermssgn(<0,1,tau>,<0,1,1>)
  //   showvtxs()
  // trim back to 8 vertices
  drop_halfspace(<-1,-tau,0>,-tau)
  drop_halfspace(<-1,tau,0>,-tau)
  drop_halfspace(<1,0,0>,-1)
  // now shift all vertices into halfspace x >= 0, and mirror
  #local i=0;#local minx=999;
  #while (i<npoints)
    #local minx=min(minx,points[i].x);
    //#if (minx>points[i].x) #local minx=points[i].x; #end
    #local i=i+1;
  #end // (while loop)
  #local i=0; #local np=npoints;
  #while (i<np)
    #declare points[i]=points[i]+<-minx,0,0>;
    #if (points[i].x>0) addpoint(<-points[i].x,points[i].y,points[i].z>) #end
    #local i=i+1;
  #end // (while loop)
  convex_hull()
#end

#macro triangular_hebesphenorotunda() // J92
    // Coords found by taking 7 vtxs of an icosahedron, placing one vtx
    // at origin, which is centre of the one hexagonal face.
    addevenperms( <1,tau,0>-<tau,0,1>)
    addevenperms( <0,1,tau>-<tau,0,1>)
    addevenperms( <-1,tau,0>-<tau,0,1>)
    addevenperms( <-tau,0,1>-<tau,0,1>)
    addevenperms( <0,1,-tau>-<tau,0,1>)
    addevenperms(-<1,tau,0>-<tau,0,1>)
    autobalance()
    convex_hull()
#end

#macro herschel_enneahedron()
  // http://aperiodical.com/2013/10/an-enneahedron-for-herschel/
  #local th=sqrt(3)/2;
  #local h1=1/2;
  #local h2=h1*4/3;
  addpoint(< 0.5 ,   0 , -h1 >)
  addpoint(< 0   ,   0 ,  0  >)
  addpoint(< 0.5 ,   0 ,  h1 >)
  addpoint(< 1   ,   0 ,  0  >)
  addpoint(< 0.5 , th/3, -h2 >)
  addpoint(< 0.25, th/2, -h1 >)
  addpoint(< 0.25, th/2,  h1 >)
  addpoint(< 0.5 , th/3,  h2 >)
  addpoint(< 0.75, th/2,  h1 >)
  addpoint(< 0.75, th/2, -h1 >)
  addpoint(< 0.5 , th  ,  0  >)
  autobalance()
  convex_hull()
#end

#macro addplane(a,b,c)
  #local n=vnormalize(vcross(points[b]-points[a],points[c]-points[a]));
  #local d=vdot(n,points[a]);
  addface(n,d)
#end

#macro triakistruncatedtetrahedron()
  addpoint(< 8/3, 1/3, 5/(3*sqrt(2))>)
  addpoint(< 8/3, 2/3, 4/(3*sqrt(2))>)
  addpoint(< 8/3, 1  , 5/(3*sqrt(2))>)
  
  addpoint(< 3  , 0  , 7/(3*sqrt(2))>)
  addpoint(< 3  , 2/3, 1/   sqrt(2) >)
  addpoint(< 3  , 4/3, 7/(3*sqrt(2))>)
  
  addpoint(<10/3, 0  , 8/(3*sqrt(2))>)
  addpoint(<10/3, 1/3, 3/   sqrt(2) >)
  addpoint(<10/3, 1  , 3/   sqrt(2) >)
  addpoint(<10/3, 4/3, 8/(3*sqrt(2))>)
  
  addpoint(<11/3, 0  , 7/(3*sqrt(2))>)
  addpoint(<11/3, 2/3, 1/   sqrt(2) >)
  addpoint(<11/3, 4/3, 7/(3*sqrt(2))>)
  
  addpoint(< 4  , 1/3, 5/(3*sqrt(2))>)
  addpoint(< 4  , 2/3, 4/(3*sqrt(2))>)
  addpoint(< 4  , 1  , 5/(3*sqrt(2))>)
  
  autobalance()
  convex_hull()
#end

#macro trapezo_rhombic_dodecahedron()
  triangular_orthobicupola()
  dual()
#end

#macro elongated_dodecahedron()
  #local c = sqrt(3);
  addpoint(< 1,  1, c+1>)
  addpoint(< 1,  1,  -1>)
  addpoint(< 1, -1, c+1>)
  addpoint(< 1, -1,  -1>)
  addpoint(<-1,  1, c+1>)
  addpoint(<-1,  1,  -1>)
  addpoint(<-1, -1, c+1>)
  addpoint(<-1, -1,  -1>)
  addpoint(< 2,  0,   0>)
  addpoint(<-2,  0,   0>)
  addpoint(< 0,  2,   0>)
  addpoint(< 0, -2,   0>)
  addpoint(< 0,  0, c+2>)
  addpoint(< 0,  0,  -2>)
  addpoint(< 2,  0, c  >)
  addpoint(<-2,  0, c  >)
  addpoint(< 0,  2, c  >)
  addpoint(< 0, -2, c  >)
  autobalance()
  convex_hull()
#end

#macro rhombic_icosahedron()
  #local A = sqrt(10 * (25 - 11 * sqrt(5))) / 20;
  #local B = sqrt(10 * ( 5 -      sqrt(5))) / 20;
  #local C = sqrt(10 * ( 5 +      sqrt(5))) / 20;
  #local D = sqrt(10 * ( 5 -      sqrt(5))) / 10;
  #local E = sqrt( 2 * ( 5 -      sqrt(5))) /  4;
  #local F = sqrt(10 * ( 5 +      sqrt(5))) / 10;
  #local G = sqrt( 2 * ( 5 +      sqrt(5))) /  4;
  #local H = sqrt(10 * (25 + 11 * sqrt(5))) / 20;
  #local I = sqrt( 5 * ( 5 +  2 * sqrt(5))) /  5;
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
  #local C2 =  1 / sqrt(  3);
  #local C3 = 11 / sqrt(243);
  #local C4 =  5 / sqrt( 27);
  
  addevenperms(< C1,  C1,  C4>)
  addevenperms(< C1, -C1, -C4>)
  addevenperms(<-C1, -C1,  C4>)
  addevenperms(<-C1,  C1, -C4>)
  
  addevenperms(< C3, -C0,  C3>)
  addevenperms(< C3,  C0, -C3>)
  addevenperms(<-C3,  C0,  C3>)
  addevenperms(<-C3, -C0, -C3>)
  
  addevenperms(< C2, -C2,  C2>)
  
  addpoint(<-C2, -C2, -C2>)
  
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
  // == sqrt( 1 - 2 * cos(pi/N) + 1 + 4c^2)
  // == sqrt( 4c^2 + 2 - 2 * cos(pi/N) ).                       (1)
  // The apex will be at z == c * cot(pi/(2*N))^2.
  // The neighbour of A on the upper main ring will be
  // A * q + (0,0,z) * (1-q)
  // == < q , 0 , c + z - z*q >.
  // The distance bewteen these points is
  // sqrt( (q-1)^2 + (0-0)^2 + (c + z - z*q - c)^2 )
  // == sqrt( (q-1)^2 + (z - z*q)^2 )
  // == sqrt( (q-1)^2 + z^2 * (1-q)^2 )
  // == sqrt( (1+z^2) * (q-1)^2 )
  // == sqrt(1+z^2) * abs(q-1)
  // == sqrt(1+z^2) * (1-q)
  // == sqrt( 1 + c^2 * cot(pi/(2*N))^4 )  *  ( 1 - q )         (2)
  // For aesthetics, I want (1) and (2) to be equal:
  // sqrt( 4c^2 + 2 - 2 * cos(pi/N) )    ==    sqrt( 1 + c^2 * cot(pi/(2*N))^4 )  *  ( 1 - q )
  // sqrt( 4c^2 + 2 - 2 * cos(pi/N) )  /  sqrt( 1 + c^2 * cot(pi/(2*N))^4 )    ==      1 - q
  // q == 1  -  sqrt( 4c^2 + 2 - 2 * cos(pi/N) )  /  sqrt( 1 + c^2 * cot(pi/(2*N))^4 )
  
  // As below, let A == <1, 0, c> be a point on the upper middle ring.
  // Then C == <cos(pi/N), sin(pi/N), -c> (as below) and D == <cos(pi/N), -sin(pi/N), -c>
  // are its nearest neighbours in the lower middle ring.  For aesthetics, I want angle CAD to be 90 degrees.
  // AC  ==  <1,0,c> - <cos(pi/N),  sin(pi/N), -c>  == < 1 - cos(pi/N) , -sin(pi/N) , 2c >
  // AD  ==  <1,0,c> - <cos(pi/N), -sin(pi/N), -c>  == < 1 - cos(pi/N) ,  sin(pi/N) , 2c >
  // For the angle to be right, we need AC (dot) AD == 0:
  // 0 == (1 - cos(pi/N))^2 - sin(pi/N)^2 + 4c^2
  // 0 == 1 - 2*cos(pi/N) + cos(pi/N)^2 - sin(pi/N)^2 + 4c^2
  // 4c^2 = 2 * cos(pi/N) - cos(2*pi/N) - 1
  // c == sqrt(2 * cos(pi/N) - cos(2*pi/N) - 1) / 2
  
  #local c = sqrt(2 * cos(pi/N) - cos(2*pi/N) - 1) / 2;
  #local p = 1 / tan(pi/(2*N));
  // I actually want the upper and lower rings to be a bit closer than I described above.
  #local q = 1 - sqrt( 4*c*c + 2 - 2 * cos(pi/N) )  /  sqrt( 1 + c*c * p*p*p*p ) * 0.75;
  
  // Points 0 through  N-1 are the upper middle ring.
  #for (I, 0, 2*N-2, 2)
    addpoint(<cos(I * pi/N), sin(I * pi/N),  c>)
  #end
  
  // Points N through 2N-1 are the lower middle ring.
  #for (I, 1, 2*N-1, 2)
    addpoint(<cos(I * pi/N), sin(I * pi/N), -c>)
  #end
  
  #local A = points[0]; // <1, 0, c>
  #local B = points[1];
  #local C = points[N];
  #local AB = A - B;
  #local AC = A - C;
  #local ABxAC = vcross(AB, AC);
  
  // The plane containing A, B, and C has equation
  // ABxAC.x * (x - A.x)  +  ABxAC.y * (y - A.y)  +  ABxAC.z * (z - A.z)  == 0
  // ABxAC.x * (x -  1 )  +  ABxAC.y * (y -  0 )  +  ABxAC.z * (z -  c )  == 0
  // The +z apex of the solid is this plane's z-intercept.
  // ABxAC.x * (0 -  1 )  +  ABxAC.y * (0 -  0 )  +  ABxAC.z * (z -  c )  == 0
  // -ABxAC.x             +            0          +  ABxAC.z * (z -  c )  == 0
  // ABxAC.z * (z -  c ) ==     ABxAC.x
  //            z -  c   ==     ABxAC.x / ABxAC.z
  //            z        == c + ABxAC.x / ABxAC.z
  
  #local Apex = <0, 0, c + ABxAC.x / ABxAC.z>;
  // The upper upper ring will be the weighted average of the upper middle ring and Apex,
  // with the ring weighted by q and Apex weighted by 1-q, and similarly for the lower lower ring.
  
  // Points 2N through 3N-1 are the upper upper ring.
  #for (I, 0, N-1)
    addpoint(points[I] * q + Apex * (1-q))
  #end
  
  // Points 3N through 4N-1 are the lower lower ring.
  #for (I, N, 2*N-1)
    addpoint(points[I] * q - Apex * (1-q))
  #end
  
  addplane(2*N, 2*N+1, 2*N+2) // The upper N-gon
  addplane(3*N, 3*N+1, 3*N+2) // The lower N-gon
  
  #for (I, 0, N-1)
    addplane(I, mod(I+1,N), I+N)
    addplane(I+N, mod(I+1,N), mod(I+1,N)+N)
  #end
  
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
  #local AB = A - B;
  #local AC = A - C;
  #local ABxAC = vcross(AB, AC);
  
  // The plane containing A, B, and C has equation
  // ABxAC.x * (x - A.x)  +  ABxAC.y * (y - A.y)  +  ABxAC.z * (z - A.z)  == 0
  // ABxAC.x * (x - r1 )  +  ABxAC.y * (y -  0 )  +  ABxAC.z * (z -  c )  == 0
  // The +z apex of the solid is this plane's z-intercept.
  // ABxAC.x * (0 - r1 )  +  ABxAC.y * (0 -  0 )  +  ABxAC.z * (z -  c )  == 0
  // -ABxAC.x * r1        +            0          +  ABxAC.z * (z -  c )  == 0
  // ABxAC.z * (z -  c ) ==     ABxAC.x * r1
  //            z -  c   ==     ABxAC.x * r1 / ABxAC.z
  //            z        == c + ABxAC.x * r1 / ABxAC.z
  
  addpoint(<0, 0, c + ABxAC.x * r1 / ABxAC.z>)
  
  addplane(N, N+1, N+2) // The N-gon
  
  #for (I, 0, N-1)
    addplane(I, mod(I+1,N), I+N)
    addplane(I+N, mod(I+1,N)+N, mod(I+1,N))
  #end
  
#end

#macro rhombic_enneacontahedron()
  #local C0 = (   -sqrt(3) + sqrt(15)) / 6;
  #local C1 =      sqrt(3)             / 3;
  #local C2 = (    sqrt(3) + sqrt(15)) / 6;
  #local C3 =                sqrt(15)  / 3;
  #local C4 = (3 * sqrt(3) + sqrt(15)) / 6;
  #local C5 = (    sqrt(3) + sqrt(15)) / 3;
  #local C6 = (5 * sqrt(3) + sqrt(15)) / 6;
  #local C7 = (2 * sqrt(3) + sqrt(15)) / 3;
  
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
  addpoint(< 1, 0, 2/2>)
  addpoint(<-1, 0, 2/2>)
  addpoint(< 0, 1,-2/2>)
  addpoint(< 0,-1,-2/2>)
  autobalance()
  convex_hull()
#end









#macro convex_hull()
  // This is an incremental convex-hull algorithm.  It should run in O(N^2) time.
  #local N    = npoints;
  #local EPS  = 1e-9;
  #local MaxF = 2*N;    // Enough for a triangulated 3D convex hull with N points.
  #local Face              = array[MaxF];
  #local AffectedEdges     = array[3*N];    // Enough for a triangulated 3D convex hull with N points.
  #local MarkedForDeletion = array[MaxF];
  #local EdgeMarks         = array[N][N];   // The contents will be 0s and 1s.
  
  // Initialize Mark[][] to all zeros.
  #for (i, 0, N-1)
    #for (j, i+1, N-1)      // Only elements with first index < second index will be used.
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
  #if (vdot(vcross(I1-I0, I2-I0), I0-Inside) > EPS)
    #local Face[0] = <i0,i1,i2>;
  #else
    #local Face[0] = <i0,i2,i1>;
  #end
  
  #if (vdot(vcross(I3-I0, I1-I0), I0-Inside) > EPS)
    #local Face[1] = <i0,i3,i1>;
  #else
    #local Face[1] = <i0,i1,i3>;
  #end
  
  #if (vdot(vcross(I2-I0, I3-I0), I0-Inside) > EPS)
    #local Face[2] = <i0,i2,i3>;
  #else
    #local Face[2] = <i0,i3,i2>;
  #end
  
  #if (vdot(vcross(I3-I1, I2-I1), I1-Inside) > EPS)
    #local Face[3] = <i1,i3,i2>;
  #else
    #local Face[3] = <i1,i2,i3>;
  #end
  
  #local Facecount = 4; // The number of faces stores in "Face".
  
  // We now select a new point P and expand the hull to it.
  // We do this by finding those faces that P can see, deleting them, figuring out what the new faces are, and adding those.
  
  #local MFD = 0;   // The number of points that get marked for deletion.  This will be reset to zero during each deletion pass.
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
        // TODO: What if Side == 0?  This can happen when a side has more than 3 vertices.
        // If we treat the Side == 0 case as if we had Side < 0, then I think everything works out fine.
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
          
          #local EdgeMarks[a][b] = 0;
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




#declare points=array[1000];
#declare tpoints=array[1000];
#declare npoints=0;
#declare faces=array[1000];
#declare nfaces=0;
#macro addpoint(a)
  #declare points[npoints]=a;
  #declare npoints=npoints+1;
#end
#macro addevenperms(a)
  addpoint(a)
  addpoint(<a.y,a.z,a.x>)
  addpoint(<a.z,a.x,a.y>)
#end
#macro addperms(a)
  addevenperms(a)
  addevenperms(<a.x,a.z,a.y>)
#end
#macro addpointssgn(a,s)
  addpoint(a)
  #if(s.x) addpointssgn(a*<-1,1,1>,s*<0,1,1>) #end
  #if(s.y) addpointssgn(a*<1,-1,1>,s*<0,0,1>) #end
  #if(s.z) addpoint(a*<1,1,-1>) #end
#end
#macro addevenpermssgn(a,s)
  addpointssgn(a,s)
  addpointssgn(<a.y,a.z,a.x>,<s.y,s.z,s.x>)
  addpointssgn(<a.z,a.x,a.y>,<s.z,s.x,s.y>)
#end
#macro addpermssgn(a,s)
  addevenpermssgn(a,s)
  addevenpermssgn(<a.x,a.z,a.y>,<s.x,s.z,s.y>)
#end
#macro addpointsevensgn(a)
  addpoint(a)
  addpoint(a*<-1,-1,1>)
  addpoint(a*<-1,1,-1>)
  addpoint(a*<1,-1,-1>)
#end
#macro addevenpermsevensgn(a)
  addevenperms(a)
  addevenperms(a*<-1,-1,1>)
  addevenperms(a*<-1,1,-1>)
  addevenperms(a*<1,-1,-1>)
#end
#macro addpermsaltsgn(a)
  addevenpermsevensgn(a)
  addevenpermsevensgn(<a.x,a.z,-a.y>)
#end
/*#macro addevenpermssgn(a,s) //Calls addevenperms with, for each 1 in s, a.{x,y,z} replaced with {+,-}a.{x,y,z}
  addevenperms(a)
  #if(s.x) addevenpermssgn(a*<-1,1,1>,s*<0,1,1>) #end
  #if(s.y) addevenpermssgn(a*<1,-1,1>,s*<0,0,1>) #end
  #if(s.z) addevenperms(a*<1,1,-1>) #end
#end*/
#macro addface(d,l)
  #local a=vnormalize(d)/l;
  #local f=1;
  #for (n, 0, nfaces-1)
    #if(vlength(faces[n]-a)<0.00001) #local f=0; #end
  #end
  #if(f)
    #declare faces[nfaces]=a;
    #declare nfaces=nfaces+1;
  #end
#end
#macro dual()
  #declare temp=faces;
  #declare faces=points;
  #declare points=temp;
  #declare temp=nfaces;
  #declare nfaces=npoints;
  #declare npoints=temp;
#end


This_shape_will_be_drawn()

//Random rotations are (hopefully) equally distributed...
#declare rot1=rand(rotation)*pi*2;
#declare rot2=acos(1-2*rand(rotation));
#declare rot3=(rand(rotation)+clock)*pi*2;
#macro dorot()
  rotate rot1*180/pi*y
  rotate rot2*180/pi*x
  rotate rot3*180/pi*y
#end

#if(1)
    //Scale shape to fit in unit sphere
    #local b=0;
    #for (a, 0, npoints-1)
      #local c=vlength(points[a]);
      #if(c>b)
        #local b=c;
      #end
    #end
    #for (a, 0, npoints-1)
      #local points[a]=points[a]/b;
    #end
    #for (a, 0, nfaces-1)
      #local faces[a]=faces[a]*b;
    #end
#end

//Draw edges
#macro addp(a)
  #declare p[np]=a;
  #declare np=np+1;
#end
#for (a, 0, nfaces-1)
  #declare p=array[MaximumVerticesPerFace];
  #declare np=0;
  #for (b, 0, npoints-1)
    #if(vdot(faces[a],points[b])>1-0.00001) addp(b) #end
  #end
  #for (c, 0, np-1)
    #for (d, 0, np-1)
      #if(p[c]<p[d]-.5)
        #local f=1;
        #for (e, 0, np-1)
          #if(e!=c & e!=d & vdot(vcross(points[p[c]],points[p[d]]),points[p[e]])<0)
            #local f=0;
          #end
        #end // for e
        #if(f)
          object {
            cylinder { points[p[c]], points[p[d]], .01 dorot() }
            pigment { colour <.3,.3,.3> }
            finish { ambient 0 diffuse 1 phong 1 }
          }
        #end // if
      #end // if
    #end // for d
  #end // #for c
#end
/*#local a=0; #while(a<npoints-.5)
  #local b=a+1; #while(b<npoints-.5)
    #if(vlength(points[a]-points[b])<elength+0.00001)
      object {
        cylinder { points[a], points[b], .01 dorot() }
        pigment { colour <.3,.3,.3> }
        finish { ambient 0 diffuse 1 phong 1 }
      }
    #end
  #local b=b+1; #end
#local a=a+1; #end*/

//Draw points
union {
  #for (a, 0, npoints-1)
    sphere { points[a], .01 dorot() }
  #end
  pigment { colour <.3,.3,.3> }
  finish { ambient 0 diffuse 1 phong 1 }
}

#if(notwireframe)
//Draw planes
object {
  intersection {
    #for (a, 0, nfaces-1)
      plane { faces[a], 1/vlength(faces[a]) }
    #end
    //planes()
    //sphere { <0,0,0>, 1 }
    //sphere { <0,0,0>, ld+.01 inverse }
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

//  CCC Y Y PP
//  C   Y Y P P
//  C    Y  PP
//  C    Y  P
//  CCC  Y  P

#for (a, 0, 11)
  light_source { <4*sin(a*pi*2/11), 5*cos(a*pi*6/11), -4*cos(a*pi*2/11)> colour (1+<sin(a*pi*2/11),sin(a*pi*2/11+pi*2/3),sin(a*pi*2/11+pi*4/3)>)*2/11 }
//  light_source { <4*sin(a*pi*2/11), 5*cos(a*pi*6/11), -4*cos(a*pi*2/11)>
 //        colour (1+<sin(a*pi*2/11),sin(a*pi*2/11+pi*2/3),sin(a*pi*2/11+pi*4/3)>)*2/11 }
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
    //  location <0,0,-10>
      look_at <0,0,0>
    }
#else
    // some auto-framing.  Not for animated versions.
    #declare camera_loc=<0,0,-4.8>;
    #declare max_elevation=0;  #declare max_bearing=0;
    #for (i, 0, npoints-1)
        #declare sighting=points[i];
        #declare sighting=vaxis_rotate(sighting,y,rot1*180/pi);
        #declare sighting=vaxis_rotate(sighting,x,rot2*180/pi);
        #declare sighting=vaxis_rotate(sighting,y,rot3*180/pi);
        #declare sighting=sighting-camera_loc;
        #declare elevation=sighting.y/sighting.z;
        #declare bearing=sighting.x/sighting.z;
        #declare max_elevation = max(max_elevation,abs(elevation));
        #declare max_bearing = max(max_bearing,abs(bearing));
    //     sphere{ (camera_loc+<bearing,elevation,1>*10), 0.2
    //         pigment{ colour rgb <1,0,1> } }
    #end
    #debug concat("Maximum: Elevation = ",str(max_elevation,4,4),"  Bearing = ",str(max_bearing,4,4),"\n")
    #if(1) // 1:1 aspect ratio
        #declare max_bearing = max(max_elevation,max_bearing); #declare max_elevation=max_bearing;
    #end
    #if(1) // 5% border
        #declare max_bearing=1.05*max_bearing;
        #declare max_elevation=1.05*max_elevation;
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
