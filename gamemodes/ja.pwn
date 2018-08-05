#include <a_samp>
#include <YSI\y_ini>
#include <YSI\y_hooks>
#include <zcmd>
#include <sscanf2>
#include <streamer>
/*
1 = Mod
2 = Admin
3 = SuperAdmin
4 = HeadAdmin
5 = Owner
*/

#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_SUCCESS_1 3
#define DIALOG_SUCCESS_2 4
#define DIALOG_EDITID 5
#define DIALOG_EDIT 6
#define DIALOG_EDITPRICE 7
#define DIALOG_EDITINTERIOR 8
#define DIALOG_HCMDS 9
#define DIALOG_CLASS 10
#define DIALOG_STATS 11

#define ENEX_STREAMER_IDENTIFIER (100)

#define MAX_HOUSES 100

#define COL_WHITE "{FFFFFF}"
#define COL_GREEN "{00FF22}"
#define COL_LIGHTBLUE "{00CED1}"
#define COL_BLUE 0x0000FFAA
#define COL_YELLOW 0xFFFF00AA
#define COL_ORANGE 0xFFA500AA
#define COLOR_RED 0xFF0000AA
#define COLOR_BLUE 0x0000FFAA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_SYNTAX 0xFF6100AA
#define COL_RED "{F81414}"
#define COL_GREEN "{00FF22}"
#define COL_LIGHTBLUE "{00CED1}"
#define COLOR_ORANGE 0xFFA500AA

#define POLICE 1
#define HITMAN 2
#define TAXI 3
#define GUN 4
#define DRUG 5
#define TERRORIST 6

native WP_Hash(buffer[], len, const str[]);

new DB: database;

enum pInfo
{
	pPass,
	pMoney,
	pAdmin,
	pKills,
	pDeaths,
}
new PlayerInfo[MAX_PLAYERS][pInfo];
new gPlayerClass[MAX_PLAYERS];
new PickedClass[MAX_PLAYERS];

enum hInfo
{
	hPrice,
	hInterior,
	hOwned,
	hLocked,
	hPick,
	Text3D:hLabel,
	hOwner[MAX_PLAYER_NAME],
	Float:hX,
	Float:hY,
	Float:hZ,
	Float:hEnterX,
	Float:hEnterY,
	Float:hEnterZ,
}
new HouseInfo[MAX_HOUSES][hInfo];
new houseid;
new InHouse[MAX_PLAYERS][MAX_HOUSES];
new hid;

new IsCuffed[MAX_PLAYERS];
new HasCoke[MAX_PLAYERS];
new HasWeed[MAX_PLAYERS];
new HasBeenReportedRecently[MAX_PLAYERS];
new MessageTDTime[MAX_PLAYERS];
new HasTicket[MAX_PLAYERS];
new TimeToPayTicket[MAX_PLAYERS];
new IsArrested[MAX_PLAYERS];
new ArrestTime[MAX_PLAYERS];



//Textdraw
new Text:MessageTD[MAX_PLAYERS];


enum sData
{
	storeName[128],
	mapIcon,
	Float:entPos[4],
	Float:extPos[4],
	Float:robPos[3],
	interiorID,
	beingRobbed,
	recentlyRobbed,
	maxMoney,
	virtualID,
	entCP,
	extCP,
	robCP
}


new storeData[][sData]=
{
// 	 store Name					mapIcon 		{EntX, EntY,EntZ,EntAngle}							{ExtX, ExtY, ExtZ, ExtAngle} 						{RobX, RobY, RobZ{					//IntID 0   0   MaxMoney
	{"Burger Shot",				10	,			{810.9576,	-1616.1613,	13.5469, 262.7102	},		{363.1512,	-74.8533,	1001.5078,	317.3523	},	{376.1824,	-65.2047,	1001.5078	},	10,	0,	0,	35000},
	{"Well Stacked Pizza Co.",	29	,			{2104.7126, -1806.5319, 13.5547, 277.7998	},		{372.3442, 	-133.2576, 	1001.4922, 	179.2050	},	{374.1206, -119.2939, 	1001.4922	},	5,	0,	0,	35000},
	{"Burger Shot",				10	,			{1199.3285,	-918.6420,	43.1190, 187.8442	},		{363.1512,	-74.8533,	1001.5078,	317.3523	},  {376.1824,	-65.2047,	1001.5078	},	10,	0,	0,	35000},
	{"Cluckin' Bell",			14	,			{928.6047,	-1352.8942,	13.3438, 93.1771	},		{364.9270,	-11.5009,	1001.8516,	1.1029		},	{369.5536,	-6.5280,	1001.8589	},	9,	0,	0,	35000},
	{"Cluckin' Bell",			14	,			{2420.1423,	-1509.0582,	24.0000, 270.8312	},		{364.9270,	-11.5009,	1001.8516,	1.1029		},	{369.5536,	-6.5280,	1001.8589	},	9,	0,	0,	35000}
};

new DelayTick[MAX_PLAYERS];

