package SBEAMS::Oligo::Settings;

###############################################################################
# Program     : SBEAMS::Oligo::Settings
# Author      : Eric Deutsch <edeutsch@systemsbiology.org>
# $Id$
#
# Description : This is part of the SBEAMS::Oligo module which handles
#               setting location-dependant variables.
#
###############################################################################


use strict;

#### Begin with the main Settings.pm
use SBEAMS::Connection::Settings;


#### Set up new variables
use vars qw(@ISA @EXPORT 
    $SBEAMS_PART
);

require Exporter;
@ISA = qw (Exporter);

@EXPORT = qw (
    $SBEAMS_PART
);


#### Define new variables
$SBEAMS_PART            = 'Oligo';


#### Override variables from main Settings.pm
$SBEAMS_SUBDIR          = 'Oligo';
