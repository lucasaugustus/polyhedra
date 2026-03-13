# polyhedra

This repository contains Python and POV-Ray code to render "[the green set](https://commons.wikimedia.org/wiki/Category:Set_of_polyhedra;_green)" of polyhedra from the Wikimedia Commons.

In the Python file, there is a list (`data`) of 3-tuples.  In each tuple, the 0<sup>th</sup> element is the English name of the polyhedron, the 1<sup>st</sup> element is a POV-Ray code snippet, and the 2<sup>nd</sup> element is a tuple of integers.  In the original POV-Ray code, the orientation of each polyhedron is determined by seeding a specific [PRNG](https://en.wikipedia.org/wiki/Pseudorandom_number_generator).  In the Python file, the 0<sup>th</sup> element of each of those tuples of integers is the orientation seed from the original POV-Ray code; the remaining integers are orientation seeds chosen by me.

# Usage:

```bash
./render.py [target="X"] [res=N] [animate=yes] [frames=120]
```

When run with no arguments, this will render all polyhedra at all orientations.  This creates a folder `images/`, containing subfolders such as `images/augmented_sphenocorona/`; that is, the names of the subfolders are the English names of the polyhedra, as recorded in the `data` list from the Python file.  Within each subfolder, there will be files with names of the form `11.pov` and `11.png`; that is, for every orientation seed listed in the Python file for a given polyhedron, its subfolder will contain a POV-Ray source file and the resulting PNG file, and their names will be the orientation seeds, with the appropriate filename extensions.

To render a specific polyhedron, use the `target=` argument.  For example,
```bash
./render.py target="augmented sphenocorona"
```
renders the augmented sphenocorona using all orientations recorded in the `data` list.

By default, the image files will be 1024 × 1024 pixels.  To render at N × N pixels, use the `res=N` argument.

To produce animations, use the `animate=yes` argument.  This will be a 360° rotation of the solid.  By default, this will have 120 frames.  To change this, use the `frames=` argument.  This works by generating a bunch of PNG files, calling ``ffmpeg`` to compile them into an MP4 file, and then deleting the PNGs.  If ``ffmpeg`` is not available, then the PNGs will still be created, but no MP4 will be created, and the PNGs will not be deleted afterwards.  The animation will run at 30 frames per second.  To change this, edit the appropriate line in `render.py`.

The Kepler-Poinsot solids, the compound of five tetrahedra, and the toroidal octahedron chain are not currently integrated into the scheme used by `render.py`.  The user must handle these separately.

# TODO

* Redo the angle stuff to replace the seeded PRNG with the actual angles being used.
* Integrate the Kepler-Poinsot solids, the toroidal octahedron chain, and the compound of five tetrahedra into the `render.py` scheme.
* Ensure that this works across platforms.

# Credits

* The POV-Ray code was largely written by Wikipedia users Cyp (https://en.wikipedia.org/wiki/User:Cyp/Poly.pov) and AndrewKepert (https://en.wikipedia.org/wiki/User:AndrewKepert/poly.pov).
* The POV-Ray code for the Herschel enneahedron and triakis truncated tetrahedron comes from https://github.com/timhutton/povray-polyhedra.
* The POV-Ray code for the Kepler-Poinsot solids and compound of five tetrahedra is derived from https://commons.wikimedia.org/wiki/File:GreatStellatedDodecahedron.jpg.  
* My modifications to the above are fairly trivial.  The original POV-Ray code renders only one polyhedron at a time and requires a manual modification for each rendering; my main contribution is the Python code, which automates that modification.
* The toroidal octahedron chain was put on the Wikimedia Commons in 2007 by Quilbert (https://commons.wikimedia.org/wiki/User:Quilbert).  I could not find the code used to generate that image, so the re-creation of it here is largely my own work.
