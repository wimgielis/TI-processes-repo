601,100
602,"WG_SECURITY_export_tm1_users_for_paw"
562,"NULL"
586,
585,
564,
565,"k\oCt99j3aYa?DCjuYL4Da\h0`1O<9_32k^]sK7NPJdE\z:kla4SfnV6O;Wg6DY0L0?bbN]2n9:KjNO3?A\R>Kuo=>Mx79hVBMA^zyk:B>xxl2eA9;iMjVz@hOTS;[]h7z`blafzSXEQgn_ckL\m<hsd@>H>HFiaau<IOdouXX6e_HdE?ZnAn2i?GcRbt`ckzWcxHth>"
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
571,All
569,0
592,0
599,1000
560,4
pIBMCloud
pEnvironments
pDirective
pOnPremNamespace
561,4
2
2
2
2
590,4
pIBMCloud,"Y / N"
pEnvironments,"Alpro|Alpro - alprotst|Beaulieu ICT nv|Beaulieu ICT nv - bigdev|Beaulieu ICT nv - bigqas, or empty (if not IBMCloud)"
pDirective,"ADD / REMOVE"
pOnPremNamespace,"Alpro"
637,4
pIBMCloud,"IBM Cloud (Y = Yes, all else = No)"
pEnvironments,"Environment name ? (could be | delimited) (empty for on-premise)"
pDirective,"Directive ? (ADD or REMOVE)"
pOnPremNamespace,"On-premise namespace ? (to unlock additional functionality)"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,248

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# June 2024
# https://www.wimgielis.com
####################################################
#
# This process can help us create PAW users, based on (the same) TM1 users.
# Both IBM cloud and on-premise installations can be supported.
# A different CSV file layout is generated depending on the installation.
#
# Fields in a custom CSV file for the IBM Cloud:
# - Mandatory fields: Login ID, First Name, Last Name
# - Optional fields: Role, Environment, Directive
#
# Fields in a custom CSV file for an on-premise installation:
# - Mandatory fields: Login ID, First Name, Last Name, Status
# - Optional fields: Role, Email, Directive
#
# The pOnPremNamespace parameter is for instance used in:
# it the }Clients dimension does not have attributes for first name and last name,
# then the }TM1_DefaultDisplayValue alias value could be split on a space after removing the Namespace and a slash.
#
# For the different environment(s) in the IBM Cloud, it is easy to first take a manual export of the users.
# The CSV file export will contain the exact name for the environment that IBM Cloud expects.
#
# Work in progress:
# - Escape the , characters that could occur in some attribute values
# - What if some attributes do not exist or some attribute values are empty ?
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
ExecuteProcess( 'WG_SECURITY_export_tm1_users_for_paw'
  , 'pIBMCloud', 'Y / N'
  , 'pEnvironments', 'Beaulieu ICT nv|Beaulieu ICT nv - bigdev|Beaulieu ICT nv - bigqas, or empty'
  , 'pDirective', 'ADD / REMOVE'
  , 'pOnPremNamespace', 'Beaulieu'
  );
EndIf;
#EndRegion CallThisProcess


cSeparator = '|';

cDim = '}Clients';
c0 = 'all_clients';

c1 = '}TM1_DefaultDisplayValue';
c2 = 'Email';
c3 = 'First Name';
c4 = 'Last Name';


# Test the parameter values
pIBMCloud = Trim( pIBMCloud );