main()
{
	print("\n----------------------------------");
	print(" Cops `n Robbers by Sorenkai");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	

	printf("--------------------------");
	printf("Robbery System Loading... ");
	new arr[3];
	arr[0] = ENEX_STREAMER_IDENTIFIER;
	for(new i=0; i!=sizeof(storeData); ++i)
	{
		storeData[i][entCP] = CreateDynamicCP(storeData[i][entPos][0], storeData[i][entPos][1], storeData[i][entPos][2]+0.5, 1, -1, -1, -1, 50);
		storeData[i][extCP] = CreateDynamicCP(storeData[i][extPos][0], storeData[i][extPos][1], storeData[i][extPos][2]+0.5, 1, i, storeData[i][interiorID], -1, 50);
		storeData[i][robCP] = CreateDynamicCP(storeData[i][robPos][0], storeData[i][robPos][1], storeData[i][robPos][2]+0.5, 3, i, storeData[i][interiorID], -1, 50);
		CreateDynamic3DTextLabel("[Entrance]", COLOR_YELLOW, storeData[i][entPos][0], storeData[i][entPos][1], storeData[i][entPos][2]+0.2, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 50);
		CreateDynamic3DTextLabel("[Exit]", COLOR_YELLOW, storeData[i][extPos][0], storeData[i][extPos][1], storeData[i][extPos][2] + 0.2, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 50);
		CreateDynamic3DTextLabel("[Rob]", COLOR_YELLOW, storeData[i][robPos][0], storeData[i][robPos][1], storeData[i][robPos][2]+0.2, 50, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 50);
		CreateDynamicMapIcon(storeData[i][entPos][0], storeData[i][entPos][1], storeData[i][entPos][2], storeData[i][mapIcon], -1, .streamdistance = 200.0, .style = MAPICON_GLOBAL);
		storeData[i][virtualID] = i;
		arr[2] = i;

		Streamer_SetArrayData(STREAMER_TYPE_CP, storeData[i][entCP], E_STREAMER_EXTRA_ID, arr);
		Streamer_SetArrayData(STREAMER_TYPE_CP, storeData[i][extCP], E_STREAMER_EXTRA_ID, arr);
		Streamer_SetArrayData(STREAMER_TYPE_CP, storeData[i][robCP], E_STREAMER_EXTRA_ID, arr);
	}
	printf("Robbery System Loaded");
	printf("--------------------------");
	LoadHouses();
	printf("House System Loaded");
	printf("--------------------------");
	SetGameModeText("CNR");
	DisableInteriorEnterExits();
	
	///--Timer Setup
	SetTimer("ServerRobbery", 1000, 1);
	SetTimer("PlayerSecVars", 1000, 1);

	//--Database setup
	if ((database = db_open("server.db")) == DB: 0)  // We open the database with name server.db and store the database connection to the "Database" variable. Directly checking if the connection handle is invalid 
    { // If it returns 0, the the database connection failed so let's inform us through console. You may exit the server if you want to. 
        print("Failed to open a connection to \"server.db\""); 
    }
	db_query(database, "CREATE TABLE IF NOT EXISTS users (  player TEXT(25),  password TEXT(255),  money integer,  admin integer,  kills integer,  deaths integer, coke integer, weed integer)");
	db_query(database, "CREATE TABLE IF NOT EXISTS houses ( id INTEGER PRIMARY KEY AUTOINCREMENT, owner text(25), price integer, level integer, x_pos real, y_pos real, z_pos real, x_ent real, y_ent real, z_ent real, owned integer");
    return 1;
}
public OnGameModeExit()
{
	db_close(database);
	return 1;
}


public OnPlayerRequestClass(playerid, classid)
{
	ShowPlayerDialog(playerid, DIALOG_CLASS, DIALOG_STYLE_LIST, "{6EF83C}Choose A Class:", "Police\nHitman\nTaxi Driver\nGun Dealer\nDrug Dealer\nTerrorist", "Choose", "");
	return 1;
}

