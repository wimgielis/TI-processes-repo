601,100
602,"WG_WRITE_CODE_transfer_data_by_measure"
562,"NULL"
586,
585,
564,
565,"hLdwcwlGa:RRy61:x\LEg1oNvJdzMNLTNtGX>]TTJTX`NxuRkytfLJdJQbhvVOSXfNOaK=7mpf[jPHgx[a]Uo^D@xGQYg:ZNG08iB:5k5\]EtM1K9Ragivyd9[8l=aMr>`NyePlB9fIqGGl=3:zzUl1fMsybKX[Pa>:ae\@qQz<\vmfY5RAf6y<Jue2rhqSGV]hKR3cW"
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
560,13
pCube_Src
pCube_Tgt
pMode
pFileName
pPrefix_Variable
pNested_Functions
pNotNested_Variables_Are_Numbers
pCumulative
pAdd_Data_Type_Check
pAdd_Code_For_Next_Line
pChars_To_Remove
pChars_To_Replace
pChars_To_Replace_With
561,13
2
2
2
2
2
1
1
1
1
1
2
2
2
590,13
pCube_Src,""
pCube_Tgt,""
pMode,"A"
pFileName,"test.pro"
pPrefix_Variable,"v"
pNested_Functions,0
pNotNested_Variables_Are_Numbers,0
pCumulative,0
pAdd_Data_Type_Check,0
pAdd_Code_For_Next_Line,0
pChars_To_Remove," "
pChars_To_Replace,"-%&"
pChars_To_Replace_With,"___"
637,13
pCube_Src,"Source cube name ?"
pCube_Tgt,"Target cube name ?"
pMode,"Mode ? (A, B or C - see inside the process for configuration details)"
pFileName,"Filename ?"
pPrefix_Variable,"Prefix for variables names ?"
pNested_Functions,"Nested cube access functions ? (0 = No, all else = Yes)"
pNotNested_Variables_Are_Numbers,"In the case of non-nested output, should the variables contain incrementing numbers or names ? (0 = No, all else = Yes)"
pCumulative,"Cumulative data loading in the target cube ? (0 = No, all else = Yes)"
pAdd_Data_Type_Check,"Do you want to add checks for non-numeric elements ? (0 = No, all else = Yes)"
pAdd_Code_For_Next_Line,"Add boilerplate code to loop for the next open line ? (0 = No, all else = Yes)"
pChars_To_Remove,"Which characters from dimension names to remove to get corresponding variables names ?"
pChars_To_Replace,"Which characters from dimension names to replace to get corresponding variables names ?"
pChars_To_Replace_With,"Which characters from dimension names to replace with to get corresponding variables names ?"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,1020

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# December 2022
# https://www.wimgielis.com
####################################################
#
# Use this process to generate TI code to transfer data on measures.
# It's the typical code of:
# - Advanced > Prolog tab creates a view containing the source data slice
# - Advanced > Prolog tab creates a view to clear data in the target slice
# - Advanced > Metadata tab does nothing (or very little)
# - Advanced > Data tab does all kind of cell retrieves and cell updates. Measures names are hardcoded and must be copy/pasted. It's tedious. hardcoded names for measures on both source and target cubes.
# - Advanced > Epilog tab does nothing (or very little)
#
# The Data tab can contain several flavours of this kind of code.
# Lately, I got very bored of writing this kind of code over and over again so I wrote this helper process.
#
# Parameter explanations:
#
# * 'pCube_Src' and 'pCube_Tgt' are intuitive. pCube_Src should exist. pCube_Src and pCube_Tgt can be equal, we have an intra-cube copy in that case.
#   If pCube_Tgt is empty, then the source cube name will be considered also the target cube name for an intra-cube copy.
#
# * 'pFileName' is the file name for the text file generated in (a subfolder of) the TM1 logging directory.
#
# * 'pMode' stands for 3 different output flavours:
#   -  mode A: when the source view contains all measures instead of just 1. The output of code is much more condensed rather than hardcoding measure element names. This option cancels out some other parameter values.
#   -  mode B: when the source view contains just 1 measure and all measure element names are hardcoded in the output.
#   -  mode C: when the source view contains just 1 measure and all measure element names are retrieved through a dimension loop in the output.
# For the specific configurations in the output, see below.
#
# * 'pCumulative' (0 = No, all else = Yes): do you want code to increment to existing values in the receiving slice, or not (overwriting existing values) ?
#
# * 'pNested_Functions' (0 = No, all else = Yes):
#       parameter value not 0: CellPutN( CellGetN( vCube_Src, vYear, 'Bonus Percentage' ), vCube_Tgt, vYear, 'Bonus Percentage' );
#       parameter value     0: V1 = CellGetN( vCube_Src, vYear, 'Bonus Percentage' );
#                              CellPutN( V1, vCube_Tgt, vYear, 'Bonus Percentage' );
#
# * 'pNotNested_Variables_Are_Numbers' (0 = No, all else = Yes):
#       parameter value not 0: V1 = ...;
#                              CellPutN( V1, ... );
#       parameter value     0: vBonus_Percentage = ...;
#                              CellPutN( vBonus_Percentage, ... );
#
# * 'pAdd_Code_For_Next_Line' (0 = No, all else = Yes): typically, we need to find a certain line number to write the data to. This code can be generated as well.
#
# * 'pPrefix_Variable': variables are created out of dimension names. Usually, this is a lower case "v" or empty. When used in variables that are numbers, we use upper case "V".
#
# * 'pAdd_Data_Type_Check': (0 = No, all else = Yes): typically, we transfer numeric data. If string data is possible, then set this parameter value different from 0.
#
# * 'pChars_To_Remove': when creating variables names out of dimension names, which characters to remove from dimension names ? (for instance, spaces to be removed)
#
# * 'pChars_To_Replace' and 'pChars_To_Replace_With': when creating variables names out of dimension names, which characters to replace by which other character ? (for instance, dashes replace by underscores)
#
# The measures dimensions are considered the be last dimension of the respective cube, unless a different dimension is marked as measures dimension for the cube.
#
# Future improvements to the code:
# - If it is feasible: instead of transferring by measure, have another dimension to be sliced ? For instance, data by account from a source cube to a target cube
# - If it is an improvement: using the Expand function for the mask, including a check that the % character does not occur in the cube or dimension names
#
####################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'WG_WRITE_CODE_transfer_data_by_measure'
  , 'pCube_Src', ''
  , 'pCube_Tgt', ''
  , 'pMode', 'A / B / C'
  , 'pFileName', 'output.pro'
  , 'pPrefix_Variable', 'v'
  , 'pNested_Functions', 1
  , 'pNotNested_Variables_Are_Numbers', 1
  , 'pCumulative', 1
  , 'pAdd_Data_Type_Check', 1
  , 'pAdd_Code_For_Next_Line', 1
  , 'pChars_To_Remove', ' '
  , 'pChars_To_Replace', '-%&'
  , 'pChars_To_Replace_With', '___'
);

