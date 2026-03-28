#! /usr/bin/env python3

# For usage instructions, credits, and further details, see https://github.com/lucasaugustus/polyhedra/blob/main/README.md.

from os import mkdir, remove
from time import time, sleep
from itertools import count
from subprocess import run
from shutil import which
from sys import argv

starttime = time()

data = [
[                  'cube'                      , 'hexahedron()'                            , (7122,)],      # Platonic
[            'octahedron'                      , 'octahedron()'                            , (4193,)],      # Platonic
[           'tetrahedron'                      , 'tetrahedron()'                           , (1889,)],      # Platonic
[           'icosahedron'                      , 'icosahedron()'                           , (7719,)],      # Platonic
[          'dodecahedron'                      , 'dodecahedron()'                          , (4412,)],      # Platonic
[         'cuboctahedron'                      , 'cuboctahedron()'                         , (1941,)],      # Archimedian
[     'icosidodecahedron'                      , 'icosidodecahedron()'                     , (2241,)],      # Archimedian
[   'rhombicuboctahedron'                      , 'rhombicuboctahedron()'                   , (6124,)],      # Archimedian
['rhombicosidodecahedron'                      , 'rhombicosidodecahedron()'                , (8266,)],      # Archimedian
['snub cube'                                   , 'snubhexahedron(-1)'                      , (7152,)],      # Archimedian
['snub dodecahedron'                           , 'snubdodecahedron(1)'                     , (8154,)],      # Archimedian
['truncated              cube'                 , 'truncatedhexahedron(0)'                  , (1345,)],      # Archimedian
['truncated     cuboctahedron'                 , 'truncatedcuboctahedron()'                , (1156,)],      # Archimedian
['truncated      dodecahedron'                 , 'truncateddodecahedron(0)'                , (9374,)],      # Archimedian
['truncated       icosahedron'                 , 'truncatedicosahedron()'                  , (1666,)],      # Archimedian
['truncated icosidodecahedron'                 , 'truncatedicosidodecahedron()'            , (1422,)],      # Archimedian
['truncated        octahedron'                 , 'truncatedoctahedron()'                   , (7235,)],      # Archimedian
['truncated       tetrahedron'                 , 'truncatedtetrahedron(0)'                 , (8717,)],      # Archimedian
[    'rhombic    dodecahedron'                 , 'rhombicdodecahedron()'                   , (7154,)],      # Catalan
[    'rhombic triacontahedron'                 , 'rhombictriacontahedron()'                , (1237,)],      # Catalan
[  'triakis       tetrahedron'                 , 'triakistetrahedron()'                    , (7735,)],      # Catalan
[  'triakis        octahedron'                 , 'triakisoctahedron()'                     , (5354,)],      # Catalan
[ 'tetrakis        hexahedron'                 , 'tetrakishexahedron()'                    , (1788,)],      # Catalan
[  'triakis       icosahedron'                 , 'triakisicosahedron()'                    , (1044,)],      # Catalan
[ 'pentakis      dodecahedron'                 , 'pentakisdodecahedron()'                  , (6100,)],      # Catalan
['deltoidal  icositetrahedron'                 , 'deltoidalicositetrahedron()'             , (5643,)],      # Catalan
['disdyakis      dodecahedron'                 , 'disdyakisdodecahedron()'                 , (1440,)],      # Catalan
['deltoidal   hexecontahedron'                 , 'deltoidalhexecontahedron()'              , (1026,)],      # Catalan
['disdyakis   triacontahedron'                 , 'disdyakistriacontahedron()'              , (1556,)],      # Catalan
['pentagonal icositetrahedron'                 , 'pentagonalicositetrahedron(-1)'          , (7771,)],      # Catalan
['pentagonal  hexecontahedron'                 , 'pentagonalhexecontahedron(-1)'           , (1046,)],      # Catalan
[    'triangular     prism'                    , 'rprism(3)'                               , (6620,)],      # Infinite family
[        'square     prism'                    , 'rprism(4)'                               , (6620,)],      # Infinite family
[    'pentagonal     prism'                    , 'rprism(5)'                               , (6620,)],      # Infinite family
[     'hexagonal     prism'                    , 'rprism(6)'                               , (6620,)],      # Infinite family
[    'heptagonal     prism'                    , 'rprism(7)'                               , (6620,)],      # Infinite family
[     'octagonal     prism'                    , 'rprism(8)'                               , (6620,)],      # Infinite family
[     'nonagonal     prism'                    , 'rprism(9)'                               , (6620,)],      # Infinite family
[     'decagonal     prism'                    , 'rprism(10)'                              , (6620,)],      # Infinite family
[       'digonal antiprism'                    , 'antiprism(2)'                            , (6620,)],      # Infinite family.  Also tetrahedron.
[    'triangular antiprism'                    , 'antiprism(3)'                            , (6620,)],      # Infinite family.  Also octahedron.
[        'square antiprism'                    , 'antiprism(4)'                            , (6620,)],      # Infinite family
[    'pentagonal antiprism'                    , 'antiprism(5)'                            , (6620,)],      # Infinite family
[     'hexagonal antiprism'                    , 'antiprism(6)'                            , (6620,)],      # Infinite family
[    'heptagonal antiprism'                    , 'antiprism(7)'                            , (6620,)],      # Infinite family
[     'octagonal antiprism'                    , 'antiprism(8)'                            , (6620,)],      # Infinite family
[     'nonagonal antiprism'                    , 'antiprism(9)'                            , (6620,)],      # Infinite family
[     'decagonal antiprism'                    , 'antiprism(10)'                           , (6620,)],      # Infinite family
['heptadecagonal antiprism'                    , 'antiprism(17)'                           , (6620,)],      # Infinite family
[    'triangular bipyramid'                    , 'bipyramid(3)'                            , (6620,)],      # Infinite family.  Also J12.
[        'square bipyramid'                    , 'bipyramid(4)'                            , (6620,)],      # Infinite family.  Also octahedron.
[    'pentagonal bipyramid'                    , 'bipyramid(5)'                            , (6620,)],      # Infinite family.  Also J13.
[     'hexagonal bipyramid'                    , 'bipyramid(6)'                            , (6620,)],      # Infinite family
[    'heptagonal bipyramid'                    , 'bipyramid(7)'                            , (6620,)],      # Infinite family
[     'octagonal bipyramid'                    , 'bipyramid(8)'                            , (6620,)],      # Infinite family
[     'nonagonal bipyramid'                    , 'bipyramid(9)'                            , (6620,)],      # Infinite family
[     'decagonal bipyramid'                    , 'bipyramid(10)'                           , (6620,)],      # Infinite family
[   'digonal trapezohedron'                    , 'trapezohedron(2)'                        , (6620,)],      # Infinite family.  Also tetrahedron.
['triangular trapezohedron'                    , 'trapezohedron(3)'                        , (6620,)],      # Infinite family.  Also cube.
[    'square trapezohedron'                    , 'trapezohedron(4)'                        , (6620,)],      # Infinite family
['pentagonal trapezohedron'                    , 'trapezohedron(5)'                        , (6620,)],      # Infinite family
[ 'hexagonal trapezohedron'                    , 'trapezohedron(6)'                        , (6620,)],      # Infinite family
['heptagonal trapezohedron'                    , 'trapezohedron(7)'                        , (6620,)],      # Infinite family
[ 'octagonal trapezohedron'                    , 'trapezohedron(8)'                        , (6620,)],      # Infinite family
[ 'nonagonal trapezohedron'                    , 'trapezohedron(9)'                        , (6620,)],      # Infinite family
[ 'decagonal trapezohedron'                    , 'trapezohedron(10)'                       , (6620,)],      # Infinite family
[    'square pyramid'                          , 'square_pyramid()'                        , (84,75)],                  # J1
['pentagonal pyramid'                          , 'pentagonal_pyramid()'                    , (11,129)],                 # J2
['triangular cupola'                           , 'triangular_cupola()'                     , (11,91,191)],              # J3
[    'square cupola'                           , 'square_cupola()'                         , (19,143,202)],             # J4
['pentagonal cupola'                           , 'pentagonal_cupola()'                     , (19,)],                    # J5
['pentagonal rotunda'                          , 'pentagonal_rotunda()'                    , (4,31,131)],               # J6
[    'elongated triangular   pyramid'          , 'elongated_pyramid(3)'                    , (444,4,13)],               # J7
[    'elongated     square   pyramid'          , 'elongated_pyramid(4)'                    , (444,4,13)],               # J8
[    'elongated pentagonal   pyramid'          , 'elongated_pyramid(5)'                    , (444,4,13)],               # J9
['gyroelongated     square   pyramid'          , 'gyroelongated_square_pyramid()'          , (6621,0,7,38,95)],         # J10
['gyroelongated pentagonal   pyramid'          , 'gyroelongated_pentagonal_pyramid()'      , (6621,4,30,36,63)],        # J11
[              'triangular bipyramid'          , 'dipyramid(3)'                            , (654,6,23)],               # J12
[              'pentagonal bipyramid'          , 'dipyramid(5)'                            , (654,6,23)],               # J13
[    'elongated triangular bipyramid'          , 'elongated_dipyramid(3)'                  , (654,13,27)],              # J14
[    'elongated     square bipyramid'          , 'elongated_dipyramid(4)'                  , (654,13,27)],              # J15
[    'elongated pentagonal bipyramid'          , 'elongated_dipyramid(5)'                  , (654,13,27)],              # J16
['gyroelongated     square bipyramid'          , 'gyroelongated_square_dipyramid()'        , (6621,13,38,46,50)],       # J17
[    'elongated triangular cupola'             , 'elongated_triangular_cupola()'           , (112358,0,88,102,114)],    # J18
[    'elongated     square cupola'             , 'elongated_square_cupola()'               , (333,1,3,10)],             # J19
[    'elongated pentagonal cupola'             , 'elongated_pentagonal_cupola()'           , (333,6,18,48,49,58)],      # J20
[    'elongated pentagonal rotunda'            , 'elongated_pentagonal_rotunda()'          , (4,1,3,5,34,36,93)],       # J21
['gyroelongated triangular cupola'             , 'gyroelongated_triangular_cupola()'       , (112358,0,38,83)],         # J22
['gyroelongated     square cupola'             , 'gyroelongated_square_cupola()'           , (333,3,8,10,48,55)],       # J23
['gyroelongated pentagonal cupola'             , 'gyroelongated_pentagonal_cupola()'       , (333,6,11,13,18,20,41)],   # J24
['gyroelongated pentagonal rotunda'            , 'gyroelongated_pentagonal_rotunda()'      , (4,3,36)],                 # J25
['gyrobifastigium'                             , 'gyrobifastigium()'                       , (112358,1,7,31)],          # J26
[          'triangular orthobicupola'          , 'triangular_orthobicupola()'              , (112358,1,5,8,11)],        # J27
[              'square orthobicupola'          , 'square_orthobicupola()'                  , (333,3,6,12,17,28)],       # J28
[              'square  gyrobicupola'          , 'square_gyrobicupola()'                   , (333,1,2,3,5,10)],         # J29
[          'pentagonal orthobicupola'          , 'pentagonal_orthobicupola()'              , (333,11,18)],              # J30
[          'pentagonal  gyrobicupola'          , 'pentagonal_gyrobicupola()'               , (333,11,13,18)],           # J31
[          'pentagonal orthocupolarotunda'     , 'pentagonal_orthocupolarotunda()'         , (4,2,9)],                  # J32
[          'pentagonal  gyrocupolarotunda'     , 'pentagonal_gyrocupolarotunda()'          , (4,2,9)],                  # J33
[          'pentagonal orthobirotunda'         , 'pentagonal_orthobirotunda()'             , (4,2,9)],                  # J34
['elongated triangular orthobicupola'          , 'elongated_triangular_orthobicupola()'    , (112358,0,6,8,10,14)],     # J35
['elongated triangular  gyrobicupola'          , 'elongated_triangular_gyrobicupola()'     , (112358,0,4,6,7,8,10,14)], # J36
['elongated     square  gyrobicupola'          , 'elongated_square_gyrobicupola()'         , (333,3,4,5,10)],           # J37
['elongated pentagonal orthobicupola'          , 'elongated_pentagonal_orthobicupola()'    , (333,6,38,45,81)],         # J38
['elongated pentagonal  gyrobicupola'          , 'elongated_pentagonal_gyrobicupola()'     , (333,6,38,45,81)],         # J39
['elongated pentagonal orthocupolarotunda'     , 'icosidodecahedron_mod(41)'               , (4,2,9,34,36,41,46,48)],   # J40
['elongated pentagonal  gyrocupolarotunda'     , 'icosidodecahedron_mod(40)'               , (4,2,9,34,36,41,46,48)],   # J41
['elongated pentagonal orthobirotunda'         , 'elongated_pentagonal_orthobirotunda()'   , (4,2,9,34,36,41,46,48)],   # J42
['elongated pentagonal  gyrobirotunda'         , 'elongated_pentagonal_gyrobirotunda()'    , (4,2,9,34,36,41,46,48)],   # J43
['gyroelongated triangular  bicupola'          , 'gyroelongated_triangular_bicupola()'     , (112358,0,6,38,45,46,333)],# J44
['gyroelongated     square  bicupola'          , 'gyroelongated_square_bicupola()'         , (333,2,3,4,10,45,48,54)],  # J45
['gyroelongated pentagonal  bicupola'          , 'gyroelongated_pentagonal_bicupola()'     , (333,0,6,38,45,46)],       # J46
['gyroelongated pentagonal  cupolarotunda'     , 'icosidodecahedron_mod(47)'               , (4,2,9,29,34,48)],         # J47
['gyroelongated pentagonal  birotunda'         , 'gyroelongated_pentagonal_birotunda()'    , (4,2,9,29,34,48)],         # J48
[      'augmented triangular prism'            , 'augmented_triangular_prism()'            , (88,29)],                  # J49
[    'biaugmented triangular prism'            , 'biaugmented_triangular_prism()'          , (88,29)],                  # J50
[   'triaugmented triangular prism'            , 'triaugmented_triangular_prism()'         , (88,29)],                  # J51
[      'augmented pentagonal prism'            , 'augmented_pentagonal_prism()'            , (5555,24,26,29,30,36,43)], # J52
[    'biaugmented pentagonal prism'            , 'biaugmented_pentagonal_prism()'          , (5555,24,26,29,30,36,43)], # J53
[      'augmented  hexagonal prism'            , 'augmented_hexagonal_prism()'             , (5555,29)],                # J54
['parabiaugmented  hexagonal prism'            , 'parabiaugmented_hexagonal_prism()'       , (5555,29)],                # J55
['metabiaugmented  hexagonal prism'            , 'metabiaugmented_hexagonal_prism()'       , (5555,29)],                # J56
[   'triaugmented  hexagonal prism'            , 'triaugmented_hexagonal_prism()'          , (5555,29)],                # J57
[      'augmented dodecahedron'                , 'augmented_dodecahedron()'                , (4412,5,17,22,80)],        # J58
['parabiaugmented dodecahedron'                , 'parabiaugmented_dodecahedron()'          , (4412,5,17,22,80)],        # J59
['metabiaugmented dodecahedron'                , 'metabiaugmented_dodecahedron()'          , (4412,5,17,22,80)],        # J60
[   'triaugmented dodecahedron'                , 'triaugmented_dodecahedron()'             , (4412,5,17,22,80)],        # J61
[             'metabidiminished icosahedron'   , 'metabidiminished_icosahedron()'          , (6621,4,6,8,14,15,36)],    # J62
[                'tridiminished icosahedron'   , 'tridiminished_icosahedron()'             , (6621,4,6,8,14,15,36)],    # J63
[      'augmented tridiminished icosahedron'   , 'augmented_tridiminished_icosahedron()'   , (6621,24,26,57)],          # J64
[      'augmented    truncated  tetrahedron'   , 'truncatedtetrahedron(1)'                 , (13,3,30,42,47,51)],       # J65
[      'augmented    truncated         cube'   , 'truncatedhexahedron(1)'                  , (1345,6,10,51,58)],        # J66
[    'biaugmented    truncated         cube'   , 'truncatedhexahedron(2)'                  , (1345,6,10,51,58)],        # J67
[      'augmented    truncated dodecahedron'   , 'truncateddodecahedron(1)'                , (19,)],                    # J68
['parabiaugmented    truncated dodecahedron'   , 'truncateddodecahedron(-2)'               , (19,0,17,35)],             # J69
['metabiaugmented    truncated dodecahedron'   , 'truncateddodecahedron(2)'                , (19,0,5,17,20,22,26)],     # J70
[   'triaugmented    truncated dodecahedron'   , 'truncateddodecahedron(3)'                , (19,0,2,5,17,20,22,26)],   # J71
[               'gyrate rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("G...")', (19,)],                    # J72
[         'parabigyrate rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("G..G")', (19,)],                    # J73
[         'metabigyrate rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("GG..")', (19,)],                    # J74
[            'trigyrate rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("GGG.")', (19,)],                    # J75
[           'diminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("D...")', (19,)],                    # J76
['paragyrate diminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("D..G")', (19,)],                    # J77
['metagyrate diminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("DG..")', (19,)],                    # J78
[  'bigyrate diminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("GDG.")', (19,)],                    # J79
[     'parabidiminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("D..D")', (19,)],                    # J80
[     'metabidiminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("DD..")', (19,)],                    # J81
[  'gyrate bidiminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("GDD.")', (19,)],                    # J82
[        'tridiminished rhombicosidodecahedron', 'mogrified_rhombicosidodecahedron("DDD.")', (19,)],                    # J83
['snub disphenoid'                             , 'snub_disphenoid()'                       , (142,4,63,66,75)],         # J84
['snub square antiprism'                       , 'snub_square_antiprism()'                 , (418,6,11,18,35)],         # J85
[               'sphenocorona'                 , 'sphenocorona()'                          , (11,35,70,72)],            # J86
[     'augmented sphenocorona'                 , 'augmented_sphenocorona()'                , (11,35,70,72)],            # J87
[               'sphenomegacorona'             , 'sphenomegacorona()'                      , (11,4,14,57,58)],          # J88
[           'hebesphenomegacorona'             , 'hebesphenomegacorona()'                  , (11,2,37,51,82)],          # J89
['disphenocingulum'                            , 'disphenocingulum()'                      , (11,0,6,15)],              # J90
['bilunabirotunda'                             , 'bilunabirotunda()'                       , (10,2,4)],                 # J91
['triangular hebesphenorotunda'                , 'triangular_hebesphenorotunda()'          , (855,13,14,22,29)],        # J92
['herschel enneahedron'                        , 'herschel_enneahedron()'                  , (0,3,31,103,112)],
['triakis truncated tetrahedron'               , 'triakistruncatedtetrahedron()'           , (190,8,10,18,32)],
]

