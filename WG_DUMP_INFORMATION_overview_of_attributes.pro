601,100
602,"WG_DUMP_INFORMATION_overview_of_attributes"
562,"NULL"
586,
585,
564,
565,"fP6D<Rah=oMJuM5V]E22\\aOpIgKU]iNplaC1DW\=tvw\u73Awy4sAbMbwU^hPM@vvelnsp;=M9o;VwSb;x]5zEqWQ=kQMuEFbPh?^7JLT:I?sQYq0XTM?rFwa9OgvRz:Jw5=jpm:UopUkRpqTAgeFEQHZ8LiT;j\0fqVgbuMG5e65Rb0BB]4lgRXUaiJ3XN^3_oGGQh"
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
572,361

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# July 2024
# https://www.wimgielis.com
####################################################
#
# This TI process can export attributes and information related to them.
#
###########################################################

#####
# Add the following process(es) to this TM1 model:
# - TECH_folder for output
#####
#EndRegion IntroduceThisProcess


#Region CallThisProcess
## call this custom process as, for instance:
If( 1 = 0 );
ExecuteProcess( 'WG_DUMP_INFORMATION_overview_of_attributes' );
EndIf;
#EndRegion CallThisProcess


# Where do we output text files ?
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Overview of attributes', 'pMainFolder', '1+' );

vFile = cDestination_Folder | 'All attributes.csv';

DataSourceAsciiQuoteCharacter = '';
DataSourceAsciiDelimiter = ';';


# output headers to a file
TextOutput( vFile, 'Dimension', 'AttributeName', 'AttributeType', 'Type', 'OData non-compliance' );

## Regular attributes