# To see what some of the various configurations can bring you in terms of output, run the below code on your cubes:
# [Uncomment the code for the legend below for further insights into the parameter values]

S = 'Activity';
T = 'Activity_Analysis';


ExecuteProcess( 'WG_WRITE_CODE_transfer_data_by_measure', 'pCube_Src', S, 'pCube_Tgt', T, 'pMode', 'A', 'pFileName', 'test1.pro', 'pPrefix_Variable', 'v', 'pNested_Functions', 1, 'pNotNested_Variables_Are_Numbers', 0, 'pCumulative', 1, 'pAdd_Data_Type_Check', 1, 'pAdd_Code_For_Next_Line', 1, 'pChars_To_Remove', ' ', 'pChars_To_Replace', '-%&', 'pChars_To_Replace_With', '___' );

ExecuteProcess( 'WG_WRITE_CODE_transfer_data_by_measure', 'pCube_Src', S, 'pCube_Tgt', T, 'pMode', 'B', 'pFileName', 'test2.pro', 'pPrefix_Variable', 'v', 'pNested_Functions', 0, 'pNotNested_Variables_Are_Numbers', 0, 'pCumulative', 1, 'pAdd_Data_Type_Check', 1, 'pAdd_Code_For_Next_Line', 1, 'pChars_To_Remove', ' ', 'pChars_To_Replace', '-%&', 'pChars_To_Replace_With', '___' );
ExecuteProcess( 'WG_WRITE_CODE_transfer_data_by_measure', 'pCube_Src', S, 'pCube_Tgt', T, 'pMode', 'B', 'pFileName', 'test3.pro', 'pPrefix_Variable', 'v', 'pNested_Functions', 1, 'pNotNested_Variables_Are_Numbers', 0, 'pCumulative', 1, 'pAdd_Data_Type_Check', 1, 'pAdd_Code_For_Next_Line', 1, 'pChars_To_Remove', ' ', 'pChars_To_Replace', '-%&', 'pChars_To_Replace_With', '___' );

ExecuteProcess( 'WG_WRITE_CODE_transfer_data_by_measure', 'pCube_Src', S, 'pCube_Tgt', T, 'pMode', 'C', 'pFileName', 'test4.pro', 'pPrefix_Variable', 'v', 'pNested_Functions', 0, 'pNotNested_Variables_Are_Numbers', 0, 'pCumulative', 1, 'pAdd_Data_Type_Check', 1, 'pAdd_Code_For_Next_Line', 1, 'pChars_To_Remove', ' ', 'pChars_To_Replace', '-%&', 'pChars_To_Replace_With', '___' );
ExecuteProcess( 'WG_WRITE_CODE_transfer_data_by_measure', 'pCube_Src', S, 'pCube_Tgt', T, 'pMode', 'C', 'pFileName', 'test5.pro', 'pPrefix_Variable', 'v', 'pNested_Functions', 0, 'pNotNested_Variables_Are_Numbers', 1, 'pCumulative', 1, 'pAdd_Data_Type_Check', 1, 'pAdd_Code_For_Next_Line', 1, 'pChars_To_Remove', ' ', 'pChars_To_Replace', '-%&', 'pChars_To_Replace_With', '___' );
ExecuteProcess( 'WG_WRITE_CODE_transfer_data_by_measure', 'pCube_Src', S, 'pCube_Tgt', T, 'pMode', 'C', 'pFileName', 'test6.pro', 'pPrefix_Variable', 'v', 'pNested_Functions', 1, 'pNotNested_Variables_Are_Numbers', 0, 'pCumulative', 1, 'pAdd_Data_Type_Check', 1, 'pAdd_Code_For_Next_Line', 1, 'pChars_To_Remove', ' ', 'pChars_To_Replace', '-%&', 'pChars_To_Replace_With', '___' );

EndIf;
#EndRegion CallThisProcess


If( pFileName @= '' );
   LogOutput( 'ERROR', 'The file name is empty.' );
   ProcessError;
EndIf;

pMode = Upper( Trim( pMode ));
If( pMode @<> 'A'
  & pMode @<> 'B'
  & pMode @<> 'C' );
   LogOutput( 'ERROR', 'The ''pMode'' parameter should be either ''A'', ''B'' or ''C''.' );
   ProcessError;
EndIf;