public OnPlayerConnect(playerid)
{
	new DBResult: Result, query[265], pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(query, sizeof(query),"SELECT `player` FROM `users` WHERE `player` = '%q'", pName);
	SetPlayerColor(playerid, COLOR_WHITE);
	Result = db_query(database, query);
	if(db_num_rows(Result))
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Login",""COL_WHITE"Enter your password below to log in.", "Login", "Quit");
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Register",""COL_WHITE"Enter your desired password below to register a new account.","Register" , "Quit");
	}


	//Textdraws
	MessageTD[playerid] = TextDrawCreate(241.000000, 410.000000, "TICKET RECIEVED");
	TextDrawBackgroundColor(MessageTD[playerid], 255);
	TextDrawFont(MessageTD[playerid], 1);
	TextDrawLetterSize(MessageTD[playerid], 0.549999, 1.500000);
	TextDrawColor(MessageTD[playerid], -1);
	TextDrawSetOutline(MessageTD[playerid], 0);
	TextDrawSetProportional(MessageTD[playerid], 1);
	TextDrawSetShadow(MessageTD[playerid], 1);
	TextDrawUseBox(MessageTD[playerid], 1);
	TextDrawBoxColor(MessageTD[playerid], 255);
	TextDrawTextSize(MessageTD[playerid], 384.000000, 0.000000);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	//new INI:File = INI_Open(UserPath(playerid));
	//INI_SetTag(File, "data");
	//INI_WriteInt(File, "Money", GetPlayerMoney(playerid));
	//INI_WriteInt(File, "Admin", PlayerInfo[playerid][pAdmin]);
	//INI_WriteInt(File, "Kills", PlayerInfo[playerid][pKills]);
	//INI_WriteInt(File, "Deaths", PlayerInfo[playerid][pDeaths]);
	//INI_Close(File);

	new query[265], pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	format(query, sizeof(query), "UPDATE `users` SET money = '%i', admin = '%i', kills = '%i', deaths = '%i', coke = '%i', weed = '%i' WHERE player = '%q'", GetPlayerMoney(playerid), PlayerInfo[playerid][pAdmin], PlayerInfo[playerid][pKills], PlayerInfo[playerid][pDeaths], pName, HasCoke[playerid],HasWeed[playerid]);
	db_query(database, query);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(gPlayerClass[playerid] == POLICE)
	{
		if(GetPlayerScore(playerid) >= 75)
		{
			SendClientMessage(playerid, COLOR_WHITE, "You chose the Police job");
			TogglePlayerControllable(playerid, 1);
			ResetPlayerWeapons(playerid);
			// Weapons
			//GivePlayerWeapon(playerid, weaponid, ammo)
			SetPlayerSkin(playerid, 280);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "You need at least 75 score to become a Police officer!");
			ShowPlayerDialog(playerid, DIALOG_CLASS, DIALOG_STYLE_LIST, "{6EF83C}Choose A Class:", "Police\nHitman\nTaxi Driver\nGun Dealer\nDrug Dealer\nTerrorist", "Choose", "");
		}
	}
	if(gPlayerClass[playerid] == HITMAN)
	{
		SendClientMessage(playerid, COLOR_WHITE, "You chose the Hitman job");
		TogglePlayerControllable(playerid, 1);
		ResetPlayerWeapons(playerid);
		// Weapons
		//GivePlayerWeapon(playerid, weaponid, ammo)
		SetPlayerSkin(playerid, 228);
	}
	if(gPlayerClass[playerid] == TAXI)
	{
		SendClientMessage(playerid, COLOR_WHITE, "You chose the Texi Driver job");
		TogglePlayerControllable(playerid, 1);
		ResetPlayerWeapons(playerid);
		// Weapons
		//GivePlayerWeapon(playerid, weaponid, ammo)
		SetPlayerSkin(playerid, 7);
	}
	if(gPlayerClass[playerid] == GUN)
	{
		SendClientMessage(playerid, COLOR_WHITE, "You chose the Gun Dealer job");
		TogglePlayerControllable(playerid, 1);
		ResetPlayerWeapons(playerid);
		// Weapons
		//GivePlayerWeapon(playerid, weaponid, ammo)
		SetPlayerSkin(playerid, 254);
	}
	if(gPlayerClass[playerid] == DRUG)
	{
		SendClientMessage(playerid, COLOR_WHITE, "You chose the Drug Dealer job");
		TogglePlayerControllable(playerid, 1);
		ResetPlayerWeapons(playerid);
		// Weapons
		//GivePlayerWeapon(playerid, weaponid, ammo)
		SetPlayerSkin(playerid, 28);
	}
	if(gPlayerClass[playerid] == TERRORIST)
	{
		SendClientMessage(playerid, COLOR_WHITE, "You chose the Terrorist job");
		TogglePlayerControllable(playerid, 1);
		ResetPlayerWeapons(playerid);
		// Weapons
		//GivePlayerWeapon(playerid, weaponid, ammo)
		SetPlayerSkin(playerid, 163);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	PlayerInfo[killerid][pKills]++;
	PlayerInfo[playerid][pDeaths]++;
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{

	new arr[3];
	Streamer_GetArrayData(STREAMER_TYPE_CP, checkpointid, E_STREAMER_EXTRA_ID, arr);
	printf("[debug] callback onplayerenterdynamiccp");
	if(arr[0] == ENEX_STREAMER_IDENTIFIER)
	{
		printf("[debug] if enex streamer identifier");
		if((gettime() - DelayTick[playerid]) < 3)
		{
			return 1;
		}
		if(checkpointid == storeData[arr[2]][entCP])
		{

			printf("[debug] on entcp: %s", storeData[arr[2]][storeName]);
			DelayTick[playerid] = gettime();
			SetPlayerVirtualWorld(playerid, storeData[arr[2]][virtualID]);
			SetPlayerInterior(playerid, storeData[arr[2]][interiorID]);

			SetPlayerPos(playerid, storeData[arr[2]][extPos][0], storeData[arr[2]][extPos][1], storeData[arr[2]][extPos][2]);
			SetPlayerFacingAngle(playerid, storeData[arr[2]][extPos][3]);
			SetCameraBehindPlayer(playerid);
		}	
		if(checkpointid == storeData[arr[2]][extCP])
		{
			printf("[debug] on extcp: %s",storeData[arr[2]][storeName]);
			DelayTick[playerid] = gettime();
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerPos(playerid, storeData[arr[2]][entPos][0], storeData[arr[2]][entPos][1], storeData[arr[2]][entPos][2]);
			SetPlayerFacingAngle(playerid, storeData[arr[2]][entPos][3]);
			SetCameraBehindPlayer(playerid);

		}
		if(checkpointid == storeData[arr[2]][robCP])
		{
			printf("[debug] on robcp: %s",storeData[arr[2]][storeName]);
			SendClientMessage(playerid, COLOR_RED, "[ROBBERY] Start a robbery by typing /rob");

		}
	}
	#if defined hk_OnPlayerEnterDynamicCP
		return hk_OnPlayerEnterDynamicCP(playerid, checkpointid)
	#else
		return 1;
	#endif
}

#if defined _ALS_OPPDP
	#undef OnPlayerEnterDynamicCP
#else
	#define _ALS_OPPDP
#endif

public OnPlayerLeaveDynamicCP(playerid, checkpointid)
{
	new arr[2];
	Streamer_GetArrayData(STREAMER_TYPE_CP, checkpointid, E_STREAMER_EXTRA_ID, arr);
	if(storeData[arr[1]][beingRobbed] >= 1)
	{
		SendClientMessage(playerid, COLOR_RED, "[ROBBERY] Robbery Failed");
		storeData[arr[1]][beingRobbed] = 0;
		return 1;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			if(!response) return Kick(playerid);
			if(response)
			{
				if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Register", ""COL_RED"You have entered an invalid password.\n"COL_WHITE"Enter your desired password below to register a new account.", "Register" ,"Quit");
				//new INI:File = INI_Open(UserPath(playerid));
				//INI_SetTag(File, "data");
				//INI_WriteInt(File, "Password", udb_hash(inputtext));
				//INI_WriteInt(File, "Cash", 0);
				//INI_WriteInt(File,"Admin",0);
				//INI_WriteInt(File, "Kills", 0);
				//INI_WriteInt(File, "Deaths", 0);
				//INI_Close(File);
				new query[265], pName[MAX_PLAYER_NAME], hashpass[144];
				GetPlayerName(playerid, pName, sizeof(pName));
				WP_Hash(hashpass, 144, inputtext);
				format(query, sizeof(query),"INSERT INTO users (player, password) VALUES ('%q', '%s')", pName, hashpass);
				db_query(database, query);

				SetSpawnInfo(playerid, 0, 0, 1958.33, 1343.12, 15.36, 269.15, 0, 0, 0, 0, 0, 0);
				SpawnPlayer(playerid);
				ShowPlayerDialog(playerid, DIALOG_SUCCESS_1, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Success!", ""COL_GREEN"You have successfully registered!", "Continue","");

			}
		}
		case DIALOG_LOGIN:
		{
			if(!response) return Kick(playerid);
			if(response)
			{	
				new buf[144], DBResult: Result, query[256], pName[MAX_PLAYER_NAME];
				GetPlayerName(playerid, pName, sizeof(pName));
				format(query, sizeof(query), "SELECT password FROM users WHERE player = '%q'",pName);
				Result = db_query(database, query);
				db_get_field_assoc(Result, "password", PlayerInfo[playerid][pPass], 144);
				db_free_result(Result);
				WP_Hash(buf,144,inputtext);
				if(!strcmp(buf, PlayerInfo[playerid][pPass]))
				{
					format(query, sizeof(query), "SELECT * FROM users WHERE player = '%q' LIMIT 1",pName);
					Result = db_query(database, query);
					PlayerInfo[playerid][pMoney] = db_get_field_assoc_int(Result, "money");
					PlayerInfo[playerid][pAdmin] = db_get_field_assoc_int(Result, "admin");
					PlayerInfo[playerid][pKills] = db_get_field_assoc_int(Result, "kills");
					PlayerInfo[playerid][pDeaths] = db_get_field_assoc_int(Result, "deaths");
					HasCoke[playerid] = db_get_field_assoc_int(Result, "coke");
					HasWeed[playerid] = db_get_field_assoc_int(Result, "weed");
					db_free_result(Result);


					GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
					ShowPlayerDialog(playerid, DIALOG_SUCCESS_2, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Success!", ""COL_GREEN"You have successfully logged in!", "Continue", "");				
				}
				else
				{
					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COL_WHITE"Login", ""COL_WHITE"Enter your password below to log in.", "Login.", "Quit.");
				}
			}

		}
		case DIALOG_EDITID:
		{
			if(response)
                {
                        new string[144], file[50];
                        hid = strval(inputtext);
                        format(file, sizeof(file), "Houses/%d.ini", hid);
                        if(!fexist(file)) return SendClientMessage(playerid, -1, "{FF0000}ERROR: {FFFFFF}This house doesn't exist in data-base.");
                        format(string, sizeof(string), "{FF0000}[EDIT-MODE]: {FFFFFF}Currently editing house: {FF0000}%d.", strval(inputtext));
                        SendClientMessage(playerid, -1, string);
                        ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                else
                {
                        SendClientMessage(playerid, -1, "{FF0000}[HOUSE]: {FFFFFF}You can't edit this house now.");
                }
		}
		case DIALOG_EDIT:
		{
			if(response)
            {
                if(listitem == 0)
                {
                    ShowPlayerDialog(playerid, DIALOG_EDITPRICE, DIALOG_STYLE_INPUT, "Edit Price", "{FFFFFF}Please, input below new house's price:", "Continue", "Back");
                }
                if(listitem == 1)
                {
                    ShowPlayerDialog(playerid, DIALOG_EDITINTERIOR, DIALOG_STYLE_INPUT, "Edit Interior", "{FFFFFF}Please, input below house's interior:", "Continue", "Back");
                }
                if(listitem == 2)
                {
                	new query[144], string[144];
                	HouseInfo[hid][hOwned] = 0;
                	//format(file, sizeof(file), "Houses/%d.ini", hid);
                	//if(fexist(file))
                	//{
                	//    dini_IntSet(file, "Owned", 0);
                	//}
					format(query, sizeof(query), "UPDATE houses SET owned = 0 WHERE id = '%i'",hid);
					db_query(database, query);
                	format(string, sizeof(string), "{FF0000}[EDIT-MODE]: {FFFFFF}House setted ownable.");
                	SendClientMessage(playerid, -1, string);
                	ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                if(listitem == 3)
                {
                    HouseInfo[hid][hLocked] = 1;
                    SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}House locked.");
                    ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                if(listitem == 4)
                {
                    HouseInfo[hid][hLocked] = 0;
                    SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}House unlocked.");
                    ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                if(listitem == 5)
                {
                    SetPlayerPos(playerid, HouseInfo[hid][hX], HouseInfo[hid][hY], HouseInfo[hid][hZ]);
        			SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}Teleported to house.");
                    ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
                if(listitem == 6)
                {
        			SetPlayerPos(playerid, HouseInfo[hid][hX], HouseInfo[hid][hY], HouseInfo[hid][hZ]);
        			SetPlayerInterior(playerid, HouseInfo[hid][hInterior]);
        			SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}Entered in house.");
                }
                if(listitem == 7)
                {
            		SetPlayerPos(playerid, HouseInfo[hid][hX], HouseInfo[hid][hY], HouseInfo[hid][hZ]);
                    SetPlayerInterior(playerid, 0);
            		SendClientMessage(playerid, -1, "{FF0000}[EDIT-MODE]: {FFFFFF}House exited to pick-up position.");
                    ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
                }
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_EDITID, DIALOG_STYLE_INPUT, "House ID", "{FFFFFF}Please, input below house ID wich you want to edit:", "Continue", "Exit");
            }
		}
		case DIALOG_EDITPRICE:
		{
			if(response)
            {
                new query[144], string[144];
                HouseInfo[hid][hPrice] = strval(inputtext);
                //format(file, sizeof(file), "Houses/%d.ini", hid);
                //if(fexist(file))
                //{
                //    dini_IntSet(file, "Price", HouseInfo[hid][hPrice]);
                //}
				format(query, sizeof(query), "UPDATE houses SET price = '%i' WHERE id = '%i'", HouseInfo[hid][hPrice],hid);
				db_query(database, query);
                format(string, sizeof(string), "{FF0000}[EDIT-MODE]: {FFFFFF}New price of house: {FF0000}%d {FFFFFF}it's {FF0000}%d.", hid, HouseInfo[hid][hPrice]);
                SendClientMessage(playerid, -1, string);
                ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
            }
            else
            {
            	ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
            }

		}
		case DIALOG_EDITINTERIOR:
		{
			if(response)
            {
            	new query[144], string[144];
                HouseInfo[hid][hInterior] = strval(inputtext);
                //format(file, sizeof(file), "Houses/%d.ini", hid);
                //if(fexist(file))
                //{
                //        dini_IntSet(file, "Interior", HouseInfo[hid][hInterior]);
                //}
				format(query, sizeof(query), "UPDATE houses SET interior = '%i' WHERE id = '%i'", HouseInfo[hid][hInterior],hid);
				db_query(database, query);
                format(string, sizeof(string), "{FF0000}[EDIT-MODE]: {FFFFFF}New interior of house: {FF0000}%d {FFFFFF}it's {FF0000}%d.", hid, HouseInfo[hid][hInterior]);
                SendClientMessage(playerid, -1, string);
                ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
            }
            else
            {
        		ShowPlayerDialog(playerid, DIALOG_EDIT, DIALOG_STYLE_LIST, "Edit House:", "Edit Price\nEdit Interior\nSet Owned\nLock House\nUnlock House\nTeleport House\nEnter House\nExit House", "Select", "Back");
            }
		}
		case DIALOG_CLASS:
		{
			if(response)
			{
				if(listitem == 0)
				{
					if(GetPlayerScore(playerid) >= 75)
					{
						SendClientMessage(playerid, COLOR_WHITE, "You chose the Police job");
						gPlayerClass[playerid] = POLICE;
						PickedClass[playerid] = 1;
						TogglePlayerControllable(playerid, 1);
						ResetPlayerWeapons(playerid);
						// Weapons
						// GivePlayerWeapon(playerid, wepid, ammo);
						SetPlayerSkin(playerid, 280);
					}
					else
					{
						SendClientMessage(playerid, COLOR_RED, "You need at least 75 score to become a Police Officer");
						ShowPlayerDialog(playerid, DIALOG_CLASS, DIALOG_STYLE_LIST, "{6EF83C}Choose A Class:", "Police\nHitman\nTaxi Driver\nGun Dealer\nDrug Dealer\nTerrorist", "Choose", "");
					}
				}
				if(listitem == 1)
				{
					SendClientMessage(playerid, COLOR_WHITE, "You chose the Hitman job");
					gPlayerClass[playerid] = HITMAN;
					PickedClass[playerid] = 1;
					TogglePlayerControllable(playerid, 1);
					ResetPlayerWeapons(playerid);
					// Weapons
					// GivePlayerWeapon(playerid, wepid, ammo);
					SetPlayerSkin(playerid, 228);
				}
				if(listitem == 2)
				{
					SendClientMessage(playerid, COLOR_WHITE, "You chose the Taxi Driver job");
					gPlayerClass[playerid] = TAXI;
					PickedClass[playerid] = 1;
					TogglePlayerControllable(playerid, 1);
					ResetPlayerWeapons(playerid);
					// Weapons
					// GivePlayerWeapon(playerid, wepid, ammo);
					SetPlayerSkin(playerid, 7);
				}
				if(listitem == 3)
				{
					SendClientMessage(playerid, COLOR_WHITE, "You chose the Gun Dealer job");
					gPlayerClass[playerid] = GUN;
					PickedClass[playerid] = 1;
					TogglePlayerControllable(playerid, 1);
					ResetPlayerWeapons(playerid);
					// Weapons
					// GivePlayerWeapon(playerid, wepid, ammo);
					SetPlayerSkin(playerid, 254);
				}
				if(listitem == 4)
				{
					SendClientMessage(playerid, COLOR_WHITE, "You chose the Drug Dealer job");
					gPlayerClass[playerid] = DRUG;
					PickedClass[playerid] = 1;
					TogglePlayerControllable(playerid, 1);
					ResetPlayerWeapons(playerid);
					// Weapons
					// GivePlayerWeapon(playerid, wepid, ammo);
					SetPlayerSkin(playerid, 26);
				}
				if(listitem == 5)
				{
					SendClientMessage(playerid, COLOR_WHITE, "You chose the Terrorist job");
					gPlayerClass[playerid] = TERRORIST;
					PickedClass[playerid] = 1;
					TogglePlayerControllable(playerid, 1);
					ResetPlayerWeapons(playerid);
					// Weapons
					// GivePlayerWeapon(playerid, wepid, ammo);
					SetPlayerSkin(playerid, 163);
				}
			}
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

/*Credits to Dracoblue*/
stock udb_hash(buf[]) {
	new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
}

stock PlayerName(playerid){
	new name[255];
	GetPlayerName(playerid, name, 255);
	return name;
}

stock UserPath(playerid)
{
	new string[128],pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid,pName,sizeof(pName));
	format(string, sizeof(string),PATH,pName);
	return string;
}

stock LoadHouses()
{
    new query[144], DBResult: Result, labelstring[144], stringlabel[144], pName[MAX_PLAYER_NAME+1];
    for(new i = 0; i < MAX_HOUSES; i++)
    {         
       	//HouseInfo[i][hOwned] = dini_Int(file, "Owned");
       	//HouseInfo[i][hPrice] = dini_Int(file, "Price");
       	//HouseInfo[i][hInterior] = dini_Int(file, "Interior");
       	//HouseInfo[i][hX] = dini_Float(file, "Position X");
       	//HouseInfo[i][hY] = dini_Float(file, "Position Y");
       	//HouseInfo[i][hZ] = dini_Float(file, "Position Z");
       	//HouseInfo[i][hEnterX] = dini_Float(file, "Enter X");
       	//HouseInfo[i][hEnterY] = dini_Float(file, "Enter Y");
       	//HouseInfo[i][hEnterZ] = dini_Float(file, "Enter Z");
        //strmid(HouseInfo[i][hOwner], dini_Get(file, "Owner"), false, strlen(dini_Get(file, "Owner")), MAX_PLAYER_NAME);
		format(query, sizeof(query), "SELECT * FROM houses WHERE id ='%i'", i);
		Result = db_query(database, query);
		HouseInfo[i][hOwned] = db_get_field_assoc_int(Result, "owned");
		HouseInfo[i][hPrice] = db_get_field_assoc_int(Result, "price");
		HouseInfo[i][hInterior] = db_get_field_assoc_int(Result, "interior");
		HouseInfo[i][hX] = db_get_field_assoc_float(Result, "x_pos");
		HouseInfo[i][hY] = db_get_field_assoc_float(Result, "y_pos");
		HouseInfo[i][hZ] = db_get_field_assoc_float(Result, "z_pos");
		HouseInfo[i][hEnterX] = db_get_field_assoc_float(Result, "x_ent");
		HouseInfo[i][hEnterY] = db_get_field_assoc_float(Result, "y_ent");
		HouseInfo[i][hEnterZ] = db_get_field_assoc_float(Result, "z_ent");
		HouseInfo[i][hOwner] = db_get_field_assoc(Result, "owner", pName, sizeof(pName));
		
		format(labelstring, sizeof(labelstring), "{15FF00}House ID: {FFFFFF}%d\n{15FF00}Status: {FFFFFF}For Sale\n{15FF00}Price: {FFFFFF}%d", i, HouseInfo[i][hPrice]);
		format(stringlabel, sizeof(stringlabel), "{15FF00}House ID: {FFFFFF}%d\n{15FF00}Owner: {FFFFFF}%s\n{15FF00}Price: {FFFFFF}%d", i, HouseInfo[i][hOwner], HouseInfo[i][hPrice]);
        if(HouseInfo[i][hOwned] == 0)
        {
            HouseInfo[i][hPick] = CreatePickup(1273, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
            HouseInfo[i][hLabel] = Create3DTextLabel(labelstring, 0xFFFFFFFF, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 30.0, 0, 0);
        }
        else if(HouseInfo[i][hOwned] == 1)
        {
            HouseInfo[i][hPick] = CreatePickup(1272, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
            HouseInfo[i][hLabel] = Create3DTextLabel(stringlabel, 0xFFFFFFFF, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 30.0, 0, 0);
        }
		db_free_result(Result);
        houseid++;
        
    }
    print(" ");
    print(" ");
    printf("  LOADED HOUSE: %d/%d", houseid, MAX_HOUSES);
    print(" ");
    print(" ");
    return 1;
}

forward Float:GetDistanceBetweenPlayers(p1,p2);
public Float:GetDistanceBetweenPlayers(p1,p2)
{
	new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
	if(!IsPlayerConnected(p1) || !IsPlayerConnected(p2)) return -1.00;

	GetPlayerPos(p1, x1, y1, z1);
	GetPlayerPos(p2, x2, y2, z2);

	return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}

forward IncreaseWantedLevel(playerid,level);
public IncreaseWantedLevel(playerid,level)
{
	new pwlvl,pwcol, string[128];
	SetPlayerWantedLevel(playerid, GetPlayerWantedLevel(playerid) + level);
	pwlvl = GetPlayerWantedLevel(playerid);
	pwcol = GetPlayerColor(playerid);
	format(string, sizeof(string), "[WANTED] Your wanted level has been increased to: %i", pwlvl);
	SendClientMessage(playerid, pwcol, string);
	if(GetPlayerWantedLevel(playerid) >= 1 && GetPlayerWantedLevel(playerid) <= 5)
	{
		SetPlayerColor(playerid, COLOR_YELLOW);
	}
	if(GetPlayerWantedLevel(playerid) >= 6 && GetPlayerWantedLevel(playerid) <= 19)
	{
		SetPlayerColor(playerid, COLOR_ORANGE);
	}
	if(GetPlayerWantedLevel(playerid) >= 20)
	{
		SetPlayerColor(playerid, COLOR_RED);
	}
	return 1;
}

forward IncreaseScore(playerid, amount);
public IncreaseScore(playerid, amount)
{
	SetPlayerScore(playerid, GetPlayerScore(playerid) + amount);
	return 1;
}


LoopAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
    ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
}

forward ServerRobbery();
public ServerRobbery()
{
	for(new i; i<MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(storeData[i][beingRobbed] > 1)
			{
				storeData[i][beingRobbed] --;
				new time[20];
				format(time, sizeof(time), "~r~Robbery Time: %d",storeData[i][beingRobbed]);
				GameTextForPlayer(i, time, 500, 3);

			}
			if(storeData[i][beingRobbed] == 1)
			{
				new string[256], pName[MAX_PLAYER_NAME];
				GetPlayerName(i, pName, MAX_PLAYER_NAME);
				SendClientMessage(i, COLOR_GREEN, "[ROBBERY] Robbery Complete!");
				SetPlayerWantedLevel(i, GetPlayerWantedLevel(i)+1);
				storeData[i][beingRobbed] = 0;
				new mrand = random(storeData[i][maxMoney]);
				GivePlayerMoney(i, mrand);
				format(string, sizeof(string), "[ROBBERY] %s(%d) has robbed a total of $%d from %s ", pName,i,mrand,storeData[i][storeName]);
				SendClientMessageToAll(COLOR_GREEN, string);
				GivePlayerMoney(i, mrand);
			}
		}
	}
	return 1;
}

forward LoadUser_data(playerid, name[],value[]);
public LoadUser_data(playerid, name[],value[])
{
	INI_Int("Password", PlayerInfo[playerid][pPass]);
	INI_Int("Money", PlayerInfo[playerid][pMoney]);
	INI_Int("Admin", PlayerInfo[playerid][pAdmin]);
	INI_Int("Kills", PlayerInfo[playerid][pKills]);
	INI_Int("Deaths", PlayerInfo[playerid][pDeaths]);
	return 1;
}

forward PlayerSecVars();
public PlayerSecVars()
{
	//new string[128];
	for(new i=0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i)){
			if(HasBeenReportedRecently[i] >= 1){
				HasBeenReportedRecently[i] --;
			}
			if(MessageTDTime[i] > 1)
	        {
	            MessageTDTime[i] --;
			}
			if(MessageTDTime[i] == 1)
			{
				TextDrawHideForPlayer(i,MessageTD[i]);
			}
			if(TimeToPayTicket[i] >= 1)
			{
				TimeToPayTicket[i] --;
			}
			if(TimeToPayTicket[i] == 1)
			{
				SendClientMessage(i, COLOR_RED, "[TICKET] You have failed to pay your ticket. Your wanted level has increased");
				IncreaseWantedLevel(i,4);
				HasTicket[i] =0;
			}
			if(ArrestTime[i] > 1)
			{
				ArrestTime[i] --;
			}
			if(ArrestTime[i] == 1)
			{
				// Release player from jail
			}
		}
	}
	return 1;
}

forward SendClientMessageToAllCops(string[]);
public SendClientMessageToAllCops(string[])
{
	for(new i=0;i<MAX_PLAYERS;i++)
	{
		if(gPlayerClass[i] == POLICE)
		{
			SendClientMessage(i, COLOR_BLUE, string);
		}
	}
	return 1;
}

CMD:rob(playerid, params[])
{
	#pragma unused params
	new args[2], string[256], pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	if(IsPlayerInDynamicCP(playerid, storeData[args[1]][robCP]))
	{
		if(storeData[args[1]][recentlyRobbed] >= 1)
		{
			format(string, sizeof(string),"[ROBBERY] This %s has been robbed recently.",storeData[args[1]][storeName]);
			SendClientMessage(playerid, COLOR_RED, string);
			return 1;
		}
		storeData[args[1]][beingRobbed] = 60;
		storeData[args[1]][recentlyRobbed] = 180;
		format(string, sizeof(string), "[ROBBERY] %s(%d) has started a robbery at a %s", pName,playerid, storeData[args[1]][storeName]);
		SendClientMessageToAll(COLOR_BLUE, string);
	}
	return 1;
}

CMD:createhouse(playerid,params[])
{
	new Price, Level, string[144], Float:X, Float:Y, Float:Z, labelstring[144];
	GetPlayerPos(playerid, X, Y, Z);
	if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] Your admin level is not high enough!");
	if(sscanf(params, "dd", Price,Level)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /createhouse <price> <level>");
	if(Level > 5 || Level < 1) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] Invalid Level [1-5]");
	if(Level == 1)
	{
		HouseInfo[houseid][hEnterX] = 2216.540087;
		HouseInfo[houseid][hEnterY] = -1078.869995;
		HouseInfo[houseid][hEnterZ] = 1049.023437;
		HouseInfo[houseid][hInterior] = 2;
		SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] Interior Set #1");
	}
	else if(Level == 2)
	{
		HouseInfo[houseid][hEnterX] = 2216.540039;
		HouseInfo[houseid][hEnterY] = -1076.290039;
		HouseInfo[houseid][hEnterZ] = 1050.484375;
		HouseInfo[houseid][hInterior] = 1;
		SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] Interior Set #2");
	}
	else if(Level == 3)
	{
		HouseInfo[houseid][hEnterX] = 2282.909912;
		HouseInfo[houseid][hEnterY] = -1137.971191;
		HouseInfo[houseid][hEnterZ] = 1050.898437;
		HouseInfo[houseid][hInterior] = 11;
		SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] Interior Set #3");
	}
	else if(Level == 4)
	{
		HouseInfo[houseid][hEnterX] = 2365.300048;
		HouseInfo[houseid][hEnterY] = -1132.920043;
		HouseInfo[houseid][hEnterZ] = 1050.875000;
		HouseInfo[houseid][hInterior] = 8;
		SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] Interior Set #4");		
	}
	else if(Level == 5)
	{
        HouseInfo[houseid][hEnterX] = 1299.079956;
        HouseInfo[houseid][hEnterY] = -795.226989;
        HouseInfo[houseid][hEnterZ] = 1084.007812;
        HouseInfo[houseid][hInterior] = 5;
        SendClientMessage(playerid, -1, "{FF0000}[HOUSE]: {FFFFFF}House Interior setted. {FF0000}#5.");
	}

	format(string, sizeof(string), "[HOUSE] House ID: %d created", houseid);
	SendClientMessage(playerid, COLOR_GREEN, string);
	format(labelstring, sizeof(labelstring), "{15FF00}House ID: {FF0000}%d\n{15FF00}Status: {FFFFFF} For Sale\n{15FF00}Price: {FFFFFF}$%d", houseid,Price);
	HouseInfo[houseid][hOwned] = 0;
	HouseInfo[houseid][hX] = X;
	HouseInfo[houseid][hY] = Y;
	HouseInfo[houseid][hZ] = Z;
	HouseInfo[houseid][hPick] = CreatePickup(1273, 1, X, Y, Z, 0);
	HouseInfo[houseid][hLabel] = Create3DTextLabel(labelstring, 0xFFFFFFFF, X, Y, Z, 30, 0, 0);
	//format(file, sizeof(file),"Houses/%d.ini",houseid);
	//if(!fexist(file))
	//{
	//	dini_Create(file);
	//	dini_IntSet(file,"Price",Price);
	//	dini_IntSet(file,"Interior",HouseInfo[houseid][hInterior]);
	//	dini_IntSet(file,"Level",Level);
	//	dini_FloatSet(file,"Position X",X);
	//	dini_FloatSet(file,"Position Y",Y);
	//	dini_FloatSet(file,"Position Z",Z);
	//	dini_FloatSet(file,"Enter X",HouseInfo[houseid][hEnterX]);
	//	dini_FloatSet(file,"Enter Y",HouseInfo[houseid][hEnterY]);
	//	dini_FloatSet(file,"Enter Z",HouseInfo[houseid][hEnterZ]);
	//}
	new query[144];
	format(query, sizeof(query), "INSERT INTO houses (price,interior,level,x_pos,y_pos,z_pos,x_ent,y_ent,z_ent) VALUES ('%i','%i','%f','%f','%f','%f','%f','%f'", Price, HouseInfo[houseid][hInterior], Level, X, Y, Z, HouseInfo[houseid][hEnterX], HouseInfo[houseid][hEnterY], HouseInfo[houseid][hEnterZ]);
	db_query(database, query);
	houseid++;
	return 1;
}

