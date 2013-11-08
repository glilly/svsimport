svsimport
=========

NLM Valueset svs xml format import to VistA 

The SVS Valueset XML files can be downloaded from the NLM Value Set Authority here:

https://vsac.nlm.nih.gov/

To import an svs file into VistA, first read the xml file into MUMPS and parse with
the MXML parser. This is accomplished with the FILEIN^KBAIVS2 command.

D FILEIN^KBAIVS2

Please enter the directory and file name for the NLM Valueset XML file
File Directory: /home/glilly/nlm-vs// /home/glilly/
File Name: ep_eh_unique_vs_20130401.xml  Replace
Reading in file ep_eh_unique_vs_20130401.xml from directory /home/glilly/
Parsing file ep_eh_unique_vs_20130401.xml
Merging MXMLDOM to TMP

The xml file is stored in a scratch global here: ^KBAI("KBAIVS","XML")
The DOM produced by the MXML parser is stored here: ^KBAI("KBAIVS","DOM")

To view the valuesets that are contained in the XML, first generate a table of 
contents with the contents^KBAIVS2 command.

mocha>D contents^KBAIVS2("G")                                                               
                                                                                
mocha>ZWR G                                                                                 
G("ACE_inhibitor_or_ARB.txt",129894)=""                                         
G("ADHD_Medications.txt",111819)=""                                           
G("Above_Normal_Follow-up.txt",149496)=""                                  
G("Above_Normal_Medications.txt",149249)=""         

The numbers in the TOC are the node IDs in the DOM where the Valueset begins. 
To show the xml for one valueset, use the show^KBAIVS2 command passing in the node ID.

D show^KBAIVS2(149496)                                                                
                                                                                
|--ns0:DescribedValueSet                                                        
|--  : ID^2.16.840.1.113883.3.600.1.1525                                        
|--  : displayName^Above Normal Follow-up                
|--  : version^20121025                                                
|  |--ns0:ConceptList                                                                     
|  |  |--ns0:Concept                                                                      
|  |  |--  : code^304549008                                                               
|  |  |--  : codeSystem^2.16.840.1.113883.6.96                                           
|  |  |--  : codeSystemName^SNOMEDCT                                                      
|  |  |--  : codeSystemVersion^2012-07                                                    
|  |  |--  : displayName^Giving encouragement to exercise (procedure)                     
|  |  |--ns0:Concept                                                                      
|  |  |--  : code^307818003                                                              
|  |  |--  : codeSystem^2.16.840.1.113883.6.96                                            
|  |  |--  : codeSystemName^SNOMEDCT                                                      
|  |  |--  : codeSystemVersion^2012-07                                                    
|  |  |--  : displayName^Weight monitoring (regime/therapy)     
<snip>

To load all of the valuesets into the fileman files, first run import^KBAIVS2 and
then run RELOAD^KBAIVS2.

D import^KBAIVS2


D RELOAD^KBAIVS2                                                
                                                                                
REBUILDING MEASURE GROUPS                                   
REBUILDING VALUE SETS                                   
will add: ACE inhibitor or ARB 2.16.840.1.113883.3.526.3.1139                   
will add: ADHD Medications 2.16.840.1.113883.3.464.1003.196.12.1171
will add: Above Normal Follow-up 2.16.840.1.113883.3.600.1.1525    
will add: Above Normal Medications 2.16.840.1.113883.3.600.1.1498    
will add: Above Normal Referrals 2.16.840.1.113883.3.600.1.1527                 
<snip>

To generate external text files of the valuesets by name and by id, run export^KBAIVS1.

d export^KBAIVS1                                                                      
                                                                                           
Please enter directory name for valueset files by name                                     
File Directory: /home/vista/valuesets/by-name/  Replace                                    
Please enter directory name for valueset files by id                                       
File Directory: /home/vista/valuesets/by-id/  Replace                                      
1 /home/vista/valuesets/by-name/ Hospital_Measures-Joint_Commission_Mental_Disorders-HMJCMD42.txt                                                                          
1 /home/vista/valuesets/by-id/ 1-3-6-1-4-1-33895-1-3-0-42.txt                              
1 /home/vista/valuesets/by-name/ Hospital_Measures-Comfort_Measures_Only_Intervention-HMCMOI45.txt                                                                         
1 /home/vista/valuesets/by-id/ 1-3-6-1-4-1-33895-1-3-0-45.txt                             
1 /home/vista/valuesets/by-name/ ONC_Administrative_Sex-ONCAS41.txt        
<snip>

To load codes into C0Q VALUE SET CODES use:

D LDCODES^KBAIVS3

only do this after RELOAD when you are satisfied with the measure and vs records

If EP/EH and Cypress categories get lost from your files, you can recover them from
gpl-vsbak2.go

D ^%GI
load the file.. it creates ^GPL
then merge it

M ^KBAI("VSBAK")=^GPL
D RESTORE^KBAIVS3

we will work on a more elegant way to preserve these mappings in the future.


gpl