If( Long( pChars_To_Replace ) <> Long( pChars_To_Replace_With ));
   LogOutput( 'ERROR', 'The parameter values for ''pChars_To_Replace'' and ''pChars_To_Replace_With'' should have an equal length. The provided values are ''' | pChars_To_Replace | ''' and ''' | pChars_To_Replace_With | '''.' );
   ProcessError;
EndIf;


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Code to transfer data by measure', 'pMainFolder', '1+' );

vFile = cDestination_Folder | pFileName;


DatasourceASCIIQuoteCharacter = '';

# TextOutput( vFile, '' );
# TextOutput( vFile, '# LEGEND:' );
# TextOutput( vFile, '' );
# TextOutput( vFile, '# Source cube: ' | pCube_Src );
# TextOutput( vFile, '# Target cube: ' | pCube_Tgt );
# TextOutput( vFile, '# Output mode: ' | pMode );
# TextOutput( vFile, '# Filename: ' | pFileName );
# TextOutput( vFile, '# Prefix for variables names: ' | pPrefix_Variable );
# TextOutput( vFile, '' );
# TextOutput( vFile, '# Nested functions: ' | NumberToString( pNested_Functions ));
# TextOutput( vFile, '# Cumulative data loading: ' | NumberToString( pCumulative ));
# TextOutput( vFile, '# Nested variables are numbers: ' | NumberToString( pNotNested_Variables_Are_Numbers ));
# TextOutput( vFile, '# Adding data type checks: ' | NumberToString( pAdd_Data_Type_Check ));
# TextOutput( vFile, '# Add code for the next line: ' | NumberToString( pAdd_Code_For_Next_Line ));
# TextOutput( vFile, '' );
# TextOutput( vFile, '' );
# TextOutput( vFile, '' );


# Validate the parameters
pCube_Src = Trim( pCube_Src );
pCube_Tgt = Trim( pCube_Tgt );

If( CubeExists( pCube_Src ) = 0 );
   LogOutput( 'ERROR', 'The cube ''' | pCube_Src | ''' does not exist. Please investigate.' );
   ProcessError;
Else;
   vCube_Src = DimensionElementPrincipalName( '}Cubes', pCube_Src );
EndIf;

If( pCube_Tgt @= '' );
   vCube_Tgt = vCube_Src;
Else;
   If( CubeExists( pCube_Tgt ) = 0 );
      LogOutput( 'ERROR', 'The cube ''' | pCube_Tgt | ''' does not exist. Please investigate.' );
      ProcessError;
   Else;
      vCube_Tgt = DimensionElementPrincipalName( '}Cubes', pCube_Tgt );
   EndIf;
EndIf;

# The measures dimensions for the cubes
vDim_Msr_Src = CellGetS( '}CubeProperties', vCube_Src, 'MEASURES_DIMENSION' );
If( Dimix( '}Dimensions', vDim_Msr_Src ) = 0 );
   vDim_Msr_Src = Tabdim( vCube_Src, CubeDimensionCountGet( vCube_Src ));
EndIf;
vDim_Msr_Tgt = CellGetS( '}CubeProperties', vCube_Tgt, 'MEASURES_DIMENSION' );
If( Dimix( '}Dimensions', vDim_Msr_Tgt ) = 0 );
   vDim_Msr_Tgt = Tabdim( vCube_Tgt, CubeDimensionCountGet( vCube_Tgt ));
EndIf;

# The cube names (variables) in the generated code output
vCube_Src_InTheCode = pPrefix_Variable | 'Cube_Src';
vCube_Tgt_InTheCode = pPrefix_Variable | 'Cube_Tgt';

If( vCube_Src @= vCube_Tgt );
   vCube_Src_InTheCode = pPrefix_Variable | 'Cube';
   vCube_Tgt_InTheCode = pPrefix_Variable | 'Cube';
EndIf;


# Intermezzo: create a mask for the dimensions of the source cube
vMask_Cube_Src = '/ = CellGet\( ' | vCube_Src_InTheCode | ', ';

d = 1;
While( d <= CubeDimensionCountGet( vCube_Src ));

   vDim = Tabdim( vCube_Src, d );

   If( Dimix( '}Dimensions', vDim ) <> Dimix( '}Dimensions', vDim_Msr_Src ));

      # Rework the dimension names in the source cube, except the measures dimension
      Chars_To_Remove = pChars_To_Remove;
      While( Long( Chars_To_Remove ) > 0 );
         Char_To_Remove = Subst( Chars_To_Remove, 1, 1 );
         While( Scan( Char_To_Remove, vDim ) > 0 );
            vScan = Scan( Char_To_Remove, vDim );
            vDim = Delet( vDim, vScan, 1 );
         End;
         Chars_To_Remove = Delet( Chars_To_Remove, 1, 1 );
      End;

      Chars_To_Replace = pChars_To_Replace;
      Chars_To_Replace_With = pChars_To_Replace_With;
      While( Long( Chars_To_Replace ) > 0 );
         Char_To_Replace = Subst( Chars_To_Replace, 1, 1 );
         While( Scan( Char_To_Replace, vDim ) > 0 );
            vScan = Scan( Char_To_Replace, vDim );
            vDim = Delet( vDim, vScan, 1 );
            vDim = Insrt( Subst( Chars_To_Replace_With, 1, 1 ), vDim, vScan );
         End;
         Chars_To_Replace = Delet( Chars_To_Replace, 1, 1 );
         Chars_To_Replace_With = Delet( Chars_To_Replace_With, 1, 1 );
      End;

      vMask_Cube_Src = vMask_Cube_Src | pPrefix_Variable | vDim | ', ';

   EndIf;

   d = d + 1;

End;

vMask_Cube_Src = vMask_Cube_Src | '''§'' )';


# Intermezzo: create a mask for the dimensions of the target cube
vMask_Cube_Tgt = 'Cell\( /, ' | vCube_Tgt_InTheCode | ', ';

d = 1;
While( d <= CubeDimensionCountGet( vCube_Tgt ) - 1 );

   vDim = Tabdim( vCube_Tgt, d );

   If( Dimix( '}Dimensions', vDim ) <> Dimix( '}Dimensions', vDim_Msr_Tgt ));

      # Rework the dimension names in the target cube, except the measures dimension
      Chars_To_Remove = pChars_To_Remove;
      While( Long( Chars_To_Remove ) > 0 );
         Char_To_Remove = Subst( Chars_To_Remove, 1, 1 );
         While( Scan( Char_To_Remove, vDim ) > 0 );
            vScan_2 = Scan( Char_To_Remove, vDim );
            vDim = Delet( vDim, vScan_2, 1 );
         End;
         Chars_To_Remove = Delet( Chars_To_Remove, 1, 1 );
      End;

      Chars_To_Replace = pChars_To_Replace;
      Chars_To_Replace_With = pChars_To_Replace_With;
      While( Long( Chars_To_Replace ) > 0 );
         Char_To_Replace = Subst( Chars_To_Replace, 1, 1 );
         While( Scan( Char_To_Replace, vDim ) > 0 );
            vScan_2 = Scan( Char_To_Replace, vDim );
            vDim = Delet( vDim, vScan_2, 1 );
            vDim = Insrt( Subst( Chars_To_Replace_With, 1, 1 ), vDim, vScan_2 );
         End;
         Chars_To_Replace = Delet( Chars_To_Replace, 1, 1 );
         Chars_To_Replace_With = Delet( Chars_To_Replace_With, 1, 1 );
      End;

      vMask_Cube_Tgt = vMask_Cube_Tgt | pPrefix_Variable | vDim | ', ';

   EndIf;

   d = d + 1;

End;

