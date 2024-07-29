601,100
602,"WG_TECH_PRO_regex find"
562,"NULL"
586,
585,
564,
565,"leWKQ8HM_L?wa8kFlr1bCf\8GZ6Fg6j7Vn=:EosqTkhPk3:Cz^`1=q1ho\K4z`MneXkcKJiCRdjtqGvG@fksR\8I>W1L8cjd[9p`ARU@5kwLhvIiWq]_r4CM5OJ4MSYxyvc1E6k^[:_zbI<lq<AtBz4EnjI?D]l?hOPMc22jbS5Su7l5^MMWp?7STuk<pf[N7;yeVdQf"
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
589,"."
568,""""
570,
571,
569,0
592,0
599,1000
560,2
pString
pExpression
561,2
2
2
590,2
pString,""
pExpression,""
637,2
pString,"String?"
pExpression,"Expression?"
577,0
578,0
579,0
580,0
581,0
582,0
603,0
572,158

#****Begin: Generated Statements***
#****End: Generated Statements****


#Region IntroduceThisProcess
####################################################
# Wim Gielis
# March 2023
# https://www.wimgielis.com
####################################################

####################################################
#
# Written by: Dennis Bontekoning (Aexis)
# February 2016
# Source: http://www.tm1forum.com/viewtopic.php?f=21&t=12296
#
####################################################
#EndRegion IntroduceThisProcess


NumericGlobalVariable('Regex_find_position');
NumericGlobalVariable('Regex_find_length');

## Determine character length of string and expression.
## Determine maximum number of options
####
vStrLen = Long(pString);
vExprLen = Long(pExpression);
vMaxOptions = vStrLen * vExprLen;


## Set starting values
####
vMatchString = '';
vUsedOptions = 0;
vStrPosEntry = 0;
vStrPosMatch = 0;


## Loop over expression string per character and see if string is valid
##
## The following arguments are supported
##  1: Single character
##  2: ? (question mark), represents a single character
##  3: * (asterix), represents any number of characters
##
####
vExprPos = 1;
While(vExprPos <= vExprLen & vUsedOptions <= vMaxOptions);

  ## Loop over string characters
  ####
  vFound = 0;
  vStrPos = 1 + vStrPosMatch + vStrPosEntry;

  # bug discovered:
  # http://www.tm1forum.com/viewtopic.php?f=21&t=12296&p=64707
  If(vStrPos > vStrLen);
    vMatchString = '';
  EndIf;

  While(vStrPos <= vStrLen);

    ## Check if next expression character matches
    ####
    vFound_next = 0;
    If(vExprPos < vExprLen & Subst(pExpression, vExprPos, 1) @= '*');
      If((Subst(pExpression, vExprPos + 1, 1) @= '?' & Subst(pString, vStrPos, 1) @<> '') %
        Subst(pExpression, vExprPos + 1, 1) @= Subst(pString, vStrPos, 1));
        vFound_next = 1;
      EndIf;
    EndIf;

    ## Check for any character (asterix)
    ## In case next expression character has a match, do not add the matched character to
    ## to the matchstring
    ####
    If(Subst(pExpression, vExprPos, 1) @= '*' & (Subst(pString, vStrPos, 1) @<> '' % Subst(pString, vStrPos, 1) @= ' '));
      If(vFound_next = 0);
        vMatchString = vMatchString | Subst(pString, vStrPos, 1);
        vFound = 1;
      Else;
        vFound = 1;
      EndIf;
    EndIf;

    ## Check for any single character (question mark)
    ####
    If(Subst(pExpression, vExprPos, 1) @= '?' & Subst(pString, vStrPos, 1) @<> '');
      vMatchString = vMatchString | Subst(pString, vStrPos, 1);
      vFound = 1;
    EndIf;

    ## Check for 1 on 1 character
    ####
    If(Subst(pExpression, vExprPos, 1) @= Subst(pString, vStrPos, 1));
      vMatchString = vMatchString | Subst(pString, vStrPos, 1);
      vFound = 1;
    EndIf;


    ## DEBUG
    ####
    #TextOutput('c:\tmp\regex.txt', pExpression, NumberToString(vExprLen), NumberToString(vExprPos), Subst(pExpression, vExprPos, 1),
      #pString, NumberToString(vStrLen), NumberToString(vStrPosEntry), NumberToString(vStrPos),
     #Subst(pString, vStrPos, 1), NumberToString(vStrPosMatch), NumberToString(vFound), vMatchSTring);

    ## If a match has been found in the input string, skip to next character of expression
    ## otherwise skip to next input string character
    ####
    If(vFound = 1 & Subst(pExpression, vExprPos, 1) @<> '*');
      vStrPosMatch = vStrPos - vStrPosEntry;
      vStrPos = vStrLen + 1;
      vExprPosReset = 0;
    ElseIf(vFound = 1 & Subst(pExpression, vExprPos, 1) @= '*');
      ## If the next character in the expression also has a match on the current string character
      ## break out of the loop and continue with the next expression character
      ####
      If(vFound_next = 1);
        vStrPosMatch = vStrPos - vStrPosEntry - 1;
        vStrPos = vStrLen + 1;
        vExprPosReset = 0;
      Else;
        vStrPosMatch = vStrPos - vStrPosEntry;
        vStrPos = vStrPos + 1;
        vExprPosReset = 0;
      EndIf;
    Else;
      vMatchString = '';
      vStrPosMatch = 0;
      vExprPosReset = 1;
      vStrPosEntry = vStrPosEntry + 1;
      vStrPos = vStrLen + 1;
    EndIf;
  End;


  ## If the expression position is reset, set expression position back to 1 and increment the
  ## counter for used options. Otherwise increase the expression position by 1.
  ####
  If(vExprPosReset = 1);
    vUsedOptions = vUsedOptions + 1;
    vExprPos = 1;
  Else;
    vExprPos = vExprPos + 1;
  EndIf;
End;


## Determine find location
####
vFindLen = Long(vMatchString);
vFindPos = Scan(vMatchString, ' ' | pString) -1;

Regex_find_position = vFindPos;
Regex_find_length = vFindLen;
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,3

#****Begin: Generated Statements***
#****End: Generated Statements****
575,3

#****Begin: Generated Statements***
#****End: Generated Statements****
576,CubeAction=1511DataAction=1503CubeLogChanges=0_DeployParams={&quotdimensionConflictResolutions&quot:{}&#044&quotclass&quot:&quotDeployParams&quot&#044&quotdataAction&quot:&quotACCUMULATE&quot}_ParseParams={&quotskipRows&quot:&quot0&quot&#044&quotlocale&quot:{&quotlanguange&quot:&quoten&quot&#044&quotvariant&quot:&quot&quot&#044&quotcountry&quot:&quotUS&quot}&#044&quotdimensions&quot:[]&#044&quotmeasures&quot:[]&#044&quotnumColumns&quot:&quot0&quot&#044&quothasHeader&quot:&quotfalse&quot}_importSourceDefinition={"scriptOnlySource":{},"sourceType":"NONE","originalColumns":null,"locale":{"localeIsDefault":false,"localeCurrencySymbol":"$","languageCode":"en","languageDisplay":"English","thousandsSeparator":",","localeCode":"en_US","localeCurrencyCode":"$","localeDisplay":"English (United States)","countryDisplay":"United States","countryCode":"US","decimalSeparator":"."},"excludedColumns":[],"columns":[],"sourceTypeHasBeenChanged":false}_ParameterConstraints=e30=
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
920,0
921,""
922,""
923,0
924,""
925,""
926,""
927,""
