601,100
602,"TECH_folder for output"
562,"NULL"
586,
585,
564,
565,"ad5MTH?UryVDHX=B3m>:>cSsrKTRhLwPQxP_L>Yz\@IT4YHsN@p7T`JGESE9bdv5lvOUhif1DodLlhZ8Nc[mig4hCzdWLGzcPZBhHkNT<xtjia4ZDN_1yDTYP<evxI8E83RNe[ub1OqWw\zDBhe7uE0NAzH2u9;fd\Iv7\@Q7`g;dzixfmeNIuTH<sKm582]H5D2C:0e"
559,0
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
568,""
570,
571,
569,0
592,0
599,1000
560,2
pSubFolder
pMainFolder
561,2
2
2
590,2
pSubFolder,"X"
pMainFolder,"1"
637,2
pSubFolder,"Name of the subfolder ?"
pMainFolder,"Name (location) of the folder containing the subfolder ?"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,126

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# February 2022
# https://www.wimgielis.com
####################################################
#
# This process returns a destination folder (including path) that can be used in other TI processes.
# I very much like the idea of storing this logic in a separate TI process, rather than copy/paste in many other processes.
# Anytime we need a certain (temporary or permanent) location for AsciiOutput or similar functions,
# it's convenient to have it all in the same place rather than spread all over the file system.
# The process helps to set up a central folder with subfolders for any area, like "Debugging", "Actuals", "Metadata", "Exports", "model_upload" and so on.
# Having this logic spread over many processes is not a good solution.
#
# The main output folder (containing the subfolder(s)) will probably be the TM1 logging directory but it can be chosen.
# Hence, there is a parameter to overwrite this choice (pMainFolder):
# 1  = TM1 Logging directory (default choice)
# 1+ = A dedicated folder within the TM1 Logging directory
# 2  = TM1 Data directory
# 2+ = A dedicated folder within the TM1 Data directory
# 3  = A specific debugging folder
# 4  = The model_upload folder with PAoC
# Or you can specify your own full path to the directory
#
# Directories that do not exist will be created.
# Relative paths are supported.
# The TM1 Logging directory is the fallback folder.
#
# As this process very often uses "1+" as the main folder, to me it makes sense to have the subfolder as the first parameter
# and the main folder as the second parameter.
#
# I do know that a CellGetS to a system cube is not difficult either. Yet, I still see use cases for the current process.
# One reason: generic TI processes can't have a CellGetS built-in because that is dependent on the TM1 model and the presence of such system cube.
#
# ONLY tested on Windows. No changing of case is done for Linux, for instance.
#
####################################################
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output'
  , 'pSubFolder', 'Name of the subfolder'
  , 'pMainFolder', 'Name (location) of the folder containing the subfolder (1, 1+, 2, 2+, 3, 4, or a full path)'
);
vFile = cDestination_Folder | 'my file.txt';
AsciiOutput( vFile, 'test', '...' );
EndIf;
#EndRegion CallThisProcess


# Which destination folder do we want, and pass the value to the calling process ?
StringGlobalVariable( 'cDestination_Folder' );

# Trim spaces
pSubFolder = Trim( pSubFolder );
pMainFolder = Trim( pMainFolder );

# Main folder
If( pMainFolder @= '1' );
    # TM1 Logging directory
    pMainFolder = GetProcessErrorFileDirectory;
ElseIf( pMainFolder @= '1+' );
    # TM1 Logging directory with a dedicated subfolder (consistency over projects and servers)
    pMainFolder = GetProcessErrorFileDirectory | 'TM1 output\';
ElseIf( pMainFolder @= '2' );
    # TM1 Data directory
    pMainFolder = '.\';
ElseIf( pMainFolder @= '2+' );
    # TM1 Data directory with a dedicated subfolder (consistency over projects and servers)
    pMainFolder = '.\' | 'TM1 output\';
ElseIf( pMainFolder @= '3' );
    # a folder to be used for debugging
    pMainFolder = '..\Debug\' | 'TM1 output\';
ElseIf( pMainFolder @= '4' );
    # the model_upload folder with PAoC
    pMainFolder = '.\model_upload\';
EndIf;

# Main folder
If( Long( pMainFolder ) = 0 );

   cDestination_Folder = GetProcessErrorFileDirectory;
   LogOutput( 'ERROR', 'The ''pMainFolder'' parameter should not be empty. This process stops and the destination folder is the TM1 logging directory.' );
   ProcessError;

Else;

   # Subfolder
   If( Subst( pSubFolder, Long( pSubFolder ), 1 ) @= '\' );
      pSubFolder = Delet( pSubFolder, Long( pSubFolder ), 1 );
   EndIf;

   If( Long( pSubFolder ) = 0 );
      LogOutput( 'WARN', 'The ''pSubFolder'' parameter is allowed to be empty. The process continues but be careful.' );
   EndIf;

   # The full path
   # it should not contain double backslashes (path separator on Windows)
   cDestination_Folder = pMainFolder | If( pMainFolder @<> '', '\', '' ) | pSubFolder | If( pSubFolder @<> '', '\', '' );
   nCtr = Long( cDestination_Folder ) - 1;
   While( nCtr >= 1 );

      If( Subst( cDestination_Folder, nCtr, 2 ) @= '\\' );
      If( nCtr > 1 );
         cDestination_Folder = Delet( cDestination_Folder, nCtr + 1, 1 );
      EndIf;
      EndIf;

      nCtr = nCtr - 1;
   End;

   # Make sure the path exists
   If( FileExists( cDestination_Folder ) = 0 );
      ExecuteCommand( Expand( 'cmd /c "md "%cDestination_Folder%""' ), 1 );
   EndIf;

EndIf;
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,3

#****Begin: Generated Statements***
#****End: Generated Statements****
575,10

#****Begin: Generated Statements***
#****End: Generated Statements****


# Fallback solution with the TM1 logging directory
If( FileExists( cDestination_Folder ) = 0 );
   LogOutput( 'WARN', 'The destination folder is the TM1 logging directory since the destination folder (''' | cDestination_Folder | ''') does not exist and could not be created.' );
   cDestination_Folder = GetProcessErrorFileDirectory;
EndIf;
576,CubeAction=1511DataAction=1503CubeLogChanges=0
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