CMD:buyhouse(playerid, params[])
{
    new name[MAX_PLAYER_NAME], labelstring[144], string[144], query[144];
    GetPlayerName(playerid, name, sizeof(name));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
        {
            if(HouseInfo[i][hOwned] == 1) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] This house has already been bought");
            if(GetPlayerMoney(playerid) < HouseInfo[i][hPrice]) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You don't have enough money to buy this house");
            DestroyPickup(HouseInfo[i][hPick]);
            format(labelstring, sizeof(labelstring), "{15FF00}House ID: {FFFFFF}%d\n{15FF00}Owner: {FFFFFF}%s\n{15FF00}Price: {FFFFFF}%d", i, name, HouseInfo[i][hPrice]);
            HouseInfo[i][hPick] = CreatePickup(1272, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
            Update3DTextLabelText(HouseInfo[i][hLabel], 0xFFFFFFFF, labelstring);
            format(labelstring, sizeof(labelstring), "{FF0000}[HOUSE]: {FFFFFF}You bought house ID: {FF0000}%d {FFFFFF}for {FF0000}$ %d.", i, HouseInfo[i][hPrice]);
            SendClientMessage(playerid, -1, string);
            HouseInfo[i][hOwned] = 1;
            HouseInfo[i][hOwner] = name;
            //format(file, sizeof(file), "Houses/%d.ini", i);
            //if(fexist(file))
            //{
            //    dini_IntSet(file, "Owned", 1);
            //    dini_Set(file, "Owner", name);
            //}
			format(query, sizeof(query), "UPDATE houses SET owned = 1 owner = '%q'", name);
			db_query(database, query);
            GivePlayerMoney(playerid, -HouseInfo[i][hPrice]);
        }
    }
    return 1;
}

