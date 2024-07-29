601,100
602,"TECH_double counting I"
562,"SUBSET"
586,"}Clients"
585,"}Clients"
564,
565,"t7eDgg?w7:xCq4p4TVNGa1Bq368HEOZP@BKm=kla;Zt5<B]iBjHZ8`hr4>XHq:kGUpCWGFuE0WLa<kwgwsGJXhc9Ay<nXXDRSI51a`@PvyePqvzAI1nY@:L?Cz0QZ9E?>@ItQd:K56ewBfFu<QC[ddQaGz<giDal^`?OSLrgQp1iqxWVMtK1a0Tsgh^CYbuO7eQvn;eA"
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
571,All
569,0
592,0
599,1000
560,13
pName
pMode
pAction
pOutput_QuickCheck
pOutput_CreateTextFile
pOutput_AddSubsetAndAttrToOriginalDim
pOutput_AddDimensionProperty
pOutput_KeepTempCube
pOutput_DetermineWeights
pAddHelperAttributes
pHier
pConsol
pConsol_Exclude
561,13
2
1
1
1
1
1
1
1
1
1
2
2
2
590,13
pName,""
pMode,3
pAction,1
pOutput_QuickCheck,0
pOutput_CreateTextFile,1
pOutput_AddSubsetAndAttrToOriginalDim,1
pOutput_AddDimensionProperty,1
pOutput_KeepTempCube,1
pOutput_DetermineWeights,1
pAddHelperAttributes,1
pHier,""
pConsol,""
pConsol_Exclude,""
637,13
pName,"Inspect what dimension / cube for double countings ?"
pMode,"Inspection Mode ? ( 1 = 1 dimension / 2 = dimensions of 1 cube / 3 = all dimensions 'light' / 4 = all dimensions 'full' / 5 = insert Input element / All else = No action )"
pAction,"Action ? ( 1 = Destroy objects & Run again / 2 = Destroy objects )"
pOutput_QuickCheck,"Quick check (stop at the first double counting issue) ? ( 0 = No / All else = Yes )"
pOutput_CreateTextFile,"Create a text file that contains the double counting elements ? ( 1 = Double countings, 2 = Number of double countings, All else = No )"
pOutput_AddSubsetAndAttrToOriginalDim,"Add a subset and attribute to the dimension containing the double countings ? ( 0 = No, All else = Yes )"
pOutput_AddDimensionProperty,"Add a property to the cube }DimensionProperties that contains the number of double counting elements ? ( 0 = No, All else = Yes )"
pOutput_KeepTempCube,"Keep the temporary cube used to store the combinations ? ( 0 = No, All else = Yes )"
pOutput_DetermineWeights,"Determine the weights for double counted elements ? ( 0 = No, All else = Yes )"
pAddHelperAttributes,"Add helper attributes in the new cube ? ( 0 = No, All else = Yes )"
pHier,"Target Hierarchy (will use default if left blank) (does not accept wildcards)"
pConsol,"Target Consolidation (does not accept wildcards)"
pConsol_Exclude,"Consolidation to exclude from processing (does not accept wildcards)"
577,1
vElement
578,1
2
579,1
1
580,1
0
581,1
0
582,1
VarType=32ColType=827
603,0
572,1174

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# January 2024
# https://www.wimgielis.com
####################################################
#
# This process checks dimensions for double countings.
# A double counting is defined as a case where 1 element (level 0 or consolidated) rolls up in more than 1 way in a certain consolidated element.
# This process supports alternative hierarchies (PA-speak).
#
# Element weights are ignored when tracing double countings, but the effect of each double counting can be expressed.
# For example, element A rolls up 3 times in element B, with cumulative weight of 1 ( +1, +1, -1 ). This can be shown in a cube.
#
# Only dimensions are checked for double countings. It could be that there are no data on these elements and hence no double countings,
# but as the potential to have data is present, we list them anyway.
# You can use other TI processes to check if an element has data in any of the cubes that use the said dimension.
#
# This main process will execute 'TECH_double counting II', unless no double countings are detected.
# In the absence of this helper process, the process will stop and error out.
#
# The parameter pMode determines to what extent dimensions will be inspected:
# If pMode = 1, you inspect 1 dimension. Specify the dimension name in pName. Wildcards * and ? are allowed.
# If pMode = 2, you inspect all dimensions of a cube. Specify the cube name in pName.
# If pMode = 3, you inspect all application dimensions and create a 'light' output. pName is ignored.
# If pMode = 4, you inspect all application dimensions and create a 'full' output. pName is ignored.
# If pMode = 5, you can insert a measure in the cube }DimensionProperties where you can skip dimensions from the treatment. pName is ignored.
#
# When pMode = 1:
# - a hierarchy (PA-speak) (pHier) can be used. For its name, wildcards are not accepted. Double countings are only searched within the elements of this hierarchy.
#   If no pConsol is used, then the main hierarchy of the dimension is investigated. It does not mean that all hierarchies are investigated, unless you only have 1 hierarchy.
# - a consolidated element (pConsol) can be used. For its name, wildcards are not accepted. Double countings are only searched below this consolidated element.
# - another consolidated element (pConsol_Exclude) can be used. For its name, wildcards are not accepted. Double countings are not searched below this consolidated element.
#
# A good idea might be to have a chore running every few days or every week, traversing all important hierarchies / hierarchies that are prone to get double countings.
# You can choose for a full or light output.
#
# The reason for number 5 is that long dimensions with many levels can take some time to process, so you can skip them.
# In TM1 even clients with Admin privileges cannot manually insert an element in a control dimension like }DimensionProperties. Hence the TI approach.
#
# This process can provide output / change existing TM1 objects in the following way:
# - by creating a text file in the TM1 logging directory, containing the double countings per hierarchy ( pOutput_CreateTextFile )
# - by adding a subset to the dimension being investigated, containing the double countings ( pOutput_AddSubsetAndAttrToOriginalDim )
# - by adding a property to the cube }DimensionProperties, containing the number of double countings per hierarchy ( pOutput_AddDimensionProperty )
# - by creating and not deleting a new cube called '}TECH_Double_Countings' ( pOutput_KeepTempCube )
#
# When you execute the process with pMode = 2 or 3, then you have less options. The script does not do all the fancy stuff in these cases.
# The parameters that are turned off, are:
# - pOutput_CreateTextFile
# - pOutput_KeepTempCube
# - pOutput_DetermineWeights
# - pAddHelperAttributes
#
# pOutput_QuickCheck can be interesting when you just want to know, for 1 dimension/hierarchy, whether 1 or more double counting issue exists or not.
# At the first encounter of such an issue, the process finishes. A global string variable will be set. Detailed information is not available.
# For detailed information you need to use other process outputs.
#
# The main reasoning behind this, is that several objects would overwrite each other anyway. Hence there is limited benefit of keeping the options in.
# So the idea is to use pMode = 2 or 3 (to save time, you can do this in a loop instead of you firing off one after the other).
# Once you have identified the dimension(s) with double countings, you can run the same process again on this dimension with pMode = 1 and all options activated.
# That way, you have the best of both worlds: speed and functionality ;-)
#
# The process will also store other information in the }DimensionProperties cube:
# - number of levels
# - number of elements
# - run time of the process
#
# ### This has been turned off for now
# ### In case a dimension is too long and/or contains too many consolidations, this process can take a while (even though it's very efficient)
# ### Therefore, I estimate onbeforehand the number of combinations that someone might have to process through loops,
# ### given that every element can potentially roll up in every consolidated element (except level 1 consolidations).
# ### My loops are more efficient than this strategy and I limit the combinations to a great extent, but still this measure of the potential number of combinations
# ### indicates whether we should attempt it or not. That theoretical number of combinations is set at 50,000,000 for the moment. You can change this limit in the process if you want.
#
# After having applied the code to a number of TM1 models, here are my results:
# - usually the Period / Month dimension has double countings.
#   For example, a 'YTD' consolidation groups 12 consolidated YTD elements for the periods (no double counting)
#   but underneath the 12 YTD elements you have the level 0 periods. These roll up several times in the "YTD" element. This is okay and not a problem.
# - I have seen dimensions for Cost centers, Accounts, Products, Employees and many more suffering from double countings. This can be problematic and the exact reason why I wrote these processes.
# - my best advice to you use this tool is:
# 1. Run the tool once with "pMode = 5". The other parameters do not matter here. You will create a }DimensionProperties element.
# 2. Single out the large dimensions with a high LevelCount (DNLEV) and run the tool with "pMode = 1" for these dimensions only.
#    Inspect the results in attributes, subsets and a text file - depending on your choices.
# 3. When you are done with these big dimensions, put a 1 for these dimensions in the }DimensionProperties cube on the measure "Skip dimension for double counting"
# 4. Run the tool with "pMode = 3" or "pMode = 4". 4 gives a richer output than 3 but it could take somewhat longer.
#
# A global numeric variable will be populated with the number of duplicates found.
#
# Technical note: this process can use recursion and execute itself a number of times (iteratively) using the correct parameter values.
# You will notice in the TM1 Server message log that the process is called a number of times.
#
####################################################

