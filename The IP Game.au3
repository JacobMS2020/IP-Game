#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ip.ico
#AutoIt3Wrapper_Outfile=The IP Game 0.7.0.0.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Global $Version = "0.7.0.0 Money Update"

#cs ===== ===== PLANNING

Font = Wingdings
http://www.alanwood.net/demos/wingdings.html
#ce

#cs ----- Coding HELP - IPID and more

--- IPID
| 0 |  1 |       2       |   3   |    4  |      5     |       6	    |	   7	|     8       |     9    |    10   |       11     |
|IP | ID | Security(0-6) | Owned | Found | Decription | Root number | Bandwidth | UnderAtack  | Favorite | Region  | Stolen/Built |
If you add to this list Change the _LoadIPTable() and _AddressWrite() functions

--- ContractID
See the function line

--- IP Address creation
_AddressWrite( | IP(*.*.*.*) | ID(program) | Security(0-6) | Owned(NotOwned) | Hidden(NotHidden) | Decription "" | Bandwidth(int) | Default=Safe(UnderAttack) | Default=NotFavorite(Favorite)

--- Game File (written on exit)
1 = $gameTimeDay,$gameTimeHour,$gameTimeMin
2 = $gameMoney
3 = $gameContractsActive,$gameContractTotalCompleate

#ce

#Region ===== ===== Varables and Includes
;--- Other
#include <File.au3>
#include <GuiListView.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiTab.au3>

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
$FileLog=@ScriptDir&"\Log.log"

;--- Misc
Global $IPID[999][99] ;See line 13 / Coding Help for more info
Global $gameContractID[999][99]

Global $ViewItem[999]
Global $ViewContractsItemID[999]
Global $IPListID[999]
Global $_connectBool=False
Global $ListViewFilter=False
Global $_connectID
Global $lableConnectedIP
Global $ii
	 ;Check proformance
Global $TickCheck=False ;True = ON
Global $TickAverage=0
Global $TickAverageFullLoop=0
Global $TickCount=0
;--- Game
Global $_tickClock ; -- See the start of game (end of load)
	;Time
Global $gameTickSpeed=1000 ;(In milliseconds Default=1000)
Global $timerContractButton[4]
Global $timerContractButton_LestCheck[4]
Global $gameTimeDay=1
Global $gameTimeHour=0
Global $gameTimeMin=1
Global $gameTime="Day "&$gameTimeDay&"  /  "&$gameTimeHour&":"&$gameTimeMin
	;Money/Contracts
Global $gameContractFindTime=3000;90000 ;(millisenconds untill you can find a new contract to add) ========= CHANGE
Global $gameMoney=0
Global $gameCash=0
Global $gameIncomeTotal=0
Global $gameExpensesTotal=0
Global $gameContractsActive=0
Global $gameContractTotalCompleate=0
Global $gameContractTotalToday=0
Global $gameContractScore=0
Global $ButtonContract[4]
Global $ButtonConnectAT0[4]
Global $ViewContractsItemCount=0
	;Tools
Global $ToolPasswordBreaker1=True
Global $ToolPasswordBreaker2=False
Global $ToolPasswordBreaker3=False
Global $gameContractFinder1=True
Global $gameContractFinder2=False
Global $gameContractFinder3=False
	;Servers & Regions
Global $RegionNames[5]
$RegionNames[1] = "Europe"
$RegionNames[2] = "America"
$RegionNames[3] = "Oceania"
$RegionNames[4] = "Asia"
Global $gameServerCount=1
Global $gameServersEurope=0
Global $gameServersAmerica=0
Global $gameServersOceania=0
Global $gameServersAsia=0
	;Server Bandwidth
Global $gameBandwidthEurope=0
Global $gameBandwidthAmerica=0
Global $gameBandwidthOceania=0
Global $gameBandwidthAsia=0
	;Bandwidth
Global $gameBandwidthTotalDefault=100
Global $gameBandwidthTotal=$gameBandwidthTotalDefault
Global $gameBandwidthContracts=0

;--- Colors
$colorREDLight=0xff9090
$colorRED=0xff0000
$colorGreenLight=0xACFFA4
$colorGreen=0x24BA06
$colorGray=0xCCCCCC
$colorOrange=0xFF9700
$colorGrayLight=0xf2f2f2

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

#Region ===== ===== GUI Setup

	#Region ----- GUI setup
	$guiHight = 450
	$guiWidth = 800
	$guiButtonHight=25
	$guiButtonWidth=125

	Global $GUI=GUICreate("The IP Game ("&$Version&")",$guiWidth,$guiHight)
	GUISetFont(9,0,0,"Arial")

	$Tab=GUICtrlCreateTab(0,0,$GUIWidth,$GUIHight)
#EndRegion

	#Region ----- Server Control
GUICtrlCreateTabItem("Server Control")

	$GUIviewSize_KnownIPs=550 ;MAX for current GUI width (v0.6.4.0)
; Right
	$top=25
	GUICtrlCreateLabel("Known Server Addresses:",$guiWidth-($GUIviewSize_KnownIPs-5),$top,$GUIviewSize_KnownIPs,-1,0x0001)
	$LableTimeP1=GUICtrlCreateLabel($gameTime,$GUIWidth-85,$top,80)
	$ViewKnownIPs=GUICtrlCreateListView("Fav|IP                              |Security|ID|Decription|Bandwidth|Region|",$guiWidth-$GUIviewSize_KnownIPs-5,$top+20,$GUIviewSize_KnownIPs,$guiHight-80)
	;to the right of the list view
	$ButtonConnect=GUICtrlCreateButton("Connect",$guiWidth-80,$guiHight-30,75,25)
	$ButtonDisconnect=GUICtrlCreateButton("Disconnect",$guiWidth-155,$guiHight-30,75,25)
	$ButtonFavorite=GUICtrlCreateButton('★',$guiWidth-160-25,$guiHight-30,30)
		GUICtrlSetFont(-1,16)
	;to the left of the list view
	$ButtonFilter=GUICtrlCreateButton("Filter (OFF)",$guiWidth-$GUIviewSize_KnownIPs-5,$guiHight-30,75)
	$ComboListViewGroups=GUICtrlCreateCombo("None",$guiWidth-$GUIviewSize_KnownIPs+75,$guiHight-28,150,-1,$CBS_DROPDOWNLIST)
		GUICtrlSetData(-1,"Favorite|Owned|IP Lookup Server|Public IP Lookup|Root Servers|Firewalls|File Servers")



; Left
	$top=25
	GUICtrlCreateLabel("Your IP Address:",5,$top,100,25)
	$IPYourIP="60.180.55.23"
	$Lable_YourIP=GUICtrlCreateLabel($IPYourIP,100,$top)
	$top+=20
	GUICtrlCreateLabel("Total Bandwidth:",5,$top,100,25)
	$LableBandwaidthTotal=GUICtrlCreateLabel($gameBandwidthTotal&" MB/s",100,$top,100)
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
GUICtrlCreateTabItem("Money and Contracts") ;Dont change this lable name

	$GUI_moneyFinanceWidth=200
	$GUI_moneyViewWidth=300

; Right
	$top=25
	$LableTimeP2=GUICtrlCreateLabel($gameTime,$GUIWidth-85,$top,80)
	GUICtrlCreateLabel("Contracts",$GUIWidth-$GUI_moneyViewWidth-5,$top,$GUI_moneyViewWidth,15)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	GUICtrlCreateLabel("Contracts",$GUIWidth-$GUI_moneyViewWidth-5,$top,$GUI_moneyViewWidth,20,0x01)
		GUICtrlSetBkColor(-1,$colorGray)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	$ViewContracts=GUICtrlCreateListView("Income|Type                             |TEST|Start|End",$GUIWidth-$GUI_moneyViewWidth-5,$top,$GUI_moneyViewWidth,$GUIHight/2)
	$top+=$GUIHight/2+5
	GUICtrlCreateLabel("New Contracts",$GUIWidth-$GUI_moneyViewWidth-5,$top,$GUI_moneyViewWidth,20,0x01)
		GUICtrlSetBkColor(-1,$colorGray)
		GUICtrlSetFont(-1,10,700)
	$top+=25
	$tempWIDTH=100
	$ButtonContract[1]=GUICtrlCreateButton("Find (300s)",$GUIWidth-$GUI_moneyViewWidth-5,$top,$tempWIDTH)
	$ButtonContract[2]=GUICtrlCreateButton("Find (300s)",$GUIWidth-$GUI_moneyViewWidth-5+$tempWIDTH,$top,$tempWIDTH)
		GUICtrlSetState(-1,$GUI_DISABLE)
	$ButtonContract[3]=GUICtrlCreateButton("Find (300s)",$GUIWidth-$GUI_moneyViewWidth-5+($tempWIDTH*2),$top,$tempWIDTH)
		GUICtrlSetState(-1,$GUI_DISABLE)
	$top+=30
	$LableBandwaidthContracts=GUICtrlCreateLabel("Bandwidth used by contrcts: "&$gameBandwidthContracts&" Mbps",$GUIWidth-$GUI_moneyViewWidth-4,$top,$GUI_moneyViewWidth)
		GUICtrlSetFont(-1,9)

; Middle
	$tempWIDTH=$GUIWidth-$GUI_moneyViewWidth-$GUI_moneyFinanceWidth-20
	$top=25
	GUICtrlCreateLabel("Services",$GUI_moneyFinanceWidth+10,$top,$tempWIDTH,15)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	GUICtrlCreateLabel("Services",$GUI_moneyFinanceWidth+10,$top,$tempWIDTH,20,0x01)
		GUICtrlSetBkColor(-1,$colorGray)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	$ViewServices=GUICtrlCreateListView("Expence|Type                             |ID",$GUI_moneyFinanceWidth+10,$top,$tempWIDTH,$GUIHight/2)
	$top+=$GUIHight/2+5

; Left
	$tempTOPmalt=43
	$top=25
	GUICtrlCreateLabel("Financial Report",5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	GUICtrlCreateLabel("Money",5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetBkColor(-1,$colorGray)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	$LableMoney=GUICtrlCreateLabel("Bank : $"&$gameMoney,5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetBKColor(-1,$colorGreenLight)
	$top+=20
	$LableCash=GUICtrlCreateLabel("Cash : $"&$gameCash,5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetBKColor(-1,$colorGreenLight)
	$top+=$tempTOPmalt
	GUICtrlCreateLabel("Income (Every 10 seconds)",5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetBkColor(-1,$colorGray)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	$LableIncome=GUICtrlCreateLabel("Income: $"&$gameIncomeTotal,5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetBKColor(-1,$colorGreenLight)
	$top+=$tempTOPmalt
	GUICtrlCreateLabel("Expenses (Every 10 seconds)",5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetBkColor(-1,$colorGray)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	$LableExpenses=GUICtrlCreateLabel("Expenses: $"&$gameExpensesTotal,5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetBKColor(-1,$colorREDLight)
	$top+=$tempTOPmalt
	GUICtrlCreateLabel("Net Income",5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetBkColor(-1,$colorGray)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	$LableNetIncome=GUICtrlCreateLabel("Net Income $"&$gameIncomeTotal-$gameExpensesTotal,5,$top,$GUI_moneyFinanceWidth,15)
		GUICtrlSetBKColor(-1,0xffffff)

	$ButtonTest2=GUICtrlCreateButton("Test2",5,$GUIHight-30,75)

	#EndRegion

	#Region ----- Server Managment
GUICtrlCreateTabItem("Server Managment")
	$top=25
	$LableTimeP3=GUICtrlCreateLabel($gameTime,$GUIWidth-85,$top,80)
	$GUI_ServerManagmentWIDTH=$guiWidth/3

; Left
	$tempTOPmalt=30
	$top=25
	GUICtrlCreateLabel(" Server Details",5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	GUICtrlCreateLabel(" Server Regions",5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBkColor(-1,$colorGray)
		GUICtrlSetFont(-1,10,700)
	$top+=20
	GUICtrlCreateLabel("",5,$top,$GUI_ServerManagmentWIDTH,15,0x07)
	GUICtrlCreateLabel(" Europe",5,$top,$GUI_ServerManagmentWIDTH,15)
		;GUICtrlSetBKColor(-1,$colorGrayLight)
		GUICtrlSetFont(-1,8.5,600)
	$top+=20
	$LableServerCountEurope=GUICtrlCreateLabel("Server Count: "&$gameServersEurope,5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBKColor(-1,$colorGrayLight)
	$top+=20
	$LableBandwidthEurope=GUICtrlCreateLabel("Bandwidth: "&$gameBandwidthEurope,5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBKColor(-1,$colorGrayLight)
	$top+=30

	GUICtrlCreateLabel("",5,$top,$GUI_ServerManagmentWIDTH,15,0x07)
	GUICtrlCreateLabel(" America",5,$top,$GUI_ServerManagmentWIDTH,15)
		;GUICtrlSetBKColor(-1,$colorGrayLight)
		GUICtrlSetFont(-1,8.5,600)
	$top+=20
	$LableServerCountAmerica=GUICtrlCreateLabel("Server Count: "&$gameServersAmerica,5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBKColor(-1,$colorGrayLight)
	$top+=20
	$LableBandwidthAmerica=GUICtrlCreateLabel("Bandwidth: "&$gameBandwidthAmerica,5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBKColor(-1,$colorGrayLight)
	$top+=30

	GUICtrlCreateLabel("",5,$top,$GUI_ServerManagmentWIDTH,15,0x07)
	GUICtrlCreateLabel(" Oceania",5,$top,$GUI_ServerManagmentWIDTH,15)
		;GUICtrlSetBKColor(-1,$colorGrayLight)
		GUICtrlSetFont(-1,8.5,600)
	$top+=20
	$LableServerCountOceania=GUICtrlCreateLabel("Server Count: "&$gameServersOceania,5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBKColor(-1,$colorGrayLight)
	$top+=20
	$LableBandwidthOceania=GUICtrlCreateLabel("Bandwidth: "&$gameBandwidthOceania,5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBKColor(-1,$colorGrayLight)

	$top+=30
	GUICtrlCreateLabel("",5,$top,$GUI_ServerManagmentWIDTH,15,0x07)
	GUICtrlCreateLabel(" Asia",5,$top,$GUI_ServerManagmentWIDTH,15)
		;GUICtrlSetBKColor(-1,$colorGrayLight)
		GUICtrlSetFont(-1,8.5,600)
	$top+=20
	$LableServerCountAsia=GUICtrlCreateLabel("Server Count: "&$gameServersAsia,5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBKColor(-1,$colorGrayLight)
	$top+=20
	$LableBandwidthAsia=GUICtrlCreateLabel("Bandwidth: "&$gameBandwidthAsia,5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBKColor(-1,$colorGrayLight)


	$top+=$tempTOPmalt
	GUICtrlCreateLabel("Totals",5,$top,$GUI_ServerManagmentWIDTH,15)
		GUICtrlSetBKColor(-1,0xffffff)

	$ButtonTest3=GUICtrlCreateButton("Test3",5,$GUIHight-30,75)


	#EndRegion

	#Region ----- Politics & Political
GUICtrlCreateTabItem("Politics and Security")
	$top=25
	GUICtrlCreateLabel(":)",5,$top)


	#EndRegion
#EndRegion

#Region ===== ===== Load Game
;----- Load Save File
	If FileExists($FileGame) Then
		;Line 1 - Time
		$SaveRead=StringSplit(FileReadLine($FileGame,1),',')
		$gameTimeDay=$SaveRead[1]
		$gameTimeHour=$SaveRead[2]
		$gameTimeMin=$SaveRead[3]
		;Line 2 - Money
		$SaveRead=StringSplit(FileReadLine($FileGame,2),',')
		$gameMoney=$SaveRead[1]
		;Line 3 - Contracts
		$SaveRead=StringSplit(FileReadLine($FileGame,3),',')
		If $SaveRead[1]>0 Then MsgBox(0,"Warning","While your servers where down you lost "&$SaveRead[1]&" contracts.") ;Last $gameContractsActive
		$gameContractScore=$SaveRead[2]
	EndIf

;----- Update GUI Lables
	$gameTime="Day "&$gameTimeDay&"  /  "&$gameTimeHour&":"&$gameTimeMin
	GUICtrlSetData($LableTimeP1,$gameTime)
	GUICtrlSetData($LableTimeP2,$gameTime)

;----- Start Timers
	$_tickClock=TimerInit()
	$timerTickCheck=TimerInit()
	$timerTickCheckFullLoop=TimerInit()
	Global $timerContractTick=TimerInit()
	For $i=1 to 3 Step 1
		$timerContractButton[$i]=TimerInit()
		$timerContractButton_LestCheck[$i]=TimerDiff($timerContractButton[$i])
		$ButtonConnectAT0[$i]=False
	Next

;----- Start Game
	_ViewUpdate()
	GUISetState(@SW_SHOW)

#EndRegion

#Region ===== ===== MAIN LOOP

While 1
	$GUI_MSG=GUIGetMsg()

; Game Tick
	_Tick()

; GUI MSG
	Switch $GUI_MSG
		case -3
			If $TickCheck=True Then _FileWriteLog($FileLog,"Tick time Average ("&$Version&") = "&$TickAverage/$TickCount)
			If $TickCheck=True Then _FileWriteLog($FileLog,"Tick time Average Full Loop ("&$Version&") = "&$TickAverageFullLoop/$TickCount)
			_Save()
			Exit
		Case $ButtonTest
			;= Test button
		Case $ButtonTest2
			;= Test button
		Case $ButtonTest3
			;= Test button
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
			If $ListViewFilter=True Then _ViewUpdate()
		Case $ButtonNewGame
			DirRemove(@ScriptDir&"\Game\",1)
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
	;Contract buttons
	For $i=1 To 3 step 1
		If $GUI_MSG=$ButtonContract[$i] Then
			If $ButtonConnectAT0[$i]=True Then
				$ButtonConnectAT0[$i]=False
				$timerContractButton[$i]=TimerInit()
				$timerContractButton_LestCheck[$i]=TimerDiff($timerContractButton[$i])
				_contracts()
			Else
				MsgBox(0,"Help","You will need to wait for the time to run out before you can find another contract, you can also unlock more contract buttons to speed things up.",10)
			EndIf
		EndIf
	Next

WEnd

#EndRegion

#Region ===== ===== FUNCTIONS

;----- Tick Counter
	Func _Tick()
	; Proformance Checking
		If $TickCheck=True Then $timerTickCheck=TimerInit()
	;In Game clock
		If TimerDiff($_tickClock)>$gameTickSpeed Then ;Default time has passed
		;Game time
			$gameTimeMin+=1
			If $gameTimeMin=60 Then
				$gameTimeMin=1
				$gameTimeHour+=1
				If $gameTimeHour=24 Then
					$gameTimeHour=0
					$gameTimeDay+=1
				EndIf
			EndIf
			If $gameTimeMin<10 Then $gameTimeMin="0"&$gameTimeMin
			$gameTime="Day "&$gameTimeDay&"  /  "&$gameTimeHour&":"&$gameTimeMin
			If _GUICtrlTab_GetCurSel($Tab)=0 Then GUICtrlSetData($LableTimeP1,$gameTime)
			If _GUICtrlTab_GetCurSel($Tab)=1 Then GUICtrlSetData($LableTimeP2,$gameTime)
			If _GUICtrlTab_GetCurSel($Tab)=2 Then GUICtrlSetData($LableTimeP3,$gameTime)
			$_tickClock=TimerInit()
		EndIf

	;Contract Buttons
		If _GUICtrlTab_GetCurSel($Tab)=1 Then ;page 2 (1)
			For $i=1 To 3 Step 1
				If $timerContractButton_LestCheck[$i]+1000<TimerDiff($timerContractButton[$i]) Then
					$tempTIME=TimerDiff($timerContractButton[$i])-$gameContractFindTime
					$timerContractButton_LestCheck[$i]=TimerDiff($timerContractButton[$i])
					If $tempTIME>0 And $ButtonConnectAT0[$i]=False Then
						GUICtrlSetData($ButtonContract[$i],"Find (0s)")
						$ButtonConnectAT0[$i]=True
					ElseIf $tempTIME<1 Then
						$tempTIME=$gameContractFindTime-TimerDiff($timerContractButton[$i])
						GUICtrlSetData($ButtonContract[$i],"Find ("&Round($tempTIME/1000,0)&"s)")
					EndIf
				EndIf
			Next
		EndIf

	;Money/Contracts calculations
		If $gameContractsActive>0 And TimerDiff($timerContractTick)>10000 Then ;Add money and delete old contracts
			$TEMPUpdate=False
			For $i=1 To $gameContractTotalToday Step 1
				If $gameContractID[$i][1]=1 Then ;if active
					$gameMoney+=$gameContractID[$i][4] ;add money
					If TimerDiff($gameContractID[$i][3])>$gameContractID[$i][2]*1000 Then ;delete if time is up
						$gameContractID[$i][1]=0
						$gameIncomeTotal-=$gameContractID[$i][4]
						$gameBandwidthContracts-=$gameContractID[$i][5]
						$gameContractsActive-=1
						$TEMPUpdate=True
					EndIf
				EndIf
			Next
			If $TEMPUpdate=True Then
				_ViewUpdate()
			Else
				_ViewUpdateMoney()
			EndIf
			$timerContractTick=TimerInit()
		EndIf

	;Check the time it takes to do a tick (proformance check)
		If $TickCheck = True Then
			$timerTickChecktime=TimerDiff($timerTickCheck)
			$timerTickCheckFullLooptime=TimerDiff($timerTickCheckFullLoop)
			$TickAverage=$TickAverage+$timerTickChecktime
			$TickAverageFullLoop=$TickAverageFullLoop+$timerTickCheckFullLooptime
			$TickCount+=1
			$timerTickCheckFullLoop=TimerInit()
		EndIf


	EndFunc
;----- Contracts
	Func _contracts()
		;| 0  |       1     |   2  |             3          |    4  |      5    |       6      |
		;| ID | Active (0-1 | Time | Start Time (timerInit) | Price | Bandwidth | View Item ID |

	;Select contract
		If 	$gameServerCount<3 Then
			$_contractsRandom=1
		ElseIf $gameServerCount>2 and $gameServerCount<7 Then
			$_contractsRandom=Random(1,2,1)
		Else
			$_contractsRandom=Random(1,3,1)
		EndIf

	;Website Contract
		If $_contractsRandom=1 Then
			$_contractsPrice=Random(25,200,1)
			$_contractsBandwidth=Random(5,20,1)*10
			$_contractsTime=Random(60,300,1) ;Seconds (1-5min)
			$_contractServiceName="Website"
			$_contractServiceRegion="any"
	;VPN Contract
		ElseIf $_contractsRandom=2 Then
			$_contractsPrice=Random(400,1500,1)
			$_contractsBandwidth=Random(50,100,1)*10
			$_contractsTime=Random(120,600,1) ;Seconds (2-10min)
			$_contractServiceName="VPN"
			$_contractServiceRegion="any"
	;Government Contract
		ElseIf $_contractsRandom=3 Then
			$_contractsPrice=Random(1000,3000,1)
			$_contractsBandwidth=Random(100,300,1)*10
			$_contractsTime=Random(300,600,1) ;Seconds (5-10min)
			$_contractServiceName="Government Service"
			$_contractServiceRegion="random (to add later)"
		Else
			MsgBox(16,"CODE ERROR","Error in the making on contracts!")
			Return
		EndIf

	;Write the new contract
		$_contractsContractDescription="Host a "&$_contractServiceName&" that uses "&$_contractsBandwidth&" Mbps at $"&$_contractsPrice&" for every 10 seconds of up time. The duration of the contract is "&$_contractsTime&" seconds ("&Round($_contractsTime/60,0)&" minuets)."&@CRLF&"Service Region: "&$_contractServiceRegion
		$_contractsYN=MsgBox(4,"New Contract","New Contract:"&@CRLF&$_contractsContractDescription&@CRLF&"Do you Accept?")
		If $_contractsYN=6 Then
			If $gameBandwidthTotal-$_contractsBandwidth < 0 Then
				MsgBox(16,'Warning!',"You dont't have enough bandwidth to fill this contract!")
				Return
			EndIf
			$gameBandwidthContracts+=$_contractsBandwidth ;Add the bandwidth to be deducted
			$gameContractTotalToday+=1
			$gameContractsActive+=1
			$gameContractScore+=1
			$gameContractID[$gameContractTotalToday][0]=$gameContractTotalToday ;ID number
			$gameContractID[$gameContractTotalToday][1]=1 ;Active (1 = yes)
			$gameContractID[$gameContractTotalToday][2]=$_contractsTime ;(time in seconds)
			$gameContractID[$gameContractTotalToday][3]=TimerInit() ;Start time
			$gameContractID[$gameContractTotalToday][4]=$_contractsPrice ;Price (to be added every x seconds)
			$gameContractID[$gameContractTotalToday][5]=$_contractsBandwidth ;Bandwidth (to be deducted and added when contract started of started)
			$gameContractID[$gameContractTotalToday][6]=$ViewContractsItemCount

			$gameIncomeTotal+=$_contractsPrice
			_ViewUpdate()
		EndIf
	EndFunc
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
				GUICtrlSetData($LablePublic,"You have already looked at all the files on this server.")
			Else
				$Temp_GUI1=GUICreate("New IP Adresses",200,300,-1,-1,0x00800000)
				$Temp_GUI1_LableIPAddresses=GUICtrlCreateLabel($_publicIPCount,3,5,190,225)
					GUICtrlSetFont(-1,7,700)
				$Temp_GUI1_ButtonAdd=GUICtrlCreateButton("ADD New Addresses",3,240,190,25)
				GUISetState(@SW_SHOW, $Temp_GUI1)
				While 1
					$GUI_MSG=GUIGetMsg()
					_Tick()
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
;----- Save Function
	Func _Save()
		If FileExists($FileGame) Then FileDelete($FileGame)
		FileWrite($FileGame,$gameTimeDay&','&$gameTimeHour&','&$gameTimeMin&@CRLF& _ ;Time data
		$gameMoney&@CRLF& _ ;Money data
		$gameContractsActive&','&$gameContractScore) ;Contract data

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
			$IPID[$ii][10]=$setupIPsplit[11];Region
			$IPID[$ii][11]=$setupIPsplit[12];Stolen/Built
		Next
	EndFunc
;----- Address Write to File
	Func _AddressWrite($_AddressWriteIP,$_AddressWriteID,$_AddressWriteSecurity,$_AddressWriteOwned,$_AddressWriteHidden,$_AddressWriteDescription,$_AddressWriteBandwidth,$_AddressWriteUnderAttack="Safe",$_AddressWriteFavorite="NotFavorite",$_AddressWriteRegion="random",$_AddressWriteStolenBuilt="stolen")
		;Root number setup
		$_addressStringSplitRootNumber=StringSplit($_AddressWriteIP,".")
		$_AddressWriteRootNumber=$_addressStringSplitRootNumber[1]
		;Region setup (random)
		If $_AddressWriteRegion='random' Then
			$_AddressWriteRegion=$RegionNames[Random(1,4,1)]
		EndIf
		;Write the file
		FileWrite($FileIPAddresses,$_AddressWriteIP&","&$_AddressWriteID&","&$_AddressWriteSecurity&","& _
		$_AddressWriteOwned&","&$_AddressWriteHidden&","&$_AddressWriteDescription&","&$_AddressWriteRootNumber&","& _
		$_AddressWriteBandwidth&","&$_AddressWriteUnderAttack&","&$_AddressWriteFavorite&","&$_AddressWriteRegion&","&$_AddressWriteStolenBuilt&@CRLF)

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
;----- VIEW UPDATE MONEY
	Func _ViewUpdateMoney()
		GUICtrlSetData($LableIncome,"Income: $"&$gameIncomeTotal)
		GUICtrlSetData($LableNetIncome,"Net Income $"&$gameIncomeTotal-$gameExpensesTotal)
		GUICtrlSetData($LableMoney,"Bank: $"&$gameMoney)
	EndFunc
;----- VIEW UPDATE FUNCTION
	Func _ViewUpdate()


		_GUICtrlListView_DeleteAllItems($ViewKnownIPs)
		_LoadIPTable()
		GUICtrlSetState($ViewKnownIPs,$GUI_HIDE)
		$gameBandwidthTotal=$gameBandwidthTotalDefault-$gameBandwidthContracts
		$gameServerCount=1
	;Known Servers List View Update
		For $i=1 to _FileCountLines($FileIPAddresses) Step 1
			If $IPID[$i][4]="unHidden" Then
					;setup of info
					If $IPID[$i][7]<1000 Then $tempBandwidth=$IPID[$i][7]&" MB/s"
					If $IPID[$i][7]>999 Then $tempBandwidth=$IPID[$i][7]/1000&" GB/s"
					If $IPID[$i][9]="Favorite" Then $tempFavorite='★'
					If $IPID[$i][9]="NotFavorite" Then $tempFavorite=''
					If $IPID[$i][3]="Owned" Then
						$gameServerCount+=1
						$gameBandwidthTotal=$gameBandwidthTotal+$IPID[$i][7]
					ElseIf $IPID[$i][8]="underAttack" Then
						$gameBandwidthTotal=$gameBandwidthTotal-$IPID[$i][7]
					EndIf

					;write the info to list
					If $ListViewFilter=False Or _Filter($i)=True Then ; Filter
						$ViewItem[$i]=GUICtrlCreateListViewItem($tempFavorite&"|"&$IPID[$i][0]&"|"&$IPID[$i][2]&"|"&$IPID[$i][1]&"|"&$IPID[$i][5]&"|"&$tempBandwidth&"|"&$IPID[$i][10],$ViewKnownIPs)
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
		GUICtrlSetState($ViewKnownIPs,$GUI_SHOW)

		;Contracts List View Update
		If $gameContractsActive>0 Then ;Add money and delete old contracts
			_GUICtrlListView_DeleteAllItems($ViewContracts)
			For $i=0 To $gameContractTotalToday Step 1
				If $gameContractID[$i][1]=1 Then ;if active
					GUICtrlCreateListViewItem("$"&$gameContractID[$i][4]&"|Website|"&$gameContractID[$i][0]&"|"&$gameTimeHour&":"&$gameTimeMin&"|"&Round($gameContractID[$i][2]/60,0)&"h",$ViewContracts)
				EndIf
			Next
		EndIf

		GUICtrlSetData($LableBandwaidthContracts,"Bandwidth used by contrcts: "&$gameBandwidthContracts&" Mbps ("&$gameBandwidthTotal&")")
		_ViewUpdateMoney()
	EndFunc



