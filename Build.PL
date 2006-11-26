use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Geo::Gpx',
    license             => 'perl',
    dist_author         => 'Andy Armstrong <andy@hexten.net>',
    dist_version_from   => 'lib/Geo/Gpx.pm',
    requires => {
        'Test::More'        => 0,
        'version'           => 0,
        'Date::Format'      => 0,
        'Date::Parse'       => 0,
        'HTML::Entities'    => 0,
        'Scalar::Util'      => 0,
        'Time::Local'       => 0,
        'XML::Descent'      => 0,
    },
    add_to_cleanup      => [ 'Geo-Gpx-*' ],
);

$builder->create_build_script();