CMD:sellhouse(playerid, params[])
{
    new pname[MAX_PLAYER_NAME], labelstring[144], string[144], query[144];
    GetPlayerName(playerid, pname, sizeof(pname));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
        {
            if(HouseInfo[i][hOwned] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You cannot sell this house");
            if(strcmp(pname, HouseInfo[i][hOwner], true)) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You aren't Owner of this house");
            format(labelstring, sizeof(labelstring), "{15FF00}House ID: {FFFFFF}%d\n{15FF00}Status: {FFFFFF}For Sale\n{15FF00}Price: {FFFFFF}%d", i, HouseInfo[i][hPrice]);
            DestroyPickup(HouseInfo[i][hPick]);
            HouseInfo[i][hPick] = CreatePickup(1273, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], 0);
            Update3DTextLabelText(HouseInfo[i][hLabel], 0xFFFFFFFF, labelstring);
            format(string, sizeof(string), "{FF0000}[HOUSE]: {FFFFFF}You've sold your house: {FF0000}%d.", i);
            SendClientMessage(playerid, -1, string);
            HouseInfo[i][hOwned] = 0;
            HouseInfo[i][hOwner] = 0;
            //format(file, sizeof(file), "Houses/%d.ini", i);
            //if(fexist(file))
            //{
            //    dini_IntSet(file, "Owned", 0);
            //    dini_Set(file, "Owner", " ");
            //}
			format(query, sizeof(query), "UPDATE houses SET owner =` ` owned = 0");
			db_query(database, query);
            GivePlayerMoney(playerid, HouseInfo[i][hPrice]);
        }
    }
    return 1;
}

