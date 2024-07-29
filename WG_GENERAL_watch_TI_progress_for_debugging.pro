601,100
602,"WG_GENERAL_watch_TI_progress_for_debugging"
562,"NULL"
586,
585,
564,
565,"g5KrfC^a9i>CjJE9OknX8E[Q3_4_ApxW]DvuM@M[BmQ<QMzYbbQr:\^^yW]t7c:MoTta8T5LE6QwGOq9y:2]FK=?yQDPCk5D]3_77M95z_I=VJkJyQq1=`r?kzaaxy\AaKI5m2FF0mShNPu8Vu6HLEeakPiijn1_j^rRdyQtoe6g?;9>5`=xKA[@OKC@HF0HGXcF@Izk"
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
589,"."
568,""""
570,
571,
569,0
592,0
599,1000
560,0
561,0
590,0
637,0
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,183

#****Begin: Generated Statements***
#****End: Generated Statements****



#Region IntroduceThisProcess
####################################################
# Wim Gielis
# January 2024
# https://www.wimgielis.com
####################################################
#
# Code that you can apply in the different tabs of a TI process, to check and follow up on the progress of execution
# Code extended based on code by Andrew Scheevel (https://www.tm1forum.com/viewtopic.php?t=16623)
#
####################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


#######################################
#####  IF NOT USING MILLISECONDS  #####
#######################################


## START of the Prolog tab ##

nLogOut = 1;
nMaxRecords = 50000;
nLogInterval = 10000;
sFormat_Count = '#,##0';
sFormat_Time = '#,##0.0';
nStart = Now;
nCounter = 0;
If( nLogOut = 1 );
   LogOutput( 'WARN', 'Starting the process' );
EndIf;


## END of the Prolog tab) ##

nDuration = ( Now - nStart ) * 86400;
sDuration = NumberToStringEx( nDuration, sFormat_Time, ',', '.' );
LogOutput( 'WARN', Expand( 'Duration of the Prolog tab: %sDuration% seconds' ));


## START of the Metadata or Data tab ##

If( nCounter = 0 );
   If( nLogOut = 1 );
      LogOutput( 'WARN', 'Starting the Data tab' );
   EndIf;
   nStart = Now;

## Stop execution if nMaxRecords is reached
ElseIf( nCounter >= nMaxRecords );
   ProcessBreak;
EndIf;

nCounter = nCounter + 1;

If( nLogInterval > 0 );
   If( Mod( nCounter, nLogInterval ) = 0 );
      If( nLogOut = 1 );
         sCt = NumberToStringEx( nCounter, sFormat_Count, ',', '.' );
         LogOutput( 'WARN', Expand( ' we are at record %sCt%' ));
      EndIf;
   EndIf;
EndIf;

## Skip the rest of Data tab; useful for existing TI when just testing max throughput
## Comment out ItemSkip and rerun to then see impact of Data tab actions on throughput
ItemSkip;


## START of the Epilog tab ##

nDuration = ( Now - nStart ) * 86400;
nRecSec = nCounter \ nDuration;
sDuration = NumberToStringEx( nDuration, sFormat_Time, ',', '.' );
sRecSec = NumberToStringEx( nRecSec, sFormat_Time, ',', '.' );
sCt = NumberToStringEx( nCounter, sFormat_Count, ',', '.' );
LogOutput( 'WARN', Expand( 'Duration: %sDuration% seconds; Records: %sCt%; Records per second: %sRecSec%' ));



###################################
#####  IF USING MILLISECONDS  #####
###################################

# NOTE: PAW does not recognize the function MilliTime()
# Process can be saved and run but a warning is given when saving the process.


## START of the Prolog tab ##

nLogOut = 1;
nMaxRecords = 50000;
nLogInterval = 10000;
sFormat_Count = '#,##0';
sFormat_Time = '#,##0.0';
nStart = MilliTime;
nCounter = 0;
If( nLogOut = 1 );
   LogOutput( 'WARN', 'Starting the process' );
EndIf;


## END of the Prolog tab ##

nDuration = ( MilliTime - nStart ) / 1000;
sDuration = NumberToStringEx( nDuration, sFormat_Time, ',', '.' );
LogOutput( 'WARN', Expand( 'Duration of the Prolog tab: %sDuration% seconds' ));


## START of the Metadata or Data tab ##

If( nCounter = 0 );
   If( nLogOut = 1 );
      LogOutput( 'WARN', 'Starting the Data tab' );
   EndIf;
   nStart = MilliTime;

## Stop execution if nMaxRecords is reached
ElseIf( nCounter >= nMaxRecords );
   ProcessBreak;
EndIf;

nCounter = nCounter + 1;

If( nLogInterval > 0 );
   If( Mod( nCounter, nLogInterval ) = 0 );
      If( nLogOut = 1 );
         sCt = NumberToStringEx( nCounter, sFormat_Count, ',', '.' );
         LogOutput( 'WARN', Expand( ' we are at record %sCt%' ));
      EndIf;
   EndIf;
EndIf;

## Skip the rest of Data tab; useful for existing TI when just testing max throughput
## Comment out ItemSkip and rerun to then see impact of Data tab actions on throughput
ItemSkip;


## START of the Epilog tab ##

nDuration = ( MilliTime - nStart ) / 1000;
nRecSec = nCounter \ nDuration;
sDuration = NumberToStringEx( nDuration, sFormat_Time, ',', '.' );
sRecSec = NumberToStringEx( nRecSec, sFormat_Time, ',', '.' );
sCt = NumberToStringEx( nCounter, sFormat_Count, ',', '.' );
LogOutput( 'WARN', Expand( 'Duration: %sDuration% seconds; Records: %sCt%; Records per second: %sRecSec%' ));



###################################
##### IF NOT TIMING THROUGHPUT / TIMING CERTAIN PARTS OF THE CODE #####
###################################

# NOTE: PAW does not recognize the function MilliTime()
# Process can be saved and run but a warning is given when saving the process.


## START of the timed part of the code ##

sFormat_Time = '#,##0.0';
nStart = MilliTime;
nLogOut = 1;
If( nLogOut = 1 );
   LogOutput( 'WARN', 'Starting the timer' );
EndIf;


## END of the timed part of the code ##

nDuration = ( MilliTime - nStart ) / 1000;
sDuration = NumberToStringEx( nDuration, sFormat_Time, ',', '.' );
LogOutput( 'WARN', Expand( 'Ending the timer. Duration: %sDuration% seconds' ));
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
1217,0
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
