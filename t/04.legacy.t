use Test::More;

BEGIN {
    eval "use Geo::Cache";
    if ($@) {
        plan skip_all => 'Geo::Cache not available';
        exit;
    }
    plan tests => 2;
    use_ok('Geo::Gpx');
}

# Get expected output from previous version
my $xml;
{ local $/; $xml = <DATA>; }
$xml = normalise($xml);

my @pts = (
    new Geo::Cache(
        lat  => 45.460366651,
        lon  => -75.767939974,
        ele  => 33.700000,
        name => 'WP0001',
        cmt  => 'WP0001',
        desc => 'WP0001',
        fix  => '2d',
        sat  => 3,
        pdop => 30.600000,
    ),
    new Geo::Cache(
        lat  => 45.460339984,
        lon  => -75.767591640,
        ele  => 33.700000,
        name => 'WP0002',
        cmt  => 'WP0002',
        desc => 'WP0002',
        fix  => '2d',
        sat  => 3,
        pdop => 30.600000,
    ),
    new Geo::Cache(
        lat  => 45.458376651,
        lon  => -75.768483307,
        ele  => 105.400000,
        name => 'WP0003',
        cmt  => 'WP0003',
        desc => 'WP0003',
        fix  => 'dgps',
        sat  => 7,
        pdop => 1.400000,
    )
);

my $gpx = Geo::Gpx->new(@pts);

my $gxml = $gpx->xml();
$gxml = normalise($gxml);

is($gxml, $xml, 'same output as previous version');
# if ($gxml ne $xml) {
#     save('orig.gpx', $xml);
#     save('gen.gpx',  $gxml);
# }

sub normalise {
    my $xml = shift;
    # Remove leading spaces in case we decide to indent the output
    $xml =~ s{^\s+}{}msg;
    my $fix_time = sub {
        my $tm = shift;
        $tm =~ s{\d}{9}g;
        $tm =~ s{[+-]}{-}g;
        return $tm;
    };
    $xml =~ s{(<time>)(.*?)(</time>)}{$1 . $fix_time->($2) . $3}eg;
    my $fix_coord = sub {
        my $co = shift;
        return sprintf("%.6f", $co);
    };
    $xml =~ s{((?:lat|lon)=\")([^\"]+)(\")}{$1 . $fix_coord->($2) . $3}eg;
    $xml =~ s{<groundspeak:cache id="\d+"}{<groundspeak:cache id="99999"}g;
    return $xml;
}

sub save {
    my ($name, $xml) = @_;
    open(my $fh, '>', $name) or die "Can't write $name ($!)\n";
    print $fh $xml;
    close($fh);
}

__DATA__
<?xml version="1.0" encoding="utf-8"?>
<gpx xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0" creator="Geo::Gpx" xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0 http://www.groundspeak.com/cache/1/0/cache.xsd" xmlns="http://www.topografix.com/GPX/1/0">
<desc>GPX file generated by Geo::Gpx</desc>
<author>Groundspeak</author>
<email>contact@groundspeak.com</email>
<time>2006-11-24T18:36:09.0000000-07:00</time>
<keywords>cache, geocache, groundspeak</keywords>
<bounds maxlat="45.460366651" maxlon="-75.76759164" minlat="45.458376651" minlon="-75.768483307" />
<wpt lat="45.460366651" lon="-75.767939974">
<time>2006-11-24T18:36:09.0000000-07:00</time>
<name>WP0001</name>
<desc>WP0001</desc>
<url>http://drbacchus.com/</url>
<urlname>Geo::Cache</urlname>
<sym>box</sym>
<type />
<groundspeak:cache id="69921" available="True" archived="False" xmlns:groundspeak="http://www.groundspeak.com/cache/1/0">
<groundspeak:name>WP0001</groundspeak:name>
<groundspeak:type>Traditional Cache</groundspeak:type>
<groundspeak:container>Regular</groundspeak:container>
<groundspeak:difficulty>1</groundspeak:difficulty>
<groundspeak:terrain>1</groundspeak:terrain>
<groundspeak:country>United States</groundspeak:country>
<groundspeak:state>Kentucky</groundpeak:state>
<groundspeak:short_description>WP0001</groundspeak:short_description>
<groundspeak:long_description html="False">Geo::Cache</groundspeak:long_description>
<groundspeak:encoded_hints />
<groundspeak:logs>
</groundspeak:logs>
<groundspeak:travelbugs />
</groundspeak:cache>
</wpt>
<wpt lat="45.460339984" lon="-75.76759164">
<time>2006-11-24T18:36:09.0000000-07:00</time>
<name>WP0002</name>
<desc>WP0002</desc>
<url>http://drbacchus.com/</url>
<urlname>Geo::Cache</urlname>
<sym>box</sym>
<type />
<groundspeak:cache id="69922" available="True" archived="False" xmlns:groundspeak="http://www.groundspeak.com/cache/1/0">
<groundspeak:name>WP0002</groundspeak:name>
<groundspeak:type>Traditional Cache</groundspeak:type>
<groundspeak:container>Regular</groundspeak:container>
<groundspeak:difficulty>1</groundspeak:difficulty>
<groundspeak:terrain>1</groundspeak:terrain>
<groundspeak:country>United States</groundspeak:country>
<groundspeak:state>Kentucky</groundpeak:state>
<groundspeak:short_description>WP0002</groundspeak:short_description>
<groundspeak:long_description html="False">Geo::Cache</groundspeak:long_description>
<groundspeak:encoded_hints />
<groundspeak:logs>
</groundspeak:logs>
<groundspeak:travelbugs />
</groundspeak:cache>
</wpt>
<wpt lat="45.458376651" lon="-75.768483307">
<time>2006-11-24T18:36:09.0000000-07:00</time>
<name>WP0003</name>
<desc>WP0003</desc>
<url>http://drbacchus.com/</url>
<urlname>Geo::Cache</urlname>
<sym>box</sym>
<type />
<groundspeak:cache id="69923" available="True" archived="False" xmlns:groundspeak="http://www.groundspeak.com/cache/1/0">
<groundspeak:name>WP0003</groundspeak:name>
<groundspeak:type>Traditional Cache</groundspeak:type>
<groundspeak:container>Regular</groundspeak:container>
<groundspeak:difficulty>1</groundspeak:difficulty>
<groundspeak:terrain>1</groundspeak:terrain>
<groundspeak:country>United States</groundspeak:country>
<groundspeak:state>Kentucky</groundpeak:state>
<groundspeak:short_description>WP0003</groundspeak:short_description>
<groundspeak:long_description html="False">Geo::Cache</groundspeak:long_description>
<groundspeak:encoded_hints />
<groundspeak:logs>
</groundspeak:logs>
<groundspeak:travelbugs />
</groundspeak:cache>
</wpt>
</gpx>