CMD:enterhouse(playerid, params[])
{
        for(new i = 0; i < MAX_HOUSES; i++)
        {
                if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
                {
                        if(HouseInfo[i][hLocked] == 1) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] This house is locked");
                        if(HouseInfo[i][hOwned] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You cannot enter this house");
                        SetPlayerPos(playerid, HouseInfo[i][hEnterX], HouseInfo[i][hEnterY], HouseInfo[i][hEnterZ]);
                        SetPlayerInterior(playerid, HouseInfo[i][hInterior]);
                        SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] You've entered a house.");
                        InHouse[playerid][i] = 1;
                }
        }
        return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:exithouse(playerid, params[])
{
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(InHouse[playerid][i] == 1)
        {
            SetPlayerPos(playerid, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]);
            SetPlayerInterior(playerid, 0);
            SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] You've exited a house.");
            InHouse[playerid][i] = 0;
        }
    }
    return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:lockhouse(playerid, params[])
{
    new pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
        {
            if(HouseInfo[i][hOwned] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You can't lock this house");
            if(HouseInfo[i][hLocked] == 1) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] This house is already locked");
            if(strcmp(pname, HouseInfo[i][hOwner], true)) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You aren't owner of this house");
            SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] You've locked your house.");
            GameTextForPlayer(playerid, "House ~r~Locked", 5000, 3);
            HouseInfo[i][hLocked] = 1;
        }
    }
    return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:unlockhouse(playerid, params[])
{
    new pname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ]))
        {
            if(HouseInfo[i][hOwned] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You can't enter this house");
            if(HouseInfo[i][hLocked] == 0) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] This house is already unlocked");
            if(strcmp(pname, HouseInfo[i][hOwner], true)) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] You aren't owner of this house");
            SendClientMessage(playerid, COLOR_GREEN, "[HOUSE] You've unlocked your house");
            GameTextForPlayer(playerid, "House ~g~UnLocked", 5000, 3);
            HouseInfo[i][hLocked] = 0;
        }
    }
    return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:edithouse(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_SYNTAX, "[HOUSE] Your admin level is not high enough");
    ShowPlayerDialog(playerid, DIALOG_EDITID, DIALOG_STYLE_INPUT, "House ID", "{FFFFFF}Please, input below house ID wich you want to edit:", "Continue", "Exit");
    return 1;
}
 
