601,100
602,"WG_SYSTEM_chore_at_irregular_times"
562,"NULL"
586,
585,
564,
565,"kMFJAtzMgz1aV716rj6xdEdEnp]Cf5SlE8pSm<gC=98DwT7F8y3LPwda6\[bMsp69:5lItGlA<i_XPVC=C7vQpS;rgnTX3PZ6b@MVaH=EJ^:E9:k3zp4bG68;Kq_BL<Z8^<Af;=3WGaJieZugTw@Z34Hx5IlNd4V<6egg;=2_xVIEZH8g8teKnyAi1xEJKLk<ICTOY5<"
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
588,","
589," "
568,""""
570,
571,
569,0
592,0
599,1000
560,2
pChore_Times
pCheckChoreRunTimes
561,2
2
1
590,2
pChore_Times,"00:00_06:00_12:00_20:00"
pCheckChoreRunTimes,1
637,2
pChore_Times,"Chore run times ? ( separate with _ and format is hh:mm )"
pCheckChoreRunTimes,"Should the process check the chore run times and stop if not satisfied ? ( 1 = Yes, all else = No )"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,77

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# August 2017
# https://www.wimgielis.com
####################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


If( pCheckChoreRunTimes = 1 );

   # Make sure the chore times end with a _
   vChore_Times = Trim( pChore_Times );
   If( Subst( vChore_Times, Long( vChore_Times ), 1 ) @<> '_' );
      vChore_Times = vChore_Times | '_';
   EndIf;

   # Now as decimal number, without the day
   vNow = Timvl( Now, 'H' ) * 60 + Timvl( Now, 'I' );

   # variables
   vTimeFound = 0;

   # loop over the chore times to see if it matches
   While( Long( vChore_Times ) > 0 );

      vChore_Time_S = Subst( vChore_Times, 1, Scan('_', vChore_Times) - 1);
      If( Long( vChore_Time_S ) = 5 );
      If( Subst( vChore_Time_S, 3, 1 ) @= ':' );

         # the chore time as a decimal number (without the day)
         vChore_Time_N = StringToNumber( Subst( vChore_Time_S, 1, 2 )) * 60 + StringToNumber( Subst( vChore_Time_S, 4, 2 ));

         # allow for a difference of (at most) 3 minutes between now and the run time of the chore
         If( Abs( vChore_Time_N - vNow ) <= 3 );
            vTimeFound = 1;
            Break;
         EndIf;

      EndIf;
      EndIf;

      vChore_Times = Delet( vChore_Times, 1, Scan('_', vChore_Times ));

   End;


   # Where do we output text files ?
   StringGlobalVariable( 'cDestination_Folder' );
   ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Chore at irregular times', 'pMainFolder', '1+' );

   If( vTimeFound = 0 );
      vFile = cDestination_Folder | 'At ' | Timst( Now, '\Y\m\d \h\i') | ' the chore will not run.txt';
   Else;
      vFile = cDestination_Folder | 'At ' | Timst( Now, '\Y\m\d \h\i') | ' the chore will run.txt';
   EndIf;
   TextOutput( vFile, '' );

EndIf;


# if a match, run the chore, if not, stop
If( vTimeFound = 1 % pCheckChoreRunTimes <> 1 );
   SaveDataAll;
Else;
   # ProcessQuit;
EndIf;
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,3

#****Begin: Generated Statements***
#****End: Generated Statements****
575,3

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
