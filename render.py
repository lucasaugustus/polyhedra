#! /usr/bin/env python3

# For usage instructions, credits, and further details, see https://github.com/lucasaugustus/polyhedra/blob/main/README.md.

from os import system, mkdir, remove
from itertools import count
from time import sleep
from sys import argv

data = [
('tetrahedron'                                 , 'tetrahedron()'                           , (1889,)),      # Platonic
('cube'                                        , 'hexahedron()'                            , (7122,)),      # Platonic
('octahedron'                                  , 'octahedron()'                            , (4193,)),      # Platonic
('dodecahedron'                                , 'dodecahedron()'                          , (4412,)),      # Platonic
('icosahedron'                                 , 'icosahedron()'                           , (7719,)),      # Platonic
('cuboctahedron'                               , 'cuboctahedron()'                         , (1941,)),      # Archimedian
('icosidodecahedron'                           , 'icosidodecahedron()'                     , (2241,)),      # Archimedian
('rhombicosidodecahedron'                      , 'rhombicosidodecahedron()'                , (8266,)),      # Archimedian
('rhombicuboctahedron'                         , 'rhombicuboctahedron()'                   , (6124,)),      # Archimedian
('snub cube'                                   , 'snubhexahedron(-1)'                      , (7152,)),      # Archimedian
('snub dodecahedron'                           , 'snubdodecahedron(1)'                     , (8154,)),      # Archimedian
('truncated cube'                              , 'truncatedhexahedron(0)'                  , (1345,)),      # Archimedian
('truncated cuboctahedron'                     , 'truncatedcuboctahedron()'                , (1156,)),      # Archimedian
('truncated dodecahedron'                      , 'truncateddodecahedron(0)'                , (9374,)),      # Archimedian
('truncated icosahedron'                       , 'truncatedicosahedron()'                  , (1666,)),      # Archimedian
('truncated icosidodecahedron'                 , 'truncatedicosidodecahedron()'            , (1422,)),      # Archimedian
('truncated octahedron'                        , 'truncatedoctahedron()'                   , (7235,)),      # Archimedian
('truncated tetrahedron'                       , 'truncatedtetrahedron(0)'                 , (8717,)),      # Archimedian
('rhombic dodecahedron'                        , 'rhombicdodecahedron()'                   , (7154,)),      # Catalan
('rhombic triacontahedron'                     , 'rhombictriacontahedron()'                , (1237,)),      # Catalan
('triakis tetrahedron'                         , 'triakistetrahedron()'                    , (7735,)),      # Catalan
('triakis octahedron'                          , 'triakisoctahedron()'                     , (5354,)),      # Catalan
('tetrakis hexahedron'                         , 'tetrakishexahedron()'                    , (1788,)),      # Catalan
('triakis icosahedron'                         , 'triakisicosahedron()'                    , (1044,)),      # Catalan
('pentakis dodecahedron'                       , 'pentakisdodecahedron()'                  , (6100,)),      # Catalan
('deltoidal icositetrahedron'                  , 'deltoidalicositetrahedron()'             , (5643,)),      # Catalan
('disdyakis dodecahedron'                      , 'disdyakisdodecahedron()'                 , (1440,)),      # Catalan
('deltoidal hexecontahedron'                   , 'deltoidalhexecontahedron()'              , (1026,)),      # Catalan
('disdyakis triacontahedron'                   , 'disdyakistriacontahedron()'              , (1556,)),      # Catalan
('pentagonal icositetrahedron'                 , 'pentagonalicositetrahedron(-1)'          , (7771,)),      # Catalan
('pentagonal hexecontahedron'                  , 'pentagonalhexecontahedron(-1)'           , (1046,)),      # Catalan
('triangular prism'                            , 'rprism(3)'                               , (6620,)),      # Infinite family
(    'square prism'                            , 'rprism(4)'                               , (6620,)),      # Infinite family
('pentagonal prism'                            , 'rprism(5)'                               , (6620,)),      # Infinite family
( 'hexagonal prism'                            , 'rprism(6)'                               , (6620,)),      # Infinite family
('heptagonal prism'                            , 'rprism(7)'                               , (6620,)),      # Infinite family
( 'octagonal prism'                            , 'rprism(8)'                               , (6620,)),      # Infinite family
( 'nonagonal prism'                            , 'rprism(9)'                               , (6620,)),      # Infinite family
( 'decagonal prism'                            , 'rprism(10)'                              , (6620,)),      # Infinite family
(       'digonal antiprism'                    , 'antiprism(2)'                            , (6620,)),      # Infinite family
(    'triangular antiprism'                    , 'antiprism(3)'                            , (6620,)),      # Infinite family
(        'square antiprism'                    , 'antiprism(4)'                            , (6620,)),      # Infinite family
(    'pentagonal antiprism'                    , 'antiprism(5)'                            , (6620,)),      # Infinite family
(     'hexagonal antiprism'                    , 'antiprism(6)'                            , (6620,)),      # Infinite family
(    'heptagonal antiprism'                    , 'antiprism(7)'                            , (6620,)),      # Infinite family
(     'octagonal antiprism'                    , 'antiprism(8)'                            , (6620,)),      # Infinite family
(     'nonagonal antiprism'                    , 'antiprism(9)'                            , (6620,)),      # Infinite family
(     'decagonal antiprism'                    , 'antiprism(10)'                           , (6620,)),      # Infinite family
('heptadecagonal antiprism'                    , 'antiprism(17)'                           , (6620,)),      # Infinite family
('triangular bipyramid'                        , 'bipyramid(3)'                            , (6620,)),      # Infinite family
(    'square bipyramid'                        , 'bipyramid(4)'                            , (6620,)),      # Infinite family
('pentagonal bipyramid'                        , 'bipyramid(5)'                            , (6620,)),      # Infinite family
( 'hexagonal bipyramid'                        , 'bipyramid(6)'                            , (6620,)),      # Infinite family
('heptagonal bipyramid'                        , 'bipyramid(7)'                            , (6620,)),      # Infinite family
( 'octagonal bipyramid'                        , 'bipyramid(8)'                            , (6620,)),      # Infinite family
( 'nonagonal bipyramid'                        , 'bipyramid(9)'                            , (6620,)),      # Infinite family
( 'decagonal bipyramid'                        , 'bipyramid(10)'                           , (6620,)),      # Infinite family
(   'digonal trapezohedron'                    , 'trapezohedron(2)'                        , (6620,)),      # Infinite family
('triangular trapezohedron'                    , 'trapezohedron(3)'                        , (6620,)),      # Infinite family
(    'square trapezohedron'                    , 'trapezohedron(4)'                        , (6620,)),      # Infinite family
('pentagonal trapezohedron'                    , 'trapezohedron(5)'                        , (6620,)),      # Infinite family
( 'hexagonal trapezohedron'                    , 'trapezohedron(6)'                        , (6620,)),      # Infinite family
('heptagonal trapezohedron'                    , 'trapezohedron(7)'                        , (6620,)),      # Infinite family
( 'octagonal trapezohedron'                    , 'trapezohedron(8)'                        , (6620,)),      # Infinite family
( 'nonagonal trapezohedron'                    , 'trapezohedron(9)'                        , (6620,)),      # Infinite family
( 'decagonal trapezohedron'                    , 'trapezohedron(10)'                       , (6620,)),      # Infinite family
('square pyramid'                              , 'square_pyramid()'                        , (84,27,29,32,75)),                             # J1
('pentagonal pyramid'                          , 'pentagonal_pyramid()'                    , (11,39,44,46,84,91,129)),                      # J2
('triangular cupola'                           , 'triangular_cupola()'                     , (11,53,58,91,142,191)),                        # J3
('square cupola'                               , 'square_cupola()'                         , (19,0,3,10,43,143,150,202)),                   # J4
('pentagonal cupola'                           , 'pentagonal_cupola()'                     , (19,)),                                        # J5
('pentagonal rotunda'                          , 'pentagonal_rotunda()'                    , (4,10,31,36,124,131,174,181,185,188,190)),     # J6
('elongated triangular pyramid'                , 'elongated_pyramid(3)'                    , (444,8,11,13,17,18,19,20,32,43)),              # J7
('elongated square pyramid'                    , 'elongated_pyramid(4)'                    , (444,1,4,8,11,13,46,53,56,58,63,84)),          # J8
('elongated pentagonal pyramid'                , 'elongated_pyramid(5)'                    , (444,6,13,51,55,58)),                          # J9
('gyroelongated square pyramid'                , 'gyroelongated_square_pyramid()'          , (6621,0,7,38,45,83,95)),                       # J10
('gyroelongated pentagonal pyramid'            , 'gyroelongated_pentagonal_pyramid()'      , (6621,4,9,30,33,35,36,42,49,56,63,80,89)),     # J11
('triangular bipyramid'                        , 'dipyramid(3)'                            , (654,12,14,15,16,17,18,19,20,21)),             # J12
('pentagonal bipyramid'                        , 'dipyramid(5)'                            , (654,6,7,18,20,23,24,25,26,27,29)),            # J13
('elongated triangular bipyramid'              , 'elongated_dipyramid(3)'                  , (654,2,5,8,9,12,14,17,19,20,27,32,37)),        # J14
('elongated square bipyramid'                  , 'elongated_dipyramid(4)'                  , (654,1,2,8,10,13,15,19,31,44,46,50,56,58,62)), # J15
('elongated pentagonal bipyramid'              , 'elongated_dipyramid(5)'                  , (654,0,2,6,8,13,14,15,24,26,35,40,44,45,46)),  # J16
('gyroelongated square bipyramid'              , 'gyroelongated_square_dipyramid()'        , (6621,6,7,8,12,13,31,38,46,50)),               # J17
('elongated triangular cupola'                 , 'elongated_triangular_cupola()'           , (112358,0,45,83,88,95,102,114)),               # J18
('elongated square cupola'                     , 'elongated_square_cupola()'               , (333,1,3,5,10,12,15,17,43)),                   # J19
('elongated pentagonal cupola'                 , 'elongated_pentagonal_cupola()'           , (333,6,13,18,20,48,49,53,58,65)),              # J20
('elongated pentagonal rotunda'                , 'elongated_pentagonal_rotunda()'          , (4,1,3,5,34,36,93)),                           # J21
('gyroelongated triangular cupola'             , 'gyroelongated_triangular_cupola()'       , (112358,0,7,38,45,50,57,83)),                  # J22
('gyroelongated square cupola'                 , 'gyroelongated_square_cupola()'           , (333,3,8,10,48,55)),                           # J23
('gyroelongated pentagonal cupola'             , 'gyroelongated_pentagonal_cupola()'       , (333,6,11,13,18,20,41)),                       # J24
('gyroelongated pentagonal rotunda'            , 'gyroelongated_pentagonal_rotunda()'      , (4,3,36)),                                     # J25
('gyrobifastigium'                             , 'gyrobifastigium()'                       , (112358,1,7,31)),                              # J26
('triangular orthobicupola'                    , 'triangular_orthobicupola()'              , (112358,1,5,8,11)),                            # J27
('square orthobicupola'                        , 'square_orthobicupola()'                  , (333,3,6,12,17,28)),                           # J28
('square gyrobicupola'                         , 'square_gyrobicupola()'                   , (333,1,2,3,5,10)),                             # J29
('pentagonal orthobicupola'                    , 'pentagonal_orthobicupola()'              , (333,11,18)),                                  # J30
('pentagonal gyrobicupola'                     , 'pentagonal_gyrobicupola()'               , (333,11,13,18)),                               # J31
('pentagonal orthocupolarotunda'               , 'pentagonal_orthocupolarotunda()'         , (4,2,9)),                                      # J32
('pentagonal gyrocupolarotunda'                , 'pentagonal_gyrocupolarotunda()'          , (4,2,9)),                                      # J33
('pentagonal orthobirotunda'                   , 'pentagonal_orthobirotunda()'             , (4,2,9)),                                      # J34
('elongated triangular orthobicupola'          , 'elongated_triangular_orthobicupola()'    , (112358,0,6,8,10,14)),                         # J35
('elongated triangular gyrobicupola'           , 'elongated_triangular_gyrobicupola()'     , (112358,0,4,6,7,8,10,14)),                     # J36
('elongated square gyrobicupola'               , 'elongated_square_gyrobicupola()'         , (333,3,4,5,10)),                               # J37
('elongated pentagonal orthobicupola'          , 'elongated_pentagonal_orthobicupola()'    , (333,6,18,24,25,29,35,41,49)),                 # J38
('elongated pentagonal gyrobicupola'           , 'elongated_pentagonal_gyrobicupola()'     , (333,6,38,45,58,81,88)),                       # J39
('elongated pentagonal orthocupolarotunda'     , 'icosidodecahedron_mod(40)'               , (4,2,9,29,34,36,41,46,48)),                    # J40
('elongated pentagonal gyrocupolarotunda'      , 'icosidodecahedron_mod(41)'               , (4,2,9,29,34,36,41,46,48)),                    # J41
('elongated pentagonal orthobirotunda'         , 'elongated_pentagonal_orthobirotunda()'   , (4,2,9,16,21,22,23,29,34,36,38,41,42,46,48)),  # J42
('elongated pentagonal gyrobirotunda'          , 'elongated_pentagonal_gyrobirotunda()'    , (4,2,9,16,21,22,23,29,34,36,38,41,42,46,48)),  # J43
('gyroelongated triangular bicupola'           , 'gyroelongated_triangular_bicupola()'     , (112358,0,3,4,7,13)),                          # J44
('gyroelongated square bicupola'               , 'gyroelongated_square_bicupola()'         , (333,2,4,10,48,54)),                           # J45
('gyroelongated pentagonal bicupola'           , 'gyroelongated_pentagonal_bicupola()'     , (333,0,6,8,11,13,20,25,34,35,38,45,46)),       # J46
('gyroelongated pentagonal cupolarotunda'      , 'icosidodecahedron_mod(47)'               , (4,2,9,16,29,34,36,41,46,48)),                 # J47
('gyroelongated pentagonal birotunda'          , 'gyroelongated_pentagonal_birotunda()'    , (4,2,9,14,16,21,23,29,34,36,38,41,42,46,48)),  # J48
(      'augmented triangular prism'            , 'augmented_triangular_prism()'            , (88,3,4,11,16,21,22,23,27,29,32,39)),          # J49
(    'biaugmented triangular prism'            , 'biaugmented_triangular_prism()'          , (88,11,17,19,21,23,24,27,29,36)),              # J50
(   'triaugmented triangular prism'            , 'triaugmented_triangular_prism()'         , (88,26,29,35,41,42,48)),                       # J51
(      'augmented pentagonal prism'            , 'augmented_pentagonal_prism()'            , (5555,16,17,23,24,26,29,30,36,41,43)),         # J52
(    'biaugmented pentagonal prism'            , 'biaugmented_pentagonal_prism()'          , (5555,17,23,24,26,27,29,30,36,41,42,43)),      # J53
(      'augmented hexagonal prism'             , 'augmented_hexagonal_prism()'             , (5555,10,11,17,18,23,24,26,29,30,36,41,42)),   # J54
('parabiaugmented hexagonal prism'             , 'parabiaugmented_hexagonal_prism()'       , (5555,11,17,18,23,24,26,29,30,36,41,42)),      # J55
('metabiaugmented hexagonal prism'             , 'metabiaugmented_hexagonal_prism()'       , (5555,17,24,29,30,36,42,48,49,54,55)),         # J56
(   'triaugmented hexagonal prism'             , 'triaugmented_hexagonal_prism()'          , (5555,26,29,35,42,48,49,54,55)),               # J57
(      'augmented dodecahedron'                , 'augmented_dodecahedron()'                , (4412,0,22,26,68,75)),                         # J58
('parabiaugmented dodecahedron'                , 'parabiaugmented_dodecahedron()'          , (4412,0,5,6,17,22,41,49,65,70,80)),            # J59
('metabiaugmented dodecahedron'                , 'metabiaugmented_dodecahedron()'          , (4412,0,5,6,10,17,20,22,26,76,80)),            # J60
(   'triaugmented dodecahedron'                , 'triaugmented_dodecahedron()'             , (4412,5,10,12,15,17,20,22,37,49)),             # J61
(             'metabidiminished icosahedron'   , 'metabidiminished_icosahedron()'          , (6621,1,2,4,6,7,8,9,14,19,21)),                # J62
(                'tridiminished icosahedron'   , 'tridiminished_icosahedron()'             , (6621,4,5,7,11,12,13,14,15,16,17,18,36,57)),   # J63
(      'augmented tridiminished icosahedron'   , 'augmented_tridiminished_icosahedron()'   , (6621,24,26,57)),                              # J64
(      'augmented truncated tetrahedron'       , 'truncatedtetrahedron(1)'                 , (13,3,30,42,47,51)),                           # J65
(      'augmented truncated cube'              , 'truncatedhexahedron(1)'                  , (1345,6,18,23,37,44,51,56,58)),                # J66
(    'biaugmented truncated cube'              , 'truncatedhexahedron(2)'                  , (1345,0,1,2,3,6,7,10,44,45,46,51,58)),         # J67
(      'augmented truncated dodecahedron'      , 'truncateddodecahedron(1)'                , (19,)),                                        # J68
('parabiaugmented truncated dodecahedron'      , 'truncateddodecahedron(-2)'               , (19,0,17,35)),                                 # J69
('metabiaugmented truncated dodecahedron'      , 'truncateddodecahedron(2)'                , (19,0,5,17,20,22,26)),                         # J70
(   'triaugmented truncated dodecahedron'      , 'truncateddodecahedron(3)'                , (19,0,2,5,17,20,22,26)),                       # J71
(               'gyrate rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("G...")', (19,)),                                        # J72
(         'parabigyrate rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("G..G")', (19,)),                                        # J73
(         'metabigyrate rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("GG..")', (19,)),                                        # J74
(            'trigyrate rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("GGG.")', (19,)),                                        # J75
(           'diminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("D...")', (19,)),                                        # J76
('paragyrate diminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("D..G")', (19,)),                                        # J77
('metagyrate diminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("DG..")', (19,)),                                        # J78
(  'bigyrate diminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("GDG.")', (19,)),                                        # J79
(     'parabidiminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("D..D")', (19,)),                                        # J80
(     'metabidiminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("DD..")', (19,)),                                        # J81
(  'gyrate bidiminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("GDD.")', (19,)),                                        # J82
(        'tridiminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("DDD.")', (19,)),                                        # J83
('snub disphenoid'                             , 'snub_disphenoid()'                       , (142,2,4,28,39,58,60,62,63,66,75)),            # J84
('snub square antiprism'                       , 'snub_square_antiprism()'                 , (418,0,1,6,11,16,18,22,23,26,29,35)),          # J85
(          'sphenocorona'                      , 'sphenocorona()'                          , (11,15,66,70,72,74)),                          # J86
('augmented sphenocorona'                      , 'augmented_sphenocorona()'                , (11,8,15,24,35,70,72,74)),                     # J87
(    'sphenomegacorona'                        , 'sphenomegacorona()'                      , (11,4,14,46,50,52,56,57,58)),                  # J88
('hebesphenomegacorona'                        , 'hebesphenomegacorona()'                  , (11,2,7,28,34,37,51,58,65,75,77,82)),          # J89
('disphenocingulum'                            , 'disphenocingulum()'                      , (11,0,3,6,10,15,18,24)),                       # J90
('bilunabirotunda'                             , 'bilunabirotunda()'                       , (10,2,3,4,8,21,24,32,33)),                     # J91
('triangular hebesphenorotunda'                , 'triangular_hebesphenorotunda()'          , (855,5,6,8,10,13,14,15,16,17,18,20,22,23,29)), # J92
('herschel enneahedron'                        , 'herschel_enneahedron()'                  , (0,3,8,31,52,53,99,103,110,112,113)),
('triakis truncated tetrahedron'               , 'triakistruncatedtetrahedron()'           , (190,8,10,11,12,16,17,18,23,32,39)),
('small stellated dodecahedron'                , 'small_stellated_dodecahedron()'          , (11404,)),
]