//------------------------------------------------------------------------------
 
CMD:housecmds(playerid, params[])
{
        new Dialog[512];
        strcat(Dialog, "{FF0000}h-House Commands.\n\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/HouseCMDS {FFFFFF}- See this list with all commands.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/BuyHouse {FFFFFF}- Buy a house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/SellHouse {FFFFFF}- Sell your house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/EnterHouse {FFFFFF}- Enter in a house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/ExitHouse {FFFFFF}- Exit from a house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/LockHouse {FFFFFF}- Locks your house.\n", sizeof(Dialog));
        strcat(Dialog, "{FFCC33}/UnlockHouse {FFFFFF}- Unlocks your house.\n\n", sizeof(Dialog));
        strcat(Dialog, "{FF0000}/CreateHouse {15FF00}- Creates a house [LOGGED AS RCON].", sizeof(Dialog));
    	ShowPlayerDialog(playerid, DIALOG_HCMDS, DIALOG_STYLE_MSGBOX, "House Commands", Dialog, "Exit", "");
        return 1;
}

CMD:stats(playerid, params[])
{
	new tName[MAX_PLAYER_NAME], targetid, stattitle[64], statinfo[1024];
	new admin = PlayerInfo[targetid][pAdmin];
	new money = PlayerInfo[targetid][pMoney];
	new kills = PlayerInfo[targetid][pKills];
	new deaths = PlayerInfo[targetid][pDeaths];
	if(sscanf(params,"i",targetid)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /stats <playerid");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not online");
	GetPlayerName(targetid, tName, sizeof(tName));
	format(stattitle, sizeof(stattitle), "%s's stats", tName);
	format(statinfo, sizeof(statinfo), "{44A1D0}Admin Level: {FFFFFF}%i\n{44A1D0}Money: {FFFFFF}$%i\n{44A1D0}Kills: {FFFFFF}%i\n{44A1D0}Deaths: {FFFFFF}%i",admin,money,kills,deaths);
	ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, stattitle, statinfo, "Close", "");
	return 1;
}

#include "cmds/admincmds.pwn"
#include "utils/cars.pwn"
#include "cmds/policecmds.pwn"