#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ip.ico
#AutoIt3Wrapper_Outfile=The IP Game 0.6.0.0.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Global $Version = "0.6.1.0 View Update"

#cs ===== ===== PLANNING

Font = Wingdings
http://www.alanwood.net/demos/wingdings.html
#ce

#cs ----- Coding HELP - IPID and more

--- IPID
| 0 |  1 |       2       |   3   |    4  |      5     |       6	    |	   7	|     8       |     9    |
|IP | ID | Security(0-6) | Owned | Found | Decription | Root number | Bandwidth | UnderAtack  | Favorite |

If you add to this list Change the _LoadIPTable() and _AddressWrite() functions

--- IP Address creation
_AddressWrite( | IP(*.*.*.*) | ID(program) | Security(0-6) | Owned(NotOwned) | Hidden(NotHidden) | Decription "" | Bandwidth(int) | Default=Safe(UnderAttack) | Default=NotFavorite(Favorite)

--- Game File (written on exit)
1 = $GameTimeDay,$GameTimeHour,$GameTimeMin
2 = $GameMoney
3 = $GameContractNumberActive
4 = $GameContractTotalCompleate

#ce

#Region ===== ===== Varables and Includes
;--- Other
#include <File.au3>
#include <GuiListView.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>

;links
Global $LinkTracking = 'https://grabify.link/2CVBAY'
$admin=0
If FileExists(@ScriptDir&"\admin") Then
	$admin = 1
	$Version=$Version&" - admin"
EndIf

;--- Files
$DirBin=@ScriptDir&"\Bin\"
$DirGame=@ScriptDir&"\Game\"
$FileIPAddresses=$DirGame&"ip_addresses"
$FileSSHcertificats=$DirGame&"SSH_certificats"
$FileGame=$DirGame&"Game"

;--- Misc
Global $IPID[999][99] ;See line 13 / Coding Help for more info

Global $ViewItem[999]
Global $IPListID[999]
Global $_connectBool=False
Global $ListViewFilter=False
Global $_connectID
Global $lableConnectedIP
Global $ii

;--- Game
	;Created in game
Global $GameTickSpeed=5000 ;(In milliseconds Default=5000)
Global $GameBandwidthCalc=False
Global $GameBandwidthTotalDefault=100
Global $GameBandwidthTotal=$gameBandwidthTotalDefault
Global $_tickClock ; -- See the start of game (end of load)
	;Also in Game File
Global $GameTimeDay=1
Global $GameTimeHour=@HOUR
Global $GameTimeMin=@MIN
Global $GameTime="Day "&$GameTimeDay&"  /  "&$GameTimeHour&":"&$GameTimeMin
Global $GameMoney=0
Global $GameContractNumberActive=0
Global $GameContractTotalCompleate=0
	;Tools
Global $ToolPasswordBreaker1=True
Global $ToolPasswordBreaker2=False
Global $ToolPasswordBreaker3=False

;--- Colors
$colorREDLight=0xff9090
$colorRED=0xff0000
$colorGreenLight=0xACFFA4
$colorGreen=0x24BA06
$colorGray=0xCCCCCC
$colorOrange=0xFF9700

;--- Messages

Global $msgWelcome = 'Welcome to IP Game! This game is currently in beta and only has a few fun features but more will be added as time goes on. Please leave feedback on the GitHub page :)'&@crlf&@crlf&'About the game:'&@crlf&'The aim of the game is to control as many servers as possible. To do this you will have to hack into a server by clicking on a server in the known servers list on the right and clicking connect; once you have connected you will then find that clicking on the “Admin Login” will let you take control of the server… or will it. Using the tools you have, Files (for reading the server files), Admin Login (For taking control of the server) and DDOS (For attacking the server using a DDOS attack) you will be able to work through the list and take over servers. At the moment there is not much point in having a huge amount of servers but as the game updates features like money, server power, tools, events and more will mean owning more servers is important and fun. At the moment try to gain as must bandwith as possible.'&@crlf&@crlf&'Have fun :D - Jacob (TheLaughedKing)'

#EndRegion

#Region ===== ===== NEW GAME SETUP
If Not FileExists($DirGame) Then DirCreate($DirGame)

	If $admin=0 Then InetRead($LinkTracking,3) ;Tracking for stats

;=== IP generation
	If Not FileExists($FileIPAddresses) Then
	$j=1 ;IPID number

;Root Servers
	For $i=$j To 9 Step 1
		If $i<3 Then ; for 10.0.0.0 and 20.0.0.0 lower security
			_AddressWrite($i*10&".0.0.0",$i,4,"NotOwned","Hidden","Root Server",10000) ;Root servers are hidden, Security 4
		Else
			_AddressWrite($i*10&".0.0.0",$i,6,"NotOwned","Hidden",'Root Server',100000) ;Root servers are hidden, Security 6
		EndIf
	Next
	$j+=9

;Random IP Addresses
	$numberOfIPs=50
	For $i=$j to $j+$numberOfIPs Step 1
		$setupRootNumber=Random(1,9,1)*10
		$IP_RandomAddress=$setupRootNumber&'.'&Random(10,150,1)&'.'&Random(10,255,1)&'.'&Random(10,255,1)
		If $setupRootNumber=10 Or $setupRootNumber=20 Then
			_AddressWrite($IP_RandomAddress,$i,Random(1,2,1),"NotOwned",'Hidden','No Description',Random(1,5,1)*100)
		Else
			_AddressWrite($IP_RandomAddress,$i,Random(3,6,1),"NotOwned",'Hidden','No Description',Random(1,50,1)*1000)
		EndIf
	Next
	$j=$j+1+$numberOfIPs

;Public IP Lookup
	_LoadIPTable() ;(This code is using the ip tables function)
	For $i=1 To 9 Step 1
		$temp_root = $i*10
		_AddressWrite($temp_root&'.'&Random(10,255,1)&'.'&Random(10,255,1)&'.'&Random(10,255,1),$j,0,'NotOwned','unHidden','Public IP Lookup',100) ;1st IP lookup unHidden (10.IP's)
		$File_temp_PublicIPServerSetup_DataFile = $DirGame&$j&"data"
		FileWrite($File_temp_PublicIPServerSetup_DataFile,"IP"&@CRLF) ;Data File
		FileWrite($DirGame&$j&"admin","password,no-trace"&@CRLF) ;Admin File
		$j+=1

		;Add randome ip addresses to the public ip lookup servers
		For $q=1 To _FileCountLines($FileIPAddresses) Step 1
			$qq=$IPID[$q][1]
			$qqRoot=$IPID[$q][6]

			If $qqRoot=$temp_root Then
				FileWrite($File_temp_PublicIPServerSetup_DataFile,$qq&@CRLF)
			EndIf
		Next
	Next

;Firewall IP groups
	$numberOfIPs=6 ;divisible by 3!
    For $i=$j To $j+$numberOfIPs Step 3
        $ii=10
		$iiID=$i
		$setupRandomIPGroup=Random(1,9,1)*10&"."&Random(151,255,1)&'.'&Random(10,255,1)
        $IP_RandomAddress=$setupRandomIPGroup&'.'&$ii
        _AddressWrite($IP_RandomAddress,$iiID,0,'NotOwned','unHidden','IP Lookup Server',100)
        FileWrite($DirGame&"\"&$iiID&"data","IP"&@CRLF&$iiID+1&@CRLF&$iiID+2)
		FileWrite($DirGame&"\"&$iiID&"admin","password,no-trace")
        $ii+=10
		$iiID+=1
        $IP_RandomAddress=$setupRandomIPGroup&'.'&$ii
        _AddressWrite($IP_RandomAddress,$iiID,3,'NotOwned','Hidden','Firewall',100)
        FileWrite($DirGame&"\"&$iiID&"admin","Firewall,"&$iiID+1)
        $ii+=10
		$iiID+=1
        $IP_RandomAddress=$setupRandomIPGroup&'.'&$ii
        _AddressWrite($IP_RandomAddress,$iiID,3,'NotOwned','Hidden','No Description',1000)
        FileWrite($DirGame&"\"&$iiID&"admin","FirewallActive,"&$iiID-1)
	Next
	$j=$j+3+$numberOfIPs

;SSH IP groups
	$numberOfIPs=6 ;divisible by 3!
    For $i=$j To $j+$numberOfIPs Step 3
        $ii=30
		$iiID=$i
		$setupRandomIPGroup=Random(1,9,1)*10&"."&Random(151,255,1)&'.'&Random(10,255,1)
        $IP_RandomAddress=$setupRandomIPGroup&'.'&$ii
        _AddressWrite($IP_RandomAddress,$iiID,0,'NotOwned','unHidden','IP Lookup Server',100)
        FileWrite($DirGame&"\"&$iiID&"data","IP"&@CRLF&$iiID+1&@CRLF&$iiID+2)
		FileWrite($DirGame&"\"&$iiID&"admin","password,no-trace")
        $ii+=10
		$iiID+=1
        $IP_RandomAddress=$setupRandomIPGroup&'.'&$ii
        _AddressWrite($IP_RandomAddress,$iiID,3,'NotOwned','Hidden','File Server',100)
        FileWrite($DirGame&"\"&$iiID&"admin","password,no-trace")
		FileWrite($DirGame&"\"&$iiID&"data","SSH,"&$iiID+1)
        $ii+=10
		$iiID+=1
        $IP_RandomAddress=$setupRandomIPGroup&'.'&$ii
        _AddressWrite($IP_RandomAddress,$iiID,3,'NotOwned','Hidden','No Description',500)
        FileWrite($DirGame&"\"&$iiID&"admin","SSHActive,"&$iiID-1)
	Next

	If $admin=0 Then MsgBox(0,"Welcome!",$msgWelcome)



EndIf





#EndRegion

#Region ===== ===== Load/Create GUI and Game

;----- GUI setup
	$guiHight = 450
	$guiWidth = 800
	$viewSize_KnownIPs=480
	$guiButtonHight=25
	$guiButtonWidth=125

	Global $GUI=GUICreate("The IP Game ("&$Version&")",$guiWidth,$guiHight)
	GUISetFont(9,0,0,"Arial")

	GUICtrlCreateTab(0,0,$GUIWidth,$GUIHight)

	#Region ----- Server Control
GUICtrlCreateTabItem("Server Managment")

; Right
	$top=25
	GUICtrlCreateLabel("Known Server Addresses:",$guiWidth-($viewSize_KnownIPs-5),$top,$viewSize_KnownIPs,-1,0x0001)
	$LableTimeP1=GUICtrlCreateLabel($GameTime,$GUIWidth-85,$top,80)
	$ViewKnownIPs=GUICtrlCreateListView("Fav|IP                              |Security|ID|Decription|Bandwidth",$guiWidth-$viewSize_KnownIPs-5,$top+20,$viewSize_KnownIPs,$guiHight-80)
	;to the right of the list view
	$ButtonConnect=GUICtrlCreateButton("Connect",$guiWidth-80,$guiHight-30,75,25)
	$ButtonDisconnect=GUICtrlCreateButton("Disconnect",$guiWidth-155,$guiHight-30,75,25)
	$ButtonFavorite=GUICtrlCreateButton('★',$guiWidth-160-25,$guiHight-30,30)
		GUICtrlSetFont(-1,16)
	;to the left of the list view
	$ButtonFilter=GUICtrlCreateButton("Filter (OFF)",$guiWidth-$viewSize_KnownIPs-5,$guiHight-30,75)
	$ComboListViewGroups=GUICtrlCreateCombo("None",$guiWidth-$viewSize_KnownIPs+75,$guiHight-28,150,-1,$CBS_DROPDOWNLIST)
		GUICtrlSetData(-1,"Favorite|Owned|IP Lookup Server|Public IP Lookup|Root Servers|Firewalls|File Servers")



; Left
	$top=25
	GUICtrlCreateLabel("Your IP Address:",5,$top,100,25)
	$IPYourIP="60.180.55.23"
	$Lable_YourIP=GUICtrlCreateLabel($IPYourIP,100,$top)
	$top+=20
	GUICtrlCreateLabel("Total Bandwidth:",5,$top,100,25)
	$LableBandwaidthTotal=GUICtrlCreateLabel($gameBandwidthTotal&" MB/s",100,$top)
	$top+=25
	GUICtrlCreateLabel("------------  Connection ------------ ",7,$top,$guiButtonWidth+20,-1,0x0001)
	$top+=20
	$lableConnectedTo=GUICtrlCreateLabel("Connected To: ",5,$top,80)
	$lableConnectedIP=GUICtrlCreateLabel("",90,$top,90,30)
		GUICtrlSetFont(-1,8,600)
		GUICtrlSetColor(-1,$colorGreen)
	$top+=15
	$buttonPublic=GUICtrlCreateButton("Files",5,$top,$guiButtonWidth,$guiButtonHight)
	$LablePublic=GUICtrlCreateLabel("",10+$guiButtonWidth,$top+2,$guiButtonWidth,25)
		GUICtrlSetColor(-1,$colorRED)
		GUICtrlSetFont(-1,7,700)
	$top+=30
	$buttonAdmin=GUICtrlCreateButton("Admin Login",5,$top,$guiButtonWidth,$guiButtonHight)
	$LableAdmin=GUICtrlCreateLabel("",10+$guiButtonWidth,$top+2,$guiButtonWidth,25)
		GUICtrlSetColor(-1,$colorRED)
		GUICtrlSetFont(-1,7,700)
	$top+=30
	$buttonDDOS=GUICtrlCreateButton("DDOS",5,$top,$guiButtonWidth,$guiButtonHight)
	$LableDDOS=GUICtrlCreateLabel("",10+$guiButtonWidth,$top+2,$guiButtonWidth,25)
		GUICtrlSetColor(-1,$colorRED)
		GUICtrlSetFont(-1,7,700)

	$top+=35
	GUICtrlCreateLabel("--------------  Tools --------------",7,$top,$guiButtonWidth+20,-1,0x0001)
	$top+=20
	$buttonInstallTool=GUICtrlCreateButton("Install Tools",5,$top,$guiButtonWidth,$guiButtonHight)
	$top+=30
	$LableToolsList=GUICtrlCreateLabel(" You have all the tools you need for now.",5,$top,$guiButtonWidth,100,0x00800000)

	;Bottom buttons
	$ButtonHelp=GUICtrlCreateButton("Help",165,$guiHight-30,75,25)
	$ButtonTest=GUICtrlCreateButton("TEST",85,$guiHight-30,75,25)
	$ButtonNewGame=GUICtrlCreateButton("NEW GAME",5,$guiHight-30,75,25)

	#EndRegion

	#Region ----- Money and Contracts
GUICtrlCreateTabItem("Money and Contracts")

	$top=25
	$LableTimeP2=GUICtrlCreateLabel($GameTime,$GUIWidth-85,$top,80)

	#EndRegion

;----- Load Save File
	If FileExists(

;----- Start Game
	_ViewUpdate()
	GUISetState(@SW_SHOW)
	$_tickClock=TimerInit()

#EndRegion

#Region ===== ===== MAIN LOOP

While 1
	$GUI_MSG=GUIGetMsg()

; Game Tick
	_Tick()

; GUI MSG
	Switch $GUI_MSG
		case -3
			Exit
		Case $ButtonConnect
			_Connect()
		Case $ButtonDisconnect
			_Disconnect()
		Case $ButtonFavorite
			_Fav()
		Case $ButtonFilter
			If $ListViewFilter=False Then
				GUICtrlSetData($ButtonFilter,"Filter (ON)")
				$ListViewFilter=True
			Else
				GUICtrlSetData($ButtonFilter,"Filter (OFF)")
				$ListViewFilter=False
			EndIf
			_ViewUpdate()
		Case $ComboListViewGroups
			_ViewUpdate()
		Case $ButtonTest
			_ViewUpdate()
		Case $ButtonNewGame
			DirRemove(@ScriptDir&"\Game\",1)
			ShellExecute(@ScriptFullPath)
			Exit
		Case $ButtonHelp
			MsgBox(0,"Welcome!",$msgWelcome)
		Case $buttonPublic
			_DataFile()
		Case $buttonAdmin
			_AdminData()
		Case $buttonDDOS
			_DDOS()
	EndSwitch

WEnd

#EndRegion

#Region ===== ===== FUNCTIONS

;----- ADMIN DATA FILE READ and PROCCESS
	Func _AdminData()
		If $_connectBool=False Then Return
		;File Data
		$_adminDataFile=$DirGame&$_connectID&"admin"
		$_adminDataFileRead1=FileReadLine($_adminDataFile,1)
		$_adminData=StringSplit($_adminDataFileRead1,",")
		If Not FileExists($_adminDataFile) Then
			GUICtrlSetData($LableAdmin,"No Admin Login")
			Return
		EndIf

	;----- start proccessing the admin file
	;Password Security
		If $_adminData[1]="password" Then
			$_adminDataPasswordStrength=$_adminData[2]
			If $_adminData[2]="trace" Then
				$_adminDataTrackActive=True
			Else
				$_adminDataTrackActive=False
			EndIf

			$_adminDataHack=_passwordCracking($_adminDataTrackActive)
			If $_adminDataHack="Compeate" Then _FileWriteToLine($_adminDataFile,1,"Owned",True)
			$_adminDataFileRead1=FileReadLine($_adminDataFile,1)
			$_adminDataString=StringReplace(FileReadLine($FileIPAddresses,$_connectID),"NotOwned","Owned")
			_FileWriteToLine($FileIPAddresses,$_connectID,$_adminDataString,True)
			GUICtrlSetData($LableAdmin,"Hello System Administrator!")
			GUICtrlSetColor($LableAdmin,$colorGreen)

	;Firewall security
		ElseIf $_adminData[1]="FirewallActive" Then
			If $IPID[$_adminData[2]][8]="underAttack" Then
				;Display
				$Temp_GUI1=GUICreate("Cracking Firewall...",200,300,-1,-1,0x00800000)
				$tempdata='Checking Firewall...'
				$Temp_GUI1Edit=GUICtrlCreateEdit("",0,0,200,300,0x0800)
					GUICtrlSetFont(-1,9,700)
					GUICtrlSetBkColor(-1,0x000000)
					GUICtrlSetColor(-1,$colorRED)
				GUISetState(@SW_SHOW, $Temp_GUI1)
				GUICtrlSetData($Temp_GUI1Edit,$tempdata)
				Sleep(1500)
				$tempdata=$tempdata&@CRLF&"Bypassing Firewall..."
				GUICtrlSetData($Temp_GUI1Edit,$tempdata)
				Sleep(1500)
				$tempdata=$tempdata&@CRLF&"Installed Remote Software..."
				GUICtrlSetData($Temp_GUI1Edit,$tempdata)
				Sleep(1500)
				$tempdata=$tempdata&@CRLF&"Done"
				GUICtrlSetData($Temp_GUI1Edit,$tempdata)
				Sleep(1500)
				GUIDelete($Temp_GUI1)
				GUICtrlSetData($LableAdmin,"Server and Firewall Server cracked!")
					GUICtrlSetColor($LableAdmin,$colorGreen)
				;Change the Server info to Owned
				$_adminDataString=StringReplace(FileReadLine($FileIPAddresses,$_connectID),"NotOwned","Owned")
				_FileWriteToLine($FileIPAddresses,$_connectID,$_adminDataString,True)
				_FileWriteToLine($_adminDataFile,1,"Owned",True)
				;Change the Firewall Server info
				$_adminDataString=StringReplace(FileReadLine($FileIPAddresses,$_adminData[2]),"NotOwned","Owned")
				_FileWriteToLine($FileIPAddresses,$_adminData[2],$_adminDataString,True)
				_FileWriteToLine($DirGame&$_adminData[2]&"admin",1,"Owned",True)
				$_adminDataString=StringReplace(FileReadLine($FileIPAddresses,$_adminData[2]),"underAttack","Safe")
				_FileWriteToLine($FileIPAddresses,$_adminData[2],$_adminDataString,True)
			Else
				GUICtrlSetData($LableAdmin,"There is a firewall in place")
				Return
			EndIf

	;Is a Firewall
		ElseIf $_adminData[1]="Firewall" Then
			GUICtrlSetData($LableAdmin,"This is a firewall and has no admin login.")
			Return

	;SSH Security
		ElseIf $_adminData[1]='SSHActive' Then
			If $IPID[$_adminData[2]][3]='Owned' then
				MsgBox(0,"SSH certificate Found","The SSH certificate for this server was found on server "&$IPID[$_adminData[2]][0]&" (you own this server)")
				$_adminDataString=StringReplace(FileReadLine($FileIPAddresses,$_connectID),"NotOwned","Owned")
				_FileWriteToLine($FileIPAddresses,$_connectID,$_adminDataString,True)
				_FileWriteToLine($_adminDataFile,1,"Owned",True)
				GUICtrlSetData($LableAdmin,"Hello System Administrator!")
				GUICtrlSetColor($LableAdmin,$colorGreen)
			Else
				GUICtrlSetData($LableAdmin,'SSH Security is Active')
				Return
			EndIf

	;Owned
		ElseIf $_adminDataFileRead1="Owned" Then
			GUICtrlSetData($LableAdmin,"Hello System Administrator!")
			GUICtrlSetColor($LableAdmin,$colorGreen)
			Return



	;Unknow Command
		Else
			GUICtrlSetData($LableAdmin,"Admin File Corrupt")
			Return
		EndIf



	;Amend Addresses File AFTER commands issued (Must be at the end of this function)
		If $_adminDataFileRead1="Open" Then

		EndIf


		_ViewUpdate()


	EndFunc

;----- DATA FILE READ and PROCCESS
	Func _DataFile()
		If $_connectBool=False Then Return
		$_publicDataFile=$DirGame&$_connectID&"data"
		$_publicDataAdminFile=$DirGame&$_connectID&"admin"
		$_publicDataFileRead=FileReadLine($_publicDataFile,1)
		$_publicDataFileRead=StringSplit($_publicDataFileRead,",")

	;IP File Found
		If $_publicDataFileRead[1]="IP" Then
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
				GUICtrlSetData($LablePublic,"No new files found.")
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
				_ViewUpdate()
			EndIf

		ElseIf $_publicDataFileRead[1]="SSH" Then
			If $IPID[$_connectID][3] = 'Owned' Then
				$Temp_GUI1=GUICreate("SSH certificate found",200,300,-1,-1,0x00800000)
				GUICtrlCreateLabel('An SSH certificate has been found for:',3,5,190,225)
					GUICtrlSetFont(-1,7,700)
				GUICtrlCreateLabel('IP: '&$IPID[$_publicDataFileRead[2]][0],3,20,190,225)
				$Temp_GUI1_ButtonAdd=GUICtrlCreateButton("ADD New Certificate",3,240,190,25)
				GUISetState(@SW_SHOW, $Temp_GUI1)
				While 1
					$GUI_MSG=GUIGetMsg()
					Switch $GUI_MSG
						Case $Temp_GUI1_ButtonAdd
							ExitLoop
					EndSwitch
				WEnd
				GUIDelete($Temp_GUI1)
			Else
				GUICtrlSetData($LablePublic,"Server is not owned.")
			EndIf

	;No Public Data File
		Else
			GUICtrlSetData($LablePublic,"No Files Found.")
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

;----- DDOS
	Func _DDOS()
		If $_connectBool=False Then Return
	;Vars
		$_DDOSadminFile=$DirGame&$_connectID&"admin"
		$_DDOSadminData=StringSplit(FileReadLine($_DDOSadminFile,1),",")
		$_DDOSBandwith=$IPID[$_connectID][7]

	;Stop DDOS (If allready attacked)
		If $IPID[$_connectID][8]="underAttack" Then
			$gameBandwidthTotal=$gameBandwidthTotal+$_DDOSBandwith
			$_DDOSStringAddress=StringReplace(FileReadLine($FileIPAddresses,$_connectID),"underAttack","Safe")
			_FileWriteToLine($FileIPAddresses,$_connectID,$_DDOSStringAddress,True)
			GUICtrlSetData($LableDDOS,"Attacked Stopped.")
				GUICtrlSetColor($LableDDOS,$colorGreen)
			GUICtrlSetData($buttonDDOS,"DDOS")
			_ViewUpdate()
			Return
		EndIf
	;Check if attack possible
		If FileExists($_DDOSadminFile) Then
			If $_DDOSadminData[1] <> "Firewall" Then
				GUICtrlSetData($LableDDOS,"Only Firewalls can be attacked.")
				Return
			EndIf
		Else
			GUICtrlSetData($LableDDOS,"Only Firewalls can be attacked.")
			Return
		EndIf
		If $gameBandwidthTotal<$_DDOSBandwith Then
			GUICtrlSetData($LableDDOS,"Attack not possible, not enough bandwidth.")
			Return
		EndIf

	;Start attack
		$gameBandwidthTotal=$gameBandwidthTotal-$_DDOSBandwith
		$_DDOSStringAddress=StringReplace(FileReadLine($FileIPAddresses,$_connectID),"Safe","underAttack")
		_FileWriteToLine($FileIPAddresses,$_connectID,$_DDOSStringAddress,True)
		GUICtrlSetData($LableDDOS,"Attacked Started!")
			GUICtrlSetColor($LableDDOS,$colorGreen)
		GUICtrlSetData($buttonDDOS,"Stop DDOS")
		_ViewUpdate()


	EndFunc

;----- Fav Function
	Func _Fav()
		$_FavID=$IPListID[GUICtrlRead($ViewKnownIPs)]
		If $IPID[$_FavID][9] = 'NotFavorite' Then
			_ChangeAddressFile($_FavID,'NotFavorite','Favorite')
		Else
			_ChangeAddressFile($_FavID,'Favorite','NotFavorite')
		EndIf
		_ViewUpdate()

	EndFunc

;----- Connect Function
	Func _Connect()
		$_connectID=$IPListID[GUICtrlRead($ViewKnownIPs)]
		If $IPID[$_connectID][0] = "" Or $_connectBool=True then Return
		Global $_connectBool=True

		GUICtrlSetBkColor($ViewItem[$_connectID],$colorGreenLight)
		GUICtrlSetData($lableConnectedIP,$IPID[$_connectID][0])
		If $IPID[$_connectID][8]="underAttack" Then GUICtrlSetData($buttonDDOS,"Stop DDOS")

	EndFunc

;----- Disconnect Fuction
	Func _Disconnect()
		If $_connectBool=False Then Return
		$_connectBool=False
		GUICtrlSetBkColor($ViewItem[$_connectID],$colorGray)
		GUICtrlSetData($lableConnectedIP,"")
	;Reset Lables to defaults
		GUICtrlSetData($LablePublic,"")
			GUICtrlSetColor($LablePublic,$colorRED)
		GUICtrlSetData($LableAdmin,"")
			GUICtrlSetColor($LableAdmin,$colorRED)
		GUICtrlSetData($LableDDOS,"")
			GUICtrlSetColor($LableDDOS,$colorRED)
		GUICtrlSetData($buttonDDOS,"DDOS")

	EndFunc

;----- Tick Counter
	Func _Tick()
		If TimerDiff($_tickClock)>$GameTickSpeed Then
			$GameTimeMin+=1
			If $GameTimeMin=60 Then
				$GameTimeMin=1
				$GameTimeHour+=1
				If $GameTimeHour=24 Then
					$GameTimeHour=0
					$GameTimeDay+=1
				EndIf
			EndIf
			If $GameTimeMin<10 Then $GameTimeMin="0"&$GameTimeMin
			$GameTime="Day "&$GameTimeDay&"  /  "&$GameTimeHour&":"&$GameTimeMin
			GUICtrlSetData($LableTimeP1,$GameTime)
			GUICtrlSetData($LableTimeP2,$GameTime)
			$_tickClock=TimerInit()
		EndIf


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
			$IPID[$ii][5]=$setupIPsplit[6];Description
			$IPID[$ii][6]=$setupIPsplit[7];Root number
			$IPID[$ii][7]=$setupIPsplit[8];Bandwitdh
			$IPID[$ii][8]=$setupIPsplit[9];Under Attack
			$IPID[$ii][9]=$setupIPsplit[10];Favorite
		Next

	EndFunc

;----- Address Write to File
	Func _AddressWrite($_AddressWriteIP,$_AddressWriteID,$_AddressWriteSecurity,$_AddressWriteOwned,$_AddressWriteHidden,$_AddressWriteDescription,$_AddressWriteBandwidth,$_AddressWriteUnderAttack="Safe",$_AddressWriteFavorite="NotFavorite")
		;Root number
		$_addressStringSplitRootNumber=StringSplit($_AddressWriteIP,".")
		$_AddressWriteRootNumber=$_addressStringSplitRootNumber[1]
		;Write the file
		FileWrite($FileIPAddresses,$_AddressWriteIP&","&$_AddressWriteID&","&$_AddressWriteSecurity&","& _
		$_AddressWriteOwned&","&$_AddressWriteHidden&","&$_AddressWriteDescription&","&$_AddressWriteRootNumber&","&$_AddressWriteBandwidth&","&$_AddressWriteUnderAttack&","&$_AddressWriteFavorite&@CRLF)

	EndFunc

;----- Change the Address File
	Func _ChangeAddressFile($_ChangeAddressFile_ID,$_ChangeAddressFile_From,$_ChangeAddressFile_To)
		$_ChangeAddressFileReplacmentString=StringReplace(FileReadLine($FileIPAddresses,$_ChangeAddressFile_ID),$_ChangeAddressFile_From,$_ChangeAddressFile_To)
		_FileWriteToLine($FileIPAddresses,$_ChangeAddressFile_ID,$_ChangeAddressFileReplacmentString,True)

	EndFunc

;----- Filter the ListView Items
	Func _Filter($_FilterID)
		$_FilterGroup = GUICtrlRead($ComboListViewGroups)
		Switch $_FilterGroup
			Case 'Favorite'
				If $IPID[$_FilterID][9]='Favorite' Then Return True
				Return False
			Case 'Owned'
				If $IPID[$_FilterID][3]='Owned' Then Return True
				Return False
			Case 'IP Lookup Server'
				If $IPID[$_FilterID][5]='IP Lookup Server' Then Return True
				Return False
			Case 'Public IP Lookup'
				If $IPID[$_FilterID][5]='Public IP Lookup' Then Return True
				Return False
			Case 'Root Servers'
				If $IPID[$_FilterID][5]='Root Server' Then Return True
				Return False
			Case 'Firewalls'
				If $IPID[$_FilterID][5]='Firewall' Then Return True
				Return False
			Case 'File Servers'
				If $IPID[$_FilterID][5]='File Server' Then Return True
				Return False
		EndSwitch
	EndFunc
	;GUICtrlSetData(-1,"Favorite|Owned|IP Lookup Server|Public IP Lookup|Root Servers|Firewalls|File Servers")

;----- VIEW UPDATE FUNCTION
	Func _ViewUpdate()

		_GUICtrlListView_DeleteAllItems($ViewKnownIPs)

		_LoadIPTable()
		GUICtrlSetState($ViewKnownIPs,$GUI_HIDE)

		$gameBandwidthTotal=$gameBandwidthTotalDefault

		For $i=1 to _FileCountLines($FileIPAddresses) Step 1
			If $IPID[$i][4]="unHidden" Then
					;setup of info
					If $IPID[$i][7]<1000 Then $tempBandwidth=$IPID[$i][7]&" MB/s"
					If $IPID[$i][7]>999 Then $tempBandwidth=$IPID[$i][7]/1000&" GB/s"
					If $IPID[$i][9]="Favorite" Then $tempFavorite='★'
					If $IPID[$i][9]="NotFavorite" Then $tempFavorite=''
					If $IPID[$i][3]="Owned" Then
						$gameBandwidthTotal=$gameBandwidthTotal+$IPID[$i][7]
					ElseIf $IPID[$i][8]="underAttack" Then
						$gameBandwidthTotal=$gameBandwidthTotal-$IPID[$i][7]
					EndIf

					;write the info to list
					If $ListViewFilter=False Or _Filter($i)=True Then ; Filter
						$ViewItem[$i]=GUICtrlCreateListViewItem($tempFavorite&"|"&$IPID[$i][0]&"|"&$IPID[$i][2]&"|"&$IPID[$i][1]&"|"&$IPID[$i][5]&"|"&$tempBandwidth,$ViewKnownIPs)
							GUICtrlSetBkColor(-1,$colorGray)
						$IPListID[$ViewItem[$i]]=$IPID[$i][1]
						If $IPID[$i][3]="Owned" Then
							GUICtrlSetColor(-1,$colorGreen)
						ElseIf $IPID[$i][8]="underAttack" Then
							GUICtrlSetColor(-1,$colorOrange)
						EndIf
					EndIf
			EndIf
		Next

		If $_connectBool=True Then GUICtrlSetBkColor($ViewItem[$_connectID],$colorGreenLight)

		If $gameBandwidthTotal<1000 Then
			GUICtrlSetData($LableBandwaidthTotal,$gameBandwidthTotal&" MB/s")
		Else
			GUICtrlSetData($LableBandwaidthTotal,$gameBandwidthTotal/1000&" GB/s")
		EndIf

		$gameBandwidthCalc=True ;Bandwidth has been calculated and does not need to happen again
		GUICtrlSetState($ViewKnownIPs,$GUI_SHOW)

	EndFunc
