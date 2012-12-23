#use strict;
require LWP::UserAgent;
use HTML::Parser;
use Switch;
my $ua = LWP::UserAgent->new;
my $p = HTML::Parser->new(api_version => 3,
      start_h => [\&start_handler, "self,tagname,attr"],
      report_tags => [qw(span a)], ignore_tags => [qw(head title meta link script h1 ul li form fieldset)],
#   a_h => [\&a_start_handler, "self,tagname,attr"], span_h => [\&span_start_handler, "self,tagname,attr"], 
	);
our ($i) = 0;
my $ua = LWP::UserAgent->new;
print "Enter the Search Query and Press Enter\n";
my $search = <STDIN>;
while($i<=29)
{
my $response = $ua->get('http://torrentz.eu/search?f='.$search.'&p='.$i);
my $_ = $response->decoded_content;
$p->parse($_ || shift) || die $!;
$i++;
#print "page$i\n\n";
}
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
    print "$url\n$title\n$age\n$size\n$seeds\n$leeches\n";
}

sub span_start_handler
{ #print "span found\n";
   my($self, $tag, $attr) = @_;
   return unless $tag eq "span";
  #return unless exists $attr->{class};
  #  "span $attr->{class}\t";
   if( $attr->{title}){our ($age) = $attr->{title};} 
   our ($class) = $attr->{class};
   $self->handler(text  => [], '@{dtext}' );
   $self->handler(end   => \&span_end_handler, "self,tagname");
}

sub span_end_handler
{   
    my($self, $tag) = @_;
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
		case "d" {our ($leeches) = $text; &dl_end_handler;}
		
	}
	$self->handler("text", undef);
    $self->handler("start", \&start_handler);
    $self->handler("end", undef);
}

sub a_start_handler
{ #print "a found \n";
   my($self, $tag, $attr) = @_;
   return unless $tag eq "a";
   return unless exists $attr->{href};
   #print "A $attr->{href}\n";
   our ($url) = $attr->{href};
   $self->handler(text  => [], '@{dtext}' );
   $self->handler(end   => \&a_end_handler, "self,tagname");
}

sub a_end_handler
{
    my($self, $tag) = @_;
    my $text = join("", @{$self->handler("text")});
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
    $text =~ s/\s+/ /g;
    #print "T $text\n";
    our ($title) = $text;
    $self->handler("text", undef);
    $self->handler("start", \&start_handler);
    $self->handler("end", undef);
}
