# $Id: 00_load.t,v 1.1 2005/03/16 15:47:33 jettero Exp $

use strict;
use Test;

plan tests => 1;

eval "use Games::RolePlay::MapGen";

ok( $@, "" );
