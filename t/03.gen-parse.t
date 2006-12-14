use Test::More tests => 5;

BEGIN {
    use_ok('Geo::Gpx');
}

my %refxml = ( );
my $k      = undef;

while (<DATA>) {
    if (/^==\s+(\S+)\s+==$/) {
        $k = $1;
    } elsif (defined($k)) {
        $refxml{$k} .= $_;
    }
}

my $gpx = Geo::Gpx->new();

my @wpt = (
    {
        # All standard GPX fields
        lat           => 54.786989,
        lon           => -2.344214,
        ele           => 512,
        time          => time(),
        magvar        => 0,
        geoidheight   => 0,
        name          => 'My house & home',
        cmt           => 'Where I live',
        desc          => '<<Chez moi>>',
        src           => 'Testing',
        link          => {
            href => 'http://hexten.net/',
            text => 'Hexten',
            type => 'Blah'
        },
        sym           => 'pin',
        type          => 'unknown',
        fix           => 'dgps',
        sat           => 3,
        hdop          => 10,
        vdop          => 10,
        pdop          => 10,
        ageofdgpsdata => 45,
        dgpsid        => 247
    },
    {
        # Fewer fields
        lat           => -38.870059,
        lon           => -151.210030,
        name          => 'Sydney, AU'
    }
);

$gpx->waypoints(\@wpt);

srand(1); # Same numbers every time
my $lat  = 54.786989;
my $lon  = -2.344214;
my $next = 1;

sub get_point {
    my $fmt  = shift;
    my $dlat = rand(1) - 0.5;
    my $dlon = rand(1) - 0.5;
    
    $lat += $dlat;
    $lon += $dlon;
    
    if ($fmt) {
        return { 
            lat  => $lat, 
            lon  => $lon, 
            name => sprintf($fmt, $next++) 
        };
    } else {
        return {
            lat => $lat, 
            lon => $lon 
        };
    }
}

my @rte = (
    {
        name => 'Route 1',
        points => [ map { get_point('WPT%d') } (1 .. 3) ]
    },
    {
        name => 'Route 2',
        points => [ map { get_point('WPT%d') } (1 .. 2) ]
    }
);

$gpx->routes(\@rte);

my @trk = (
    {
        name => 'Track 1',
        segments => [
            {
                points => [ map { get_point() } (1 .. 3) ]
            },
            {
                points => [ map { get_point() } (1 .. 1) ]
            }
        ]
    },
    {
        name => 'Track 2',
        segments => [
            {
                points => [ map { get_point() } (1 .. 5) ]
            }
        ]
    }
);

$gpx->tracks(\@trk);

$gpx->name('Test');
$gpx->desc('Test data');
$gpx->author({ 
    name    => 'Andy Armstrong', 
    email   => {
        id      => 'andy', 
        domain  => 'hexten.net'
    },
    link    => { 
        href    => 'http://hexten.net/', 
        text    => 'Hexten' 
    } 
});
$gpx->copyright('(c) Anyone');
$gpx->link({
    href => 'http://www.topografix.com/GPX', 
    text => 'GPX Spec', 
    type => 'unknown' 
});
$gpx->time(time());
$gpx->keywords(['this', 'that', 'the other']);

for my $version (keys %refxml) {
    my $xml = normalise($refxml{$version});
    my $gen = normalise($gpx->xml($version));
    is($gen, $xml, 'generated version ' . $version);
    # save_if_diff("generated-$version", $gen, $xml);

    # Parse reference XMLs
    my $ngpx = Geo::Gpx->new(xml => $refxml{$version});
    my $ngen = normalise($ngpx->xml());
    is($ngen, $xml, 'reparsed version ' . $version);
    #save_if_diff("reparsed-$version", $ngen, $xml);
}

sub save_if_diff {
    my ($base, $gen, $orig) = @_;
    if ($gen ne $orig) {
        save("$base-orig.gpx", $orig);
        save("$base-gen.gpx",  $gen);
    }
}

sub save {
    my ($name, $xml) = @_;
    open(my $fh, '>', $name) or die "Can't write $name ($!)\n";
    print $fh $xml;
    close($fh);
}

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
    return $xml;
}

