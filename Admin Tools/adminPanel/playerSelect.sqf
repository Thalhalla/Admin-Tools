// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Version: 1.0
//	@file Name: playerSelect.sqf
//	@file Author: [404] Deadbeat
//	@file Created: 20/11/2012 05:19
//	@file Args:

#define playerMenuDialog 55500
#define playerMenuPlayerList 55505
#define playerMenuSpectateButton 55506
#define playerMenuWarnMessage 55509

disableSerialization;

private ["_expl1","_dummyVar","_dialog","_playerListBox","_spectateButton","_switch","_index","_modSelect","_playerData","_target","_check","_spectating","_camadm","_rnum","_warnText","_targetUID","_playerName","_fine"];
_uid = getPlayerUID player;
if (_uid call isAdmin) then
{
	_dialog = findDisplay playerMenuDialog;
	_playerListBox = _dialog displayCtrl playerMenuPlayerList;
	_spectateButton = _dialog displayCtrl playerMenuSpectateButton;
	_warnMessage = _dialog displayCtrl playerMenuWarnMessage;

	_switch = _this select 0;
	_index = lbCurSel _playerListBox;
	_playerData = _playerListBox lbData _index;

	{
		if (getPlayerUID _x == _playerData) exitWith
		{
			_target = _x;
		};
	} forEach allPlayers;

	if (isNil "_target" || {isNull _target}) exitWith{};

		switch (_switch) do
		{
			case 0: //Spectate
			{
					closeDialog 0;
					fnc_getConfig = {
					_cfg = '';
					if(isClass (configFile >> 'CfgWeapons' >> _this))then
					{
						_cfg = 'CfgWeapons';
					}
					else
					{
						if(isClass (configFile >> 'CfgMagazines' >> _this))then
						{
							_cfg = 'CfgMagazines';
						}
						else
						{
							if(isClass (configFile >> 'CfgVehicles' >> _this))then
							{
								_cfg = 'CfgVehicles';
							};
						};
					};
					_cfg
				};

				CCGLogger = ["AdminLog", format["Admin Spectating Player [Admin = %1 - %2 (Player = %3 - %4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";				

				cutText ['Spectating - Press F10 to exit.', 'PLAIN DOWN'];
				if(isNil 'SpecateLoopActive')then
				{
					SpecateLoopActive = true;
					while {!isNil 'SpecateLoopActive'} do
					{

						if(isNil '_target')then{_target = player;};

						_veh = vehicle _target;
						if(str _veh != str cameraOn)then{_veh switchCamera cameraView;for '_i' from 3025 to 3045 do {['',0,0,1,0,0,_i] spawn bis_fnc_dynamicText;};};
					
					
						_log = format['%1 (%2) @%3',name _target,getPlayerUID _target,mapGridPosition _veh];
						['<t align=''left'' size=''0.5'' color=''#238701''>'+_log+'</t>',safezoneX+0.2,safezoneY+0.405,0.3,0,0,3033] spawn bis_fnc_dynamicText;
					
						_log2 = format['Health: %1',(1-(damage _target))*100];
						['<t align=''left'' size=''0.5'' color=''#238701''>'+_log2+'</t>',safezoneX+0.2,safezoneY+0.435,0.3,0,0,3034] spawn bis_fnc_dynamicText;
					
						_cwep = '';
						_cammo = '';
						_cmags = '';
						_wpnstate = weaponState _target;
						if(!isNil '_wpnstate')then
						{
							if(str _wpnstate != '[]')then
							{
								_cwep = _wpnstate select 0;
								_cmags = {_wpnstate select 3 == _x} count magazines _target;
								_cammo = _wpnstate select 4;
							};
						};
						if(_cwep == '')then
						{
							_log3 = 'Bare Fists';
							['<t align=''left'' size=''0.5'' color=''#238701''>'+_log3+'</t>',safezoneX+0.2,safezoneY+0.465,0.3,0,0,3035] spawn bis_fnc_dynamicText;
						}
						else
						{
							_type = _cwep;
							_cfg = _type call fnc_getConfig;
							_displayName = getText (configFile >> _cfg >> _type >> 'displayName');
							_pic = getText (configFile >> _cfg >> _type >> 'picture');
						
							_log3 = format[' %1 [%2] (%3/%4)',_displayName,_cwep,_cammo,_cmags];
							['
							<img size=''0.75'' image='''+_pic+''' align=''left''/>
							<t align=''left'' size=''0.5'' color=''#238701''>'+_log3+'</t>
							',
							safezoneX+0.2,safezoneY+0.465,0.3,0,0,3035] spawn bis_fnc_dynamicText;
						
							if(_veh != _target)then
							{
								_cwepsV = [];
								{
									if(_x find 'Horn' == -1)then
									{
										_cwepsV pushBack _x;
									};
								} forEach (weapons _veh);
							
								if(count _cwepsV > 0)then
								{
									_id = 3032;
									_YPOS = safezoneY+0.355;
								
									{
										_cwep = _x;
										_cammo = _veh ammo _cwep;
										_cmags = {currentMagazine _veh == _x} count magazines _veh;
										
										_type = _cwep;
										_cfg = _type call fnc_getConfig;
										_displayName = getText (configFile >> _cfg >> _type >> 'displayName');
									
										_log3a = format[' %1 [%2] (%3/%4)',_displayName,_cwep,_cammo,_cmags];
										['<t align=''left'' size=''0.5'' color=''#A90F68''>'+_log3a+'</t>',safezoneX+0.2,_YPOS,0.3,0,0,_id] spawn bis_fnc_dynamicText;
									
										_id = _id - 1;
										_YPOS = _YPOS - 0.03;
									} forEach _cwepsV;
								};
							};
						};

						_ct = cursorTarget;
						if(!isNull _ct)then
						{
							if(getPlayerUID _ct != '')then
							{
								_cwep_ct = currentWeapon _ct;
								_cammo_ct = _ct ammo _cwep_ct;
								_cmags_ct = {currentMagazine _ct == _x} count magazines _ct;
							
								_log4 = format['%1 (%2) @%3',name _ct,getPlayerUID _ct,mapGridPosition _ct];
								['<t align=''left'' size=''0.5'' color=''#B80B36''>'+_log4+'</t>',safezoneX+0.2,safezoneY+0.545,0.3,0,0,3036] spawn bis_fnc_dynamicText;
								
								_log5 = format['Health: %1  Distance: %2m',(1-(damage _ct))*100,round(cameraOn distance _ct)];
								['<t align=''left'' size=''0.5'' color=''#B80B36''>'+_log5+'</t>',safezoneX+0.2,safezoneY+0.575,0.3,0,0,3037] spawn bis_fnc_dynamicText;
							
								_type = _cwep_ct;
								_cfg = _type call fnc_getConfig;
								_displayName = getText (configFile >> _cfg >> _type >> 'displayName');
								_pic = getText (configFile >> _cfg >> _type >> 'picture');
								_log6 = format[' %1 [%2] (%3/%4)',_displayName,_cwep_ct,_cammo_ct,_cmags_ct];
								['
								<img size=''0.75'' image='''+_pic+''' align=''left''/>
								<t align=''left'' size=''0.5'' color=''#B80B36''>'+_log6+'</t>
								',
								safezoneX+0.2,safezoneY+0.605,0.3,0,0,3038] spawn bis_fnc_dynamicText;
							}
							else
							{
								_type = typeOf _ct;
								_cfg = _type call fnc_getConfig;
								_displayName = getText (configFile >> _cfg >> _type >> 'displayName');
								_log4 = format['%1 [%2] @%3',_displayName,_type,mapGridPosition _ct];
								['<t align=''left'' size=''0.5'' color=''#B80B36''>'+_log4+'</t>',safezoneX+0.2,safezoneY+0.545,0.3,0,0,3036] spawn bis_fnc_dynamicText;
							
								_log5 = format['Health: %1 - Distance: %2m',(1-(damage _ct))*100,round(cameraOn distance _ct)];
								['<t align=''left'' size=''0.5'' color=''#B80B36''>'+_log5+'</t>',safezoneX+0.2,safezoneY+0.575,0.3,0,0,3037] spawn bis_fnc_dynamicText;
							
								['',0,0,1,0,0,3038] spawn bis_fnc_dynamicText;
							};
						
							_vehCT = vehicle _ct;
							if((_vehCT isKindOf 'LandVehicle') || (_vehCT isKindOf 'Air') || (_vehCT isKindOf 'Ship') || (_vehCT isKindOf 'Static'))then
							{
								_cwepsV = [];
								{
									if(_x find 'Horn' == -1)then
									{
										_cwepsV pushBack _x;
									};
								} forEach (weapons _vehCT);
							
								if(count _cwepsV > 0)then
								{
									_id = 3039;
									_YPOS = safezoneY+0.655;
								
									{
										_cwep = _x;
										_cammo = _vehCT ammo _cwep;
										_cmags = {currentMagazine _vehCT == _x} count magazines _vehCT;
									
										_type = _cwep;
										_cfg = _type call fnc_getConfig;
										_displayName = getText (configFile >> _cfg >> _type >> 'displayName');
									
										_log6a = format[' %1 [%2] (%3/%4)',_displayName,_cwep,_cammo,_cmags];
										['<t align=''left'' size=''0.5'' color=''#A90F68''>'+_log6a+'</t>',safezoneX+0.2,_YPOS,0.3,0,0,_id] spawn bis_fnc_dynamicText;
									
										_id = _id + 1;
										_YPOS = _YPOS + 0.03;
									} forEach _cwepsV;
								};
							};
						};
					
					if(isNil 'SpecateLoopActive')exitWith{};
					uiSleep 0.2;
					if(isNil 'SpecateLoopActive')exitWith{};
					};
					(vehicle player) switchCamera cameraView;
					for '_i' from 3025 to 3045 do {['',0,0,1,0,0,_i] spawn bis_fnc_dynamicText;};
					cutText ['Finished spectating.', 'PLAIN DOWN'];
					CCGLogger = ["AdminLog", format["Admin Stopped Spectating Player [Admin = %1 - %2 (Player = %3 - %4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
					publicVariableServer "CCGLogger";
				};
			};
			case 1: //Warn
			{
				_warnText = ctrlText _warnMessage;
				_playerName = name player;
				[format ["Message from Admin: %1", _warnText], "A3W_fnc_titleTextMessage", _target, false] call A3W_fnc_MP;
				CCGLogger = ["AdminLog", format["Message from Admin [Admin = %1 - %2 (Player = %3 - %4) - %5)]", name player, getPlayerUID player, name _target, getPlayerUID _target, _warnText]];
				publicVariableServer "CCGLogger";
			};
			case 2: //Slay
			{
				if (damage _target < 1) then // if check required to prevent "Killed" EH from getting triggered twice
				{
					_target setVariable ["A3W_deathCause_remote", ["forcekill",serverTime], true];
					_target setDamage 1;
				};
				CCGLogger = ["AdminLog", format["Admin Slayed Player [Admin = %1 - %2 (Player = %3 - %4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";
			};
			case 3: //Unlock Team Switcher
			{
				pvar_teamSwitchUnlock = getPlayerUID _target;
				publicVariableServer "pvar_teamSwitchUnlock";
				CCGLogger = ["AdminLog", format["Admin PlayerMgmt_UnlockTeamSwitch [Admin = %1 - %2 (Player = %2 - %3)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";
			};
			case 4: //Unlock Team Killer
			{
				pvar_teamKillUnlock = getPlayerUID _target;
				publicVariableServer "pvar_teamKillUnlock";
				CCGLogger = ["AdminLog", format["Admin PlayerMgmt_UnlockTeamKill [Admin = %1 - %2 (Player= %3 - %4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";
			};
			case 5: //Remove All Money
			{
				_targetUID = getPlayerUID _target;
				{
					if(getPlayerUID _x == _targetUID) exitWith
					{
						_x setVariable["cmoney",0,true];
					};
				}forEach playableUnits;
				CCGLogger = ["AdminLog", format["Removed all Money from player by [Admin = %1 - %2 (Player= %3 - %4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";
			};
			case 6: //Remove 10K
			{
				_targetUID = getPlayerUID _target;
				{
					if(getPlayerUID _x == _targetUID) exitWith
					{
						_fine = 10000;
						_playerMoney = _x getVariable ["cmoney", 0];
						//_x getVariable ["cmoney", 0];
						//_x setVariable["cmoney",0,true];
						_x setVariable ["cmoney", _playerMoney - _fine, true];
					};
				}forEach playableUnits;
				CCGLogger = ["AdminLog", format["Removed 10k from player by [Admin = %1 - %2 (Player= %3 - %4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";
			};
			case 7: //Eject Player from a vehicle
			{
				doGetOut _target;
				CCGLogger = ["AdminLog", format["Admin Ejected Player from a vehicle [Admin = %1 - %2 (Player= %3 - %4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";
			};
			case 8: //TP to player
			{
				vehicle player setPosASL (getPosASL _target);	
				hint format ["You TP'd to %1", name _target];
				_gridPos = mapGridPosition getPos _target;
				CCGLogger = ["AdminLog", format["Admin[%1 (%2) TP'd to player %3 (%4) at GPS Position %5]", name player, getPlayerUID player, name _target, getPlayerUID _target, _gridPos]];
				publicVariableServer "CCGLogger";
				closeDialog 0;											
			};
			case 9: //TP to Admin
			{
				vehicle _target setPosASL (getPosASL player);
				hint format ["TP player %1 to Admin", name _target];
				_gridPos = mapGridPosition getPos player;
				CCGLogger = ["AdminLog", format["Player [%1 (%2) TP'd to admin %3 (%4) at GPS Position %5]", name _target, getPlayerUID _target, name player, getPlayerUID player, _gridPos]];
				publicVariableServer "CCGLogger";
				closeDialog 0;									
			};	
			case 10: //Heal target
			{
				_target setDamage 0;
				hint format ["Healing target player %1", name _target];
				CCGLogger = ["AdminLog", format["Admin [%1 (%2) Healed player %3 (%4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";
				closeDialog 0;									
			};
			case 11: //kick target
			{
				CCGLogger = ["AdminLog", format["Admin [%1 (%2) Kicked player %3 (%4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";
				_dummyVar = "A3W_fnc_antihackLog_" + str floor random 1e6;
				missionNamespace setVariable [_dummyVar, getPlayerUID _target];
				publicVariableServer _dummyVar;
				closeDialog 0;									
			};
			case 12: //Cock Head
			{
				_expl1 = "Cock_random_F" createVehicle position _target; _expl1 attachTo [_target, [-0.1, 0.1, 0.15], "Head"]; _expl1 setVectorDirAndUp [ [0.5, 0.5, 0], [-0.5, 0.5, 0] ];
				CCGLogger = ["AdminLog", format["Admin [%1 (%2) attached a Cock to a players head !! %3 (%4)]", name player, getPlayerUID player, name _target, getPlayerUID _target]];
				publicVariableServer "CCGLogger";
				closeDialog 0;				
			};			
		};
};


