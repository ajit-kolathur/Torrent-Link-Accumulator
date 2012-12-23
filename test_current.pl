#use strict;
require LWP::UserAgent;
use HTML::Parser;
use Switch;
#use Firefox::Application;
#use Net::BitTorrent;
#use File::Download;
our $flag = 0;
our $type = undef;
my $ua = LWP::UserAgent->new;
my $p = HTML::Parser->new(api_version => 3,
      start_h => [\&start_handler, "self,tagname,attr"],
      report_tags => [qw(span a)], ignore_tags => [qw(head title meta link script h1 ul li form fieldset)],
	);
our ($i) = 0;
my $uq = LWP::UserAgent->new;
print "Enter the Search Query and Press Enter\n";
my $search = <STDIN>;
while($i<=9)
{
our $torrent_flag = 1;
my $response = $ua->get('http://torrentz.eu/search?f='."\"$search\"".'&p='.$i);
my $_ = $response->decoded_content;
$p->parse($_ || shift) || die $!;
$i++;
#print "##########################################################################################################################################";
print "page$i\a\n\n";
}
sub start_handler
{
  my($self, $tag, $attr) = @_;
  return unless ( $tag eq "a" || $tag eq "span" );
  if ($tag eq "a"){ 
   # if( ($attr->{href} =~ m(\.torrent$)) or ($attr->{href} =~ m(\.torrent\Z)) or ($attr->{rel} eq "no follow")){
   #   our ($torrent) = $attr->{href};
   #   print $torrent;
   #   $torrent_flag =0;
   #   shift;
   #   return;
   #} 
  &a_start_handler;}
  if ($tag eq "span"){&span_start_handler;}
}
sub dl_end_handler
{	
	return unless ($url =~ m(^\/(?:[a-z]|\d){40})); 
    print "$url\n$title\n$age\n$size\n$seeds\n$leeches\n";
	my $page = $_;
	$flag = 1;
	&depth_search;
	print "links obtained \n\n";
	$torrent_flag =1;
	$flag = 0;
	$_ = $page;
}

sub depth_search
{
	$response_sub = $uq->get('http://www.torrentz.eu'.$url);
	my $q = HTML::Parser->new(api_version => 3,
      start_h => [\&start_handler, "self,tagname,attr"],
      report_tags => [qw(a span)], ignore_tags => [qw(head title meta link script h1 ul li form fieldset)],
	);
	$_ = $response_sub->decoded_content;
	$q->parse($_ || shift) || die $!;
	
}
sub depth_print
{
	#return unless ($url =~ m(^\/(?:[a-z]|\d){40})); 
    #if($title = "links"){print "$url\t$age\n"};
	my $temp = $_;
	switch($type)
	{
		case "links" {print "$type\t\t$url\t$age\n";
		if($torrent_flag eq 1){
		#print "entered\n";
		#my $response_tor = $ur->get($url);
		#my $r = HTML::Parser->new(api_version => 3, start_h => [\&start_handler,"self,tagname,attr"],report_tags =>[qw(a)],);
		#$_  = $response_tor->decoded_content; #$r->parse($_ || shift) || die $!;shift;
		&get_torrent; shift;$type = undef; return;
		}
		}
		case "tracker list" {print "tracker list link $url\n";}
		case "tracker" {print "$type\t$url\t$seeds\t$leeches\t$age\n";}
	}
	$_ = $temp;
	shift;$type = undef;
}
sub span_start_handler
{ #print "span found\n";
   my($self, $tag, $attr) = @_;
   return unless $tag eq "span";
  #return unless exists $attr->{class};
  #  "span $attr->{class}\t";
   if( $attr->{title}){our ($age) = $attr->{title};}
   #if($attr->{title} && $flag eq 1){&depth_print;} 
   our ($class) = $attr->{class};
   $self->handler(text  => [], '@{dtext}' );
   $self->handler(end   => \&span_end_handler, "self,tagname");
}

sub get_torrent{
    my $ur = LWP::UserAgent->new;
    my $page = $ur->get("$url");
    my $tmp = $_;
	my $r = HTML::Parser->new(api_version => 3,
      start_h => [\&start, "self,tagname,attr"],
      report_tags => [qw(a)], ignore_tags => [qw(span head title meta link script h1 ul li form fieldset)],
	);

  #  my $r = HTML::Parser->new( api_version => 3,start_h => [\&start, "self tagname, attr"],report_tags => [qw(a)], ignore_tags => [qw(span head title meta link script h1 ul li form fieldset)],);
	$var = $page->decoded_content;
	$r->parse( $var || shift) || $!;
	$var = $tmp;
	$$_ = $tmp;
	return;
}
sub file_down
{
	#$torrent_file
	#use Firefox::Application;
    #my $ff = Firefox::Application->new();
	
	#return;
}
sub start{
    my($self, $tag, $attr) = @_;
    return unless $tag eq "a";
    return unless exists $attr->{href};
	if( ($attr->{href} =~ m((?i)\.(torrent)$) ) or ($attr->{rel} eq "no follow")){
	our $torrent_file = $attr->{href};
	print "$torrent_file\n";
	$torrent_flag =0;
	#&file_down;
	}shift;
}
	

sub span_end_handler
{   
    my ($self, $tag, $attr) = @_;
    my $text = join("", @{$self->handler("text")});
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
    $text =~ s/\s+/ /g;
    #print "S $text\n";
    switch($class)
	{
		case "v" {shift;}
		case "a" {shift; &span_start_handler;}
		#case "title" { our ($age) = $text;}
		case "s" {our ($size) = $text;}
		case "u" {our ($seeds) = $text;}
		case "d" {our ($leeches) = $text; if($flag eq 0){&dl_end_handler;}}
		
	}
	$self->handler("text", undef);
    $self->handler("start", \&start_handler);
    $self->handler("end", undef);
}

sub a_start_handler
{ #print "a found \n";
 #if($torrent_flag eq 1 && $flag eq 1){return;}
 if($flag eq 0)
  {
    my($self, $tag, $attr) = @_;
    return unless $tag eq "a";
    return unless exists $attr->{href};
    #print "A $attr->{href}\n";
    our ($url) = $attr->{href};
    $self->handler(text  => [], '@{dtext}' );
    $self->handler(end   => \&a_end_handler, "self,tagname");
  }
  else
  { 
    my($self, $tag, $attr) = @_;
    return unless $tag eq "a";
    return unless exists $attr->{href};
    &depth_print;
    #print "A $attr->{href}\n";
    our ($url) = $attr->{href};
    if ( $attr->{rel} eq "e" && ($url =~ m(^(http|https):\/\/))){$type = "links" ;}
    if ( $attr->{rel} eq "e" && $url =~ m(^\/announcelist_)){$type = "tracker list" ;}
    if ( $url=~ m(^\/tracker_)){$type = "tracker";$self->handler(text  => [], '@{dtext}' );
    $self->handler(end   => \&a_end_handler, "self,tagname");}
    shift;
    return;
  }
}

sub a_end_handler
{
    my($self, $tag, $attr) = @_;
    my $text = join("", @{$self->handler("text")});
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
    $text =~ s/\s+/ /g;
    #print "T $text\n";
    if($flag eq 0){ $title = $text;}else{$url = $text;}
    $self->handler("text", undef);
    $self->handler("start", \&start_handler);
    $self->handler("end", undef);
}
