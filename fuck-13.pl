#!/usr/bin/perl

$this->{plugins} = {
  'generator' => []
};
$this->{max_span} = '50';
$this->{min_size} = '2x2';
$this->{max_room_size} = '7x7';
$this->{fname} = '/home/jettero/code/perl/mapgen/test.xml';
$this->{closed_room_corridor_door_percent} = {
  'stuck' => '10',
  'locked' => '30',
  'door' => '5',
  'secret' => '95'
};
$this->{t_cb} = sub { "DUMMY" };
$this->{generator} = 'Games::RolePlay::MapGen::Generator::Basic';
$this->{num_rooms} = '2d4';
$this->{open_corridor_corridor_door_percent} = {
  'stuck' => '25',
  'locked' => '50',
  'door' => '1',
  'secret' => '10'
};
$this->{tile_size} = '10';
$this->{open_room_corridor_door_percent} = {
  'stuck' => '25',
  'locked' => '50',
  'door' => '95',
  'secret' => '2'
};
$this->{cell_size} = '32x32';
$this->{closed_corridor_corridor_door_percent} = {
  'stuck' => '10',
  'locked' => '30',
  'door' => '1',
  'secret' => '95'
};
$this->{y_size} = '13';
$this->{sparseness} = '10';
$this->{remove_deadend_percent} = '60';
$this->{min_room_size} = '2x2';
$this->{x_size} = '20';
$this->{same_way_percent} = '90';
$this->{_the_groups} = [
  bless( {
    'extents' => [
      3,
      0,
      7,
      4
    ],
    'loc' => [
      [
        '3',
        '0'
      ]
    ],
    'name' => 'Room #1',
    'loc_size' => '(5, 2) 5x5',
    'type' => 'room',
    'size' => [
      [
        5,
        5
      ]
    ]
  }, 'Games::RolePlay::MapGen::_group' ),
  bless( {
    'extents' => [
      8,
      7,
      13,
      11
    ],
    'loc' => [
      [
        '8',
        '7'
      ]
    ],
    'name' => 'Room #2',
    'loc_size' => '(10, 9) 6x5',
    'type' => 'room',
    'size' => [
      [
        6,
        5
      ]
    ]
  }, 'Games::RolePlay::MapGen::_group' ),
  bless( {
    'extents' => [
      16,
      2,
      18,
      4
    ],
    'loc' => [
      [
        '16',
        '2'
      ]
    ],
    'name' => 'Room #3',
    'loc_size' => '(17, 3) 3x3',
    'type' => 'room',
    'size' => [
      [
        3,
        3
      ]
    ]
  }, 'Games::RolePlay::MapGen::_group' ),
  bless( {
    'extents' => [
      2,
      7,
      5,
      10
    ],
    'loc' => [
      [
        '2',
        '7'
      ]
    ],
    'name' => 'Room #4',
    'loc_size' => '(3, 8) 4x4',
    'type' => 'room',
    'size' => [
      [
        4,
        4
      ]
    ]
  }, 'Games::RolePlay::MapGen::_group' ),
  bless( {
    'extents' => [
      9,
      0,
      13,
      3
    ],
    'loc' => [
      [
        '9',
        '0'
      ]
    ],
    'name' => 'Room #5',
    'loc_size' => '(11, 1) 5x4',
    'type' => 'room',
    'size' => [
      [
        5,
        4
      ]
    ]
  }, 'Games::RolePlay::MapGen::_group' )
];
$this->{exporter} = 'Games::RolePlay::MapGen::Exporter::BasicImage';
$this->{objs} = {
  'exporter' => bless( {
    'o' => {
      'max_room_size' => '7x7',
      'min_size' => '2x2',
      'max_span' => '50',
      'fname' => '/home/jettero/code/perl/mapgen/test.xml',
      't_cb' => $this->{t_cb},
      'closed_room_corridor_door_percent' => $this->{closed_room_corridor_door_percent},
      'generator' => 'Games::RolePlay::MapGen::Generator::Basic',
      'num_rooms' => '2d4',
      'open_corridor_corridor_door_percent' => $this->{open_corridor_corridor_door_percent},
      'tile_size' => '10',
      'cell_size' => '32x32',
      'open_room_corridor_door_percent' => $this->{open_room_corridor_door_percent},
      'closed_corridor_corridor_door_percent' => $this->{closed_corridor_corridor_door_percent},
      'sparseness' => '10',
      'y_size' => '13',
      'remove_deadend_percent' => '60',
      'min_room_size' => '2x2',
      'x_size' => '20',
      'same_way_percent' => '90',
      '_the_groups' => $this->{_the_groups},
      'exporter' => 'Games::RolePlay::MapGen::Exporter::BasicImage',
      '_the_map' => bless( [
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '2'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '3',
            'y' => '0',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '4',
            'y' => '0',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '5',
            'y' => '0',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '6',
            'y' => '0',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '7',
            'y' => '0',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '8'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '9',
            'y' => '0',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '10',
            'y' => '0',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '11',
            'y' => '0',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '12',
            'y' => '0',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '13',
            'y' => '0',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '0',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '1',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '1',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '1',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '2'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '3',
            'y' => '1',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '4',
            'y' => '1',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '5',
            'y' => '1',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '6',
            'y' => '1',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '7',
            'y' => '1',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => bless( {
                'open' => 0,
                'stuck' => 1,
                'locked' => 0,
                'open_dir' => {
                  'minor' => 's',
                  'major' => 'e'
                },
                'secret' => 0
              }, 'Games::RolePlay::MapGen::_door' ),
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '1',
            'od' => {
              'w' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[1][7]{'od'}{'e'},
              'e' => bless( {
                'open' => 0,
                'stuck' => 0,
                'locked' => 1,
                'open_dir' => {
                  'minor' => 'n',
                  'major' => 'e'
                },
                'secret' => 0
              }, 'Games::RolePlay::MapGen::_door' ),
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '8'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '9',
            'y' => 1,
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[1][8]{'od'}{'e'},
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '10',
            'y' => 1,
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '11',
            'y' => 1,
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '12',
            'y' => 1,
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '13',
            'y' => 1,
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 1,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 1,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 1,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 1,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 1,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 1,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '2',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '2',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '2',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '2'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '3',
            'y' => '2',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '4',
            'y' => '2',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '5',
            'y' => '2',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '6',
            'y' => '2',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '7',
            'y' => '2',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '2',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '8'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '9',
            'y' => '2',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '10',
            'y' => '2',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '11',
            'y' => '2',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '12',
            'y' => '2',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '13',
            'y' => '2',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '2',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '2',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '16',
            'y' => '2',
            'group' => $this->{_the_groups}[2],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '17',
            'y' => '2',
            'group' => $this->{_the_groups}[2],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '18',
            'y' => '2',
            'group' => $this->{_the_groups}[2],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '2',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '3',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '3',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '3',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '2'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '3',
            'y' => '3',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '4',
            'y' => '3',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '5',
            'y' => '3',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '6',
            'y' => '3',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '7',
            'y' => '3',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '3',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '8'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '9',
            'y' => '3',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '10',
            'y' => '3',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '11',
            'y' => '3',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '12',
            'y' => '3',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '13',
            'y' => '3',
            'group' => $this->{_the_groups}[4],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '3',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '3',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '16',
            'y' => '3',
            'group' => $this->{_the_groups}[2],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '17',
            'y' => '3',
            'group' => $this->{_the_groups}[2],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '18',
            'y' => '3',
            'group' => $this->{_the_groups}[2],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '3',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '4',
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '4',
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '4',
            'od' => {
              'w' => 1,
              'e' => bless( {
                'open' => 0,
                'stuck' => 0,
                'locked' => 0,
                'open_dir' => {
                  'minor' => 's',
                  'major' => 'e'
                },
                'secret' => 1
              }, 'Games::RolePlay::MapGen::_door' ),
              'n' => 0,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '2'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '3',
            'y' => '4',
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[4][2]{'od'}{'e'},
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '4',
            'y' => 4,
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '5',
            'y' => 4,
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '6',
            'y' => 4,
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => bless( {
                'open' => 0,
                'stuck' => 1,
                'locked' => 0,
                'open_dir' => {
                  'minor' => 'w',
                  'major' => 's'
                },
                'secret' => 0
              }, 'Games::RolePlay::MapGen::_door' )
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '7',
            'y' => 4,
            'group' => $this->{_the_groups}[0],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 4,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '8'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 4,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '9'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 4,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '10'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 4,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '11'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 4,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '12'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 4,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '13'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 4,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 4,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '16',
            'y' => 4,
            'group' => $this->{_the_groups}[2],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => bless( {
                'open' => 0,
                'stuck' => 0,
                'locked' => 0,
                'open_dir' => {
                  'minor' => 'w',
                  'major' => 'n'
                },
                'secret' => 0
              }, 'Games::RolePlay::MapGen::_door' )
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '17',
            'y' => 4,
            'group' => $this->{_the_groups}[2],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '18',
            'y' => 4,
            'group' => $this->{_the_groups}[2],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 4,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '5',
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '5',
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '5',
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '2'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '5',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '3'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '5',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '4'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '5',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '5'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '5',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[4][6]{'od'}{'s'},
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '6'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '7'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '8'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '9'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '10'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '11'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '12'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '13'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[4][16]{'od'}{'s'},
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 5,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => bless( {
                'open' => 0,
                'stuck' => 0,
                'locked' => 0,
                'open_dir' => {
                  'minor' => 'e',
                  'major' => 's'
                },
                'secret' => 1
              }, 'Games::RolePlay::MapGen::_door' )
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '2'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '3'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '4'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '5'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '6'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '7'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '8'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '9'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '10'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '11'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '12'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '13'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '6',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '7',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '7',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '2',
            'y' => '7',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[6][2]{'od'}{'s'},
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '3',
            'y' => 7,
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '4',
            'y' => 7,
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '5',
            'y' => 7,
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 7,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '6'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 7,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '7'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '8',
            'y' => 7,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '9',
            'y' => 7,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '10',
            'y' => 7,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '11',
            'y' => 7,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '12',
            'y' => 7,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '13',
            'y' => 7,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 0,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 7,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 7,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 7,
            'od' => {
              'w' => 0,
              'e' => bless( {
                'open' => 0,
                'stuck' => 0,
                'locked' => 0,
                'open_dir' => {
                  'minor' => 'n',
                  'major' => 'w'
                },
                'secret' => 1
              }, 'Games::RolePlay::MapGen::_door' ),
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 7,
            'od' => {
              'w' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[7][16]{'od'}{'e'},
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 7,
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 0,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 7,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '2',
            'y' => '8',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '3',
            'y' => '8',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '4',
            'y' => '8',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '5',
            'y' => '8',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '6'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '7'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '8',
            'y' => '8',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '9',
            'y' => '8',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '10',
            'y' => '8',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '11',
            'y' => '8',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '12',
            'y' => '8',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '13',
            'y' => '8',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '8',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '2',
            'y' => '9',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '3',
            'y' => '9',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '4',
            'y' => '9',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '5',
            'y' => '9',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '6'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '7'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '8',
            'y' => '9',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '9',
            'y' => '9',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '10',
            'y' => '9',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '11',
            'y' => '9',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '12',
            'y' => '9',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '13',
            'y' => '9',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => bless( {
                'open' => 0,
                'stuck' => 0,
                'locked' => 1,
                'open_dir' => {
                  'minor' => 'w',
                  'major' => 's'
                },
                'secret' => 0
              }, 'Games::RolePlay::MapGen::_door' )
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '9',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '10',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '10',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '2',
            'y' => '10',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => bless( {
                'open' => 0,
                'stuck' => 1,
                'locked' => 1,
                'open_dir' => {
                  'minor' => 'w',
                  'major' => 'n'
                },
                'secret' => 0
              }, 'Games::RolePlay::MapGen::_door' )
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '3',
            'y' => '10',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '4',
            'y' => '10',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '5',
            'y' => '10',
            'group' => $this->{_the_groups}[3],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '10',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '6'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '10',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '7'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '8',
            'y' => '10',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '9',
            'y' => '10',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '10',
            'y' => '10',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '11',
            'y' => '10',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '12',
            'y' => '10',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '13',
            'y' => '10',
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '10',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '10',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '10',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '10',
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 0,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '10',
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[9][18]{'od'}{'s'},
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 10,
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 0,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '11',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '11',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '11',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[10][2]{'od'}{'s'},
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '2'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '3'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '4'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '5'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '6'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '7'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '8',
            'y' => 11,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '9',
            'y' => 11,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '10',
            'y' => 11,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '11',
            'y' => 11,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => bless( {
                'open' => 0,
                'stuck' => 0,
                'locked' => 0,
                'open_dir' => {
                  'minor' => 'w',
                  'major' => 'n'
                },
                'secret' => 1
              }, 'Games::RolePlay::MapGen::_door' )
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '12',
            'y' => 11,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'v' => 0,
            'x' => '13',
            'y' => 11,
            'group' => $this->{_the_groups}[1],
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 0
            },
            'type' => 'room'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 0,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 11,
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 1
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        [
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '12',
            'od' => {
              'w' => 0,
              'e' => 0,
              'n' => 0,
              's' => 0
            },
            'v' => 0,
            'x' => '0'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '12',
            'od' => {
              'w' => 0,
              'e' => bless( {
                'open' => 0,
                'stuck' => 0,
                'locked' => 0,
                'open_dir' => {
                  'minor' => 's',
                  'major' => 'w'
                },
                'secret' => 1
              }, 'Games::RolePlay::MapGen::_door' ),
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '1'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => '12',
            'od' => {
              'w' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[12][1]{'od'}{'e'},
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '2'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '3'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '4'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '5'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '6'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '7'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '8'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '9'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '10'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[11][11]{'od'}{'s'},
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '11'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '12'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '13'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '14'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '15'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => bless( {
                'open' => 0,
                'stuck' => 0,
                'locked' => 1,
                'open_dir' => {
                  'minor' => 's',
                  'major' => 'e'
                },
                'secret' => 0
              }, 'Games::RolePlay::MapGen::_door' ),
              'n' => 0,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '16'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => $this->{objs}{'exporter'}{'o'}{'_the_map'}[12][16]{'od'}{'e'},
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '17'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 1,
              'n' => 1,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '18'
          }, 'Games::RolePlay::MapGen::_tile' ),
          bless( {
            '__c' => 'Games::RolePlay::MapGen::_tile',
            'y' => 12,
            'od' => {
              'w' => 1,
              'e' => 0,
              'n' => 1,
              's' => 0
            },
            'type' => 'corridor',
            'v' => 0,
            'x' => '19'
          }, 'Games::RolePlay::MapGen::_tile' )
        ],
        []
      ], 'Games::RolePlay::MapGen::_interconnected_map' ),
      'bounding_box' => '20x13',
      'same_node_percent' => '30',
      'xml_input_file' => '/home/jettero/code/perl/mapgen/test.xml',
      'max_size' => '9x9'
    }
  }, 'Games::RolePlay::MapGen::Exporter::BasicImage' ),
  'generator' => bless( {
    'plugins' => {
      'door' => [],
      'post' => [],
      'trap' => [],
      'pre' => [],
      'encr' => [],
      'tres' => []
    },
    'o' => {
      'remove_deadend_percent' => 60,
      'min_room_size' => '2x2',
      'max_room_size' => '7x7',
      'same_way_percent' => 90,
      'generator' => 'Games::RolePlay::MapGen::Generator::XMLImport',
      'num_rooms' => '1d4+1',
      'tile_size' => 10,
      'cell_size' => '20x20',
      'exporter' => 'Games::RolePlay::MapGen::Exporter::Text',
      'same_node_percent' => 30,
      'bounding_box' => '50x50',
      'sparseness' => 10
    }
  }, 'Games::RolePlay::MapGen::Generator::XMLImport' )
};
$this->{xml_input_file} = '/home/jettero/code/perl/mapgen/test.xml';
$this->{same_node_percent} = '30';
$this->{bounding_box} = '20x13';
$this->{_the_map} = $this->{objs}{'exporter'}{'o'}{'_the_map'};
$this->{max_size} = '9x9';
