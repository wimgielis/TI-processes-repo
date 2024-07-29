601,100
602,"WG_SECURITY_transfer_security_group_membership"
562,"NULL"
586,
585,
564,
565,"y`[GE\Ju7e44E>2xo_0>NQ@A3aCjOrpv::ahf@kAK3E^3d?M`1GAnHukax@Gq<GolghL4N;Xz\X3^JbW?YuR^NKADK3kXuobSp8>hDfMA<BzWdZu4P2DT;yzuP07p`ZxfxB?bTaB79U0umYvVs?ud55sOIjUs:Ys3DdDG4qed\KhRauw[KZ\1S6oUaa9LVdRooos??sZ"
559,1
928,0
593,
594,
595,
597,
598,
596,
800,
801,
566,0
567,","
588,"."
589,","
568,""""
570,
571,
569,0
592,0
599,1000
560,2
pSourceUserName
pTargetUserName
561,2
2
2
590,2
pSourceUserName,"Jerome Leclercq"
pTargetUserName,"Planning Analytics/jerome.leclercq@eiffage.com"
637,2
pSourceUserName,"Source username ?"
pTargetUserName,"Target username ?"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,108

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# December 2023
# https://www.wimgielis.com
####################################################
#
# - copy the security group membership from 1 username to another
# - it is not needed to do a Security Refresh
# - the process requires either existing principal element names, either alias values, on the dimension }Clients
# - 
####################################################
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'WG_SECURITY_transfer_security_group_membership'
  , 'pSourceUserName', 'Gielis Wim'
  , 'pTargetUserName', 'Wim Gielis'
);
EndIf;
#EndRegion CallThisProcess


### Should you want to loop (and using an attribute to capture the target username):
###
### # If needed:
### # AttrInsert( '}Clients', '', 'Target user', 'S' );
### # AttrPutS( '...', '}Clients', '...', 'Target user' );
###
###
### sDim = '}Clients';
### nCtr = 1;
### While( nCtr <= Dimsiz( sDim ));
###
###    sEl = Dimnm( sDim, nCtr );
###
###    # sAttr = Attrs( sDim, sEl, 'Target user' );
###    sAttr = CellGetS( '}ElementAttributes_' | sDim, sEl, 'Target user' );
###
###    If( sAttr @<> '' );
###       nRet = ExecuteProcess( 'WG_SECURITY_transfer_security_group_membership'
###          , 'pSourceUserName', sEl
###          , 'pTargetUserName', sAttr );
###
###       If( nRet <> 0 );
###          ProcessQuit;
###       EndIf;
###
###    EndIf;
###
###    nCtr = nCtr + 1;
###
### End;



# Check the usernames

# Source
If( Dimix( '}Clients', pSourceUserName ) = 0 );
   LogOutput( 'INFO', Expand( 'The Source Username ''%pSourceUserName%'' does not exist in dimension ''}Clients''.' ));
   ProcessError;
EndIf;

# Target
If( Dimix( '}Clients', pTargetUserName ) = 0 );
   LogOutput( 'INFO', Expand( 'The Target Username ''%pTargetUserName%'' does not exist in dimension ''}Clients''.' ));
   ProcessError;
EndIf;

# Different usernames
If( Dimix( '}Clients', pSourceUserName ) = Dimix( '}Clients', pTargetUserName ));
   LogOutput( 'INFO', Expand( 'The Source and Target Usernames match: ''%pSourceUserName%'' and ''%pTargetUserName%''.' ));
   ProcessError;
EndIf;

pSourceUserName = DimensionElementPrincipalName( '}Clients', pSourceUserName );
pTargetUserName = DimensionElementPrincipalName( '}Clients', pTargetUserName );


# Retrieving security group membership and transfer
n = 1;
While( n <= Dimsiz( '}Groups' ));

   vGroup = Dimnm( '}Groups', n );
   vAccess_Src = CellGetS( '}ClientGroups', pSourceUserName, vGroup );

   If( CellIsUpdateable( '}ClientGroups', pTargetUserName, vGroup ) = 1 );
      CellPutS( vAccess_Src, '}ClientGroups', pTargetUserName, vGroup );
   Else;
      nErrors = 1;
      LogOutput( 'INFO', Expand( 'Unable to set the access of ''%vAccess_Src%'' for the Target username ''%pTargetUserName%'' due to a non-updateable cell for security group ''%vGroup%''. The Source username is ''%pSourceUserName%''.' ));
   EndIf;

   n = n + 1;
End;

If( nErrors > 0 );
   ProcessQuit; 
EndIf;
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,3

#****Begin: Generated Statements***
#****End: Generated Statements****
575,4

#****Begin: Generated Statements***
#****End: Generated Statements****

576,CubeAction=1511DataAction=1503CubeLogChanges=0_ParameterConstraints=e30=
930,0
638,1
804,0
1217,1
900,
901,
902,
938,0
937,
936,
935,
934,
932,0
933,0
903,
906,
929,
907,
908,
904,0
905,0
909,0
911,
912,
913,
914,
915,
916,
917,0
918,1
919,0
920,50000
921,""
922,""
923,0
924,""
925,""
926,""
927,""
