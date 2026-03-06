# polyhedra

This repository contains Python and POV-Ray code to render "the green set" of polyhedra from the Wikimedia Commons.  The POV-Ray code was largely written by Wikipedia users Cyp (https://en.wikipedia.org/wiki/User:Cyp/Poly.pov) and AndrewKepert (https://en.wikipedia.org/wiki/User:AndrewKepert/poly.pov); my modifications to that are fairly trivial.  The POV-Ray code renders only one polyhedron at a time and requires a manual modification for each rendering; my main contribution is the Python code, which automates that modification.

In the Python file, there is a list (`data`) of 3-tuples.  In each tuple, the 0<sup>th</sup> element is the English name of the polyhedron, the 1<sup>st</sup> element is a POV-Ray code snippet, and the 2<sup>nd</sup> element is a tuple of integers.  

In the original POV-Ray code, the orientation of each polyhedron is determined by seeding a specific [PRNG](https://en.wikipedia.org/wiki/Pseudorandom_number_generator).  In the Python file, the 0<sup>th</sup> element of each of those tuples of integers is the orientation seed from the original POV-Ray code; the remaining integers are orientation seeds chosen by me.

# Usage:

```bash
./render.py [target="X"] [res=N]
```

When run with no arguments, this will render all polyhedra at all orientations.  This creates a folder `images/`, containing subfolders such as `images/augmented_sphenocorona/`; that is, the names of the subfolders are the English names of the polyhedra, as recorded in the `data` list from the Python file.  Within each subfolder, there will be files with names of the form `11.pov` and `11.png`; that is, for every orientation seed listed in the Python file for a given polyhedron, its subfolder will contain a POV-Ray source file and the resulting PNG file, and their names will be the orientation seeds, with the appropriate filename extensions.

To render a specific polyhedron, use the `target=` argument.  For example,
```bash
./render.py target="augmented sphenocorona"
```
renders the augmented sphenocorona all recorded orientations.

By default, the image files will be 1024 × 1024 pixels.  To render at N × N pixels, use the `res=N` argument.

# TODO

- [ ] Redo the angle stuff to replace the seeded PRNG with the actual angles being used.