# loop over the dimensions that contain attributes
d = 1;
While( d <= Dimsiz( '}Dimensions' ));

   vDim = Dimnm( '}Dimensions', d );

   If( Scan( ':', vDim ) = 0 );
      vMain_Dim = vDim;
   Else;
      vMain_Dim = Subst( vDim, 1, Scan( ':', vDim ) - 1 );
   EndIf;
   vDimAttr = '}ElementAttributes_' | vMain_Dim;

   # Skip certain dimensions
   If( Scan( '}tp_', vDim ) <> 1 );

      If( DimensionExists( vDimAttr ) > 0 );

         If( Dimsiz( vDimAttr ) > 0 );

            # there appear to be attributes, so let's loop over them
            a = 1;
            While( a <= Dimsiz( vDimAttr ));

               vAttributeName = Dimnm( vDimAttr, a );
               vAttributeType = DType( vDimAttr, vAttributeName );

               # determine the attribute type
               If( vAttributeType @= 'AA' );
                  vAttributeType_Name = 'Alias';
               ElseIf( vAttributeType @= 'AN' );
                  vAttributeType_Name = 'Numeric attribute';
               ElseIf( vAttributeName @= 'Format' );
                  vAttributeType_Name = 'Formatting attribute';
               Else;
                  vAttributeType_Name = 'Text attribute';
               EndIf;

               vREST_Allowed = 'Y';
               t = 1;
               While( (t <= Long( vAttributeName )) & ( vREST_Allowed @= 'Y' ));
                  tLetter = Subst( vAttributeName, t, 1 );
                  If( Scan( tLetter, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_' ) = 0 );
                     vREST_Allowed = 'N';
                  EndIf;
                  t = t + 1;
               End;

               # output to a file
               TextOutput( vFile, vDim, vAttributeName, vAttributeType_Name, 'Regular attribute', vREST_Allowed );

               a = a + 1;
            End;

         EndIf;

      EndIf;

   EndIf;

   d = d + 1;

End;


## Attributes for builtin objects

# loop over the objects that can have such attributes
o = 1;
While( o <= 4 );

   If( o = 1 );
      vObject = 'Cube';
   ElseIf( o = 2 );
      vObject = 'Dimension';
   ElseIf( o = 3 );
      vObject = 'Process';
   Else;
      vObject = 'Chore';
   EndIf;

   vDimAttr = '}' | vObject | 'Attributes';

   If( CubeExists( vDimAttr ) > 0 );
   If( DimensionExists( vDimAttr ) > 0 );
   If( Dimsiz( vDimAttr ) > 0 );

       # there appear to be attributes, so let's loop over them
       a = 1;
       While( a <= Dimsiz( vDimAttr ));

          vAttributeName = Dimnm( vDimAttr, a );
          vAttributeType = DType( vDimAttr, vAttributeName );

          # determine the attribute type
          If( vAttributeType @= 'AA' );
             vAttributeType_Name = 'Alias';
          ElseIf( vAttributeType @= 'AN' );
             vAttributeType_Name = 'Numeric attribute';
          ElseIf( vAttributeName @= 'Format' );
             vAttributeType_Name = 'Formatting attribute';
          Else;
             vAttributeType_Name = 'Text attribute';
          EndIf;

          # output to a file
          TextOutput( vFile, vObject, vAttributeName, vAttributeType_Name, 'Attributes for objects', 'W.I.P.' );

          a = a + 1;
       End;

   EndIf;
   EndIf;
   EndIf;

   o = o + 1;

End;


## Localized attributes for regular dimensions

# loop over the cubes that pertain to localized attributes
c = 1;
While( c <= Dimsiz( '}Cubes' ));

   vCube = Dimnm( '}Cubes', c );

   # Skip certain cubes
   If( Scan( '}LocalizedElementAttributes_', vCube ) = 1 );

      vMain_Dim = Tabdim( vCube, 1 );
      vDimAttr = Tabdim( vCube, 3 );

      If( Dimsiz( vDimAttr ) > 0 );

         # there appear to be attributes, so let's loop over them
         a = 1;
         While( a <= Dimsiz( vDimAttr ));

            vAttributeName = Dimnm( vDimAttr, a );
            vAttributeType = DType( vDimAttr, vAttributeName );

            # determine the attribute type
            If( vAttributeType @= 'AA' );
               vAttributeType_Name = 'Alias';
            ElseIf( vAttributeType @= 'AN' );
               vAttributeType_Name = 'Numeric attribute';
            ElseIf( vAttributeName @= 'Format' );
               vAttributeType_Name = 'Formatting attribute';
            Else;
               vAttributeType_Name = 'Text attribute';
            EndIf;

            # output to a file
            TextOutput( vFile, vMain_Dim, vAttributeName, vAttributeType_Name, 'Localized attributes for regular dimensions', 'W.I.P.' );

            a = a + 1;
         End;

      EndIf;

   EndIf;

   c = c + 1;

End;


## View attributes for cubes

# loop over the cubes that pertain to view attributes for cubes
c = 1;
While( c <= Dimsiz( '}Cubes' ));

   vCube = Dimnm( '}Cubes', c );

   # Skip certain cubes
   If( Scan( '}ViewAttributes_', vCube ) = 1 );

      vMain_Cube = Delet( vCube, 1, Long( '}ViewAttributes_' ));
      vDimAttr = vCube;

      If( Dimsiz( vDimAttr ) > 0 );

         # there appear to be attributes, so let's loop over them
         a = 1;
         While( a <= Dimsiz( vDimAttr ));

            vAttributeName = Dimnm( vDimAttr, a );
            vAttributeType = DType( vDimAttr, vAttributeName );

            # determine the attribute type
            If( vAttributeType @= 'AA' );
               vAttributeType_Name = 'Alias';
            ElseIf( vAttributeType @= 'AN' );
               vAttributeType_Name = 'Numeric attribute';
            ElseIf( vAttributeName @= 'Format' );
               vAttributeType_Name = 'Formatting attribute';
            Else;
               vAttributeType_Name = 'Text attribute';
            EndIf;

            # output to a file
            TextOutput( vFile, vMain_Cube, vAttributeName, vAttributeType_Name, 'View attributes for cubes', 'W.I.P.' );

            a = a + 1;
         End;

      EndIf;

   EndIf;

   c = c + 1;

End;


### Subset attributes for dimensions

# loop over the cubes that pertain to subset attributes for dimensions
c = 1;
While( c <= Dimsiz( '}Cubes' ));

   vCube = Dimnm( '}Cubes', c );

   # Skip certain cubes
   If( Scan( '}SubsetAttributes_', vCube ) = 1 );

      vMain_Dim = Delet( vCube, 1, Long( '}SubsetAttributes_' ));
      vDimAttr = vCube;

      If( Dimsiz( vDimAttr ) > 0 );

         # there appear to be attributes, so let's loop over them
         a = 1;
         While( a <= Dimsiz( vDimAttr ));

            vAttributeName = Dimnm( vDimAttr, a );
            vAttributeType = DType( vDimAttr, vAttributeName );

            # determine the attribute type
            If( vAttributeType @= 'AA' );
               vAttributeType_Name = 'Alias';
            ElseIf( vAttributeType @= 'AN' );
               vAttributeType_Name = 'Numeric attribute';
            ElseIf( vAttributeName @= 'Format' );
               vAttributeType_Name = 'Formatting attribute';
            Else;
               vAttributeType_Name = 'Text attribute';
            EndIf;

            # output to a file
            TextOutput( vFile, vMain_Dim, vAttributeName, vAttributeType_Name, 'Subset attributes for dimensions', 'W.I.P.' );

            a = a + 1;
         End;

      EndIf;

   EndIf;

   c = c + 1;

End;

## Localized attributes for objects

# loop over the cubes that pertain to such localized attributes
c = 1;
While( c <= Dimsiz( '}Cubes' ));

   vCube = Dimnm( '}Cubes', c );

   # Skip certain cubes
   If( Scan( '}Localized', vCube ) = 1 );
   If( Scan( '}LocalizedElementAttributes_', vCube ) = 0 );

      vMain_Dim = Tabdim( vCube, 1 );
      vDimAttr = Tabdim( vCube, 3 );

      If( Dimsiz( vDimAttr ) > 0 );

         # there appear to be attributes, so let's loop over them
         a = 1;
         While( a <= Dimsiz( vDimAttr ));

            vAttributeName = Dimnm( vDimAttr, a );
            vAttributeType = DType( vDimAttr, vAttributeName );

            # determine the attribute type
            If( vAttributeType @= 'AA' );
               vAttributeType_Name = 'Alias';
            ElseIf( vAttributeType @= 'AN' );
               vAttributeType_Name = 'Numeric attribute';
            ElseIf( vAttributeName @= 'Format' );
               vAttributeType_Name = 'Formatting attribute';
            Else;
               vAttributeType_Name = 'Text attribute';
            EndIf;

            # output to a file
            TextOutput( vFile, vMain_Dim, vAttributeName, vAttributeType_Name, 'Localized attributes for objects', 'W.I.P.' );

            a = a + 1;
         End;

      EndIf;

   EndIf;
   EndIf;

   c = c + 1;

End;
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