pDirective = Trim( pDirective );
If( pDirective @<> 'ADD' & pDirective @<> 'REMOVE' );
   vMessage = 'The ''pDirective'' parameter should be either ''ADD'' or ''REMOVE''. However, the user provided: ''' | pDirective | '''.';
   LogOutput( 'ERROR', vMessage );
   ProcessError;
EndIf;

# Where do we output text files and import them again afterwards
StringGlobalVariable( 'cDestination_Folder' );
ExecuteProcess( 'TECH_folder for output', 'pSubfolder', 'Export TM1 users for PAW', 'pMainFolder', '1+' );

# The CSV file for the output
vFile = cDestination_Folder | 'all-users' | Timst( Now, '\Y-\m-\d \h\i\s' ) | '.csv';
SetOutputCharacterSet( vFile, 'TM1CS_UTF8' );

DatasourceAsciiDelimiter = ',';
DatasourceAsciiQuoteCharacter = '';
DatasourceAsciiDecimalSeparator = '';
DatasourceAsciiThousandSeparator = '';

# A header for the CSV file
If( pIBMCloud @= 'Y' );
   TextOutput( vFile, 'Login Id', 'First Name', 'Last Name', 'Role', 'Environment', 'Directive', 'Last Login' );
Else;
   TextOutput( vFile, 'Login Id', 'First Name', 'Last Name', 'Role', 'Email', 'Status', 'Directive', 'Last Login' );
EndIf;

# Retrieve all clients in the model
SubsetCreateByMDX( c0, 'TM1SubsetAll( [ ' | cDim | '] )', 1 );

If( SubsetExists( cDim, c0 ) = 0 );
   vMessage = 'The subset with all clients on the dimension ''' | cDim | ''' could not be created successfully.';
   LogOutput( 'ERROR', vMessage );
   DataSourceType = 'NULL';
   ProcessError;
EndIf;
vNameExtraction = 0;

# Loop over the clients
c = 1;
While( c <= SubsetGetSize( cDim, c0 ));

   vClient = SubsetGetElementName( cDim, c0, c );

   # Gather the file contents as properties of the client
   vDisabled = CellGetN( '}ClientProperties', vClient, 'IsDisabled' );

   vReadOnly = CellGetN( '}ClientProperties', vClient, 'ReadOnlyUser' );
   vAdmin = CellGetS( '}ClientGroups', vClient, 'ADMIN' );

   vDirective = pDirective;
   vLast_Login = '';
   vClient_DisplayName = '';
   vEmail_Address = '';
   vFirst_Name = '';
   vLast_Name = '';

   If( Dimix( '}ElementAttributes_' | cDim, c1 ) > 0 );
      vClient_DisplayName = Attrs( cDim, vClient, c1 );
      If( vClient_DisplayName @= '' );
         vClient_DisplayName = vClient;
      EndIf;
   Else;
      vClient_DisplayName = vClient;
   EndIf;
   If( Dimix( '}ElementAttributes_' | cDim, c2 ) > 0 );
      vEmail_Address = Attrs( cDim, vClient, c2 );
   Else;
      vEmail_Address = Expand( 'Unknown email for %vClient_DisplayName%' );
   EndIf;
   If( Dimix( '}ElementAttributes_' | cDim, c3 ) > 0 );
      vFirst_Name = Attrs( cDim, vClient, c3 );
   # Else;
      # vFirst_Name = vClient;
   EndIf;
   If( Dimix( '}ElementAttributes_' | cDim, c4 ) > 0 );
      vLast_Name = Attrs( cDim, vClient, c4 );
   # Else;
      # vLast_Name = vClient;
   EndIf;
   # unlocking extra functionality to extract first name/last name:
   # maybe the }TM1_DefaultDisplayValue alias value can be split on a space
   # we might need to remove the namespace first
   If( vFirst_Name @= '' );
   If( vLast_Name @= '' );

      If( Dimix( '}ElementAttributes_' | cDim, c1 ) > 0 );
         vNameExtraction = 1;
         vClient_DisplayName = Trim( Attrs( cDim, vClient, c1 ));
         If( vClient_DisplayName @<> '' );
            If( pOnPremNamespace @<> '' );
               If( Subst( vClient_DisplayName, 1, Long( pOnPremNamespace )) @= pOnPremNamespace );
               If( Subst( vClient_DisplayName, Long( pOnPremNamespace ) + 1, 1 ) @= '\' %
                   Subst( vClient_DisplayName, Long( pOnPremNamespace ) + 1, 1 ) @= '/' );
                  vClient_DisplayName = Delet( vClient_DisplayName, 1, Long( pOnPremNamespace ) + 1 );
               EndIf;
               EndIf;
            EndIf;
            If( Scan( ' ', vClient_DisplayName ) > 1 );
               vFirst_Name = Subst( vClient_DisplayName, 1, Scan( ' ', vClient_DisplayName ) - 1 );
               vLast_Name  = Delet( vClient_DisplayName, 1, Scan( ' ', vClient_DisplayName ));
            EndIf;
         EndIf;
      EndIf;

   EndIf;
   EndIf;

   If( vAdmin @<> '' );
      vRole = 'Administrator';
   ElseIf( vReadOnly <> 0 );
      vRole = 'Consumer';
   Else;
      vRole = 'Consumer';
      # vRole = 'Analyst';
      # vRole = 'Modeler';
   EndIf;

   # A "warning text" near the top of the CSV file
   If( c = 1 );
      If( vNameExtraction = 1 );
         TextOutput( vFile, '' );
         TextOutput( vFile, '' );
         TextOutput( vFile, '     ATTENTION ! The extraction code has tried to come up with sensible first and last names for clients.' );
         TextOutput( vFile, '     In case they are swapped please turn around the column entries/headers.' );
         TextOutput( vFile, '' );
         TextOutput( vFile, '     Also, remove this notification text prior to uploading the generated CSV file in PA.' );
         TextOutput( vFile, '' );
         TextOutput( vFile, '' );
      EndIf;
   EndIf;

   # Output to text file
   If( pIBMCloud @= 'Y' );

      vLogin_ID = vEmail_Address;

      # Loop over the environments to create entries in the CSV file
      vEnvironments = Trim( pEnvironments );
      If( Subst( vEnvironments, Long( vEnvironments ) - Long( cSeparator ) + 1, Long( cSeparator )) @<> cSeparator );
         vEnvironments = vEnvironments | cSeparator;
      EndIf;

      r = Scan( cSeparator, vEnvironments );
      While( r > 0 );

         vEnvironment = Subst( vEnvironments, 1, r - 1 );

         # Update the text file output
         TextOutput( vFile, vLogin_ID, vFirst_Name, vLast_Name, vRole, vEnvironment, vDirective, vLast_Login );

         vEnvironments = Delet( vEnvironments, 1, r + Long( cSeparator ) - 1 );
         r = Scan( cSeparator, vEnvironments );

      End;

   Else;

      vLogin_ID = vClient;

      If( vDisabled = 0 );
         vStatus = 'ACTIVE';
      Else;
         vStatus = 'SUSPENDED';
      EndIf;

      If( vEmail_Address @= '' );
         vEmail_Address = 'NOT_SET';
      EndIf;

      # Update the text file output
      TextOutput( vFile, vLogin_ID, vFirst_Name, vLast_Name, vRole, vEmail_Address, vStatus, vDirective, vLast_Login );

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
576,CubeAction=1511DataAction=1503CubeLogChanges=0_ParameterConstraints=e30
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
