new VehicleNames[212][] = {
{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},
{"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},
{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},{"Washington"},
{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},
{"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},
{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},
{"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},
{"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},
{"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},
{"Rustler"},{"ZR-350"},{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},
{"Baggage"},{"Dozer"},{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},
{"Jetmax"},{"Hotring"},{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},
{"Mesa"},{"RC Goblin"},{"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},
{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},
{"Tanker"}, {"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},
{"NRG-500"},{"HPV1000"},{"Cement Truck"},{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},
{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},
{"Blade"},{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},
{"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},
{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},
{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},
{"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},
{"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},
{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},{"Freight Carriage"},
{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},{"Police Car (SFPD)"},
{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},{"Alpha"},{"Phoenix"},{"Glendale"},
{"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},
{"Utility Trailer"}};

new Float:vehicleX, Float:vehicleY, Float:vehicleZ, Float:vehicleAngle;
forward GetVehicleModelIDFromName(vname[]);
public GetVehicleModelIDFromName(vname[])
{
	for(new i=0; i<211; i++)
	{
		if(strfind(VehicleNames[i], vname, true) != -1) return i+400;
	}

	return -1;
}

//-----------------LEVEL 1------------------//
CMD:setpos(playerid,params[])
{
	new Float:x, Float:y, Float:z, interiorid, vw;
	if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your admin level is not high enough");
	if(sscanf(params,"fffii",x,y,z,interiorid,vw)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /setpos <x> <y> <z> <interiorid> <virtualworldid>");
	SetPlayerPos(playerid, x, y, z);
	SetPlayerInterior(playerid, interiorid);
	SetPlayerVirtualWorld(playerid, vw);
	return 1;
}

CMD:kick(playerid,params[])
{
	new targetid, reason[50], string[128], pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName, sizeof(pName));
	if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your admin level is not high enough");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_SYNTAX, "ERROR: This player is not online!");
	if(sscanf(params,"is[50]",targetid,reason)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /kick <playerid> <reason>");
	format(string, sizeof(string), "[CnR] You have been kicked by %s(%i) for:\n %s",pName,playerid,reason);
	SendClientMessage(targetid, COLOR_RED, string);
	halt(1);
	Kick(targetid);
	return 1;
}
CMD:jetpack(playerid,params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your admin level is not high enough");
	if(sscanf(params, "i", playerid)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /jetpack <playerid>");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	return 1;
}

CMD:v(playerid, params[])
{
        new Vehicle[32], VehicleID, ColorOne, ColorTwo;
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your admin level is not high enough");
        if(sscanf(params, "s[32]D(1)D(1)", Vehicle, ColorOne, ColorTwo))
        {

            SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /v <Vehicle name/id] <Color 1 (optional)> <Color 2 (optional)>");
            return 1;
        }
       
        if(PlayerInfo[playerid][pAdmin] > 1)
        {
            VehicleID = GetVehicleModelIDFromName(Vehicle);
            if(VehicleID != 425 && VehicleID != 432 && VehicleID != 447 &&
               VehicleID != 430 && VehicleID != 417 && VehicleID != 435 &&
           VehicleID != 446 && VehicleID != 449 && VehicleID != 450 &&
               VehicleID != 452 && VehicleID != 453 && VehicleID != 454 &&
                   VehicleID != 460 && VehicleID != 464 && VehicleID != 465 &&
                   VehicleID != 469 && VehicleID != 472 && VehicleID != 473 &&
                   VehicleID != 476 && VehicleID != 484 && VehicleID != 487 &&
                   VehicleID != 488 && VehicleID != 493 && VehicleID != 497 &&
                   VehicleID != 501 && VehicleID != 511 && VehicleID != 512 &&
                   VehicleID != 513 && VehicleID != 519 && VehicleID != 520 &&
                   VehicleID != 537 && VehicleID != 538 && VehicleID != 548 &&
                   VehicleID != 553 && VehicleID != 563 && VehicleID != 564 &&
                   VehicleID != 569 && VehicleID != 570 && VehicleID != 577 &&
                   VehicleID != 584 && VehicleID != 590 && VehicleID != 591 &&
                   VehicleID != 592 && VehicleID != 593 && VehicleID != 594 &&
                   VehicleID != 595 && VehicleID != 606 && VehicleID != 607 &&
                   VehicleID != 608 && VehicleID != 610 && VehicleID != 611) {
                        if(VehicleID == -1 )
                        {
                                VehicleID = strval(Vehicle);
 
                                if(VehicleID < 400 || VehicleID > 611 )
                                {
                                        return SendClientMessage(playerid, COLOR_RED, "You entered an invalid vehiclename!");
                                }
                        }
 
                        GetPlayerPos(playerid, vehicleX, vehicleY, vehicleZ);
                        GetPlayerFacingAngle(playerid, vehicleAngle);
 

                        new vehicle = CreateVehicle(VehicleID, vehicleX, vehicleY, vehicleZ+2.0, vehicleAngle, ColorOne, ColorTwo, -1);
                        LinkVehicleToInterior(vehicle, GetPlayerInterior(playerid));
                        PutPlayerInVehicle(playerid, vehicle, 0);
                        SendClientMessage(playerid, COLOR_GREEN, "You succesfully spawned this vehicle!");
                } else {
                    SendClientMessage(playerid, COLOR_RED, "ERROR: You are not allowed to spawn this vehicle!!");
                }
        } else {
                SendClientMessage(playerid, COLOR_RED, "ERROR: You can not spawn vehicles in this zone!");
        }
        return 1;
}

CMD:vrepair(playerid,params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);
	RepairVehicle(vehicleid);
	SendClientMessage(playerid, COLOR_GREEN, "You've successfully repaired your vehicle");

	return 1;
}

CMD:vnos(playerid,params[])
{
	new vehicleid = GetPlayerVehicleID(playerid);
	if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your admin level is not high enough");
	AddVehicleComponent(vehicleid, 1010);
	return 1;
}

CMD:setalevel(playerid,params[])
{
	new targetid, targetname[MAX_PLAYER_NAME], pName[MAX_PLAYER_NAME], tmsg[144],pmsg[144], level;
	GetPlayerName(targetid, targetname,sizeof(targetname));
	GetPlayerName(playerid, pName,sizeof(pName));
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your admin level is not high enough");
	if(sscanf(params, "ii", targetid, level)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /setalevel <playerid> <level 1-5>");
	if(level > PlayerInfo[playerid][pAdmin]) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not set the player's admin level higher than your own");
	if(level < 0 || level > 5 ) return SendClientMessage(playerid, COLOR_RED, "ERROR: Invalid level <1-5>");
	PlayerInfo[targetid][pAdmin] = level;
	format(pmsg, sizeof(pmsg), "[Admin] You have set %s(%i)'s level to %i", targetname,targetid,level);
	format(tmsg, sizeof(tmsg), "[Admin] %s(%i) set your admin level to %i", pName,playerid,level);
	SendClientMessage(playerid, COLOR_GREEN, pmsg);
	SendClientMessage(targetid, COLOR_GREEN, tmsg);
	return 1;
}

CMD:giveweapon(playerid,params[])
{
	new targetid, targetname[MAX_PLAYER_NAME], pName[MAX_PLAYER_NAME], tmsg[144], pmsg[144], wepid, ammo;
	GetPlayerName(targetid, targetname, sizeof(targetname));
	GetPlayerName(playerid, pName, sizeof(pName));
	if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "ERROR: Your admin level is not high enough!");
	if(sscanf(params, "iii", targetid, wepid, ammo)) return SendClientMessage(playerid, COLOR_SYNTAX, "SYNTAX: /giveweapon <playerid> <weaponid> <ammo>");
	if(PlayerInfo[targetid][pAdmin] > PlayerInfo[playerid][pAdmin]) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can not execute commands on players with a higher level.");
	GivePlayerWeapon(playerid, wepid, ammo);
	format(pmsg, sizeof(pmsg), "[Admin] You have given %s(%i) weapon: %i with %i rounds of ammo", targetname,targetid,wepid,ammo);
	format(tmsg, sizeof(tmsg), "[Admin] %s(%i) gave you weapon: %i with %i rounds of ammo", pName, playerid, wepid, ammo);
	SendClientMessage(playerid, COLOR_GREEN, pmsg);
	SendClientMessage(targetid, COLOR_GREEN, tmsg);
	return 1;
}

halt(seconds)
{
	new _newTime[4], _oldTime[4];
	gettime(_oldTime[0], _oldTime[1], _oldTime[2]);
	_oldTime[3] = _oldTime[2] + (_oldTime[1] * 60) + (_oldTime[0] * 600);

	while(_newTime[3] != (_oldTime[3] + seconds))
	{
		gettime(_newTime[0], _newTime[1], _newTime[2]);
		_newTime[3] = _newTime[2] + (_newTime[1] * 60) + (_newTime[0] * 600);
	}
}
