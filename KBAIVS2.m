KBAIVS2 ; GPL - NLM Valueset import routines fileman version ; 3/22/13 4:51pm
 ;;0.1;C0Q;nopatch;noreleasedate;Build 7
 ;Copyright 2013 George Lilly.  Licensed Apache 2
 ;
 Q
 ;
 ; This version of the NLM Valueset importer imports the ValueSets to three
 ;   fileman files:
 ;
 ; ^DIC(176.801,0)="C0Q VALUE SET CODES^176.801"
 ; ^DIC(176.802,0)="C0Q NLM QUALITY MEASURE GROUPS^176.802"
 ; ^DIC(176.803,0)="C0Q CODE SYSTEMS^176.803"
 ;
 ;
 Q
 ;
C0QVSFN() Q 176.801  ; file number of C0Q VALUE SET CODES file
C0QVSCFN() Q 176.8011  ; subfile number of value set codes multiple
C0QVSGFN() Q 176.8012  ; subfile number of value set measure group multiple
 ;
C0QGRFN() Q 176.802  ; file number of the C0Q NLM MEASURE GROUP file
C0QGRCD() Q 176.8024  ; subfile number of the CODE SET subfile
 ;
 ; field identifiers for adding to the measure group file
GRPFLDS ; format = identifier^field number
 ;;CATEGORY^2.1
 ;;CMS eMeasure ID^2.2
 ;;Endorsed By^2.3
 ;;GUID^.02
 ;;Meaningful Use Measures^2.4
 ;;Measure Developer^2.5
 ;;Measure Steward^2.6
 ;;Measure Type^2.7
 ;;NQF Number^.03
 ;;SHEETNAME^2.8
 ;;eMeasure Copyright^2.9
 ;;eMeasure Description^1.1
 ;;eMeasure Identifier^3
 ;;eMeasure Status^3.1
 ;;eMeasure Title^.01
 ;;eMeasure Version number^.04
 Q
 ;
ADDGRPS ; adds groups to 176.802. 
 ;
 n gn s gn=$na(^KBAI("KBAIVS","ALLGROUPS"))
 n guid s guid=""
 f  s guid=$o(@gn@(guid)) q:guid=""  d  ;
 . k KBAIFDA
 . n seq,map,tag,field
 . f seq=1:1 s map=$p($t(GRPFLDS+seq),";;",2) q:map=""  d  ;
 . . s tag=$p(map,"^",1)
 . . s field=$p(map,"^",2)
 . . s KBAIFDA($$C0QGRFN,"?+1,",field)=$$CLEAN($g(@gn@(guid,tag)))
 . n KBAIEN
 . d UPDIE(.KBAIFDA,.KBAIEN)
 . ;
 . n KBAIMSG
 . n KBAIWPR s KBAIWPR(1,0)=$g(@gn@(guid,"eMeasure Description"))
 . d WP^DIE($$C0QGRFN,KBAIEN(1)_",",1,"K","KBAIWPR","KBAIMSG")
 . i $G(DIERR) break
 q
 ;
tree(where,prefix) ; show a tree starting at a node in MXML. where is passed by value
 ; 
 i $g(prefix)="" s prefix="|--" ; starting prefix
 ;i '$d(C0XJOB) s C0XJOB=$J
 n node s node=$na(^KBAI("KBAIVS","DOM",where))
 n txt s txt=$$CLEAN($$ALLTXT(node))
 w !,prefix_@node_" "_txt
 n zi s zi=""
 f  s zi=$o(@node@("A",zi)) q:zi=""  d  ;
 . w !,prefix_"  : "_zi_"^"_$g(@node@("A",zi))
 f  s zi=$o(@node@("C",zi)) q:zi=""  d  ;
 . d tree(zi,"|  "_prefix)
 q
 ;
show(what) ;
 ;S C0XJOB=26295
 I '$D(C0XJOB) S C0XJOB=$J
 d tree(what)
 q
 ; 