vMask_Cube_Tgt = vMask_Cube_Tgt | '''§'' );';



# Continue the text file output
If( vCube_Src @= vCube_Tgt );
   TextOutput( vFile, vCube_Src_InTheCode | ' = ''' | vCube_Src | ''';' );
Else;
   TextOutput( vFile, vCube_Src_InTheCode | ' = ''' | vCube_Src | ''';' );
   TextOutput( vFile, vCube_Tgt_InTheCode | ' = ''' | vCube_Tgt | ''';' );
EndIf;


If( vCube_Src @= vCube_Tgt );

   TextOutput( vFile, '' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '### As both cubes coincide and this is an intra-cube copy process,' );
   TextOutput( vFile, '### ADJUST the code below to read from and write to different cube intersections !' );
   TextOutput( vFile, '### If not, you might end up with data losses or data duplications !' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '' );

EndIf;


TextOutput( vFile, '' );
TextOutput( vFile, 'CellPutS( ''NO'', ''}CubeProperties'', ' | vCube_Tgt_InTheCode | ', ''LOGGING'' );' );
TextOutput( vFile, '' );

If( pAdd_Code_For_Next_Line = 1 );

   TextOutput( vFile, '' );
   TextOutput( vFile, '# Find the next line to output to' );
   TextOutput( vFile, '' );
   TextOutput( vFile, 'cParent = ''All Lines'';' );
   TextOutput( vFile, '' );
   TextOutput( vFile, 'n = 1;' );
   TextOutput( vFile, 'While( n <= ElcompN( ''Cm_Line'', cParent ));' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '   ' | pPrefix_Variable | 'Line = Elcomp( ''Cm_Line'', cParent, n );' );
   TextOutput( vFile, '' );

   # Is it CellGetN or CellGetS, likewise, CellPutN or CellPutS or CellIncrementN ?
   vType = 'N';
   # vType = 'S';

   # Insert pieces of text in the relevant places
   sMask_Cube_Src = vMask_Cube_Src;

   sMask_Cube_Src = Delet( sMask_Cube_Src, 1, 4 );

   vScan = Scan( '''§''', sMask_Cube_Src );
   sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 3 );
   sMask_Cube_Src = Insrt( pPrefix_Variable | 'Line, ''Counter''', sMask_Cube_Src, vScan );
   # sMask_Cube_Src = Insrt( 'Used', sMask_Cube_Src, vScan );

   vScan = Scan( '\', sMask_Cube_Src );
   sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
   sMask_Cube_Src = Insrt( vType, sMask_Cube_Src, vScan );

   TextOutput( vFile, '   If( ' | sMask_Cube_Src | ' = 0 );' );
   # TextOutput( vFile, '   If( ' | sMask_Cube_Src | ' @= '''' );' );

   TextOutput( vFile, '      Break;' );
   TextOutput( vFile, '   EndIf;' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '   n = n + 1;' );
   TextOutput( vFile, 'End;' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '# OR:' );

   vScan = Scan( pPrefix_Variable | 'Line, ''Counter''', sMask_Cube_Src );
   sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, Long( pPrefix_Variable | 'Line' ));
   sMask_Cube_Src = Insrt( 'cParent', sMask_Cube_Src, vScan );

   TextOutput( vFile, pPrefix_Variable | 'Line = ''Line '' | NumberToString( ' | sMask_Cube_Src | ' + 1 );' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '### ADJUST the code below to use ''' | pPrefix_Variable | 'Line'' !' );
   TextOutput( vFile, '### ADJUST the code below to put a 1 in the measure ''Counter'' ! (or similar coding)' );
   TextOutput( vFile, '### ADJUST the code below to create a new line if the last line is populated ! If not, data is possibly inconsistent !' );
   TextOutput( vFile, '' );

EndIf;


TextOutput( vFile, '' );
TextOutput( vFile, '# Retrieve and transfer values' );
TextOutput( vFile, '' );



