# polyhedra

This repository contains Python and POV-Ray code to render "[the green set](https://commons.wikimedia.org/wiki/Category:Set_of_polyhedra;_green)" of polyhedra from the Wikimedia Commons, plus some other solids which I intend to upload there in due course.  It also allows the creation of STL files for 3D modelling and printing, and the creation of animations of these solids rotating about a vertical axis.

In the Python file `render.py`, there are two lists (`data` and `atad`) of lists.
* The sublists in the `data` list have 3 elements each:
  * The 0<sup>th</sup> element is the English name of a polyhedron.
  * The 1<sup>st</sup> element is a POV-Ray code snippet.  This snippet controls which parts of `convex.pov` get executed, and therefore which of the polyhedra described in that file get rendered.
  * The 2<sup>nd</sup> element is a tuple of integers.  In the original POV-Ray code, the orientation of each polyhedron is determined by seeding a specific [PRNG](https://en.wikipedia.org/wiki/Pseudorandom_number_generator).  In the Python file, the 0<sup>th</sup> element of each of those tuples of integers is the orientation seed from the original POV-Ray code; the remaining integers are orientation seeds chosen by me.
* The sublists in the `atad` list have 3 elements each:
  * The 0<sup>th</sup> and 2<sup>nd</sup> elements are as in the `data` list.
  * The 1<sup>st</sup> element is the name of the corresponding POV-Ray file found in the `povcode/` directory.

# Usage:

```bash
./render.py [target="X[,Y[,Z...]]"] [res=N] [filetypes=mp4,png,pov,stl,svg]
            [frames=120] [keepframes=yes] [angles=0[,1[,2[,3...]]]]
```

When run with no arguments, this will render all polyhedra at all recorded orientations.  This creates a folder `images/`, containing subfolders such as `images/augmented_sphenocorona/`; that is, the names of the subfolders are the English names of the polyhedra, as recorded in the `data` and `atad` lists from the Python file.  Within each subfolder, there will be files with names of the form `11.png`; that is, for every orientation seed listed in the Python file for a given polyhedron, its subfolder will contain a PNG file, and their names will be their orientation seeds.

To render a specific set of polyhedra, use the `target=` argument.  For example,
```bash
./render.py target="cube,augmented sphenocorona,great dodecahedron"
```
renders the cube, augmented sphenocorona, and great dodecahedron using all orientations recorded in the `data` and `atad` lists.  Extra spaces can be added between the quotation marks as long as the spaces do not split a word.  For example, 
```bash
./render.py target="  cube ,     augmented     sphenocorona,great dodecahedron"
```
has the same effect as the previous command.

By default, the image files will be 1024 × 1024 pixels.  To render at N × N pixels, use the `res=N` argument.

The program will produce MP4, PNG, POV, STL, or SVG files (at the moment, only solids in `data` can be rendered as SVGs).  To specify which, use the `filetypes=` argument.  It is not case-sensitive.  For example, to produce only PNGs and STLs, one could use
```bash
./render.py filetypes=PnG,stL
```
By default, only PNGs will be made.  If making MP4s, they will be 360° rotations of the solids.  This works by generating a bunch of PNG files, calling `ffmpeg` to compile them into an MP4 file, and then deleting the PNGs.  By default, animations will have 120 frames.  To change this, use the `frames=` argument.  The animation will run at 30 frames per second.  To change this, edit the appropriate line in `render.py`.

When animating, the default behavior is to delete all the frames after compiling them into the MP4.  If FFmpeg is not available, or if the `keepframes=yes` argument is used, then the frames will not be deleted.

To override the built-in angles, use the `angles=` option.

A number of files will be created in the relevant subdirectories of `images/`.  Any pre-existing files with conflicting filenames will be overwritten.  Some of the created files will be deleted, depending on the `filetypes=` argument.

# Included solids

* All Platonic solids
* All Archimedean solids
* All Catalan solids
* All Johnson solids
* All Kepler-Poinsot solids
* The *n*-biprisms for *n* = 3&ndash;10
* The *n*-antiprisms for *n* = 2&ndash;10 and 17
* The *n*-bipyramids for *n* = 3&ndash;10
* The *n*-trapezohedra for *n* = 2&ndash;10
* The truncated *n*-trapezohedra for *n* = 3&ndash;10
* The diminished *n*-trapezohedra for *n* = 3&ndash;10
* The compound of five tetrahedra
* [This toroidal complex of eight octahedra](https://commons.wikimedia.org/wiki/File:Toroidal_polyhedron.gif)
* The Schoenhardt polyhedron
* The truncated triakis tetrahedron
* The triakis truncated tetrahedron
* The Herschel enneahedron
* The stellated octahedron
* The Csaszar polyhedron
* The rhombic icosahedron
* The trapezo-rhombic dodecahedron
* The elongated dodecahedron
* The elongated gyrobifastigium

# TODO

* Implement aliases.  For example, the cube is also the hexahedron, and the compound of two tetrahedra is also the stellated octahedron is also the stella octangula.
* Redo the angle stuff to replace the seeded PRNG with the actual angles being used.
* Figure out how to prevent animations from zooming in and out.
* https://polytope.miraheze.org/wiki/File:Trefoil_knot_toroid_36P6.png
* https://en.wikipedia.org/wiki/Template:Star_polyhedron_navigator
* https://en.wikipedia.org/wiki/Boerdijk%E2%80%93Coxeter_helix
* https://en.wikipedia.org/wiki/Category:Polyhedral_compounds
* https://en.wikipedia.org/wiki/Prismatic_uniform_polyhedron
* https://en.wikipedia.org/wiki/Cubitruncated_cuboctahedron
* https://en.wikipedia.org/wiki/Compound_of_ten_tetrahedra
* https://en.wikipedia.org/wiki/Compound_of_five_octahedra
* https://en.wikipedia.org/wiki/Rhombic_enneacontahedron
* https://en.wikipedia.org/wiki/Near-miss_Johnson_solid
* https://en.wikipedia.org/wiki/Uniform_star_polyhedron
* https://en.wikipedia.org/wiki/Compound_of_three_cubes
* https://en.wikipedia.org/wiki/Compound_of_five_cubes
* https://en.wikipedia.org/wiki/Compound_of_four_cubes
* https://en.wikipedia.org/wiki/Jessen%27s_icosahedron
* https://en.wikipedia.org/wiki/Tetrated_dodecahedron
* https://en.wikipedia.org/wiki/Tridyakis_icosahedron
* https://polytope.miraheze.org/wiki/File:P_star.png
* https://en.wikipedia.org/wiki/Toroidal_polyhedron
* https://en.wikipedia.org/wiki/Waterman_polyhedron
* https://en.wikipedia.org/wiki/Szilassi_polyhedron
* https://en.wikipedia.org/wiki/Hexagonal_bifrustum
* https://en.wikipedia.org/wiki/Regular_polyhedron
* https://en.wikipedia.org/wiki/Hill_tetrahedron
* https://en.wikipedia.org/wiki/Tetradecahedron
* https://dmccooey.com/polyhedra/index.html
* Truncated bipyramids
* Allow arbitrary members of the infinite families.
* Ensure that this works across platforms.
* Handle chirality when relevant.
* Make SVGs for non-`convex.pov` solids.

# Credits

* The POV-Ray code in `convex.pov` was largely written by Wikipedia users Cyp (https://en.wikipedia.org/wiki/User:Cyp/Poly.pov) and AndrewKepert (https://en.wikipedia.org/wiki/User:AndrewKepert/poly.pov), though some of the solids in it are my contribution.
* The POV-Ray code for the Herschel enneahedron and triakis truncated tetrahedron comes from https://github.com/timhutton/povray-polyhedra.
* The POV-Ray code for the Kepler-Poinsot solids and compound of five tetrahedra is derived from https://commons.wikimedia.org/wiki/File:GreatStellatedDodecahedron.jpg.  
* The original POV-Ray code renders only one polyhedron at a time and requires a manual modification for each rendering; I wrote `render.py` to automate everything.
* The toroidal octahedron chain was put on the Wikimedia Commons in 2007 by Quilbert (https://commons.wikimedia.org/wiki/User:Quilbert).  I could not find the code used to generate that image, so the re-creation of it here is largely my own work.
* The code for generating the STL and SVG files is found in `convex_to_stl.py`, `pov_faces_to_stl.py`, and `convex_to_svg.py`. I vibe-coded them through ChatGPT 5.4, because I could not find any existing programs that would do that in an automatable manner, and because writing them myself seemed beyond my skill level.  I have personally vetted them on all solids currently in this project, and will ensure that they continue to operate correctly on any further solids that get added.
* The files `csaszar.pov`, `schoenhardt.pov`, and `stel_octa.pov` are my own work.