# Internet resources:
# http://www.tm1forum.com/viewtopic.php?f=3&t=12706

#####
# Add the following process(es) to this TM1 model:
# - TECH_double counting II
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
NumericGlobalVariable( 'Number_of_duplicates' );
NumericGlobalVariable( 'Double_counting_exists' );
ExecuteProcess( 'TECH_double counting I'
  , 'pName', 'DIMENSION NAME / CUBE NAME / leave empty'
  , 'pMode', 1 / 2 / 3 / 4 / 5
  , 'pAction', 1
  , 'pOutput_QuickCheck', 0
  , 'pOutput_CreateTextFile', 1
  , 'pOutput_AddSubsetAndAttrToOriginalDim', 1
  , 'pOutput_AddDimensionProperty', 1
  , 'pOutput_KeepTempCube', 1
  , 'pOutput_DetermineWeights', 1
  , 'pAddHelperAttributes', 1
  , 'pHier', 'HIERARCHY NAME'
  , 'pConsol', 'CONSOLIDATED ELEMENT NAME'
  , 'pConsol_Exclude', 'ANOTHER CONSOLIDATED ELEMENT NAME'
  );
TextOutput( 'Number of double countings.txt', NumberToString( Number_of_duplicates ));
TextOutput( 'Number of double countings.txt', NumberToString( Double_counting_exists ));
EndIf;
#EndRegion CallThisProcess


## Constants
cAPP_NAME_TM1 = 'TECH_Double_Countings';
cAPP_NAME_TM1_Control = '}' | cAPP_NAME_TM1;

# a cube for calculations
vCube = cAPP_NAME_TM1_Control;
vDim1 = cAPP_NAME_TM1_Control | '_All';
vDim2 = cAPP_NAME_TM1_Control | '_Conso';
vDim3 = cAPP_NAME_TM1_Control | '_Msr';

NumericGlobalVariable( 'Number_of_duplicates' );
NumericGlobalVariable( 'Double_counting_exists' );
vSkip_processing = 0;

# a text file for output
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Double counting', 'pMainFolder', '1+' );

vFile = cDestination_Folder | cAPP_NAME_TM1 | '_' | TimSt( Now, '\Y\m\d_\h\i\s' ) | '_output.csv';

DataSourceASCIIDelimiter = Char( 9 );
DataSourceASCIIQuoteCharacter = '';

# a second process that can be executed
cProcess = 'TECH_double counting II';

# Constants to be used in this proces
c00 = 'Default';
c01 = 'Weight';
c02 = cAPP_NAME_TM1;
c03 = 'Count of instances';
c04 = 'Double counting issue';
c05 = 'Descendant';
c06 = 'Consolidation';
c07 = '# double counting';
c08 = 'Skip dimension for double counting';
c09 = 'Double counting: nr of levels';
c10 = 'Double counting: nr of elements';
c11 = 'Double counting: run time';

dp = '}DimensionProperties';


# A temporary string
cTemp = cAPP_NAME_TM1_Control | '_tmp';

# the maximum number of possible combinations (iterations) above which this process will not attempt to calculate all potential double counting issues
cMaxIterations = 50000000;


pAction = Int( pAction );
If( pAction < 1 % pAction > 2 );
   ProcessQuit;
EndIf;

pMode = Int( pMode );
If( pMode < 1 % pMode > 5 );
   ProcessQuit;
EndIf;

# Certain choices are better not to be used together
If( pAction > 1 );
   pHier = '';
   pConsol = '';
   pConsol_Exclude = '';
EndIf;

If( Scan( '*', pName ) > 0 % Scan( '?', pName ) > 0 );
   pOutput_QuickCheck = 0;
   pHier = '';
   pConsol = '';
   pConsol_Exclude = '';
EndIf;

If( pOutput_QuickCheck <> 0 );
   pOutput_CreateTextFile = 0;
   pOutput_AddSubsetAndAttrToOriginalDim = 0;
   pOutput_AddDimensionProperty = 0;
   pOutput_KeepTempCube = 0;
   pOutput_DetermineWeights = 0;
   pAddHelperAttributes = 0;
EndIf;

If( pOutput_CreateTextFile <> 0 %
    pOutput_AddSubsetAndAttrToOriginalDim <> 0 %
    pOutput_AddDimensionProperty <> 0 %
    pOutput_KeepTempCube <> 0 %
    pOutput_DetermineWeights <> 0 %
    pAddHelperAttributes <> 0 );
   pOutput_QuickCheck = 0;
EndIf;


vStartTime = Now;


####################
# The main code starts here #
####################