tree2(where,prefix) ; show a tree starting at a node in MXML. where is passed by value
 ; tree2 handles ConceptLists as tables
 i $g(prefix)="" s prefix="|--" ; starting prefix
 i '$d(C0XJOB) s C0XJOB=$J
 n node s node=$na(^KBAI("KBAIVS","DOM",where))
 ;n txt s txt=$$CLEAN($$ALLTXT(node))
 n txt d alltxt(.txt,node)
 ;w !,prefix_@node_" "_txt
 n zk s zk=""
 f  s zk=$o(txt(zk)) q:zk=""  d  ;
 . i zk=1 d out(prefix_@node_" "_txt(zk))  q  ;
 . d out(prefix_txt(zk))
 i @node["ns0:ConceptList" d  q  ;
 . d clist(where,prefix)
 n zi s zi=""
 f  s zi=$o(@node@("A",zi)) q:zi=""  d  ;
 . ;w !,prefix_"  : "_zi_"^"_$g(@node@("A",zi))
 . d out(prefix_"  : "_zi_"^"_$g(@node@("A",zi)))
 n grpstart s grpstart=0
 f  s zi=$o(@node@("C",zi)) q:zi=""  d  ;
 . i @node@("C",zi)="ns0:RevisionDate" d newgrp
 . i @node@("C",zi)="ns0:Group" d group(zi)  q  ;
 . d tree2(zi,"|  "_prefix)
 d:grpstart grpout2
 q
 ;
newgrp ; kill the group array for a new group
 ;W !,"NEW GROUP"
 k ^KBAI("KBAIVS","GROUP")
 q
 ;
group(where) ; add a group node to the group array
 s grpstart=1
 n gn s gn=$na(^KBAI("KBAIVS","GROUP"))
 n node s node=$na(^KBAI("KBAIVS","DOM"))
 n gnum s gnum=$g(@node@(where,"A","ID"))
 i gnum="" d  q  ;
 . w !,"error finding group number ",where
 n var s var=@node@(where,"A","displayName")
 n valref s valref=$o(@node@(where,"C",""))
 i valref="" d  q  ;
 . w !,"error finding value reference ",where
 n val s val=@node@(valref,"T",1)
 s @gn@(gnum,var)=val
 q
 ;
grpout ; output the group array
 n gn s gn=$na(^KBAI("KBAIVS","GROUP"))
 n grp s grp=""
 f  s grp=$o(@gn@(grp)) q:grp=""  d  ;
 . d out("--------------------------------------------------------------")
 . n attr s attr=""
 . f  s attr=$o(@gn@(grp,attr)) q:attr=""  d  ;
 . . d out(attr_": "_@gn@(grp,attr))
 q
 ;
grpout2 ; merge the group array with all groups
 n gn s gn=$na(^KBAI("KBAIVS","GROUP"))
 n gnall s gnall=$na(^KBAI("KBAIVS","ALLGROUPS"))
 n grp s grp=""
 f  s grp=$o(@gn@(grp)) q:grp=""  d  ;
 . n guid s guid=$g(@gn@(grp,"GUID"))
 . i guid="" d  q  ;
 . . w !,"no guid for ",$o(@gn@(grp,""))
 . m @gnall@(guid)=@gn@(grp)
 . n mien s mien=$o(^C0QVS(176.802,"GUID",guid,""))
 . i mien="" d  q  ;
 . . w !,"measure file not built yet... run ADDGRPS then rerun import"
 . k KBAIFDA
 . s KBAIFDA($$C0QVSGFN,"?+1,"_KBAIREC_",",.01)=mien
 . n KBAIIEN
 . d UPDIE(.KBAIFDA,.KBAIIEN)
 . k KBAIFDA,KBAIIEN
 . s KBAIFDA($$C0QGRCD,"?+1,"_mien_",",.01)=KBAIREC
 . d UPDIE(.KBAIFDA,.KBAIIEN)
 q
 ;
out(txt) ; add line to output array
 q  ; do nothing
 s c0xout=$na(^KBAI("KBAIOUT",$J))
 n cnt
 s cnt=$o(@c0xout@(""),-1)
 i cnt="" s cnt=0
 s @c0xout@(cnt+1)=txt
 q
 ;
clist(where,prefix,nohead) 
 n nd s nd=$na(^KBAI("KBAIVS","DOM"))
 ;i '$d(nohead) s nohead=0
 ;i 'nohead d  ;
 d out($j("Code",20)_$j("System",10)_$j("Description",20))
 n zzi s zzi=""
 f  s zzi=$o(@nd@(where,"C",zzi)) q:zzi=""  d  ;
 . n code,system,desc
 . s code=$g(@nd@(zzi,"A","code"))
 . s system=$g(@nd@(zzi,"A","codeSystemName"))
 . s desc=$g(@nd@(zzi,"A","displayName"))
 . d out($j(code,20)_$j(system,10)_"  "_desc)
 ;w @nd,":",@nd@("T",1)  
 q
 ;
alltxt(rtn,node) ; handle arrays of text
 m rtn=@node@("T")
 n zj s zj=""
 f  s zj=$o(rtn(zj)) q:zj=""  d  ;
 . s rtn(zj)=$$CLEAN(rtn(zj))
 . s rtn(zj)=$$LDBLNKS(rtn(zj))
 . i rtn(zj)="" k rtn(zj)
 . i (rtn(zj)=" ")&(zj>1) k rtn(zj)
 q
 ;
ALLTXT(where) ; extrinsic which returns all text lines from the node .. concatinated 
 ; together
 n zti s zti=""
 n ztr s ztr=""
 f  s zti=$o(@where@("T",zti)) q:zti=""  d  ;
 . s ztr=ztr_$g(@where@("T",zti))
 q ztr
 ;
CLEAN(STR) ; extrinsic function; returns string - gpl borrowed from the CCR package
 ;; Removes all non printable characters from a string.
 ;; STR by Value
 N TR,I
 F I=0:1:31,128:1:256 S TR=$G(TR)_$C(I)
 S TR=TR_$C(127)
 N ZR S ZR=$TR(STR,TR)
 S ZR=$$LDBLNKS(ZR) ; get rid of leading blanks
 QUIT ZR
 ;
LDBLNKS(st) ; extrinsic which removes leading blanks from a string
 n pos f pos=1:1:$l(st)  q:$e(st,pos)'=" "
 q $e(st,pos,$l(st))
 ;
VACCD ; set C0XJOB to the VA CCD
 s C0XJOB=14921
 q
 ;
NLMVS ; set C0XJOB to the NLM Values Set xml
 s C0XJOB=26295
 Q
 ;
contents(zrtn,ids) ; produce an agenda for the docId 1 in the MXML dom
 ; generally, a first level index to the document
 ; set C0XJOB if you want to use a different $J to locate the dom
 ; zrtn passed by name
 ; ids=1 names them by number ids=0 or null names them by displayname
 n zi s zi=""
 n dom s dom=$na(^KBAI("KBAIVS","DOM"))
 f  s zi=$o(@dom@(1,"C",zi)) q:zi=""  d  ;
 . n zn ;
 . d:$g(ids)  ;
 . . s zn=$tr($g(@dom@(zi,"A","ID")),".","-")_".txt"
 . . s @zrtn@(zn,zi)=""
 . d:'$g(ids)  ;
 . . s zn=$tr($g(@dom@(zi,"A","displayName"))," ","_")_".txt"
 . . s zn=$tr(zn,"()","") ; get rid of parens for valid filename
 . . s zn=$tr(zn,"/","-") ; get rid of slash for valid filename
 . . s @zrtn@(zn,zi)=""
 q
 ;
contents2(zrtn) ; produce an agenda for the docId 1 in the MXML dom
 ; generally, a first level index to the document
 ; set C0XJOB if you want to use a different $J to locate the dom
 ; zrtn passed by name
 n zi s zi=""
 n dom s dom=$na(^KBAI("KBAIVS","DOM"))
 f  s zi=$o(@dom@(1,"C",zi)) q:zi=""  d  ;
 . n zn,zid,zidfile,zfile ;
 . s zid=$g(@dom@(zi,"A","ID"))
 . s @zrtn@("ID",zid,zi)=""
 . s @zrtn@(zi,"ID")=zid
 . s zidfile=$tr($g(@dom@(zi,"A","ID")),".","-")_".txt"
 . s @zrtn@("IDFILE",zidfile,zi)=""
 . s @zrtn@(zi,"IDFILE")=zidfile
 . s zfile=$tr($g(@dom@(zi,"A","displayName"))," ","_")_".txt"
 . s zfile=$tr(zfile,"()","") ; get rid of parens for valid filename
 . s zfile=$tr(zfile,"/","-") ; get rid of slash for valid filename
 . s @zrtn@("FILE",zfile,zi)=""
 . s @zrtn@(zi,"FILE")=zfile
 . s zn=$g(@dom@(zi,"A","displayName"))
 . s @zrtn@("NAME",zn,zi)=""
 . s @zrtn@(zi,"NAME")=zn
 q
 ;
import ; imports value sets into fileman files
 ; 
 n g,zi,zname,where,dirname,gn,zid
 ;s gn=$na(^KBAI("KBAIOUT",$J))
 ;w !,"Please enter directory name for valueset files by name"
 ;q:'$$GETDIR(.dirname,"/home/vista/valuesets/by-name/")
 s zi=""
 d contents2("g") ; new contents format includes both name and id
 f  s zi=$o(g("NAME",zi)) q:zi=""  d  ;
 . s znum=$o(g("NAME",zi,""))
 . s zid=g(znum,"ID")
 . k KBAIFDA
 . s KBAIFDA($$C0QVSFN,"?+1,",.01)=zi
 . s KBAIFDA($$C0QVSFN,"?+1,",.02)=zid
 . n KBAIIEN
 . ;d UPDIE(.KBAIFDA,.KBAIIEN) ; KBAIIEN is ien of the current valueset (see groupout2)
 . s KBAIREC=$G(KBAIIEN)
 . i KBAIREC="" D  ;
 . . s KBAIREC=$O(^C0QVS(176.801,"ID",zid,""))
 . . i KBAIREC="" B  ;
 . s where=$o(g("NAME",zi,""))
 . s KBAIROOT=where ; node of current Value Set 
 . ;k @gn
 . d tree2(where,"| ")
 . ;n gn2 s gn2=$na(@gn@(1)) ; name for gtf
 . ;s ok=$$GTF^%ZISH(gn2,3,dirname,fname)
 q
 ;
export ; exports separate files for each value set
 ; one copy in a file with a text name based on the displayName
 n g,zi,fname,where,dirname,gn
 s gn=$na(^KBAI("KBAIOUT",$J))
 w !,"Please enter directory name for valueset files by name"
 q:'$$GETDIR(.dirname,"/home/vista/valuesets/by-name/")
 s zi=""
 d contents("g") ; first with text names
 f  s zi=$o(g(zi)) q:zi=""  d  ;
 . s fname=zi
 . s where=$o(g(zi,""))
 . k @gn
 . d tree2(where,"| ")
 . n gn2 s gn2=$na(@gn@(1)) ; name for gtf
 . s ok=$$GTF^%ZISH(gn2,3,dirname,fname)
 q
 ;
export2 ; exports separate files for each value set
 ; one copy in a file with a numeric file name based on ID
 n g,zi,fname,where,dirname,gn
 s gn=$na(^KBAI("KBAIOUT",$J))
 w !,"Please enter directory name for valueset files by id"
 q:'$$GETDIR(.dirname,"/home/vista/valuesets/by-id/")
 ;s dirname="/home/wvehr2/valuesets/by-id/"
 s zi=""
 d contents("g",1) ; with id names
 f  s zi=$o(g(zi)) q:zi=""  d  ;
 . s fname=zi
 . s where=$o(g(zi,""))
 . k @gn
 . d tree2(where,"| ")
 . n gn2 s gn2=$na(@gn@(1)) ; name for gtf
 . s ok=$$GTF^%ZISH(gn2,3,dirname,fname)
 q
 ;
FILEIN ; import the valueset xml file, parse with MXML, and put the dom in ^TMP
 ;
 N FNAME,DIRNAME
 W !,"Please enter the directory and file name for the NLM Valueset XML file"
 Q:'$$GETDIR(.DIRNAME,"/home/glilly/nlm-vs") ; prompt the user for the directory
 Q:'$$GETFN(.FNAME,"valuesets.xml") ; prompt user for filename
 N GN S GN=$NA(^KBAI("KBAIVS")) ; root to store xml and dom
 K @GN ; clear the area
 N GN1 S GN1=$NA(@GN@("XML",1)) ; place to put the xml file
 W !,"Reading in file ",FNAME," from directory ",DIRNAME
 Q:$$FTG^%ZISH(DIRNAME,FNAME,GN1,3)=""
 N KBAIDID
 W !,"Parsing file ",FNAME
 S KBAIDID=$$EN^MXMLDOM($NA(@GN@("XML")),"W")
 I KBAIDID=0 D  Q  ;
 . ZWRITE ^TMP("MXMLERR",$J,*)
 W !,"Merging MXMLDOM to TMP"
 M @GN@("DOM")=^TMP("MXMLDOM",$J,KBAIDID)
 K ^TMP("MXMLDOM",$J)
 Q
 ;
GETDIR(KBAIDIR,KBAIDEF) ; extrinsic which prompts for directory
 ; returns true if the user gave values
 S DIR(0)="F^3:240"
 S DIR("A")="File Directory"
 I '$D(KBAIDEF) S KBAIDEF="/home/glilly/nlm-vs"
 S DIR("B")=KBAIDEF
 D ^DIR
 I Y="^" Q 0 ;
 S KBAIDIR=Y
 Q 1
 ;
GETFN(KBAIFN,KBAIDEF) ; extrinsic which prompts for filename
 ; returns true if the user gave values
 S DIR(0)="F^3:240"
 S DIR("A")="File Name"
 I '$D(KBAIDEF) S KBAIDEF="valuesets.xml"
 S DIR("B")=KBAIDEF
 D ^DIR
 I Y="" Q 0 ;
 I Y="^" Q 0 ;
 S KBAIFN=Y
 Q 1
 ;
UPDIE(ZFDA,ZIEN) ; INTERNAL ROUTINE TO CALL UPDATE^DIE AND CHECK FOR ERRORS
 ; ZFDA IS PASSED BY REFERENCE
 ; ZIEN IS PASSED BY REFERENCE
 D:$G(DEBUG)
 . ZWRITE ZFDA
 . B
 K ZERR
 D CLEAN^DILF
 D UPDATE^DIE("","ZFDA","ZIEN","ZERR")
 I $D(ZERR) S ZZERR=ZZERR ; ZZERR DOESN'T EXIST, 
 ; INVOKE THE ERROR TRAP IF TASKED
 ;. W "ERROR",!
 ;. ZWR ZERR
 ;. B
 K ZFDA
 Q
 ;
