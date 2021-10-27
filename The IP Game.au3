;=========================DELETE
;DirRemove(@ScriptDir&"\Game\",1)
;=========================DELETE
Global $Version = "0.3.2.0 Android"

#Region ===== ===== Varables and Includes

#include <File.au3>
#include <GuiListView.au3>

;--- Files
$DirBin=@ScriptDir&"\Bin\"
$DirGame=@ScriptDir&"\Game\"
$FileIPAddresses=$DirGame&"ip_addresses"

;--- Vars
;                    | 0 |  1 |       2       |      3     |      4     |     5            6			 7
Global $IPID[999][8] ;IP | ID | Security(0-6) | Owned(0-1) | Found(0-1) | Decription | Root number | Bandwith |
Global $ViewItem[999]
Global $IPListID[999]
Global $_connectBool=False
Global $gameBandwidthTotal=100
Global $_connectID
Global $lableConnectedIP
Global $ii
;Tools
Global $ToolPasswordBreaker1=True
Global $ToolPasswordBreaker2=False
Global $ToolPasswordBreaker3=False

;--- Color
$colorREDLight=0xff9090
$colorRED=0xff0000
$colorGreenLight=0xACFFA4
$colorGreen=0x24BA06
$colorGray=0xCCCCCC

#EndRegion

#Region ===== ===== GAME SETUP (and loading)

If Not FileExists($DirGame) Then DirCreate($DirGame)
If Not FileExists($FileIPAddresses) Then
;=== IP generation
	$j=1
;Root Servers
	For $i=$j To 9 Step 1
		If $i<3 Then ; for 10.0.0.0 and 20.0.0.0 lower security
			FileWrite($FileIPAddresses,$i*10&".0.0.0,"&$i&",4,NotOwned,Hidden,Root Server,"&$i*10&",10000"&@CRLF) ;Root servers are hidden, Security 4
		Else
			FileWrite($FileIPAddresses,$i*10&".0.0.0,"&$i&",6,NotOwned,Hidden,Root Server,"&$i*10&",100000"&@CRLF) ;Root servers are hidden, Security 6
		EndIf
	Next
	$j+=9
;Public IP Lookup
	$IPID_PublicLookupServer10=$j
	FileWrite($FileIPAddresses,"10."&Random(10,255,1)&'.'&Random(10,255,1)&'.'&Random(10,255,1)&","&$j&",0,NotOwned,unHidden,Public IP Lookup,10,100"&@CRLF) ;1st IP lookup unHidden (10.IP's)
	$j+=1
	$IPID_PublicLookupServer20=$j
	FileWrite($FileIPAddresses,"20."&Random(10,255,1)&'.'&Random(10,255,1)&'.'&Random(10,255,1)&","&$j&",0,NotOwned,Hidden,Public IP Lookup,20,100"&@CRLF) ;2nd IP Lookup Hidden (20.IP's)
	$j+=1
;Random IP Addresses
	For $i=$j to $j+50 Step 1
		$setupRootNumber=Random(1,9,1)*10
		$IP_RandomAddress=$setupRootNumber&'.'&Random(10,150,1)&'.'&Random(10,255,1)&'.'&Random(10,255,1)
		If $setupRootNumber=10 Or $setupRootNumber=20 Then
			FileWrite($FileIPAddresses,$IP_RandomAddress&","&$i&","&Random(1,2,1)&",NotOwned,Hidden,No Description,"&$setupRootNumber&","&Random(1,5,1)*100&@CRLF)
		Else
			FileWrite($FileIPAddresses,$IP_RandomAddress&","&$i&","&Random(3,6,1)&",NotOwned,Hidden,No Description,"&$setupRootNumber&","&Random(1,50,1)*1000&@CRLF)
		EndIf
	Next
	$j+=50
;Firewall IP groupes
    For $i=$j To $j+6 Step 2 ;might need to be in Step 1
        $ii=1
        $setupRootNumber=Random(1,9,1)*10 ;IP addresses are writtem wrong as they both cant be random as they need to look the same to the user.
        $IP_RandomAddress=$setupRootNumber&"."&Random(151,255)&'.'&Random(10,255,1)&'.'&$ii
        FileWrite($FileIPAddresses,$IP_RandomAddress&","&$i&",3,NotOwned,unHidden,Firewall,"&$setupRootNumber&",10"&@CRLF)
        FileWrite($DirGame&"\"&$i&"admin","Firewall"&@CRLF&$i+1)
        $ii+=1
        $i+=1
        $IP_RandomAddress=$setupRootNumber&"."&Random(151,255)&'.'&Random(10,255,1)&'.'&$ii
        FileWrite($FileIPAddresses,$IP_RandomAddress&","&$i&",3,NotOwned,unHidden,Firewall,"&$setupRootNumber&",10"&@CRLF)
        FileWrite($DirGame&"\"&$i&"admin","FirewallActive"&@CRLF&$i-1)
		
        

;Load IP Addresses Table
	_LoadIPTable()

;Public IP Lookup Data Files Setup
	;Public Lookup Server 10
	$File_PublicLookupServer10_Public=$DirGame&"\"&$IPID_PublicLookupServer10&"public" ; Public
	FileWrite($File_PublicLookupServer10_Public,"IP"&@CRLF)
	FileWrite($File_PublicLookupServer10_Public,$IPID[$IPID_PublicLookupServer20][1]&@CRLF)
	$File_PublicLookupServer10_Admin=$DirGame&"\"&$IPID_PublicLookupServer10&"admin" ; Admin
	FileWrite($File_PublicLookupServer10_Admin,"password,1,no-trace"&@CRLF)

	;Public Lookup Server 20
	$File_PublicLookupServer20_Public=$DirGame&"\"&$IPID_PublicLookupServer20&"public" ;Public
	FileWrite($File_PublicLookupServer20_Public,"IP"&@CRLF)

	;Auto ADD
	For $q=1 To _FileCountLines($FileIPAddresses) Step 1
		$qq=$IPID[$q][1]
		$qqRoot=$IPID[$q][6]

		If $qqRoot=$IPID[$IPID_PublicLookupServer10][6] Then
			FileWrite($File_PublicLookupServer10_Public,$qq&@CRLF)
		EndIf

		If $qqRoot=$IPID[$IPID_PublicLookupServer20][6] Then
			FileWrite($File_PublicLookupServer20_Public,$qq&@CRLF)
		EndIf
	Next

EndIf



#EndRegion

#Region ===== ===== Load/Create Game

;--- GUI
$guiHight = 400
$guiWidth = 800
$viewSizeListKnownIPs=420
$guiButtonHight=25
$guiButtonWidth=125

Global $GUI=GUICreate("The IP Game",$guiWidth,$guiHight)

;Right
GUICtrlCreateLabel("Known Server Addresses:",$guiWidth-($viewSizeListKnownIPs-5),5,$viewSizeListKnownIPs,-1,0x0001)
$ViewKnownIPs=GUICtrlCreateListView("IP                              |Security|ID|Decription|Bandwidth",$guiWidth-$viewSizeListKnownIPs-5,20,$viewSizeListKnownIPs,$guiHight-60)

$ButtonConnect=GUICtrlCreateButton("Connect",$guiWidth-80,$guiHight-30,75,25)
$ButtonDisconnect=GUICtrlCreateButton("Disconnect",$guiWidth-160,$guiHight-30,75,25)
$ButtonTest=GUICtrlCreateButton("TEST",5,$guiHight-30,75,25)

;Left
$top=5
GUICtrlCreateLabel("Your IP Address:",5,$top,100,25)
$IPYourIP="60.180.55.23"
$Lable_YourIP=GUICtrlCreateLabel($IPYourIP,100,$top)
$top+=20
GUICtrlCreateLabel("Total Bandwidth:",5,$top,100,25)
$LableBandwaidthTotal=GUICtrlCreateLabel($gameBandwidthTotal&" MB/s",100,$top)
$top+=25
$lableConnectedTo=GUICtrlCreateLabel("Connected To: ",5,$top,80)
$lableConnectedIP=GUICtrlCreateLabel("",90,$top,90,30)
	GUICtrlSetFont(-1,8,600)
$top+=15
$buttonPublic=GUICtrlCreateButton("Public Content",5,$top,$guiButtonWidth,$guiButtonHight)
$LablePublic=GUICtrlCreateLabel("",10+$guiButtonWidth,$top+2,$guiButtonWidth,25)
	GUICtrlSetColor(-1,$colorRED)
	GUICtrlSetFont(-1,7,700)
$top+=30
$buttonAdmin=GUICtrlCreateButton("Admin Login",5,$top,$guiButtonWidth,$guiButtonHight)
$LableAdmin=GUICtrlCreateLabel("",10+$guiButtonWidth,$top+2,$guiButtonWidth,25)
	GUICtrlSetColor(-1,$colorRED)
	GUICtrlSetFont(-1,7,700)



_ViewKnownIPsUpdate()
GUISetState(@SW_SHOW)

#EndRegion

#Region ===== ===== MAIN LOOP

While 1
	$GUI_MSG=GUIGetMsg()

	Switch $GUI_MSG
		case -3
			Exit
		Case $ButtonConnect
			_Connect()
		Case $ButtonDisconnect
			_Disconnect()
		Case $ButtonTest
			_ViewKnownIPsUpdate()
		Case $buttonPublic
			_PublicData()
		Case $buttonAdmin
			_AdminData()

	EndSwitch

WEnd

#EndRegion

#Region ===== ===== FUNCTIONS

;----- ADMIN DATA FILE READ and PROCCESS
	Func _AdminData()
		If $_connectBool=False Then
			Return
		EndIf
		;File Data
		$_adminDataFile=$DirGame&$_connectID&"admin"
		$_adminDataFileRead1=FileReadLine($_adminDataFile,1)
		$_admindata=StringSplit($_adminDataFileRead1,",")
		If Not FileExists($_adminDataFile) Then
			GUICtrlSetData($LableAdmin,"No Admin File")
			Return
		EndIf

	;Password Security
		If $_admindata[1]="password" Then
			$_admindataPasswordStrength=$_admindata[2]
			If $_admindata[3]="trace" Then
				$_admindataTrackActive=True
			Else
				$_admindataTrackActive=False
			EndIf

			$_admindataHack=_passwordCracking($_admindataTrackActive)
			If $_admindataHack="Compeate" Then _FileWriteToLine($_adminDataFile,1,"Open",True)
			$_adminDataFileRead1=FileReadLine($_adminDataFile,1)

		EndIf


	;Under Hacks - Read admin data file
		If $_adminDataFileRead1="Open" Then
			$_adminDataFileRead2=FileReadLine($_adminDataFile,2)
			;If $_adminDataFileRead2= Something then next step
			_FileWriteToLine($_adminDataFile,1,"Owned",True)
			$_admindataString=StringReplace(FileReadLine($FileIPAddresses,$_connectID),"NotOwned","Owned")
			_FileWriteToLine($FileIPAddresses,$_connectID,$_admindataString,True)
		EndIf

	;Owned
		If $_adminDataFileRead1="Owned" Then
			GUICtrlSetData($LableAdmin,"Hello System Administrator!")
			GUICtrlSetColor($LableAdmin,$colorGreen)
		EndIf


	EndFunc

;----- Password Cracking
	Func _passwordCracking($_passwordCrackingTraceActive)

		$_passwordCrackingGUIwidth=200
		$_passwordCrackingGUIhight=200
		$_passwordCrackingGUI=GUICreate("Password Cracking",$_passwordCrackingGUIwidth,$_passwordCrackingGUIhight,-1,-1,0x00400000)
		If $ToolPasswordBreaker1=True Then
			$active1=-1
		Else
			$active1=0x08000000
		EndIf
		If $ToolPasswordBreaker2=True Then
			$active2=-1
		Else
			$active2=0x08000000
		EndIf
		If $ToolPasswordBreaker3=True Then
			$active3=-1
		Else
			$active3=0x08000000
		EndIf

		$top=5
		$_passwordCrackingGUI_LableTrace=GUICtrlCreateLabel("Trace time remaing = (no trace)",5,$top,$_passwordCrackingGUIwidth-10,15,0x0001)
			GUICtrlSetFont(-1,8.5,700)
		$top+=20
		$_passwordCrackingGUI_ButtonPasswordCracker1=GUICtrlCreateButton("Password Cracker Level 1",5,$top,$_passwordCrackingGUIwidth-10,25,$active1)
		$top+=30
		$_passwordCrackingGUI_ButtonPasswordCracker2=GUICtrlCreateButton("Password Cracker Level 2",5,$top,$_passwordCrackingGUIwidth-10,25,$active2)
		$top+=30
		$_passwordCrackingGUI_ButtonPasswordCracker3=GUICtrlCreateButton("Password Cracker Level 3",5,$top,$_passwordCrackingGUIwidth-10,25,$active3)
		$top+=30
		$_passwordCrackingGUI_InputPassword=GUICtrlCreateInput("",5,$top,$_passwordCrackingGUIwidth-10,25)
		$top+=30
		$top_button=$top ; Button is here
		GUISetState(@SW_SHOW,$_passwordCrackingGUI)
		While 1
			$GUI_MSG=GUIGetMsg()
			Switch $GUI_MSG
				Case $_passwordCrackingGUI_ButtonPasswordCracker1
					ExitLoop
				Case $_passwordCrackingGUI_ButtonPasswordCracker2
					ExitLoop
				Case $_passwordCrackingGUI_ButtonPasswordCracker3
					ExitLoop
			EndSwitch
		WEnd
		$_passwordCrackingTimer=TimerInit()
		$pwd = ""
		Do
			$pwd=""
			Dim $aSpace[3]
			$digits = Random(16,24,1)
			For $i = 1 To $digits
				$aSpace[0] = Chr(Random(65, 90, 1)) ;A-Z
				$aSpace[1] = Chr(Random(97, 122, 1)) ;a-z
				$aSpace[2] = Chr(Random(48, 57, 1)) ;0-9
				$pwd &= $aSpace[Random(0, 2, 1)]
			Next
			Sleep(50)
			GUICtrlSetData($_passwordCrackingGUI_InputPassword,$pwd)
		Until TimerDiff($_passwordCrackingTimer)>1000
		GUICtrlSetData($_passwordCrackingGUI_InputPassword,"Password Found")
		GUICtrlSetBkColor($_passwordCrackingGUI_InputPassword,$colorGreenLight)
		$_passwordCrackingGUI_ButtonNext = GUICtrlCreateButton("Next",($_passwordCrackingGUIwidth/2)-25,$top,50,25)
		While 1
			$GUI_MSG=GUIGetMsg()
			Switch $GUI_MSG
				Case $_passwordCrackingGUI_ButtonNext
					ExitLoop
			EndSwitch
		WEnd
		GUIDelete($_passwordCrackingGUI)

	EndFunc

;----- PUBLIC DATA FILE READ and PROCCESS
	Func _PublicData()
		If $_connectBool=False Then Return
		$_publicDataFile=$DirGame&$_connectID&"public"
		$_publicDataFileRead=FileReadLine($_publicDataFile,1)

	;IP File Found
		If $_publicDataFileRead="IP" Then
			$_publicIPCount="New IP Addresses Found:"&@CRLF
			$_publicIPCount2=0
			For $i=2 to _FileCountLines($_publicDataFile) Step 1
				$_publicDataFileRead=FileReadLine($_publicDataFile,$i)
				If $_publicDataFileRead<>"" Then
					$_publicSplit=StringSplit(FileReadLine($FileIPAddresses,$_publicDataFileRead),",")
					If $_publicSplit[5]="Hidden" Then
						$_publicString=StringReplace(FileReadLine($FileIPAddresses,$_publicDataFileRead),"Hidden","unHidden")
						_FileWriteToLine($FileIPAddresses,$_publicDataFileRead,$_publicString,True)
						$_publicIPCount=$_publicIPCount&$_publicSplit[1]&@CRLF
						$_publicIPCount2+=1
					EndIf
				EndIf

			Next
			If $_publicIPCount2=0 Then
				GUICtrlSetData($LablePublic,"No new IP addresses found.")
			Else
				$Temp_GUI1=GUICreate("New IP Adresses",200,300,-1,-1,0x00800000)
				$Temp_GUI1_LableIPAddresses=GUICtrlCreateLabel($_publicIPCount,3,5,190,225)
					GUICtrlSetFont(-1,7,700)
				$Temp_GUI1_ButtonAdd=GUICtrlCreateButton("ADD New Addresses",3,240,190,25)
				GUISetState(@SW_SHOW, $Temp_GUI1)
				While 1
					$GUI_MSG=GUIGetMsg()
					Switch $GUI_MSG
						Case $Temp_GUI1_ButtonAdd
							ExitLoop
					EndSwitch
				WEnd
				GUIDelete($Temp_GUI1)
				_ViewKnownIPsUpdate()
			EndIf

	;No Public Data File
		Else
			GUICtrlSetData($LablePublic,"No Public Data File Found.")
		EndIf
	EndFunc

;----- Connect Function
	Func _Connect()
		$_connectID=$IPListID[GUICtrlRead($ViewKnownIPs)]
		If $IPID[$_connectID][0] = "" Or $_connectBool=True then Return
		Global $_connectBool=True

		GUICtrlSetBkColor($ViewItem[$_connectID],$colorGreenLight)
		GUICtrlSetData($lableConnectedIP,$IPID[$_connectID][0])
		_ViewKnownIPsUpdate()

	EndFunc

;----- Disconnect Fuction
	Func _Disconnect()
		If $_connectBool=False Then Return
		$_connectBool=False
		GUICtrlSetBkColor($ViewItem[$_connectID],$colorGray)
		GUICtrlSetData($lableConnectedIP,"")

		GUICtrlSetData($LablePublic,"")
			GUICtrlSetColor($LablePublic,$colorRED)
		GUICtrlSetData($LableAdmin,"")
			GUICtrlSetColor($LableAdmin,$colorRED)

	EndFunc

;---- Load IP Table
	Func _LoadIPTable()

		For $i=1 To _FileCountLines($FileIPAddresses) Step 1
			$setupFileRead=FileReadLine($FileIPAddresses,$i)
			$setupIPsplit=StringSplit($setupFileRead,",")
			$ii=$setupIPsplit[2]
			$IPID[$ii][0]=$setupIPsplit[1];Address
			$IPID[$ii][1]=$ii			  ;ID
			$IPID[$ii][2]=$setupIPsplit[3];Security
			$IPID[$ii][3]=$setupIPsplit[4];Owned
			$IPID[$ii][4]=$setupIPsplit[5];Hidden/unHidden
			$IPID[$ii][5]=$setupIPsplit[6];Desription
			$IPID[$ii][6]=$setupIPsplit[7];Root number
			$IPID[$ii][7]=$setupIPsplit[8];Bandwitdh
		Next
	EndFunc

;--- VIEW UPDATE FUNCTION
	Func _ViewKnownIPsUpdate()

		_GUICtrlListView_DeleteAllItems($ViewKnownIPs)

		_LoadIPTable()

		For $i=1 to _FileCountLines($FileIPAddresses) Step 1
			If $IPID[$i][4]="unHidden" Then
				If $IPID[$i][7]<1000 Then $tempBandwidth=$IPID[$i][7]&" MB/s"
				If $IPID[$i][7]>999 Then $tempBandwidth=$IPID[$i][7]/1000&" GB/s"
				$ViewItem[$i]=GUICtrlCreateListViewItem($IPID[$i][0]&"|"&$IPID[$i][2]&"|"&$IPID[$i][1]&"|"&$IPID[$i][5]&"|"&$tempBandwidth,$ViewKnownIPs)
				$IPListID[$ViewItem[$i]]=$IPID[$i][1]
				If $IPID[$i][3]="Owned" Then
					GUICtrlSetColor(-1,$colorGreen)
				EndIf
				GUICtrlSetBkColor(-1,$colorGray)
			EndIf
		Next

		If $_connectBool=True Then GUICtrlSetBkColor($ViewItem[$_connectID],$colorGreenLight)

	EndFunc