If( pMode = 1 );

   #############################
   # Treat 1 dimension
   #############################

   If( DimensionExists( pName ) > 0 );

      pDim = HierarchyElementPrincipalName( '}Dimensions', '}Dimensions', pName );

      # vCheckDp = 0;
      # If( Dimix( dp, c08 ) = 0 );
      #    vCheckDp = 1;
      # ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
      #    vCheckDp = 1;
      # EndIf;

      # If( vCheckDp = 0 );
      #    LogOutput( 'INFO', 'Dimension ''' | pDim | ''' is skipped for treatment in the cube ''' | dp | '''.' );
      #    DataSourceType = 'NULL';
      # EndIf;

      # this is the standard case: execute the remainder of this process for 1 dimension
      # just follow this script
      # we will break out of the script if we need to loop over several dimensions

   Else;

      # allow for wildcards in the dimension name pName
      vDims = '}Dimensions';

      SubsetCreateByMDX( 'tmp_', '{TM1FilterByPattern( Except( TM1SubsetAll( [' | vDims | '].[' | vDims | '] ), TM1FilterByPattern( TM1SubsetAll( [' | vDims | '].[' | vDims | '] ), "}*") ), "' | pName | '")}', vDims, 1 );

      # Loop through the matches, if any
      mm = 1;
      While( mm <= HierarchySubsetGetSize( vDims, vDims, 'tmp_' ));
         pDim = HierarchySubsetGetElementName( vDims, vDims, 'tmp_', mm );

         vCheckDp = 0;
         If( ElementIndex( dp, dp, c08 ) = 0 );
            vCheckDp = 1;
         ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
            vCheckDp = 1;
         EndIf;

         If( vCheckDp = 0 );
            LogOutput( 'INFO', 'The hierarchy ''' | pDim | ''' is skipped for treatment in the cube ''' | dp | '''.' );
            DataSourceType = 'NULL';
         Else;

            ExecuteProcess( GetProcessName
              , 'pName', pDim
              , 'pMode', 1
              , 'pAction', pAction
              , 'pOutput_QuickCheck', pOutput_QuickCheck
              , 'pOutput_CreateTextFile', 0
              , 'pOutput_AddSubsetAndAttrToOriginalDim', pOutput_AddSubsetAndAttrToOriginalDim
              , 'pOutput_AddDimensionProperty', pOutput_AddDimensionProperty
              , 'pOutput_KeepTempCube', 0
              , 'pOutput_DetermineWeights', 0
              , 'pAddHelperAttributes', 0
              , 'pHier', ''
              , 'pConsol', pConsol
              , 'pConsol_Exclude', pConsol_Exclude
              );

            NumericGlobalVariable( 'ProcessReturnCode' );
            If( ProcessReturnCode = ProcessExitSeriousError );
               ProcessError;
            ElseIf( ProcessReturnCode = ProcessExitByQuit );
               ProcessQuit;
            EndIf;

         EndIf;

         mm = mm + 1;

      End;

      # a text file for output
      If( pOutput_CreateTextFile <> 0 );

         TextOutput( vFile, 'Dimension', 'Double counted element', 'Parents' );

         mm = 1;
         While( mm <= HierarchySubsetGetSize( vDims, vDims, 'tmp_' ));
            pDim = HierarchySubsetGetElementName( vDims, vDims, 'tmp_', mm );

            vCheckDp = 0;
            If( ElementIndex( dp, dp, c08 ) = 0 );
               vCheckDp = 1;
            ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
               vCheckDp = 1;
            EndIf;

            If( vCheckDp = 1 );

               If( HierarchySubsetExists( pDim, pDim, c02 ) > 0 );

                  s = 1;
                  While( s <= HierarchySubsetGetSize( pDim, pDim, c02 ));
                     vDC = HierarchySubsetGetElementName( pDim, pDim, c02, s );
                     vParents = ElementAttrS( pDim, pDim, vDC, c02 );
                     TextOutput( vFile, pDim, vDC, vParents );
                     s = s + 1;
                  End;

               EndIf;
            EndIf;

            mm = mm + 1;

         End;

      EndIf;

      # a numeric global variable
      Number_of_duplicates = 0;
      mm = 1;
      While( mm <= HierarchySubsetGetSize( vDims, vDims, 'tmp_' ));
         pDim = HierarchySubsetGetElementName( vDims, vDims, 'tmp_', mm );

         vCheckDp = 0;
         If( ElementIndex( dp, dp, c08 ) = 0 );
            vCheckDp = 1;
         ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
            vCheckDp = 1;
         EndIf;

         If( vCheckDp = 1 );

            If( HierarchySubsetExists( pDim, pDim, c02 ) > 0 );

               Number_of_duplicates = Number_of_duplicates + HierarchySubsetGetSize( pDim, pDim, c02 );

            EndIf;
         EndIf;

         mm = mm + 1;

      End;

      DataSourceType = 'NULL';

   EndIf;

   # We could also look for attributes (aliases) on the dimension }Dimensions and test if the dimension pattern exists
   # This is not done here, however. See other processes if wanted.

ElseIf( pMode = 2 );

   #############################
   # Treat the dimensions of 1 cube
   #############################

   pCube = Trim( pName );
   If( CubeExists( pCube ) > 0 );

      pCube = HierarchyElementPrincipalName( '}cubes', '}cubes', pCube );

      # m loops over the dimensions in the cube
      m = 1;
      While( m <= CubeDimensionCountGet( pCube ));
         pDim = Tabdim( pCube, m );

         vCheckDp = 0;
         If( ElementIndex( dp, dp, c08 ) = 0 );
            vCheckDp = 1;
         ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
            vCheckDp = 1;
         EndIf;

         If( vCheckDp = 0 );
            LogOutput( 'INFO', 'Dimension ''' | pDim | ''' is skipped for treatment in the cube ''' | dp | '''.' );
            DataSourceType = 'NULL';
         Else;

            ExecuteProcess( GetProcessName
              , 'pName', pDim
              , 'pMode', 1
              , 'pAction', pAction
              , 'pOutput_QuickCheck', pOutput_QuickCheck
              , 'pOutput_CreateTextFile', 0
              , 'pOutput_AddSubsetAndAttrToOriginalDim', pOutput_AddSubsetAndAttrToOriginalDim
              , 'pOutput_AddDimensionProperty', pOutput_AddDimensionProperty
              , 'pOutput_KeepTempCube', 0
              , 'pOutput_DetermineWeights', 0
              , 'pAddHelperAttributes', 0
              , 'pHier', ''
              , 'pConsol', pConsol
              , 'pConsol_Exclude', pConsol_Exclude
              );

            NumericGlobalVariable( 'ProcessReturnCode' );
            If( ProcessReturnCode = ProcessExitSeriousError );
               ProcessError;
            ElseIf( ProcessReturnCode = ProcessExitByQuit );
               ProcessQuit;
            EndIf;

         EndIf;

         m = m + 1;

      End;

      # a text file for output
      If( pOutput_CreateTextFile <> 0 );

         TextOutput( vFile, 'Dimension', 'Double counted element', 'Parents' );

         m = 1;
         While( m <= CubeDimensionCountGet( pCube ));
            pDim = Tabdim( pCube, m );

            vCheckDp = 0;
            If( ElementIndex( dp, dp, c08 ) = 0 );
               vCheckDp = 1;
            ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
               vCheckDp = 1;
            EndIf;

            If( vCheckDp = 1 );

               If( HierarchySubsetExists( pDim, pDim, c02 ) > 0 );

                  s = 1;
                  While( s <= HierarchySubsetGetSize( pDim, pDim, c02 ));
                     vDC = HierarchySubsetGetElementName( pDim, pDim, c02, s );
                     vParents = ElementAttrS( pDim, pDim, vDC, c02 );
                     TextOutput( vFile, pDim, vDC, vParents );
                     s = s + 1;
                  End;

               EndIf;
            EndIf;

            m = m + 1;

         End;

      EndIf;

      # a numeric global variable
      Number_of_duplicates = 0;
      m = 1;
      While( m <= CubeDimensionCountGet( pCube ));
         pDim = Tabdim( pCube, m );

         vCheckDp = 0;
         If( ElementIndex( dp, dp, c08 ) = 0 );
            vCheckDp = 1;
         ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
            vCheckDp = 1;
         EndIf;

         If( vCheckDp = 1 );

            If( HierarchySubsetExists( pDim, pDim, c02 ) > 0 );

               Number_of_duplicates = Number_of_duplicates + HierarchySubsetGetSize( pDim, pDim, c02 );

            EndIf;
         EndIf;

         m = m + 1;

      End;

   Else;

      LogOutput( 'ERROR', 'Cube ''' | pCube | ''' does not exist.' );
      ProcessError;

   EndIf;

   DataSourceType = 'NULL';

ElseIf( pMode = 3 );

   #############################
   # Treat all application dimensions in the TM1 model and create a 'light' output
   #############################

   # d loops over the dimensions in the model
   d = 1;
   While( d <= ElementCount( '}Dimensions', '}Dimensions' ));

      pDim = ElementName( '}Dimensions', '}Dimensions', d );

      If( Subst( pDim, 1, 1 ) @<> '}' );

         vCheckDp = 0;
         If( ElementIndex( dp, dp, c08 ) = 0 );
            vCheckDp = 1;
         ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
            vCheckDp = 1;
         EndIf;

         If( vCheckDp = 0 );
            LogOutput( 'INFO', 'Dimension ''' | pDim | ''' is skipped for treatment in the cube ''' | dp | '''.' );
            DataSourceType = 'NULL';
         Else;

            ExecuteProcess( GetProcessName
              , 'pName', pDim
              , 'pMode', 1
              , 'pAction', pAction
              , 'pOutput_QuickCheck', pOutput_QuickCheck
              , 'pOutput_CreateTextFile', 0
              , 'pOutput_AddSubsetAndAttrToOriginalDim', pOutput_AddSubsetAndAttrToOriginalDim
              , 'pOutput_AddDimensionProperty', pOutput_AddDimensionProperty
              , 'pOutput_KeepTempCube', 0
              , 'pOutput_DetermineWeights', 0
              , 'pAddHelperAttributes', 0
              , 'pHier', ''
              , 'pConsol', pConsol
              , 'pConsol_Exclude', pConsol_Exclude
              );

            NumericGlobalVariable( 'ProcessReturnCode' );
            If( ProcessReturnCode = ProcessExitSeriousError );
               ProcessError;
            ElseIf( ProcessReturnCode = ProcessExitByQuit );
               ProcessQuit;
            EndIf;

         EndIf;

      EndIf;

      d = d + 1;

   End;

   # a text file for output
   If( pOutput_CreateTextFile <> 0 );

      TextOutput( vFile, 'Dimension', 'Double counted element' );

      d = 1;
      While( d <= ElementCount( '}Dimensions', '}Dimensions' ));

         pDim = ElementName( '}Dimensions', '}Dimensions', d );

         If( Subst( pDim, 1, 1 ) @<> '}' );

            vCheckDp = 0;
            If( ElementIndex( dp, dp, c08 ) = 0 );
               vCheckDp = 1;
            ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
               vCheckDp = 1;
            EndIf;

            If( vCheckDp = 1 );

               If( HierarchySubsetExists( pDim, pDim, c02 ) > 0 );

                  s = 1;
                  While( s <= HierarchySubsetGetSize( pDim, pDim, c02 ));
                     vDC = HierarchySubsetGetElementName( pDim, pDim, c02, s );
                     vParents = ElementAttrS( pDim, pDim, vDC, c02 );
                     TextOutput( vFile, pDim, vDC, vParents );
                     s = s + 1;
                  End;

               EndIf;

            EndIf;

         EndIf;

         d = d + 1;

      End;

   EndIf;

   # a numeric global variable
   Number_of_duplicates = 0;
   d = 1;
   While( d <= ElementCount( '}Dimensions', '}Dimensions' ));

      pDim = ElementName( '}Dimensions', '}Dimensions', d );

      If( Subst( pDim, 1, 1 ) @<> '}' );

         vCheckDp = 0;
         If( ElementIndex( dp, dp, c08 ) = 0 );
            vCheckDp = 1;
         ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
            vCheckDp = 1;
         EndIf;

         If( vCheckDp = 1 );

            If( HierarchySubsetExists( pDim, pDim, c02 ) > 0 );

               Number_of_duplicates = Number_of_duplicates + HierarchySubsetGetSize( pDim, pDim, c02 );

            EndIf;

         EndIf;

      EndIf;

      d = d + 1;

   End;

   DataSourceType = 'NULL';

ElseIf( pMode = 4 );

   #############################
   # Treat all application dimensions in the TM1 model and create a 'full' output
   #############################

   # d loops over the dimensions in the model
   d = 1;
   While( d <= ElementCount( '}Dimensions', '}Dimensions' ));

      pDim = ElementName( '}Dimensions', '}Dimensions', d );

      If( Subst( pDim, 1, 1 ) @<> '}' );

         vCheckDp = 0;
         If( ElementIndex( dp, dp, c08 ) = 0 );
            vCheckDp = 1;
         ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
            vCheckDp = 1;
         EndIf;

         If( vCheckDp = 0 );
            LogOutput( 'INFO', 'Dimension ''' | pDim | ''' is skipped for treatment in the cube ''' | dp | '''.' );
            DataSourceType = 'NULL';
         Else;

            ExecuteProcess( GetProcessName
              , 'pName', pDim
              , 'pMode', 1
              , 'pAction', pAction
              , 'pOutput_QuickCheck', pOutput_QuickCheck
              , 'pOutput_CreateTextFile', 0
              , 'pOutput_AddSubsetAndAttrToOriginalDim', 1
              , 'pOutput_AddDimensionProperty', 1
              , 'pOutput_KeepTempCube', 0
              , 'pOutput_DetermineWeights', 1
              , 'pAddHelperAttributes', 0
              , 'pHier', ''
              , 'pConsol_Exclude', pConsol_Exclude
              );

            NumericGlobalVariable( 'ProcessReturnCode' );
            If( ProcessReturnCode = ProcessExitSeriousError );
               ProcessError;
            ElseIf( ProcessReturnCode = ProcessExitByQuit );
               ProcessQuit;
            EndIf;

         EndIf;

      EndIf;

      d = d + 1;

   End;

   # a text file for output
   If( pOutput_CreateTextFile <> 0 );

      TextOutput( vFile, 'Dimension', 'Double counted element' );

      d = 1;
      While( d <= ElementCount( '}Dimensions', '}Dimensions' ));

         pDim = ElementName( '}Dimensions', '}Dimensions', d );

         If( Subst( pDim, 1, 1 ) @<> '}' );

            vCheckDp = 0;
            If( ElementIndex( dp, dp, c08 ) = 0 );
               vCheckDp = 1;
            ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
               vCheckDp = 1;
            EndIf;

            If( vCheckDp = 1 );

               If( HierarchySubsetExists( pDim, pDim, c02 ) > 0 );

                  s = 1;
                  While( s <= HierarchySubsetGetSize( pDim, pDim, c02 ));
                     vDC = HierarchySubsetGetElementName( pDim, pDim, c02, s );
                     vParents = ElementAttrS( pDim, pDim, vDC, c02 );
                     TextOutput( vFile, pDim, vDC, vParents );
                     s = s + 1;
                  End;

               EndIf;

            EndIf;

         EndIf;

         d = d + 1;

      End;

   EndIf;

   # a numeric global variable
   Number_of_duplicates = 0;
   d = 1;
   While( d <= ElementCount( '}Dimensions', '}Dimensions' ));

      pDim = ElementName( '}Dimensions', '}Dimensions', d );

      If( Subst( pDim, 1, 1 ) @<> '}' );

         vCheckDp = 0;
         If( ElementIndex( dp, dp, c08 ) = 0 );
            vCheckDp = 1;
         ElseIf( CellGetN( dp, pDim, c08 ) = 0 );
            vCheckDp = 1;
         EndIf;

         If( vCheckDp = 1 );

            If( HierarchySubsetExists( pDim, pDim, c02 ) > 0 );

               Number_of_duplicates = Number_of_duplicates + HierarchySubsetGetSize( pDim, pDim, c02 );

            EndIf;

         EndIf;

      EndIf;

      d = d + 1;

   End;

   DataSourceType = 'NULL';


ElseIf( pMode = 5 );

   #############################
   # Add an element to the dimension }DimensionProperties to skip certain dimensions
   #############################

   If( ElementIndex( dp, dp, c08 ) = 0 );
      HierarchyElementInsert( dp, dp, '', c08, 'N' );
   EndIf;

   DataSourceType = 'NULL';

EndIf;



# Here begins the code to treat 1 dimension
# Notice the above:
#    DataSourceType = 'NULL';
#    ProcessBreak;


If( DataSourceType @= 'NULL' );
  pAction = 0;
EndIf;


# destroy / clean up
#######################

# the }DimensionProperties cube
If( pMode = 3
  % pMode = 4 );
    ViewDestroy( dp, c02 );
    HierarchySubsetDestroy( '}Dimensions', '}Dimensions', c02 );
    HierarchySubsetDestroy( dp, dp, c02 );
EndIf;


If( ( pMode = 1 ) & ( DimensionExists( pName ) > 0 ) );

   LogOutput( 'INFO', 'START Dimension: ''' | pName | '''.' );

   AsciiDelete( vFile );

   pDim = pName;

   If( pHier @= '' );
      pHier = pDim;
   Else;
      If( HierarchyExists( pDim, pHier ) = 0 );
         LogOutput( 'ERROR', 'The hierarchy ''' | pHier | ''' could not be found in the dimension ''' | pDim | '''.' );
         ProcessError;
      ElseIf( pHier @= 'Leaves' );
         LogOutput( 'ERROR', 'The Leaves hierarchy in the dimension ''' | pDim | ''' will not be investigated. By definition, no double counting to be expected.' );
         ProcessQuit;
      EndIf;
   EndIf;

   If( DimensionExists( pDim ) > 0 );
      If( HierarchyExists( pDim, pHier ) > 0 );
         HierarchySubsetDestroy( pDim, pHier, c02 );
         ElementAttrDelete( pDim, pHier, c02 );
      EndIf;
   EndIf;

   If( ElementIndex( dp, dp, c07 ) > 0 );
      # HiearchyElementDelete( '}DimensionProperties', '}DimensionProperties', c07 );
      CellPutN( 0, dp, pDim, c07 );
   EndIf;


   # the consolidated element - include elements below
   pConsol = Trim( pConsol );
   If( pConsol @<> '' );
      If( Scan( '*', pConsol ) > 0 % Scan( '?', pConsol ) > 0 );
         LogOutput( 'ERROR', 'Item "' | pConsol | '" contains wildcards. This is not allowed.' );
      ElseIf( ElementIndex( pDim, pHier, pConsol ) = 0 );
         LogOutput( 'ERROR', 'Item "' | pConsol | '" does not exist in the hierarchy ''' | pDim | ':' | pHier | '''. This is not allowed.' );
      ElseIf( ElementType( pDim, pHier, pConsol ) @<> 'C' );
         LogOutput( 'ERROR', 'Item "' | pConsol | '" is not a consolidated element in the hierarchy ''' | pDim | ':' | pHier | '''. This is not allowed.' );
      EndIf;
   EndIf;

   # the consolidated element - exclude elements below
   pConsol_Exclude = Trim( pConsol_Exclude );
   If( pConsol_Exclude @<> '' );
      If( Scan( '*', pConsol_Exclude ) > 0 % Scan( '?', pConsol_Exclude ) > 0 );
         LogOutput( 'ERROR', 'Item "' | pConsol_Exclude | '" contains wildcards. This is not allowed.' );
      ElseIf( ElementIndex( pDim, pHier, pConsol_Exclude ) = 0 );
         LogOutput( 'ERROR', 'Item "' | pConsol_Exclude | '" does not exist in the hierarchy ''' | pDim | ':' | pHier | '''. This is not allowed.' );
      ElseIf( ElementType( pDim, pHier, pConsol_Exclude ) @<> 'C' );
         LogOutput( 'ERROR', 'Item "' | pConsol_Exclude | '" is not a consolidated element in the hierarchy ''' | pDim | ':' | pHier | '''. This is not allowed.' );
      ElseIf( ( pConsol @<> '' ) & ( ElementIndex( pDim, pHier, pConsol ) = ElementIndex( pDim, pHier, pConsol_Exclude )));
         LogOutput( 'ERROR', 'Item "' | pConsol_Exclude | '" is also used for the consolidation to be included (pConsol), in the hierarchy ''' | pDim | ':' | pHier | '''. This is not allowed.' );
      EndIf;
   EndIf;


   CubeDestroy( vCube );
   DimensionDestroy( vDim1 );
   DimensionDestroy( vDim2 );
   DimensionDestroy( vDim3 );

   # cTemp will be a cube that is used to determine the weights of an element (when double counting) into a consolidation
   CubeDestroy( cTemp );
   DimensionDestroy( cTemp );


   # set up the objects and prepare for the real work
   If( pAction = 1 );

      # sanity checks
      If( DimensionExists( pDim ) = 0 );
         LogOutput( 'ERROR', 'Dimension ''' | pDim | ''' does not exist. The process stops.' );
         ProcessError;
      Else;
         vDim = DimensionElementPrincipalName( '}Dimensions', pDim );
      EndIf;

      ### Uncomment this section if you want to check for control dimensions
      ### pMode = 3 and pMode = 4 (looping over dimensions) exclude control dimensions (see above)
      ### If( Subst( vDim, 1, 1 ) @= '}' );
      ###   LogOutput( 'INFO', 'Dimension ''' | pDim | ''' starts with } and is not treated - no double counting detected.' );
      ###   pAction = 0;
      ###   DataSourceType = 'NULL';
      ### EndIf;

      If( ElementCount( vDim, pHier ) <= 1 );
         If( ElementCount( vDim, pHier ) = 0 );
            LogOutput( 'INFO', 'Hierarchy ''' | pHier | ''' in dimension ''' | pDim | ''' is empty - no double counting detected.' );
            pAction = 0;
            DataSourceType = 'NULL';
         Else;
            LogOutput( 'INFO', 'Hierarchy ''' | pHier | ''' in dimension ''' | pDim | ''' has only 1 element - no double counting detected.' );
            pAction = 0;
            DataSourceType = 'NULL';
         EndIf;
      EndIf;

      If( pConsol @= '' );
         vNrOfLevels = LevelCount( vDim, pHier );
         If( vNrOfLevels < 3 );
            LogOutput( 'INFO', 'Hierarchy ''' | pHier | ''' in dimension ''' | pDim | '''  has ' | NumberToString( vNrOfLevels ) | ' level(s) of elements - no double counting detected.' );
            pAction = 0;
            DataSourceType = 'NULL';
         EndIf;
      Else;
         vNrOfLevels = ElementLevel( vDim, pHier, pConsol );
         If( vNrOfLevels < 2 );
            LogOutput( 'INFO', 'Consolidation ''' | pConsol | ''' has level ' | NumberToString( vNrOfLevels ) | ' in the hierarchy ''' | pHier | ''' in dimension ''' | pDim | ''' - no double counting detected.' );
            pAction = 0;
            DataSourceType = 'NULL';
         EndIf;
         vNrOfLevels = vNrOfLevels + 1;
      EndIf;

      If( pAction = 1 );

         If( ProcessExists( cProcess ) = 0 );
            LogOutput( 'ERROR', 'The helper process ''' | cProcess | ''' could not be found.' );
            ProcessError;
         EndIf;


         # dimension 1 - a new dimension containing all (non-string) elements of the original dimension
         # but all are of type n in the new dimension
         If( DimensionExists( vDim1 ) > 0 );
            HierarchyDeleteAllElements( vDim1, vDim1 );
         Else;
            DimensionCreate( vDim1 );
         EndIf;

         # dimension 2 - a new dimension containing all consolidated elements of the original dimension
         # but all are of type n in the new dimension
         If( DimensionExists( vDim2 ) > 0 );
            HierarchyDeleteAllElements( vDim2, vDim2 );
         Else;
            DimensionCreate( vDim2 );
         EndIf;

         # dimension 3 - a measures dimension
         If( DimensionExists( vDim3 ) > 0 );
            HierarchyDeleteAllElements( vDim3, vDim3 );
         Else;
            DimensionCreate( vDim3 );
         EndIf;

         # a new cube to store the double countings, if any
         If( CubeExists( vCube ) > 0 );
            CellPutS( 'NO', '}CubeProperties', vCube, 'LOGGING' );
            CubeClearData( vCube );
         Else;
            CubeCreate( vCube, vDim1, vDim2, vDim3 );
            CellPutS( 'NO', '}CubeProperties', vCube, 'LOGGING' );
         EndIf;

         CellPutS( vDim3, '}CubeProperties', vCube, 'MEASURES_DIMENSION' );

         # a format attribute
         If( DimensionExists( '}ElementAttributes_' | vDim3 ) * ElementIndex( '}ElementAttributes_' | vDim3, '}ElementAttributes_' | vDim3, 'Format' ) = 0 );
            ElementAttrInsert( vDim3, vDim3, '', 'Format', 'S' );
         EndIf;

         # adding attributes
         If( pAddHelperAttributes <> 0 );

            If( DimensionExists( '}ElementAttributes_' | vDim1 ) * ElementIndex( '}ElementAttributes_' | vDim1, '}ElementAttributes_' | vDim1, 'Element Type' ) = 0 );
               ElementAttrInsert( vDim1, vDim1, '', 'Element Type', 'A' );
            EndIf;

            If( DimensionExists( '}ElementAttributes_' | vDim1 ) * ElementIndex( '}ElementAttributes_' | vDim1, '}ElementAttributes_' | vDim1, 'Element Index' ) = 0 );
               ElementAttrInsert( vDim1, vDim1, '', 'Element Index', 'A' );
            EndIf;

            If( DimensionExists( '}ElementAttributes_' | vDim2 ) * ElementIndex( '}ElementAttributes_' | vDim2, '}ElementAttributes_' | vDim2, 'Element Type' ) = 0 );
               ElementAttrInsert( vDim2, vDim2, '', 'Element Type', 'A' );
            EndIf;

            If( DimensionExists( '}ElementAttributes_' | vDim2 ) * ElementIndex( '}ElementAttributes_' | vDim2, '}ElementAttributes_' | vDim2, 'Element Index' ) = 0 );
               ElementAttrInsert( vDim2, vDim2, '', 'Element Index', 'A' );
            EndIf;

            CellPutS( 'NO', '}CubeProperties', '}ElementAttributes_' | vDim1, 'LOGGING' );
            CellPutS( 'NO', '}CubeProperties', '}ElementAttributes_' | vDim2, 'LOGGING' );

         EndIf;

         # add dimension properties
         If( pOutput_AddDimensionProperty <> 0 );

            If( ElementIndex( dp, dp, c07 ) = 0 );
               HierarchyElementInsert( dp, dp, '', c07, 'N' );
            EndIf;

            If( ElementIndex( dp, dp, c09 ) = 0 );
               HierarchyElementInsert( dp, dp, '', c09, 'N' );
            EndIf;

            If( ElementIndex( dp, dp, c10 ) = 0 );
               HierarchyElementInsert( dp, dp, '', c10, 'N' );
            EndIf;

            If( ElementIndex( dp, dp, c11 ) = 0 );
               HierarchyElementInsert( dp, dp, '', c11, 'N' );
            EndIf;

         EndIf;


         # Uncomment(/comment) these sections if you do (no) want to check for a maximum number of combinations
         # read the header of this process about the maximum number of combinations. Here we count them.
         # if too many combinations, stop it
         # I create dynamic subsets on vDim and immediately after that, I convert them to static subsets
         # The computations below ignore the parameter pConsol_Exclude, if used by the user
         l = 0;
         While( l < vNrOfLevels - 1 );
            vSubset_Up = 'Level ' | NumberToString( l + 1 ) | ' and up';

            m = l + 1;
            vLevels = '';
            While( m <= vNrOfLevels );
               vLevels = vLevels | ',' | NumberToString( m );
               m = m + 1;
            End;
            vLevels = Delet( vLevels, 1, 1 );

            HierarchySubsetCreate( vDim, pHier, vSubset_Up, 1 );
            If( pConsol @= '' );
               HierarchySubsetMDXSet( vDim, pHier, vSubset_Up, 'TM1FilterByLevel( Distinct( [' | vDim | '].[' | pHier | '].Members ), ' | vLevels | ')' );
               # LogOutput( 'INFO', '1' | '...' | NumberToString( l ) | '...' | vSubset_Up | '...' | 'TM1FilterByLevel( Distinct( [' | vDim | '].[' | pHier | '].Members ), ' | vLevels | ')' | '...' | NumberToString( HierarchySubsetGetSize( vDim, pHier, vSubset_Up )));
            Else;
               HierarchySubsetMDXSet( vDim, pHier, vSubset_Up, 'TM1FilterByLevel( Descendants( {[' | vDim | '].[' | pHier | '].[' | pConsol | ']} ), ' | vLevels | ')' );
               # LogOutput( 'INFO', '2' | '...' | NumberToString( l ) | '...' | vSubset_Up | '...' | 'TM1FilterByLevel( Descendants( {[' | vDim | '].[' | pHier | '].[' | pConsol | ']} ), ' | vLevels | ')' | '...' | NumberToString( HierarchySubsetGetSize( vDim, pHier, vSubset_Up )));
            EndIf;
            HierarchySubsetMDXSet( vDim, pHier, vSubset_Up, '' );

            If( HierarchySubsetGetSize( vDim, pHier, vSubset_Up ) = 0 );
               LogOutput( 'ERROR', 'Subset ''' | vSubset_Up | ''' does not contain elements, or could not be created.' );
               ProcessError;
            EndIf;

            vSubset = 'Level ' | NumberToString( l );

            HierarchySubsetDestroy( vDim, pHier, vSubset );

            vLevels = NumberToString( l );

            HierarchySubsetCreate( vDim, pHier, vSubset, 1 );
            If( pConsol @= '' );
               HierarchySubsetMDXSet( vDim, pHier, vSubset, 'TM1FilterByLevel( Distinct( [' | vDim | '].[' | pHier | '].Members ), ' | vLevels | ')' );
               # LogOutput( 'INFO', '3' | '...' | NumberToString( l ) | '...' | vSubset | '...' | 'TM1FilterByLevel( Distinct( [' | vDim | '].[' | pHier | '].Members ), ' | vLevels | ')' | '...' | NumberToString( HierarchySubsetGetSize( vDim, pHier, vSubset )));
            Else;
               HierarchySubsetMDXSet( vDim, pHier, vSubset, 'TM1FilterByLevel( Descendants( {[' | vDim | '].[' | pHier | '].[' | pConsol | ']} ), ' | vLevels | ')' );
               # LogOutput( 'INFO', '4' | '...' | NumberToString( l ) | '...' | vSubset | '...' | 'TM1FilterByLevel( Descendants( {[' | vDim | '].[' | pHier | '].[' | pConsol | ']} ), ' | vLevels | ')' | '...' | NumberToString( HierarchySubsetGetSize( vDim, pHier, vSubset )));
            EndIf;
            HierarchySubsetMDXSet( vDim, pHier, vSubset, '' );

            l = l + 1;
         End;


         LogOutput( 'INFO', '......' );


         vNrOfCombos = 0;
         l = 0;
         While( l < vNrOfLevels - 1 );
            vSubset_Up = 'Level ' | NumberToString( l + 1 ) | ' and up';
            vSubset = 'Level ' | NumberToString( l );

            # LogOutput( 'INFO', NumberToString( l ) | '...' | NumberToString( vNrOfLevels - 1 ) | '...' | vSubset_Up | '...' | vSubset | '...' | NumberToString( HierarchySubsetGetSize( vDim, pHier, vSubset_Up ) ) | '...' |
            #    NumberToString( HierarchySubsetGetSize( vDim, pHier, vSubset ) ) | '...' | NumberToString( HierarchySubsetGetSize( vDim, pHier, vSubset_Up ) * HierarchySubsetGetSize( vDim, pHier, vSubset )));

            vNrOfCombos = vNrOfCombos +
                          HierarchySubsetGetSize( vDim, pHier, vSubset_Up ) *
                          HierarchySubsetGetSize( vDim, pHier, vSubset );

            l = l + 1;

         End;

         # check the possible combinations
         sNrOfCombos = NumberToStringEx( vNrOfCombos, '#,#.##', ',', '.' );
         sMaxIterations = NumberToStringEx( cMaxIterations, '#,#.##', ',', '.' );
         If( vNrOfCombos > cMaxIterations );
            If( pConsol @= '' );
               If( pHier @= '' );
                  LogOutput( 'ERROR', 'In theory (but I do it better), checking dimension ''' | vDim | ''' would lead to looping over ' | sNrOfCombos | ' combinations. The process stops. The maximum number allowed is ' | sMaxIterations | '.' );
               Else;
                  LogOutput( 'ERROR', 'In theory (but I do it better), checking hierarchy ''' | pHier | ''' of dimension ''' | vDim | ''' would lead to looping over ' | sNrOfCombos | ' combinations. The process stops. The maximum number allowed is ' | sMaxIterations | '.' );
               EndIf;
            Else;
               If( pHier @= '' );
                  LogOutput( 'ERROR', 'In theory (but I do it better), checking consolidation ''' | pConsol | ''' in dimension ''' | vDim | ''' would lead to looping over ' | sNrOfCombos | ' combinations. The process stops. The maximum number allowed is ' | sMaxIterations | '.' );
               Else;
                  LogOutput( 'ERROR', 'In theory (but I do it better), checking consolidation ''' | pConsol | ''' in hierarchy ''' | pHier | ''' of dimension ''' | vDim | ''' would lead to looping over ' | sNrOfCombos | ' combinations. The process stops. The maximum number allowed is ' | sMaxIterations | '.' );
               EndIf;
            EndIf;
            ProcessError;
         Else;
            If( pConsol @= '' );
               If( pHier @= '' );
                  LogOutput( 'INFO', 'In theory (but I do it better), checking dimension ''' | vDim | ''' would lead to looping over ' | sNrOfCombos | ' combinations.' );
               Else;
                  LogOutput( 'INFO', 'In theory (but I do it better), checking hierarchy ''' | pHier | ''' of dimension ''' | vDim | ''' would lead to looping over ' | sNrOfCombos | ' combinations.' );
               EndIf;
            Else;
               If( pHier @= '' );
                  LogOutput( 'INFO', 'In theory (but I do it better), checking consolidation ''' | pConsol | ''' in dimension ''' | vDim | ''' would lead to looping over ' | sNrOfCombos | ' combinations.' );
               Else;
                  LogOutput( 'INFO', 'In theory (but I do it better), checking consolidation ''' | pConsol | ''' in hierarchy ''' | pHier | ''' of dimension ''' | vDim | ''' would lead to looping over ' | sNrOfCombos | ' combinations.' );
               EndIf;
            EndIf;
         EndIf;

         # populate the dimensions
         HierarchyElementInsert( vDim3, vDim3, '', c03, 'N');
         HierarchyElementInsert( vDim3, vDim3, '', c04, 'N');
         If( pOutput_DetermineWeights <> 0 );
            HierarchyElementInsert( vDim3, vDim3, '', c01, 'N');
         EndIf;
         HierarchyElementInsert( vDim3, vDim3, '', c05, 'S');
         HierarchyElementInsert( vDim3, vDim3, '', c06, 'S');

         # Create a cube to determine the weights: the effect of a double counted element on a consolidated element
         If( pOutput_DetermineWeights <> 0 );
            CubeDestroy( cTemp );
            DimensionDestroy( cTemp );
            DimensionCreate( cTemp );
            HierarchyElementInsert( cTemp, cTemp, '', c01, 'N' );
            CubeCreate( cTemp, pDim, cTemp );
            CellPutS( 'NO', '}CubeProperties', cTemp, 'LOGGING' );
         EndIf;

         Double_counting_exists = 0;

         # set the data source as the original dimension
         DataSourceType = 'SUBSET';
         If( pHier @= '' );
            DataSourceNameForServer = pDim;
         Else;
            DataSourceNameForServer = pDim | ':' | pHier;
         EndIf;
         DataSourceDimensionSubset = 'ALL';

         vIndex_of_Consol = ElementIndex( vDim, vDim, pConsol );
         vIndex_of_Consol_Exclude = ElementIndex( vDim, vDim, pConsol_Exclude );

      EndIf;
   EndIf;
EndIf;
573,40

#****Begin: Generated Statements***
#****End: Generated Statements****


# filling dimensions in the new cube
##############################

If( pAction = 1 );

   If( pConsol @<> '' );
   If( ElementIndex( vDim, pHier, vElement ) <> vIndex_of_Consol );
   If( ElementIsAncestor( vDim, pHier, pConsol, vElement ) = 0 );
      ItemSkip;
   EndIf;
   EndIf;
   EndIf;

   If( pConsol_Exclude @<> '' );
   If( ( ElementIndex( vDim, pHier, vElement ) = vIndex_of_Consol_Exclude ) %
       ( ElementIsAncestor( vDim, pHier, pConsol_Exclude, vElement ) > 0 ));
      ItemSkip;
   EndIf;
   EndIf;

   If( ElementType( vDim, pHier, vElement ) @= 'S' );
      ItemSkip;
   EndIf;

   # dimension 1: all elements
   # If( ElementParent( vDim, vDim, vElement, 1 ) @= '' );
      HierarchyElementInsert( vDim1, vDim1, '', vElement, 'N' );
   # EndIf;

   # dimension 2: all (consolidated) elements with a level of at least 1
   If( ElementLevel( vDim, pHier, vElement ) > 1 );
      HierarchyElementInsert( vDim2, vDim2, '', vElement, 'N' );
   EndIf;

EndIf;
574,44

#****Begin: Generated Statements***
#****End: Generated Statements****


# filling helper attributes
##############################

If( pAction = 1 );

   If( pAddHelperAttributes <> 0 );

      If( pConsol @<> '' );
      If( ElementIndex( vDim, pHier, vElement ) <> vIndex_of_Consol );
      If( ElementIsAncestor( vDim, pHier, pConsol, vElement ) = 0 );
         ItemSkip;
      EndIf;
      EndIf;
      EndIf;

      If( pConsol_Exclude @<> '' );
      If( ( ElementIndex( vDim, pHier, vElement ) = vIndex_of_Consol_Exclude ) %
          ( ElementIsAncestor( vDim, pHier, pConsol_Exclude, vElement ) > 0 ));
         ItemSkip;
      EndIf;
      EndIf;

      If( ElementType( vDim, pHier, vElement ) @= 'S' );
         ItemSkip;
      EndIf;

      # dimension 1: all elements
      ElementAttrPutS( vElement | ' (' | DType( pDim, vElement) | ')', vDim1, vDim1, vElement, 'Element Type' );
      ElementAttrPutS( vElement | ' (' | NumberToString( Dimix( pDim, vElement )) | ')', vDim1, vDim1, vElement, 'Element Index' );

      # dimension 2: all consolidated elements
      If( ElementLevel( pDim, pHier, vElement ) > 1 );
         ElementAttrPutS( vElement | ' (C)', vDim2, vDim2, vElement, 'Element Type' );
         ElementAttrPutS( vElement | ' (' | NumberToString( Dimix( pDim, vElement)) | ')', vDim2, vDim2, vElement, 'Element Index' );
      EndIf;

   EndIf;

EndIf;
575,221

#****Begin: Generated Statements***
#****End: Generated Statements****


If( pMode = 1 & pAction = 1 );

   If( ElementCount( vDim1, vDim1 ) = 0 );
     LogOutput( 'INFO', 'Dimension ''' | vDim1 | ''' has no elements.' );
     pAction = 0;
     # ProcessQuit;
   EndIf;

   If( ElementCount( vDim2, vDim2 ) = 0 );
     LogOutput( 'ERROR', 'Dimension ''' | vDim2 | ''' has no elements.' );
     pAction = 0;
     # ProcessQuit;
   EndIf;

   If( pAction = 1 );

      # loop over all consolidated elements, create a subset with the descendants and count the occurrences
      ##############################
      HierarchySubsetCreate( pDim, pHier, cTemp, 1 );
      vNrOfCombosDone = 0;
      e = 1;
      While( e <= ElementCount( vDim2, vDim2 ));
         vConso = ElementName( vDim2, vDim2, e );

         HierarchySubsetMDXSet( pDim, pHier, cTemp, '{Descendants(['| pDim |'].['| pHier |'].['| vConso |'])}' );
         HierarchySubsetElementDelete( pDim, pHier, cTemp, 1 );

         s = 1;
         While( s <= HierarchySubsetGetSize( pDim, pHier, cTemp ));
            vComponent = HierarchySubsetGetElementName( pDim, pHier, cTemp, s );
            CellIncrementN( 1, vCube, vComponent, vConso, c03 );
            vNrOfCombosDone = vNrOfCombosDone + 1;
            If( CellGetN( vCube, vComponent, vConso, c03 ) > 1 );
               Double_counting_exists = 1;
               If( pOutput_QuickCheck <> 0 );
                  # Escape as soon as possible !
                  s = HierarchySubsetGetSize( pDim, pHier, cTemp );
                  e = ElementCount( vDim2, vDim2 );
                  vSkip_processing = 1;
               EndIf;
            EndIf;

            s = s + 1;
         End;

         e = e + 1;

      End;


      LogOutput( 'INFO', 'Number of combinations done: ' | NumberToStringEx( vNrOfCombosDone, '#,#.##', ',', '.' ) | '.' );

      If( vSkip_processing = 0 );

         # apply formatting for the measures
         ##############################
         e = 1;
         While( e <= ElementCount( vDim3, vDim3 ));
            vElement = ElementName( vDim3, vDim3, e );
            If( ElementType( vDim, pHier, vElement ) @<> 'S' );
               ElementAttrPutS( 'b:0' | Char(12) | 'F|0|', vDim3, vDim3, vElement, 'Format' );
            EndIf;
            e = e + 1;
         End;


         # copy the double counting issues in the cube to a second measure to filter easily
         ##############################
         If( Double_counting_exists = 1 );

            If( pOutput_AddSubsetAndAttrToOriginalDim <> 0
              % pOutput_CreateTextFile <> 0 );
                  HierarchySubsetCreate( pDim, pHier, c02 );
                  ElementAttrInsert( pDim, pHier, '' ,c02, 'S' );
                  CellPutS( 'NO', '}CubeProperties', '}ElementAttributes_' | pDim, 'LOGGING' );
            EndIf;

            ExecuteProcess( cProcess
              , 'pCube', vCube
              , 'pDim', pDim
              , 'pHier', pHier
              , 'pSubsetAndAttrWithDC', If( pOutput_AddSubsetAndAttrToOriginalDim <> 0 % pOutput_CreateTextFile <> 0, c02, '' )
              , 'cTemp', If( pOutput_DetermineWeights <> 0, cTemp, '' )
            );

            # add a dimension property
            If( pOutput_AddDimensionProperty <> 0 );

               CellPutN( HierarchySubsetGetSize( pDim, pHier, c02 ), dp, pDim, c07 );
               If( ElementIndex( dp, dp, c07 ) = 0 );
                  ElementAttrPutS( 'b:0' | Char(12) | 'F|0|', dp, dp, c07, 'Format' );
               EndIf;

            EndIf;

            # add a view and subsets for easy navigation
            If( pOutput_AddDimensionProperty <> 0 );
               If( HierarchySubsetExists( '}Dimensions', '}Dimensions', c02 ) = 0 );
                  SubsetCreateByMDX( c02, '{Order( Filter( TM1FilterByLevel( TM1SubsetAll( [}Dimensions].[}Dimensions] ), 0),
                  [' | dp | '].([' | dp | '].[' | c07 | ']) <> 0 ), [' | dp | '].([' | dp | '].[' | c07 | ']), BDesc) }' );
               EndIf;
               If( HierarchySubsetExists( dp, dp, c02 ) = 0 );
                  SubsetCreateByMDX( c02, '{[' | dp | '].[' | dp | '].[' | c07 | ']}' );
               EndIf;

               If( ViewExists( dp, c02 ) = 0 );
                  ViewCreate( dp, c02 );
                  ViewSubsetAssign( dp, c02, '}Dimensions', c02 );
                  ViewSubsetAssign( dp, c02, dp, c02 );
                  ViewTitleDimensionSet( dp, c02, c02 );
                  ViewRowDimensionSet( dp, c02, '}Dimensions', 1 );
                  ViewRowSuppressZeroesSet( dp, c02, 1 );
               EndIf;
            EndIf;

         Else;

            CellPutN( 0.001, vCube, ElementFirst( vDim1, vDim1 ), ElementFirst( vDim2, vDim2 ), 'Double counting issue' );
            CellPutS( 'No double counting spotted', vCube, ElementFirst( vDim1, vDim1 ), ElementFirst( vDim2, vDim2 ), c06 );

         EndIf;


         # a text file for output
         If( pOutput_CreateTextFile <> 0 );

            If( HierarchySubsetExists( pDim, pHier, c02 ) > 0 );

               If( Double_counting_exists = 0 );
                  TextOutput( vFile, 'No double countings detected' );
               Else;
                  TextOutput( vFile, 'Dimension', 'Double counted element', 'Parents' );
                  s = 1;
                  While( s <= HierarchySubsetGetSize( pDim, pHier, c02 ));
                     vDC = HierarchySubsetGetElementName( pDim, pHier, c02, s );
                     vParents = ElementAttrS( pDim, pHier, vDC, c02 );
                     If( pHier @= '' );
                        TextOutput( vFile, pDim, vDC, vParents );
                     Else;
                        TextOutput( vFile, pDim | ':' | pHier, vDC, vParents );
                     EndIf;
                     s = s + 1;
                  End;
               EndIf;

            EndIf;

         EndIf;

         If( HierarchySubsetExists( pDim, pHier, c02 ) > 0 );

            LogOutput( 'INFO', 'Number of duplicates found for dimension ''' | pDim | ''': ' | NumberToString( HierarchySubsetGetSize( pDim, pHier, c02 )) | '.' );
            Number_of_duplicates = SubsetGetSize( pDim, c02 );

         EndIf;


         # keep the temporary cube that contains the double counted elements, their problematic ancestors, their weights, and more
         If( pOutput_KeepTempCube <> 0 );

            # create a Default view with the double counted elements
            ##############################
            ViewDestroy( vCube, c00 );
            SubsetDestroy( vDim1, c00 );
            SubsetDestroy( vDim2, c00 );
            SubsetDestroy( vDim3, c00 );

            SubsetCreateByMDX( c00, '{TM1SubsetAll( [' | vDim1 | '].[' | vDim1 | '] )}');
            SubsetCreateByMDX( c00, '{TM1SubsetAll( [' | vDim2 | '].[' | vDim2 | '] )}');

            HierarchySubsetCreate( vDim3, vDim3, c00 );
            HierarchySubsetElementInsert( vDim3, vDim3, c00, c04, 0 );
            If( pOutput_DetermineWeights <> 0 );
               HierarchySubsetElementInsert( vDim3, vDim3, c00, c01, 0 );
            EndIf;
            HierarchySubsetElementInsert( vDim3, vDim3, c00, c05, 0 );
            HierarchySubsetElementInsert( vDim3, vDim3, c00, c06, 0 );

            ViewCreate( vCube, c00 );
            ViewSuppressZeroesSet( vCube, c00, 1 );

            ViewSubsetAssign( vCube, c00, vDim1, c00 );
            ViewSubsetAssign( vCube, c00, vDim2, c00 );
            ViewSubsetAssign( vCube, c00, vDim3, c00 );

            ViewRowDimensionSet( vCube, c00, vDim1, 1 );
            ViewRowDimensionSet( vCube, c00, vDim2, 2 );
            ViewColumnDimensionSet( vCube,  c00, vDim3, 1 );

         Else;

            CubeDestroy( vCube );
            DimensionDestroy( vDim1 );
            DimensionDestroy( vDim2 );
            DimensionDestroy( vDim3 );

         EndIf;


         If( pOutput_DetermineWeights <> 0 );
            CubeDestroy( cTemp );
            DimensionDestroy( cTemp );
         EndIf;

         # store statistics
         CellPutN( LevelCount( vDim, vDim ), dp, vDim, c09 );
         CellPutN( ElementCount( vDim, vDim ), dp, vDim, c10 );
         CellPutN( RoundP(( Now - vStartTime ) / 24 / 60 / 60, 2 ), dp, vDim, c11 );

      EndIf;

      LogOutput( 'INFO', 'END Dimension: ''' | pName | '''.' );

   EndIf;

EndIf;
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