If( pMode @= 'A' );

   # The source view contains all measures, the output code is condensed

   ########################
   # OUTPUT IS AS FOLLOWS
   ########################

   # Example:
   #
   # If( Dimix( 'Tgt msr dim', vMsr ) > 0 );
   #    If( CellIsUpdateable( vCube_Tgt, vYear, vMsr ) = 1 );
   #        If( Value_Is_String = 1 );
   #            CellPutS( SValue, vCube_Tgt, vYear, vMsr );
   #        Else;
   #            CellPutN( NValue, vCube_Tgt, vYear, vMsr );
   #            Or:
   #            CellIncrementN( NValue, vCube_Tgt, vYear, vMsr );
   #        EndIf;
   #    Else;
   #       AsciiOutput( 'test.txt', '' );
   #    EndIf;
   # Else;
   #    AsciiOutput( 'test.txt', '' );
   # EndIf;


   # Rework the dimension names in the target cube, except the measures dimension
   vDim = vDim_Msr_Src;

   Chars_To_Remove = pChars_To_Remove;
   While( Long( Chars_To_Remove ) > 0 );
      Char_To_Remove = Subst( Chars_To_Remove, 1, 1 );
      While( Scan( Char_To_Remove, vDim ) > 0 );
         vScan_2 = Scan( Char_To_Remove, vDim );
         vDim = Delet( vDim, vScan_2, 1 );
      End;
      Chars_To_Remove = Delet( Chars_To_Remove, 1, 1 );
   End;

   Chars_To_Replace = pChars_To_Replace;
   Chars_To_Replace_With = pChars_To_Replace_With;
   While( Long( Chars_To_Replace ) > 0 );
      Char_To_Replace = Subst( Chars_To_Replace, 1, 1 );
      While( Scan( Char_To_Replace, vDim ) > 0 );
         vScan_2 = Scan( Char_To_Replace, vDim );
         vDim = Delet( vDim, vScan_2, 1 );
         vDim = Insrt( Subst( Chars_To_Replace_With, 1, 1 ), vDim, vScan_2 );
      End;
      Chars_To_Replace = Delet( Chars_To_Replace, 1, 1 );
      Chars_To_Replace_With = Delet( Chars_To_Replace_With, 1, 1 );
   End;

   vDim = pPrefix_Variable | vDim;

   # Insert pieces of text in the relevant places

   # For the target side
   sMask_Cube_Tgt = vMask_Cube_Tgt;

   vScan = Scan( '''§''', sMask_Cube_Tgt );
   sMask_Cube_Tgt = Delet( sMask_Cube_Tgt, vScan, 3 );
   sMask_Cube_Tgt = Insrt( vDim, sMask_Cube_Tgt, vScan );

   TextOutput( vFile, 'If( Dimix( ''' | vDim_Msr_Tgt | ''', ' | vDim | ' ) > 0 );' );
   TextOutput( vFile, '' );

   # part 1: CellIsUpdateable
   sMask_Cube_Tgt_P1 = sMask_Cube_Tgt;

   vScan = Scan( '/', sMask_Cube_Tgt_P1 );
   sMask_Cube_Tgt_P1 = Delet( sMask_Cube_Tgt_P1, vScan, 1 );
   sMask_Cube_Tgt_P1 = Delet( sMask_Cube_Tgt_P1, vScan, 2 );

   vScan = Scan( '\', sMask_Cube_Tgt_P1 );
   sMask_Cube_Tgt_P1 = Delet( sMask_Cube_Tgt_P1, vScan, 1 );
   sMask_Cube_Tgt_P1 = Insrt( 'IsUpdateable', sMask_Cube_Tgt_P1, vScan );

   vScan = Scan( ');', sMask_Cube_Tgt_P1 );
   sMask_Cube_Tgt_P1 = Insrt( ') = 1 ', sMask_Cube_Tgt_P1, vScan );

   sMask_Cube_Tgt_P1 = Insrt( 'If( ', sMask_Cube_Tgt_P1, 1 );

   TextOutput( vFile, '   ' | sMask_Cube_Tgt_P1 );
   If( pAdd_Data_Type_Check <> 0 );
   TextOutput( vFile, '      If( Value_Is_String = 1 );' );
   Else;
   TextOutput( vFile, '      If( Dtype( ''' | vDim_Msr_Tgt | ''', ' | vDim | ' ) @<> ''S'' );' );
   EndIf;

   # part 2: CellPutS
   sMask_Cube_Tgt_P2 = sMask_Cube_Tgt;

   vScan = Scan( '/', sMask_Cube_Tgt_P2 );
   sMask_Cube_Tgt_P2 = Delet( sMask_Cube_Tgt_P2, vScan, 1 );
   sMask_Cube_Tgt_P2 = Insrt( 'SValue', sMask_Cube_Tgt_P2, vScan );

   vScan = Scan( '\', sMask_Cube_Tgt_P2 );
   sMask_Cube_Tgt_P2 = Delet( sMask_Cube_Tgt_P2, vScan, 1 );
   sMask_Cube_Tgt_P2 = Insrt( 'PutS', sMask_Cube_Tgt_P2, vScan );

   If( pAdd_Data_Type_Check <> 0 );
   TextOutput( vFile, '         ' | sMask_Cube_Tgt_P2 );
   EndIf;

   If( pAdd_Data_Type_Check <> 0 );
   TextOutput( vFile, '      Else;' );
   EndIf;

   # part 3: CellPutN/CellIncrementN
   If( pCumulative = 0 );
      vCumulative = 'PutN';
   Else;
      vCumulative = 'IncrementN';
   EndIf;

   sMask_Cube_Tgt_P3 = sMask_Cube_Tgt;

   vScan = Scan( '/', sMask_Cube_Tgt_P3 );
   sMask_Cube_Tgt_P3 = Delet( sMask_Cube_Tgt_P3, vScan, 1 );
   sMask_Cube_Tgt_P3 = Insrt( 'NValue', sMask_Cube_Tgt_P3, vScan );

   vScan = Scan( '\', sMask_Cube_Tgt_P3 );
   sMask_Cube_Tgt_P3 = Delet( sMask_Cube_Tgt_P3, vScan, 1 );
   sMask_Cube_Tgt_P3 = Insrt( vCumulative, sMask_Cube_Tgt_P3, vScan );

   TextOutput( vFile, '         ' | sMask_Cube_Tgt_P3 );

   If( pAdd_Data_Type_Check <> 0 );
   TextOutput( vFile, '      EndIf;' );
   Else;
   TextOutput( vFile, '      EndIf;' );
   EndIf;

   TextOutput( vFile, '' );
   TextOutput( vFile, '   Else;' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '      AsciiOutput( ''test.txt'', '''' );' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '   EndIf;' );
   TextOutput( vFile, '' );
   TextOutput( vFile, 'Else;' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '   AsciiOutput( ''missing measures.txt'', '''' );' );
   TextOutput( vFile, '' );
   TextOutput( vFile, 'EndIf;' );


ElseIf( pMode @= 'B' );

   # The source view contains 1 measure, the output code is generated by looping in the code over the measures

   ########################
   # OUTPUT IS AS FOLLOWS
   ########################

   # Example:
   #
   # m = 1;
   # While( m <= Dimsiz( vDim ));
   #
   #    vMsr = Dimnm( vDim, m );
   #    vMsr_Tgt = Attrs( vDim, vMsr, 'Mapped measure' );
   #
   #    If( CellIsUpdateable( vCube_Tgt, vYear, vMsr_Tgt ) = 1 );
   #        If( Dtype( vDim, vMsr_Tgt ) @= 'S' );
   #            vText = CellGetS( vCube_Src, vYear, vMsr );
   #            CellPutS( vText, vCube_Tgt, vYear, vMsr_Tgt );
   #            Or:
   #            CellPutS( CellGetS( vCube_Src, vYear, vMsr ), vCube_Tgt, vYear, vMsr_Tgt );
   #        Else;
   #            vNumber = CellGetN( vCube_Src, vYear, vMsr );
   #            CellPutN( vNumber, vCube_Tgt, vYear, vMsr_Tgt );
   #            Or:
   #            CellPutN( CellGetN( vCube_Src, vYear, vMsr ), vCube_Tgt, vYear, vMsr_Tgt );
   #            CellIncrementN( CellGetN( vCube_Src, vYear, vMsr ), vCube_Tgt, vYear, vMsr_Tgt );
   #        EndIf;
   #    Else;
   #       AsciiOutput( 'test.txt', '' );
   #    EndIf;
   #
   #    m = m + 1;
   #
   # End;


   # Insert pieces of text in the relevant places

   # For the target side
   sMask_Cube_Tgt = vMask_Cube_Tgt;

   vScan = Scan( '''§''', sMask_Cube_Tgt );
   sMask_Cube_Tgt = Delet( sMask_Cube_Tgt, vScan, 3 );
   sMask_Cube_Tgt = Insrt( pPrefix_Variable | 'Msr_Tgt', sMask_Cube_Tgt, vScan );

   TextOutput( vFile, 'm = 1;' );
   TextOutput( vFile, 'While( m <= Dimsiz( ''' | vDim_Msr_Src | ''' ));' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '   ' | pPrefix_Variable | 'Msr = Dimnm( ''' | vDim_Msr_Src | ''', m );' );
   If( vCube_Src @= vCube_Tgt );
      TextOutput( vFile, '   ' | pPrefix_Variable | 'Msr_Tgt = ' | pPrefix_Variable | 'Msr;' );
   Else;
      TextOutput( vFile, '   ' | pPrefix_Variable | 'Msr_Tgt = Attrs( ''' | vDim_Msr_Src | ''', ' | pPrefix_Variable | 'Msr, ''Mapped measure'' );' );
   EndIf;
   TextOutput( vFile, '' );

   # part 1: CellIsUpdateable
   sMask_Cube_Tgt_P1 = sMask_Cube_Tgt;

   vScan = Scan( '/', sMask_Cube_Tgt_P1 );
   sMask_Cube_Tgt_P1 = Delet( sMask_Cube_Tgt_P1, vScan, 1 );
   sMask_Cube_Tgt_P1 = Delet( sMask_Cube_Tgt_P1, vScan, 2 );

   vScan = Scan( '\', sMask_Cube_Tgt_P1 );
   sMask_Cube_Tgt_P1 = Delet( sMask_Cube_Tgt_P1, vScan, 1 );
   sMask_Cube_Tgt_P1 = Insrt( 'IsUpdateable', sMask_Cube_Tgt_P1, vScan );

   vScan = Scan( ');', sMask_Cube_Tgt_P1 );
   sMask_Cube_Tgt_P1 = Insrt( ') = 1 ', sMask_Cube_Tgt_P1, vScan );

   sMask_Cube_Tgt_P1 = Insrt( 'If( ', sMask_Cube_Tgt_P1, 1 );

   TextOutput( vFile, '   ' | sMask_Cube_Tgt_P1 );

   If( pAdd_Data_Type_Check <> 0 );
   TextOutput( vFile, '      If( Dtype( ''' | vDim_Msr_Src | ''', ' | pPrefix_Variable | 'Msr ) @= ''S'' );' );
   Else;
   TextOutput( vFile, '      If( Dtype( ''' | vDim_Msr_Src | ''', ' | pPrefix_Variable | 'Msr ) @<> ''S'' );' );
   EndIf;

   # part 2: CellGetS and CellPutS
   vType = 'S';
   vCumulative = 'PutS';
   If( pNested_Functions = 0 );

      vMask_Cube_Src_P2 = vMask_Cube_Src | ';';

      # Insert pieces of text in the relevant places
      sMask_Cube_Src = vMask_Cube_Src_P2;

      vScan = Scan( '''§''', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 3 );
      sMask_Cube_Src = Insrt( pPrefix_Variable | 'Msr', sMask_Cube_Src, vScan );

      vScan = Scan( '/', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( pPrefix_Variable | 'Text', sMask_Cube_Src, vScan );

      vScan = Scan( '\', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( vType, sMask_Cube_Src, vScan );

      If( pAdd_Data_Type_Check <> 0 );
      TextOutput( vFile, '         ' | sMask_Cube_Src );
      EndIf;

      sMask_Cube_Tgt_P2 = sMask_Cube_Tgt;

      vScan = Scan( '/', sMask_Cube_Tgt_P2 );
      sMask_Cube_Tgt_P2 = Delet( sMask_Cube_Tgt_P2, vScan, 1 );
      sMask_Cube_Tgt_P2 = Insrt( pPrefix_Variable | 'Text', sMask_Cube_Tgt_P2, vScan );

      vScan = Scan( '\', sMask_Cube_Tgt_P2 );
      sMask_Cube_Tgt_P2 = Delet( sMask_Cube_Tgt_P2, vScan, 1 );
      sMask_Cube_Tgt_P2 = Insrt( vCumulative, sMask_Cube_Tgt_P2, vScan );

      If( pAdd_Data_Type_Check <> 0 );   
      TextOutput( vFile, '         ' | sMask_Cube_Tgt_P2 );
      EndIf;

   Else;

      # For the source side
      sMask_Cube_Src = vMask_Cube_Src;

      sMask_Cube_Src = Delet( sMask_Cube_Src, 1, 4 );

      vScan = Scan( '''§''', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 3 );
      sMask_Cube_Src = Insrt( pPrefix_Variable | 'Msr', sMask_Cube_Src, vScan );

      vScan = Scan( '\', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( vType, sMask_Cube_Src, vScan );

      # For the target side
      sMask_Cube_Tgt_P2 = sMask_Cube_Tgt;

      vScan = Scan( '/', sMask_Cube_Tgt_P2 );
      sMask_Cube_Tgt_P2 = Delet( sMask_Cube_Tgt_P2, vScan, 1 );
      sMask_Cube_Tgt_P2 = Insrt( sMask_Cube_Src, sMask_Cube_Tgt_P2, vScan );

      vScan = Scan( '\', sMask_Cube_Tgt_P2 );
      sMask_Cube_Tgt_P2 = Delet( sMask_Cube_Tgt_P2, vScan, 1 );
      sMask_Cube_Tgt_P2 = Insrt( vCumulative, sMask_Cube_Tgt_P2, vScan );

      If( pAdd_Data_Type_Check <> 0 );
      TextOutput( vFile, '         ' | sMask_Cube_Tgt_P2 );
      EndIf;

   EndIf;

   If( pAdd_Data_Type_Check <> 0 );
   TextOutput( vFile, '      Else;' );
   EndIf;

   # part 3: CellPutN/CellIncrementN
   vType = 'N';
   If( pCumulative = 0 );
      vCumulative = 'PutN';
   Else;
      vCumulative = 'IncrementN';
   EndIf;

   If( pNested_Functions = 0 );

      vMask_Cube_Src_P2 = vMask_Cube_Src | ';';

      # Insert pieces of text in the relevant places
      sMask_Cube_Src = vMask_Cube_Src_P2;

      vScan = Scan( '''§''', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 3 );
      sMask_Cube_Src = Insrt( pPrefix_Variable | 'Msr', sMask_Cube_Src, vScan );

      vScan = Scan( '/', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( pPrefix_Variable | 'Number', sMask_Cube_Src, vScan );

      vScan = Scan( '\', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( vType, sMask_Cube_Src, vScan );

      TextOutput( vFile, '         ' | sMask_Cube_Src );

      sMask_Cube_Tgt_P3 = sMask_Cube_Tgt;

      vScan = Scan( '/', sMask_Cube_Tgt_P3 );
      sMask_Cube_Tgt_P3 = Delet( sMask_Cube_Tgt_P3, vScan, 1 );
      sMask_Cube_Tgt_P3 = Insrt( pPrefix_Variable | 'Number', sMask_Cube_Tgt_P3, vScan );

      vScan = Scan( '\', sMask_Cube_Tgt_P3 );
      sMask_Cube_Tgt_P3 = Delet( sMask_Cube_Tgt_P3, vScan, 1 );
      sMask_Cube_Tgt_P3 = Insrt( vCumulative, sMask_Cube_Tgt_P3, vScan );

      TextOutput( vFile, '         ' | sMask_Cube_Tgt_P3 );

   Else;

      # For the source side
      sMask_Cube_Src = vMask_Cube_Src;

      sMask_Cube_Src = Delet( sMask_Cube_Src, 1, 4 );

      vScan = Scan( '''§''', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 3 );
      sMask_Cube_Src = Insrt( pPrefix_Variable | 'Msr', sMask_Cube_Src, vScan );

      vScan = Scan( '\', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( vType, sMask_Cube_Src, vScan );

      # For the target side
      sMask_Cube_Tgt_P3 = sMask_Cube_Tgt;

      vScan = Scan( '/', sMask_Cube_Tgt_P3 );
      sMask_Cube_Tgt_P3 = Delet( sMask_Cube_Tgt_P3, vScan, 1 );
      sMask_Cube_Tgt_P3 = Insrt( sMask_Cube_Src, sMask_Cube_Tgt_P3, vScan );

      vScan = Scan( '\', sMask_Cube_Tgt_P3 );
      sMask_Cube_Tgt_P3 = Delet( sMask_Cube_Tgt_P3, vScan, 1 );
      sMask_Cube_Tgt_P3 = Insrt( vCumulative, sMask_Cube_Tgt_P3, vScan );

      TextOutput( vFile, '         ' | sMask_Cube_Tgt_P3 );

   EndIf;

   If( pAdd_Data_Type_Check <> 0 );
   TextOutput( vFile, '      EndIf;' );
   Else;
   TextOutput( vFile, '      EndIf;' );
   EndIf;

   TextOutput( vFile, '   Else;' );
   TextOutput( vFile, '      AsciiOutput( ''test.txt'', '''' );' );
   TextOutput( vFile, '   EndIf;' );
   TextOutput( vFile, '' );
   TextOutput( vFile, '   m = m + 1;' );
   TextOutput( vFile, '' );
   TextOutput( vFile, 'End;' );