resolution = 1024
solids = {x[0] for x in data}
animate = False
frames = 120

for arg in argv:
    if '=' in arg:
        arg1, arg2 = arg.split('=')
        if arg1 == 'res': resolution = int(arg2)
        if arg1 == 'target': solids = {arg2}
        if arg1 == 'animate': animate = (arg2 == 'yes')
        if arg1 == 'frames': frames = int(arg2)

data_reduced = [x for x in data if x[0] in solids]

try: mkdir('images')
except: pass

"""
name, code, _ = data[-1]
for rotation in count(0):
    solidname = name.replace(' ', '_')
    filename = 'images/' + solidname + '_' + str(rotation)
    with open(filename + '.pov', 'w') as srcfile, open('head.pov', 'r') as head, open('tail.pov', 'r') as tail:
        srcfile.write(head.read())
        srcfile.write(code + ' #declare rotation=seed(%d);\n' % rotation)
        srcfile.write(tail.read())
    system('povray +I%s.pov +O%s.png +w%d +h%d +p' % (filename, filename, resolution, resolution))
    sleep(0.1)
    remove(filename + '.pov')
    remove(filename + '.png')
#"""
for (name, code, angles) in data_reduced:
    solidname = name.replace(' ', '_')
    try: mkdir('images/' + solidname)
    except: pass
    for rotation in angles:
        fileprefix = 'images/' + solidname + '/' + str(rotation)
        srcfilename = fileprefix + '.pov'
        imgfilename = fileprefix + '.png'
        with open(srcfilename, 'w') as srcfile, open('head.pov', 'r') as head, open('tail.pov', 'r') as tail:
            srcfile.write(head.read())
            srcfile.write(code + ' #declare rotation=seed(%d);\n' % rotation)
            srcfile.write(tail.read())
        system('povray +I%s +O%s +w%d +h%d +A -D' % (srcfilename, imgfilename, resolution, resolution))
        sleep(0.1)
        if animate:
            system('povray +I%s +O%s +w%d +h%d +kc +kff%d +A -D' % (srcfilename, fileprefix + '_.png', resolution, resolution, frames))
            sleep(0.1)
            system('ffmpeg -framerate 30 -i %s_%%0%dd.png -c:v libx264 -crf 0 -preset veryslow %s.mp4' % (fileprefix, len(str(frames)), fileprefix))
            for i in range(1, frames + 1): remove((fileprefix + '_%%0%dd.png' % len(str(frames))) % i)
        #remove(filename + '.pov')
#"""
print('done')

