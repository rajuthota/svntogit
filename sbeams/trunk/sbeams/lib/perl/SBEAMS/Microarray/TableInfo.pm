package SBEAMS::Microarray::TableInfo;

###############################################################################
# Program     : SBEAMS::Microarray::TableInfo
# Author      : Eric Deutsch <edeutsch@systemsbiology.org>
# $Id$
#
# Description : This is part of the SBEAMS::Microarray module which returns
#               information about various tables.
#
###############################################################################

use strict;
use CGI::Carp qw(fatalsToBrowser croak);

use SBEAMS::Microarray::Settings;
use SBEAMS::Microarray::Tables;
use SBEAMS::Connection::Tables;


###############################################################################
# Constructor
###############################################################################
sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;
    return($self);
}


###############################################################################
# Return Table Info
#
# Return the required information about the specified Table
###############################################################################
sub returnTableInfo {
    my $self = shift;
    my $table_name = shift || croak("parameter table_name not specified");
    my $info_key = shift || croak("parameter info_key not specified");

    my @row;
    my $sql_query;
    my $result;


###############################################################################
#
# First we have table-specific overrides of the default answers
#
# This is mostly just Queries now.  This should be pushed out into a
# nicely formatted file of queries.
#
###############################################################################
###############################################################################
    if ($table_name eq "hardware") {

        if ($info_key eq "BASICQuery") {
            return qq~
		SELECT hardware_id,HT.name,make,model,serial_number,uri
		  FROM $TB_HARDWARE H
		  JOIN $TB_HARDWARE_TYPE HT
		       ON (H.hardware_type_id=HT.hardware_type_id)
		 WHERE H.record_status!='D'
            ~;
        }

        if ($info_key eq "FULLQuery") {
            return qq~
		SELECT H.*
		  FROM $TB_HARDWARE H
		  JOIN $TB_HARDWARE_TYPE HT
		       ON (H.hardware_type_id=HT.hardware_type_id)
		 WHERE H.record_status!='D'
            ~;
        }


    }


###############################################################################
    if ($table_name eq "software") {

        if ($info_key eq "BASICQuery") {
            return qq~
		SELECT software_id,ST.name,version,operating_system,uri
		  FROM $TB_SOFTWARE S
		  JOIN $TB_SOFTWARE_TYPE ST
		       ON (S.software_type_id=ST.software_type_id)
		 WHERE S.record_status!='D'
            ~;
        }

        if ($info_key eq "FULLQuery") {
            return qq~
		SELECT S.*
		  FROM $TB_SOFTWARE S
		  JOIN $TB_SOFTWARE_TYPE ST
		       ON (S.software_type_id=ST.software_type_id)
		 WHERE S.record_status!='D'
            ~;
        }

    }


###############################################################################
    if ($table_name eq "slide_type") {

        if ($info_key eq "BASICQuery") {
            return qq~
		SELECT slide_type_id,ST.name,organism_name AS 'organism',price
		  FROM $TBMA_SLIDE_TYPE ST
		  JOIN $TB_ORGANISM O
		       ON (ST.organism_id=O.organism_id)
		 WHERE ST.record_status!='D'
            ~;
        }

        if ($info_key eq "FULLQuery") {
            return qq~
		SELECT slide_type_id,ST.name,O.organism_name,price,ST.sort_order,
		       ST.date_created,ST.created_by_id,ST.date_modified,
		       ST.modified_by_id,ST.record_status
		  FROM $TBMA_SLIDE_TYPE ST
		  JOIN $TB_ORGANISM O
		       ON (ST.organism_id=O.organism_id)
		 WHERE ST.record_status!='D'
            ~;
        }

    }


###############################################################################
    if ($table_name eq "slide_type_cost") {

        if ($info_key eq "BASICQuery") {
            return qq~
		SELECT slide_type_cost_id,name,cost_scheme_name,STC.price
		  FROM $TBMA_SLIDE_TYPE_COST STC
		  JOIN $TBMA_SLIDE_TYPE ST
		       ON (STC.slide_type_id=ST.slide_type_id)
		  JOIN $TBMA_COST_SCHEME CS
		       ON (STC.cost_scheme_id=CS.cost_scheme_id)
		 WHERE STC.record_status!='D'
            ~;
        }

    }


###############################################################################
    if ($table_name eq "labeling_method") {

        if ($info_key eq "BASICQuery") {
            return qq~
		SELECT labeling_method_id,LM.name,xna_type,
		       dye_name,desired_micrograms,Ebase,MWbase,price
		  FROM $TBMA_LABELING_METHOD LM
		  LEFT JOIN $TBMA_XNA_TYPE XT
		       ON (LM.xna_type_id=XT.xna_type_id)
		  LEFT JOIN $TBMA_DYE D
		       ON (LM.dye_id=D.dye_id)
		 WHERE LM.record_status!='D'
            ~;
        }

        if ($info_key eq "FULLQuery") {
            return qq~
		SELECT LM.*
		  FROM $TBMA_LABELING_METHOD LM
		 WHERE LM.record_status!='D'
            ~;
        }

    }


###############################################################################
    if ($table_name eq "array_request") {

        if ($info_key eq "BASICQuery") {
            return qq~
		SELECT array_request_id,username,n_slides,ST.name,
		       request_status
		  FROM $TBMA_ARRAY_REQUEST AR
		  LEFT JOIN $TB_USER_LOGIN U
		       ON (AR.contact_id=U.contact_id)
		  LEFT JOIN $TBMA_SLIDE_TYPE ST
		       ON (AR.slide_type_id=ST.slide_type_id)
		 WHERE AR.record_status!='D'
            ~;
        }

    }



###############################################################################
    if ($table_name eq "slide_model") {

        if ($info_key eq "BASICQuery") {
            return qq~
		SELECT slide_model_id,vendor_name,model_name,contact_id,comment
		  FROM $TBMA_SLIDE_MODEL
		 WHERE record_status!='D'
            ~;
        }

    }




###############################################################################
    if ($table_name eq "slide_lot") {

        if ($info_key eq "BASICQuery") {
            return qq~
		SELECT slide_lot_id,SM.vendor_name,SM.model_name,lot_number,
		       date_received,SL.comment
		  FROM $TBMA_SLIDE_LOT SL
		  LEFT JOIN $TBMA_SLIDE_MODEL SM
		       ON (SL.slide_model_id=SM.slide_model_id)
		 WHERE SL.record_status!='D'
            ~;
        }

    }


###############################################################################
    if ($table_name eq "printing_batch") {

    }


###############################################################################
    if ($table_name eq "slide") {

        if ($info_key eq "BASICQuery") {
            return qq~
		SELECT slide_id,lot_number,slide_number
		  FROM $TBMA_SLIDE S
		  LEFT JOIN $TBMA_SLIDE_LOT SL
		       ON (S.slide_lot_id=SL.slide_lot_id)
		 WHERE S.record_status!='D'
		   AND SL.record_status!='D'
            ~;
        }

    }


###############################################################################
    if ($table_name eq "array_layout") {

    }



###############################################################################
    if ($table_name eq "array") {

        # Removed multi-insert capability because individual linking to
        # requested_array_slide_id's and array_name added and that makes
        # things more complicated.  Could still be added with additional
        # code functionality
        #return "slide_id" if ($info_key eq "MULTI_INSERT_COLUMN");

    }


###############################################################################
    if ($table_name eq "labeling") {

    }



###############################################################################
    if ($table_name eq "hybridization") {

    }



###############################################################################
    if ($table_name eq "array_scan") {

    }


###############################################################################
    if ($table_name eq "array_quantitation") {

    }


###############################################################################

    #### Obtain main SBEAMS object and fall back to its TableInfo handler
    my $sbeams = $self->getSBEAMS();
    my @temp_result = $sbeams->returnTableInfo($table_name,$info_key);
    return @temp_result;

}

1;

__END__
###############################################################################
###############################################################################
###############################################################################