__END__
== 1.0 ==
<?xml version="1.0" encoding="utf-8"?>
<gpx xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0" creator="Geo::Gpx" xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd" xmlns="http://www.topografix.com/GPX/1/0">
  <name>Test</name>
  <desc>Test data</desc>
  <author>Andy Armstrong</author>
  <email>andy@hexten.net</email>
  <time>2006-11-24T23:59:59Z</time>
  <keywords>this, that, the other</keywords>
  <copyright>(c) Anyone</copyright>
  <url>http://www.topografix.com/GPX</url>
  <urlname>GPX Spec</urlname>
  <bounds maxlat="55.4451622411372" maxlon="-2.344214" minlat="-38.870059" minlon="-151.21003" />
  <rte>
    <name>Route 1</name>
    <rtept lat="54.3286193447719" lon="-2.38972155527137">
      <name>WPT1</name>
    </rtept>
    <rtept lat="54.6634365629388" lon="-2.55373552512617">
      <name>WPT2</name>
    </rtept>
    <rtept lat="54.7289259665049" lon="-3.05196861273443">
      <name>WPT3</name>
    </rtept>
  </rte>
  <rte>
    <name>Route 2</name>
    <rtept lat="54.4165154835049" lon="-2.56153453279676">
      <name>WPT4</name>
    </rtept>
    <rtept lat="54.6670126167344" lon="-2.69526089464403">
      <name>WPT5</name>
    </rtept>
  </rte>
  <trk>
    <name>Track 1</name>
    <trkseg>
      <trkpt lat="54.5182217145253" lon="-2.62191579018834">
      </trkpt>
      <trkpt lat="54.1507759448355" lon="-3.05774931478646">
      </trkpt>
      <trkpt lat="54.6016296784874" lon="-3.40418920968631">
      </trkpt>
    </trkseg>
    <trkseg>
      <trkpt lat="54.6862790450185" lon="-3.68760108982739">
      </trkpt>
    </trkseg>
  </trk>
  <trk>
    <name>Track 2</name>
    <trkseg>
      <trkpt lat="54.9927807628549" lon="-4.04712811256436">
      </trkpt>
      <trkpt lat="55.1148395198045" lon="-4.33623533555793">
      </trkpt>
      <trkpt lat="54.6214174046189" lon="-4.26293674042878">
      </trkpt>
      <trkpt lat="55.0540816059084" lon="-4.42261020671926">
      </trkpt>
      <trkpt lat="55.4451622411372" lon="-4.32873765338">
      </trkpt>
    </trkseg>
  </trk>
  <wpt lat="54.786989" lon="-2.344214">
    <ageofdgpsdata>45</ageofdgpsdata>
    <cmt>Where I live</cmt>
    <desc>&#x3C;&#x3C;Chez moi&#x3E;&#x3E;</desc>
    <dgpsid>247</dgpsid>
    <ele>512</ele>
    <fix>dgps</fix>
    <geoidheight>0</geoidheight>
    <hdop>10</hdop>
    <url>http://hexten.net/</url>
    <urlname>Hexten</urlname>
    <magvar>0</magvar>
    <name>My house &#x26; home</name>
    <pdop>10</pdop>
    <sat>3</sat>
    <src>Testing</src>
    <sym>pin</sym>
    <time>2006-11-24T23:59:59Z</time>
    <type>unknown</type>
    <vdop>10</vdop>
  </wpt>
  <wpt lat="-38.870059" lon="-151.21003">
    <name>Sydney, AU</name>
  </wpt>
</gpx>
== 1.1 ==
<?xml version="1.0" encoding="utf-8"?>
<gpx xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1" creator="Geo::Gpx" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd" xmlns="http://www.topografix.com/GPX/1/1">
  <metadata>
    <name>Test</name>
    <desc>Test data</desc>
    <author>
      <email domain="hexten.net" id="andy">
      </email>
      <link href="http://hexten.net/">
        <text>Hexten</text>
      </link>
      <name>Andy Armstrong</name>
    </author>
    <time>2006-11-24T23:59:59Z</time>
    <keywords>this, that, the other</keywords>
    <copyright>(c) Anyone</copyright>
    <link href="http://www.topografix.com/GPX">
      <text>GPX Spec</text>
      <type>unknown</type>
    </link>
    <bounds maxlat="55.4451622411372" maxlon="-2.344214" minlat="-38.870059" minlon="-151.21003" />
  </metadata>
  <rte>
    <name>Route 1</name>
    <rtept lat="54.3286193447719" lon="-2.38972155527137">
      <name>WPT1</name>
    </rtept>
    <rtept lat="54.6634365629388" lon="-2.55373552512617">
      <name>WPT2</name>
    </rtept>
    <rtept lat="54.7289259665049" lon="-3.05196861273443">
      <name>WPT3</name>
    </rtept>
  </rte>
  <rte>
    <name>Route 2</name>
    <rtept lat="54.4165154835049" lon="-2.56153453279676">
      <name>WPT4</name>
    </rtept>
    <rtept lat="54.6670126167344" lon="-2.69526089464403">
      <name>WPT5</name>
    </rtept>
  </rte>
  <trk>
    <name>Track 1</name>
    <trkseg>
      <trkpt lat="54.5182217145253" lon="-2.62191579018834">
      </trkpt>
      <trkpt lat="54.1507759448355" lon="-3.05774931478646">
      </trkpt>
      <trkpt lat="54.6016296784874" lon="-3.40418920968631">
      </trkpt>
    </trkseg>
    <trkseg>
      <trkpt lat="54.6862790450185" lon="-3.68760108982739">
      </trkpt>
    </trkseg>
  </trk>
  <trk>
    <name>Track 2</name>
    <trkseg>
      <trkpt lat="54.9927807628549" lon="-4.04712811256436">
      </trkpt>
      <trkpt lat="55.1148395198045" lon="-4.33623533555793">
      </trkpt>
      <trkpt lat="54.6214174046189" lon="-4.26293674042878">
      </trkpt>
      <trkpt lat="55.0540816059084" lon="-4.42261020671926">
      </trkpt>
      <trkpt lat="55.4451622411372" lon="-4.32873765338">
      </trkpt>
    </trkseg>
  </trk>
  <wpt lat="54.786989" lon="-2.344214">
    <ageofdgpsdata>45</ageofdgpsdata>
    <cmt>Where I live</cmt>
    <desc>&#x3C;&#x3C;Chez moi&#x3E;&#x3E;</desc>
    <dgpsid>247</dgpsid>
    <ele>512</ele>
    <fix>dgps</fix>
    <geoidheight>0</geoidheight>
    <hdop>10</hdop>
    <link href="http://hexten.net/">
      <text>Hexten</text>
      <type>Blah</type>
    </link>
    <magvar>0</magvar>
    <name>My house &#x26; home</name>
    <pdop>10</pdop>
    <sat>3</sat>
    <src>Testing</src>
    <sym>pin</sym>
    <time>2006-11-24T23:59:59Z</time>
    <type>unknown</type>
    <vdop>10</vdop>
  </wpt>
  <wpt lat="-38.870059" lon="-151.21003">
    <name>Sydney, AU</name>
  </wpt>
</gpx>
