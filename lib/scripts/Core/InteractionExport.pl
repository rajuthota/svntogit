#!/usr/local/bin/perl -w
use strict;
use FindBin;
use Getopt::Long;
use lib qw (../perl ../../perl);
use vars qw ($q $recordCon $USAGE %OPTIONS $QUIET $VERBOSE $DEBUG $TESTONLY
             $current_contact_id $current_username $PROG_NAME );

						 
use SBEAMS::Interactions;
use SBEAMS::Interactions::Settings;
use SBEAMS::Interactions::Tables;

use SBEAMS::Connection qw($q);
use SBEAMS::Connection::Settings;
use SBEAMS::Connection::Tables;

$recordCon = new SBEAMS::Connection;
$recordCon->setSBEAMS_SUBDIR($SBEAMS_SUBDIR);


$PROG_NAME = $FindBin::Script;
$USAGE = <<EOU;
Usage: $PROG_NAME [OPTIONS]
Options:
  --verbose n          Set verbosity level.  default is 0
  --quiet              Set flag to print nothing at all except errors
  --debug n            Set debug flag
  --testonly           If set, rows in the database are not changed or added
  --destination_file XXX    Source file name from which data are to be updated
  --check_status       Is set, nothing is actually done, but rather
                       a summary of what should be done is printed

 e.g.:  $PROG_NAME --check_status --destination_file 45277084.htm

EOU


#### Process options
unless (GetOptions(\%OPTIONS,"verbose:s","quiet","debug:s","testonly",
		   "destination_file:s","check_status",
		  )) {
  print "$USAGE";
  exit;
}

$VERBOSE = $OPTIONS{"verbose"} || 0;
$QUIET = $OPTIONS{"quiet"} || 0;
$DEBUG = $OPTIONS{"debug"} || 0;
$TESTONLY = $OPTIONS{"testonly"} || 0;
if ($DEBUG) {
  print "Options settings:\n";
  print "  VERBOSE = $VERBOSE\n";
  print "  QUIET = $QUIET\n";
  print "  DEBUG = $DEBUG\n";
  print "  TESTONLY = $TESTONLY\n";
}

# these are the columns and column sequence for the output file
my @columnOrder = qw / Organism_bioentity1_name
	 Bioentity1_type
	 Bioentity1_common_name
	 Bioentity1_canonical_name
	 Bioentity1_full_name
	 Bioentity1_aliases
	 Bioentity1_location
	 Bioentity1_state
	 Bioentity1_regulatory_feature
	 Interaction_type
	 Organism_bioentity2_name
	 Bioentity2_common_name
	 Bioentity2_canonical_name
	 Bioentity2_full_name
	 Bioentity2_aliases
	 Bioentity2_type
	 Bioentity2_regulatory_feature
	 Bioentity2_location
	 Interaction_group
	 Confidence_score
	 Interaction_description
	 Assay_name
	 Assay_type
	 Publication_ids /;
	 
main(); 
exit;