atad = [
['compound of five tetrahedra'  , '5_tets.pov'             , (22113,)],
['great            icosahedron' , 'great_ico.pov'          , (31234,)],
['great           dodecahedron' , 'great_dod.pov'          , (11404,)],
['great stellated dodecahedron' , 'great_stel_dod.pov'     , (7409,)],
['small stellated dodecahedron' , 'small_stel_dod.pov'     , (11404,)],
[      'stellated   octahedron' , 'stel_octa.pov'          , (1,2,4,11,17)],
['toroidal octahedron chain'    , 'toroidal_octachain.pov' , (1,)],
['schoenhardt'                  , 'schoenhardt.pov'        , (0,1,6,7,13)],
['truncated triakis tetrahedron', 'trunc_triakis_tet.pov'  , (0,)],
['csaszar'                      , 'csaszar.pov'            , (13,)],
['rhombic icosahedron'          , 'rhombic_icosahedron.pov', (3,12,13,14,15)],
]

for i in range(len(data)):
    data[i][0] = ' '.join(data[i][0].split())   # Replace all runs of spaces with single spaces.
    data[i][1] = '#macro This_shape_will_be_drawn()\n' + data[i][1] + '\n#end\n'
    data[i].append('tail.pov')

for (name, file, angles) in atad:
    name = ' '.join(name.split())               # Replace all runs of spaces with single spaces.
    data.append([name, '', angles, file])