ElseIf( pMode @= 'C' );

   # The source view contains 1 measure, the output code is generated by hardcoding the measure element names

If( pNested_Functions = 0 );

   ########################
   # OUTPUT IS NOT NESTED
   ########################

   # Example:
   #
   # V1 = CellGetN( vCube_Src, vYear, 'Bonus Percentage' );
   # CellPutN( V1, vCube_Tgt, vYear, 'Bonus Percentage' );
   #
   # or:
   #
   # vBonus_Percentage = CellGetN( vCube_Src, vYear, 'Bonus Percentage' );
   # CellPutN( vBonus_Percentage, vCube_Tgt, vYear, 'Bonus Percentage' );

   vMask_Cube_Src = vMask_Cube_Src | ';';

   # Loop over measures on the source side, in order to retrieve the values
   m = 1;
   While( m <= Dimsiz( vDim_Msr_Src ));

      vMsr = Dimnm( vDim_Msr_Src, m );

      # Is it CellGetN or CellGetN, likewise, CellPutN or CellPutS or CellIncrementN ?
      If( Dtype( vDim_Msr_Src, vMsr ) @= 'S' );
         vType = 'S';
      Else;
         vType = 'N';
      EndIf;

      # Insert pieces of text in the relevant places
      sMask_Cube_Src = vMask_Cube_Src;

      vScan = Scan( '§', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( vMsr, sMask_Cube_Src, vScan );

      vScan = Scan( '/', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );

      If( pNotNested_Variables_Are_Numbers = 1 );
         sMask_Cube_Src = Insrt( Upper( pPrefix_Variable ) | NumberToString( m ), sMask_Cube_Src, vScan );
      Else;

         Chars_To_Remove = pChars_To_Remove;
         While( Long( Chars_To_Remove ) > 0 );
            Char_To_Remove = Subst( Chars_To_Remove, 1, 1 );
            While( Scan( Char_To_Remove, vMsr ) > 0 );
               vScan_2 = Scan( Char_To_Remove, vMsr );
               vMsr = Delet( vMsr, vScan_2, 1 );
            End;
            Chars_To_Remove = Delet( Chars_To_Remove, 1, 1 );
         End;

         Chars_To_Replace = pChars_To_Replace;
         Chars_To_Replace_With = pChars_To_Replace_With;
         While( Long( Chars_To_Replace ) > 0 );
            Char_To_Replace = Subst( Chars_To_Replace, 1, 1 );
            While( Scan( Char_To_Replace, vMsr ) > 0 );
               vScan_2 = Scan( Char_To_Replace, vMsr );
               vMsr = Delet( vMsr, vScan_2, 1 );
               vMsr = Insrt( Subst( Chars_To_Replace_With, 1, 1 ), vMsr, vScan_2 );
            End;
            Chars_To_Replace = Delet( Chars_To_Replace, 1, 1 );
            Chars_To_Replace_With = Delet( Chars_To_Replace_With, 1, 1 );
         End;

         sMask_Cube_Src = Insrt( pPrefix_Variable | vMsr, sMask_Cube_Src, vScan );
      EndIf;

      vScan = Scan( '\', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( vType, sMask_Cube_Src, vScan );

      If(( pAdd_Data_Type_Check <> 0 ) % ( vType @= 'N' ));
      TextOutput( vFile, sMask_Cube_Src );
      EndIf;

      m = m + 1;

   End;

   TextOutput( vFile, '' );
   TextOutput( vFile, '' );

   # Loop over measures on the source side, in order to write values to the target side
   m = 1;
   While( m <= Dimsiz( vDim_Msr_Src ));

      vMsr = Dimnm( vDim_Msr_Src, m );

      # Is it CellGetN or CellGetN, likewise, CellPutN or CellPutS or CellIncrementN ?
      If( Dtype( vDim_Msr_Src, vMsr ) @= 'S' );
         vType = 'S';
      Else;
         vType = 'N';
      EndIf;

      If( Dtype( vDim_Msr_Src, vMsr ) @= 'S' );
         vCumulative = 'PutS';
      Else;
         If( pCumulative = 0 );
            vCumulative = 'PutN';
         Else;
            vCumulative = 'IncrementN';
         EndIf;
      EndIf;

      # Insert pieces of text in the relevant places
      sMask_Cube_Tgt = vMask_Cube_Tgt;

      vScan = Scan( '§', sMask_Cube_Tgt );
      sMask_Cube_Tgt = Delet( sMask_Cube_Tgt, vScan, 1 );
      sMask_Cube_Tgt = Insrt( vMsr, sMask_Cube_Tgt, vScan );

      vScan = Scan( '/', sMask_Cube_Tgt );
      sMask_Cube_Tgt = Delet( sMask_Cube_Tgt, vScan, 1 );

      If( pNotNested_Variables_Are_Numbers = 1 );
         sMask_Cube_Tgt = Insrt( Upper( pPrefix_Variable ) | NumberToString( m ), sMask_Cube_Tgt, vScan );
      Else;

         Chars_To_Remove = pChars_To_Remove;
         While( Long( Chars_To_Remove ) > 0 );
            Char_To_Remove = Subst( Chars_To_Remove, 1, 1 );
            While( Scan( Char_To_Remove, vMsr ) > 0 );
               vScan_2 = Scan( Char_To_Remove, vMsr );
               vMsr = Delet( vMsr, vScan_2, 1 );
            End;
            Chars_To_Remove = Delet( Chars_To_Remove, 1, 1 );
         End;

         Chars_To_Replace = pChars_To_Replace;
         Chars_To_Replace_With = pChars_To_Replace_With;
         While( Long( Chars_To_Replace ) > 0 );
            Char_To_Replace = Subst( Chars_To_Replace, 1, 1 );
            While( Scan( Char_To_Replace, vMsr ) > 0 );
               vScan_2 = Scan( Char_To_Replace, vMsr );
               vMsr = Delet( vMsr, vScan_2, 1 );
               vMsr = Insrt( Subst( Chars_To_Replace_With, 1, 1 ), vMsr, vScan_2 );
            End;
            Chars_To_Replace = Delet( Chars_To_Replace, 1, 1 );
            Chars_To_Replace_With = Delet( Chars_To_Replace_With, 1, 1 );
         End;

         sMask_Cube_Tgt = Insrt( pPrefix_Variable | vMsr, sMask_Cube_Tgt, vScan );

      EndIf;

      vScan = Scan( '\', sMask_Cube_Tgt );
      sMask_Cube_Tgt = Delet( sMask_Cube_Tgt, vScan, 1 );
      sMask_Cube_Tgt = Insrt( vCumulative, sMask_Cube_Tgt, vScan );

      If(( pAdd_Data_Type_Check <> 0 ) % ( vType @= 'N' ));
      TextOutput( vFile, sMask_Cube_Tgt );
      EndIf;

      m = m + 1;

   End;

Else;

   ########################
   # OUTPUT IS NESTED
   ########################

   # Example:
   #
   # CellPutN( CellGetN( vCube_Src, vYear, 'Bonus Percentage' ), vCube_Tgt, vYear, 'Bonus Percentage' );

   # Loop over measures on the source side, in order to retrieve the values
   m = 1;
   While( m <= Dimsiz( vDim_Msr_Src ));

      vMsr = Dimnm( vDim_Msr_Src, m );

      # Is it CellGetN or CellGetN, likewise, CellPutN or CellPutS or CellIncrementN ?
      If( Dtype( vDim_Msr_Src, vMsr ) @= 'S' );
         vType = 'S';
      Else;
         vType = 'N';
      EndIf;

      If( Dtype( vDim_Msr_Src, vMsr ) @= 'S' );
         vCumulative = 'PutS';
      Else;
         If( pCumulative = 0 );
            vCumulative = 'PutN';
         Else;
            vCumulative = 'IncrementN';
         EndIf;
      EndIf;

      # Insert pieces of text in the relevant places

      # For the source side
      sMask_Cube_Src = vMask_Cube_Src;

      sMask_Cube_Src = Delet( sMask_Cube_Src, 1, 4 );

      vScan = Scan( '§', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( vMsr, sMask_Cube_Src, vScan );

      vScan = Scan( '\', sMask_Cube_Src );
      sMask_Cube_Src = Delet( sMask_Cube_Src, vScan, 1 );
      sMask_Cube_Src = Insrt( vType, sMask_Cube_Src, vScan );

      # For the target side
      sMask_Cube_Tgt = vMask_Cube_Tgt;

      vScan = Scan( '§', sMask_Cube_Tgt );
      sMask_Cube_Tgt = Delet( sMask_Cube_Tgt, vScan, 1 );
      sMask_Cube_Tgt = Insrt( vMsr, sMask_Cube_Tgt, vScan );

      vScan = Scan( '/', sMask_Cube_Tgt );
      sMask_Cube_Tgt = Delet( sMask_Cube_Tgt, vScan, 1 );
      sMask_Cube_Tgt = Insrt( sMask_Cube_Src, sMask_Cube_Tgt, vScan );

      vScan = Scan( '\', sMask_Cube_Tgt );
      sMask_Cube_Tgt = Delet( sMask_Cube_Tgt, vScan, 1 );
      sMask_Cube_Tgt = Insrt( vCumulative, sMask_Cube_Tgt, vScan );

      If(( pAdd_Data_Type_Check <> 0 ) % ( vType @= 'N' ));
      TextOutput( vFile, sMask_Cube_Tgt );
      EndIf;

      m = m + 1;

   End;

EndIf;

EndIf;

TextOutput( vFile, '' );
TextOutput( vFile, '' );
TextOutput( vFile, '' );
TextOutput( vFile, 'CellPutS( ''YES'', ''}CubeProperties'', ' | vCube_Tgt_InTheCode | ', ''LOGGING'' );' );
TextOutput( vFile, '' );
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