sub main
{ 
# Do the SBEAMS authentication and exit if a username is not returned
  exit unless ($current_username = $recordCon->Authenticate(
    work_group=>'Developer',
  ));


  $recordCon->printPageHeader() unless ($QUIET);
  handleRequest();
  $recordCon->printPageFooter() unless ($QUIET);

}
	 
	 
sub handleRequest
{
	my %args = @_;
# Set the command-line options
  my $destination_file = $OPTIONS{"destination_file"} || '';
  my $check_status = $OPTIONS{"check_status"} || '';


# Print out the header
  unless ($QUIET)
	{
    $recordCon->printUserContext();
    print "\n";
  }


# Verify that destination_file was passed and can be opened
  unless ($destination_file)
	{
    print "ERROR: You must supply a --destination_file parameter\n$USAGE\n";
    return;
  }
  
	open (File,">$destination_file") or die "can not open $destination_file\n$!";;		
	 my $dataQuery = 
	 qq/select 
	 ON1.organism_name as Organism_bioentity1_name,
	 BT1.bioentity_type_name as Bioentity1_type,
	 BE1.bioentity_common_name as Bioentity1_common_name,
	 BE1.bioentity_canonical_name as Bioentity1_canonical_name,
	 BE1.bioentity_full_name as Bioentity1_full_name,
	 BE1.bioentity_aliases as Bioentity1_aliases,
	 BE1.bioentity_location as Bioentity1_location,
	 BS1.bioentity_state_name as Bioentity1_state,
	 REG1.regulatory_feature_name as Bioentity1_regulatory_feature,
	 IT.interaction_type_name as Interaction_type, 
	 ON2.organism_name as Organism_bioentity2_name,
	 BE2.bioentity_common_name as Bioentity2_common_name,
	 BE2.bioentity_canonical_name as Bioentity2_canonical_name,
	 BE2.bioentity_full_name as Bioentity2_full_name,
	 BE2.bioentity_aliases as Bioentity2_aliases,
	 BT2.bioentity_type_name as Bioentity2_type,
	 REG2.regulatory_feature_name as Bioentity2_regulatory_feature,
	 BE2.bioentity_location as Bioentity2_location,
	 IG.interaction_group_name as Interaction_group,
	 CS.confidence_score_name as Confidence_score,
	 I.interaction_description as Interaction_description,
	 AN.assay_name as Assay_name,
	 AT.assay_type_name as Assay_type,
	 P.pubmed_id as Publication_ids
	 from $TBIN_INTERACTION I
	 full outer join $TBIN_BIOENTITY BE1 on  (I.bioentity1_id = BE1.bioentity_id)
	 join $TB_ORGANISM ON1 on (BE1.organism_id = ON1.organism_id)
	 full outer join $TBIN_BIOENTITY BE2 on  (I.bioentity2_id = BE2.bioentity_id)
	 join $TB_ORGANISM ON2 on (BE2.organism_id = ON2.organism_id)
	 join $TBIN_BIOENTITY_TYPE BT1 on (BE1.bioentity_type_id = BT1.bioentity_type_id)
	 join $TBIN_BIOENTITY_TYPE BT2 on (BE2.bioentity_type_id = BT2.bioentity_type_id)
	 left outer join $TBIN_BIOENTITY_STATE BS1 on (I.bioentity1_state_id = BS1.bioentity_state_id)
	 left outer join $TBIN_BIOENTITY_STATE BS2 on (I.bioentity2_state_id = BS2.bioentity_state_id)
	 left outer join $TBIN_REGULATORY_FEATURE REG1 on (I.regulatory_feature1_id = REG1.regulatory_feature_id)
	 left outer join $TBIN_REGULATORY_FEATURE REG2 on (I.regulatory_feature1_id = REG2.regulatory_feature_id) 
	 join $TBIN_INTERACTION_TYPE IT on (I.interaction_type_id = IT.interaction_type_id)
	 join $TBIN_INTERACTION_GROUP IG on (I.interaction_group_id = IG.interaction_group_id)
	 left outer join $TBIN_CONFIDENCE_SCORE CS on (I.confidence_score_id = CS.confidence_score_id)
	 left outer join $TBIN_ASSAY AN on (I.assay_id = AN.assay_id)
	 left outer join $TBIN_ASSAY_TYPE AT on (AN.assay_type_id = AT.assay_type_id)
	 left outer join $TBIN_PUBLICATION P on (AN.publication_id = P.publication_id)/;

#@retrunedRows is on array of array references
	my @returnedRows = $recordCon->selectSeveralColumns ($dataQuery);	

	foreach my $element (@columnOrder)
	{
			print File "$element\t";
	}
	print File "\t\n";

	for (my $outercount = 0;$outercount<@returnedRows;$outercount++)
	{
			my $count = 0; 
			for($count=0;$count<@{$returnedRows[$outercount]};$count++) 
			{
					print File "@{$returnedRows[$outercount]}->[$count]\t";
			
			}
			print File "\t\n";
	}
	close File;
}