resolution = '1024'
solids = {x[0] for x in data}
frames = '120'
keepframes = False
filetypes = ['png']
angle_override = []
threads = ''

for arg in argv:
    if '=' in arg:
        arg1, arg2 = arg.split('=')
        if arg1 == 'res': resolution = arg2
        if arg1 == 'target': solids = set(' '.join(x.split()) for x in arg2.split(','))
        if arg1 == 'frames': frames = arg2
        if arg1 == 'filetypes': filetypes = [x.lower() for x in arg2.split(',')]
        if arg1 == 'keepframes': keepframes = (arg2 == 'yes')
        if arg1 == 'angles': angle_override = list(map(int, arg2.split(',')))
        if arg1 == 'threads': threads = arg2

data_reduced = [x for x in data if x[0] in solids]

try: mkdir('images')
except: pass

for (name, code, angles, file) in data_reduced:
    solidname = name.replace(' ', '_')
    try: mkdir('images/' + solidname)
    except: pass
    if angle_override: angles = angle_override
    for rotation in angles:
        fileprefix = 'images/' + solidname + '/' + str(rotation)
        srcfilename = fileprefix + '.pov'
        imgfilename = fileprefix + '.png'
        with open(srcfilename, 'w') as srcfile, open('povcode/' + file, 'r') as tail:
            srcfile.write(code + '#declare rotation=seed(%d);\n' % rotation)
            srcfile.write('#declare notwireframe=1;\n')
            srcfile.write('#declare withreflection=0;\n')
            srcfile.write('#ifndef (flashiness)\n  #declare flashiness=1;\n#end\n')
            srcfile.write(tail.read())
        
        if 'png' in filetypes:
            command = ['povray',
                       '+I' + srcfilename, '+O' + imgfilename,
                       '+w' + resolution,  '+h' + resolution,
                       '+A', '-D'       # +A turns on antialiasing; -D suppresses the preview window.
                       ]
            if threads: command += ['+WT', threads]      # By default, use POV-Ray's default of maximum parallelism.
            run(command, check=True)
        
        if 'svg' in filetypes:
            if file == 'tail.pov':
                command = ['python3', 'pov_to_svg.py',
                           'povcode/tail.pov',
                           fileprefix + '.svg',
                           '--shape', code.split('\n')[1],
                           '--seed', str(rotation),
                           '--tint-strength',    '1.5',
                           '--shade-strength',   '1.8',
                           '--brightness',       '1.5',
                           '--face-alpha-scale', '1.3',
                           '--vertex-scale',     '0.0',
                           '--edge-scale',       '0.6',
                           ]
                run(command, check=True)
            else:
                if True:
                    with open(fileprefix + "_error.svg", "w") as outfile:
                        outfile.write('<svg width="600" height="42" xmlns="http://www.w3.org/2000/svg">')
                        outfile.write('<rect width="100%" height="100%" fill="white"/>')
                        outfile.write('<text x="0" y="30" font-family="serif" font-size="24">')
                        outfile.write('SVGs are not available yet for this polyhedron.</text>')
                        outfile.write('</svg>')
                else:
                    command = ['python3', 'pov__to__svg.py',
                               'povcode/' + file,
                               '-o', fileprefix + '.svg',
                               '--rotation-seed', str(rotation),
                               '--cylinder-steps', '5',
                               '--sphere-steps', '2',
                               ]
                    print("\n\n\n")
                    print(command)
                    run(command, check=True)
        
        if 'mp4' in filetypes:
            command = ['povray',
                       '+I' + srcfilename, '+O' + fileprefix + '_.png',
                       '+w' + resolution,  '+h' + resolution,
                       '+kc', '+kff' + frames,    # Cyclic animation, with number of frames
                       'Declare=flashiness=0.25',
                       '+A', '-D'                 # +A turns on antialiasing; -D suppresses the preview window.
                       ]
            if threads: command += ['+WT', threads]      # By default, use POV-Ray's default of maximum parallelism.
            run(command, check=True)
            if which('ffmpeg') is None:
                print('FFmpeg was not available, so the animation was left as a bunch of individual frames.')
            else:
                command = ['ffmpeg',
                           '-y',                                              # Overwrite
                           '-framerate', '30',
                           '-i', fileprefix + '_%%0%dd.png' % len(frames),    # Input filenames
                           '-c:v', 'libx264',                                 # Codec
                           '-crf', '10', '-preset', 'veryslow',               # Quality settings
                           fileprefix + '.mp4'                                # Output filename
                           ]
                run(command, check=True)
                if not keepframes:
                    for i in range(1, int(frames) + 1):
                        remove((fileprefix + '_%%0%dd.png' % len(frames)) % i)
        
        if 'pov' not in filetypes: remove(srcfilename)
        #sleep(0.1)
    
    if 'stl' in filetypes:
        if file == 'tail.pov':
            command = ['python3', 'pov_to_stl.py',
                       'povcode/tail.pov',
                       '--call', code.split('\n')[1],
                       '--output', 'images/' + solidname + '/' + solidname + '.stl'
                       ]
        else:
            command = ['python3', 'pov_faces_to_stl.py',
                       'povcode/' + file,
                       '-o', 'images/' + solidname + '/' + solidname + '.stl'
                       ]
        run(command, check=True)

print('\nDone.')
print('Wall time: %d seconds.' % int(time() - starttime))
