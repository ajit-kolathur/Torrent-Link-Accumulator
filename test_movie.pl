#use strict;
require LWP::UserAgent;
use HTML::Parser;
use Switch;
open FILE, ">output.txt" or die $!;
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
while($i<=29)
{
my $response = $ua->get('http://torrentz.eu/search?f='.$search.'&p='.$i);
my $_ = $response->decoded_content;
$p->parse($_ || shift) || die $!;
$i++;
#print "##########################################################################################################################################";
print "page$i\a\n\n";
}
close FILE;
sub start_handler
{
  my($self, $tag, $attr) = @_;
  return unless ( $tag eq "a" || $tag eq "span" );
  if ($tag eq "a"){&a_start_handler;}
  if ($tag eq "span"){&span_start_handler;}
}

sub dl_end_handler
{
	return unless ($url =~ m(^\/(?:[a-z]|\d){40})); 
    print FILE "$url\n$title\n$age\n$size\n$seeds\n$leeches\n";
	my $page = $_;
	$flag = 1;
	&depth_search;
	print "links obtained \n\n";
	$flag = 0;
	$_ = $page;
}

sub depth_search
{
	$response_sub = $uq->get('http://www.torrentz.eu'.$url);
	my $q = HTML::Parser->new(api_version => 3,
      start_h => [\&start_handler, "self,tagname,attr"],
      report_tags => [qw(span a)], ignore_tags => [qw(head title meta link script h1 ul li form fieldset)],
	);
    my $_ = $response_sub->decoded_content;
	$q->parse($_ || shift) || die $!;

}
sub depth_print
{
	#return unless ($url =~ m(^\/(?:[a-z]|\d){40})); 
    #if($title = "links"){print "$url\t$age\n"};
	switch($type)
	{
		case "links" {print FILE "$type\t\t$url\t$age\n";}
		case "tracker list" {print FILE "tracker list link $url\n";}
		case "tracker" {print FILE "$type\t$url\t$seeds\t$leeches\t$age\n";}
	}
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

sub span_end_handler
{   
    my($self, $tag, $attr) = @_;
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
