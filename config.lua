config = {}
config.wardrobe = 'illenium-appearance' -- choose your skin menu
config.target = true                    -- false = markers zones type. true = ox_target, qb-target
config.business = false                 -- allowed players to purchase the motel
config.autokickIfExpire = true          -- auto kick occupants if rent is due. if false owner of motel must kick the occupants
config.breakinJobs = {                  -- jobs can break in to door using gunfire in doors
	['police'] = true,
	--[[ 	['lspd'] = true,
	['sasp'] = true,
	['bcso'] = true,
	['sapr'] = true, ]]
}
config.wardrobes = { -- skin menus
	['renzu_clothes'] = function()
		exports.renzu_clothes:OpenClotheInventory()
	end,
	['fivem-appearance'] = function()
		return exports['fivem-appearance']:startPlayerCustomization() -- you could replace this with outfits events
	end,
	['illenium-appearance'] = function()
		return TriggerEvent('illenium-appearance:client:openOutfitMenu')
	end,
	['qb-clothing'] = function()
		return TriggerEvent('qb-clothing:client:openOutfitMenu')
	end,
	['esx_skin'] = function()
		TriggerEvent('esx_skin:openSaveableMenu')
	end,
}

-- Shells Offsets and model name
config.shells = {
	['standard'] = {
		shell = `standardmotel_shell`, -- kambi shell
		offsets = {
			exit = vec3(-0.43, -2.51, 1.16),
			stash = vec3(1.368164, -3.134506, 1.16),
			wardrobe = vec3(1.643646, 2.551102, 1.16),
		}
	},
	['modern'] = {
		shell = `modernhotel_shell`, -- kambi shell
		offsets = {
			exit = vec3(5.410095, 4.299301, 0.9),
			stash = vec3(-4.068207, 4.046188, 0.9),
			wardrobe = vec3(2.811829, -3.619385, 0.9),
		}
	},
}

config.messageApi = function(data) -- {title,message,motel}
	local motel = GlobalState.Motels[data.motel]
	local identifier = motel.owned -- owner identifier
	-- add your custom message here. ex. SMS phone

	-- basic notification (remove this if using your own message system)
	local success = lib.callback.await('renzu_motels:MessageOwner', false,
		{ identifier = identifier, message = data.message, title = data.title, motel = data.motel })
	if success then
		Notify('message has been sent', 'success')
	else
		Notify('message fail  \n  owner is not available yet', 'error')
	end
end

-- @shell string (shell type)
-- @Mlo string ( toggle MLO or shell type)
-- @hour_rate int ( per hour rates)
-- @motel string (Motel Index Name)
-- @rentcoord vec3 (coordinates of Rental Menu)
-- @radius float ( total size radius of motel )
-- @maxoccupants int (total player can rent in each Rooms)
-- @uniquestash bool ( Toggle Non Sharable / Stealable Stash Storage )
-- @doors table ( lists of doors feature coordinates. ex. stash, wardrobe) wardrobe,stash coords are only applicable in Mlo. using shells has offsets for stash and wardrobes.
-- @manual boolean ( accept walk in occupants only )
-- @businessprice int ( value of motel)
-- @door int (door hash or doormodel `model`) for MLO type

config.motels = {
	[1] = {              -- index name of motel
		manual = false,  -- set the motel to auto accept occupants or false only the owner of motel can accept Occupants
		Mlo = false,     -- if MLO you need to configure each doors coordinates,stash etc. if false resource will use shells
		shell = 'standard', -- shell type, configure only if using Mlo = true
		label = 'Motel Pink Cage',
		rental_period = 'day', -- hour, day, month
		rate = 120,      -- cost per period
		businessprice = 1000000,
		motel = 'pinkcage',
		payment = 'money',                                           -- money, bank
		door = `gabz_pinkcage_doors_front`,                          -- door hash for MLO type
		rentcoord = vec3(313.38, -225.20, 54.212),
		coord = vec3(326.04, -210.47, 54.086),                       -- center of the motel location
		radius = 50.0,                                               -- radius of motel location
		maxoccupants = 1,                                            -- maximum renters per room
		uniquestash = false,                                         -- if true. each players has unique stash ID (non sharable and non stealable). if false stash is shared to all Occupants if maxoccupans is > 1
		doors = {                                                    -- doors and other function of each rooms
			[1] = {                                                  -- COORDINATES FOR GABZ PINKCAGE
				door = vec3(307.21499633789, -212.79479980469, 54.420265197754), -- Door requires when using MLO/Shells
				--[[ 				stash = vec3(307.01657104492, -207.91079711914, 53.758548736572), --  requires when using MLO
				wardrobe = vec3(302.58380126953, -207.71691894531, 54.598297119141), --  requires when using MLO
				fridge = vec3(305.00064086914, -206.12855529785, 54.544868469238), --  requires when using MLO
				-- luckyme = vec3(0.0,0.0,0.0) -- extra ]]
			},
			[2] = {
				door = vec3(310.95474243164, -202.91288757324, 54.421058654785),
				--[[ 				stash = vec3(310.91235351563, -198.10073852539, 53.758598327637),
				wardrobe = vec3(306.25433349609, -197.75250244141, 54.564342498779),
				fridge = vec3(308.79779052734, -196.23670959473, 54.440326690674), ]]
			},
			[3] = {
				door = vec3(316.28607177734, -194.54536437988, 54.391784667969),
				--[[ 				stash = vec3(321.10150146484, -194.42211914063, 53.758399963379),
				wardrobe = vec3(321.42459106445, -189.79216003418, 54.65941619873),
				fridge = vec3(322.92010498047, -192.31481933594, 54.600353240967), ]]
			},
			[4] = {
				door = vec3(314.36087036133, -219.91516113281, 58.151386260986),
				--[[ 				stash = vec3(309.6142578125, -220.16128540039, 57.557399749756),
				wardrobe = vec3(309.21203613281, -224.6675567627, 58.375194549561),
				fridge = vec3(307.6989440918, -222.11755371094, 58.293560028076), ]]
			},
			[5] = {
				door = vec3(307.22616577148, -212.77645874023, 58.204700469971),
				--[[ 				stash = vec3(306.89093017578, -207.88090515137, 57.556159973145),
				wardrobe = vec3(302.57464599609, -207.71339416504, 58.440250396729),
				fridge = vec3(305.044921875, -205.99066162109, 58.394989013672), ]]
			},
			[6] = {
				door = vec3(311.00057983398, -202.87718200684, 58.148029327393),
				--[[ 				stash = vec3(310.88967895508, -198.16856384277, 57.556510925293),
				wardrobe = vec3(306.09225463867, -198.40795898438, 58.27188873291),
				fridge = vec3(308.73110961914, -196.40968322754, 58.407859802246), ]]
			},
			[7] = {
				door = vec3(316.29287719727, -194.5479888916, 58.212650299072),
				--[[ 				stash = vec3(321.24801635742, -194.29737854004, 57.556739807129),
				wardrobe = vec3(321.46688842773, -189.68632507324, 58.422557830811),
				fridge = vec3(322.98544311523, -192.33996582031, 58.386581420898), ]]
			},
			[8] = {
				door = vec3(339.43377685547, -219.99412536621, 54.431659698486),
				--[[ 				stash = vec3(339.67279052734, -224.8221282959, 53.759098052979),
				wardrobe = vec3(344.28637695313, -224.95460510254, 54.527130126953),
				fridge = vec3(341.86477661133, -226.15287780762, 54.642837524414), ]]
			},
			[9] = {
				door = vec3(343.23126220703, -210.10203552246, 54.410026550293),
				--[[ 				stash = vec3(343.47601318359, -214.96635437012, 53.758640289307),
				wardrobe = vec3(347.99655151367, -215.08934020996, 54.489669799805),
				fridge = vec3(345.53387451172, -216.53938293457, 54.698444366455), ]]
			},
			[10] = {
				door = vec3(347.0237121582, -200.22482299805, 54.414268493652),
				--[[ 				stash = vec3(347.33102416992, -205.13743591309, 53.759078979492),
				wardrobe = vec3(351.68756103516, -205.30010986328, 54.674419403076),
				fridge = vec3(349.34033203125, -206.6258392334, 54.639694213867), ]]
			},
			[11] = {
				door = vec3(334.44702148438, -227.61134338379, 58.205139160156),
				--[[ 				stash = vec3(329.67590332031, -227.8233795166, 57.556579589844),
				wardrobe = vec3(329.43222045898, -232.33073425293, 58.42276763916),
				fridge = vec3(327.64138793945, -229.79788208008, 58.355628967285), ]]
			},
			[12] = {
				door = vec3(339.44650268555, -219.9709777832, 58.177570343018),
				--[[ 				stash = vec3(339.79351806641, -224.86245727539, 57.55553817749),
				wardrobe = vec3(344.26574707031, -225.00813293457, 58.302909851074),
				fridge = vec3(341.6985168457, -226.52975463867, 58.367748260498), ]]
			},
			[13] = {
				door = vec3(343.22320556641, -210.1229095459, 58.176639556885),
				--[[ 				stash = vec3(343.47412109375, -214.96145629883, 57.55553817749),
				wardrobe = vec3(348.07550048828, -215.08416748047, 58.288040161133),
				fridge = vec3(345.40502929688, -216.88189697266, 58.281555175781), ]]
			},
			[14] = {
				door = vec3(347.03012084961, -200.20816040039, 58.177433013916),
				--[[ 				stash = vec3(347.12841796875, -205.05494689941, 57.55553817749),
				wardrobe = vec3(351.77719116211, -205.24267578125, 58.351734161377),
				fridge = vec3(349.24819946289, -206.78134155273, 58.326892852783), ]]
			},

		},
	},

	[2] = {              -- index name of motel
		manual = false,  -- set the motel to auto accept occupants or false only the owner of motel can accept Occupants
		Mlo = false,     -- if MLO you need to configure each doors coordinates,stash etc. if false resource will use shells
		shell = 'standard', -- shell type, configure only if using Mlo = true
		label = 'Bilingsgate Motel',
		rental_period = 'day', -- hour, day, month
		rate = 120,      -- cost per period
		businessprice = 1000000,
		motel = 'bilingsgate',
		payment = 'money', -- money, bank
		--door = `gabz_pinkcage_doors_front`, -- door hash for MLO type
		rentcoord = vec3(569.81, -1746.47, 29.21),
		coord = vec3(565.35, -1765.13, 29.16), -- center of the motel location
		radius = 50.0,                    -- radius of motel location
		maxoccupants = 1,                 -- maximum renters per room
		uniquestash = false,              -- if true. each players has unique stash ID (non sharable and non stealable). if false stash is shared to all Occupants if maxoccupans is > 1
		doors = {                         -- doors and other function of each rooms
			[1] = {                       -- COORDINATES FOR GABZ PINKCAGE
				door = vec3(566.22, -1778.18, 29.35), -- Door requires when using MLO/Shells

			},
			[2] = {
				door = vec3(550.43, -1775.49, 29.31),

			},
			[3] = {
				door = vec3(552.25, -1771.56, 29.31),

			},
			[4] = {
				door = vec3(554.69, -1766.34, 29.31),

			},
			[5] = {
				door = vec3(557.79, -1759.72, 29.31),

			},
			[6] = {
				door = vec3(561.45, -1751.87, 29.28),

			},
			[7] = {
				door = vec3(560.33, -1776.54, 33.44),

			},
			[8] = {
				door = vec3(559.05, -1777.24, 33.44),

			},
			--[[ 			[9] = {
				door = vec3(550.09, -1773.05, 33.44),

			}, ]]
			[9] = {
				door = vec3(550.14, -1770.58, 33.44),

			},
			[10] = {
				door = vec3(552.55, -1765.31, 33.44),

			},
			[11] = {
				door = vec3(555.60, -1758.74, 33.44),

			},
			--[[ 			[13] = {
				door = vec3(343.22320556641,-210.1229095459,58.176639556885),

			}, ]]
			[12] = {
				door = vec3(555.60, -1758.74, 33.44),

			},
			[13] = {
				door = vec3(561.79, -1747.39, 33.44),

			},

		},
	},

	[3] = {              -- index name of motel
		manual = false,  -- set the motel to auto accept occupants or false only the owner of motel can accept Occupants
		Mlo = false,     -- if MLO you need to configure each doors coordinates,stash etc. if false resource will use shells
		shell = 'standard', -- shell type, configure only if using Mlo = true
		label = 'Perrera Beach Motel',
		rental_period = 'day', -- hour, day, month
		rate = 120,      -- cost per period
		businessprice = 1000000,
		motel = 'perrera',
		payment = 'money', -- money, bank
		--door = `gabz_pinkcage_doors_front`, -- door hash for MLO type
		rentcoord = vec3(-1477.14, -674.39, 29.04),
		coord = vec3(-1470.57, -659.14, 29.31), -- center of the motel location
		radius = 50.0,                     -- radius of motel location
		maxoccupants = 1,                  -- maximum renters per room
		uniquestash = false,               -- if true. each players has unique stash ID (non sharable and non stealable). if false stash is shared to all Occupants if maxoccupans is > 1
		doors = {                          -- doors and other function of each rooms
			[1] = {                        -- COORDINATES FOR GABZ PINKCAGE
				door = vec3(-1493.67, -668.31, 29.03), -- Door requires when using MLO/Shells

			},
			[2] = {
				door = vec3(-1498.12, -664.65, 29.03),

			},
			[3] = {
				door = vec3(-1495.29, -661.63, 29.03),

			},
			[4] = {
				door = vec3(-1490.71, -658.31, 29.03),

			},
			[5] = {
				door = vec3(-1486.73, -655.42, 29.58),

			},
			[6] = {
				door = vec3(-1482.17, -652.09, 29.58),

			},
			[7] = {
				door = vec3(-1478.20, -649.20, 29.58),

			},
			[8] = {
				door = vec3(-1473.65, -645.87, 29.58),

			},
			[9] = {
				door = vec3(-1469.63, -642.94, 29.58),

			},
			[10] = {
				door = vec3(-1465.05, -639.67, 29.58),

			},
			[11] = {
				door = vec3(-1461.32, -640.87, 29.58),

			},
			[12] = {
				door = vec3(-1452.47, -653.20, 29.58),

			},
			[13] = {
				door = vec3(-1454.50, -655.96, 29.58),
			},
			[14] = {
				door = vec3(-1459.01, -659.32, 29.58),
			},
			[15] = {
				door = vec3(-1462.92, -662.10, 29.58),
			},
			[16] = {
				door = vec3(-1467.56, -665.46, 29.58),
			},
			[17] = {
				door = vec3(-1471.49, -668.40, 29.58),
			},
			[18] = {
				door = vec3(-1461.33, -640.85, 33.38),
			},
			[19] = {
				door = vec3(-1457.95, -645.44, 33.38),
			},
			[20] = {
				door = vec3(-1455.70, -648.61, 33.38),
			},
			[21] = {
				door = vec3(-1452.32, -653.24, 33.38),
			},
			[22] = {
				door = vec3(-1454.34, -655.85, 33.38),
			},
			[23] = {
				door = vec3(-1459.01, -659.31, 33.38),
			},
			[24] = {
				door = vec3(-1462.99, -662.13, 33.38),
			},
			[25] = {
				door = vec3(-1467.55, -665.48, 33.38),
			},
			[26] = {
				door = vec3(-1471.50, -668.30, 33.38),
			},
			[27] = {
				door = vec3(-1476.04, -671.69, 33.38),
			},
			[28] = {
				door = vec3(-1465.02, -639.65, 33.38),
			},
			[29] = {
				door = vec3(-1469.66, -642.96, 33.38),
			},
			[30] = {
				door = vec3(-1473.59, -645.87, 33.38),
			},
			[31] = {
				door = vec3(-1478.22, -649.17, 33.38),
			},
			[32] = {
				door = vec3(-1482.19, -652.06, 33.38),
			},
			[33] = {
				door = vec3(-1486.73, -655.42, 33.38),
			},
			[34] = {
				door = vec3(-1490.72, -658.29, 33.38),
			},
			[35] = {
				door = vec3(-1495.37, -661.64, 33.38),
			},
			[36] = {
				door = vec3(-1497.98, -664.67, 33.38),
			},
			[37] = {
				door = vec3(-1493.65, -668.24, 33.38),
			},
			[38] = {
				door = vec3(-1489.91, -671.35, 33.38),
			},

		},
	},


	[4] = {              -- index name of motel
		manual = false,  -- set the motel to auto accept occupants or false only the owner of motel can accept Occupants
		Mlo = false,     -- if MLO you need to configure each doors coordinates,stash etc. if false resource will use shells
		shell = 'standard', -- shell type, configure only if using Mlo = true
		label = 'The Motor Motel',
		rental_period = 'day', -- hour, day, month
		rate = 120,      -- cost per period
		businessprice = 1000000,
		motel = 'motor',
		payment = 'money', -- money, bank
		--door = `gabz_pinkcage_doors_front`, -- door hash for MLO type
		rentcoord = vec3(1142.33, 2663.98, 38.16),
		coord = vec3(1123.42, 2656.62, 38.00), -- center of the motel location
		radius = 50.0,                    -- radius of motel location
		maxoccupants = 1,                 -- maximum renters per room
		uniquestash = false,              -- if true. each players has unique stash ID (non sharable and non stealable). if false stash is shared to all Occupants if maxoccupans is > 1
		doors = {                         -- doors and other function of each rooms
			[1] = {                       -- COORDINATES FOR GABZ PINKCAGE
				door = vec3(1142.32, 2654.69, 38.15), -- Door requires when using MLO/Shells

			},
			[2] = {
				door = vec3(1142.33, 2651.17, 38.14),

			},
			[3] = {
				door = vec3(1142.31, 2643.59, 38.14),

			},
			[4] = {
				door = vec3(1141.21, 2641.74, 38.14),

			},
			[5] = {
				door = vec3(1136.45, 2641.74, 38.14),

			},
			[6] = {
				door = vec3(1132.84, 2641.74, 38.14),

			},
			[7] = {
				door = vec3(1125.33, 2641.74, 38.14),

			},
			[8] = {
				door = vec3(1121.55, 2641.74, 38.14),

			},
			[9] = {
				door = vec3(1114.69, 2641.74, 38.14),

			},
			[10] = {
				door = vec3(1107.37, 2641.74, 38.14),

			},
			[11] = {
				door = vec3(1106.11, 2648.98, 38.14),

			},
			[12] = {
				door = vec3(1106.11, 2652.76, 38.14),

			},


		},
	},

	--[[  [2] = { -- index name of motel
		manual = false, -- set the motel to auto accept occupants or false only the owner of motel can accept Occupants
		Mlo = true, -- if MLO you need to configure each doors coordinates,stash etc. if false resource will use shells
		shell = 'modern', -- shell type, configure only if using Mlo = true
		label = 'Yacht Club Motel',
		rental_period = 'day',-- hour, day, month
		payment = 'money', -- money, bank
		rate = 1000, -- cost per period
		motel = 'yacht',
		door = `gabz_pinkcage_doors_front`, -- door hash for MLO type
		businessprice = 1000000,
		rentcoord = vec3(-916.54,-1302.56,6.2001),
		coord = vec3(-916.54,-1302.56,6.2001), -- center of the motel location
		radius = 50.0, -- radius of motel location
		maxoccupants = 5, -- maximum renters per room
		uniquestash = true, -- if true. each players has unique stash ID (non sharable and non stealable). if false stash is shared to all Occupants if maxoccupans is > 1
		doors = { -- doors and other function of each rooms
			[1] = {
				door = vec3(-936.25,-1311.38,6.20),
				stash = vec3(-944.08,-1317.83,6.19),
				wardrobe = vec3(-941.21,-1324.9,6.19),
				--fridge = vec3(305.26,-206.43,54.22),
				-- luckyme = vec3(0.0,0.0,0.0) -- extra shit
			},
		},
	}, ]]



	--[[ [3] = { -- index name of motel
		businessprice = 1000000,
		manual = false, -- set the motel to auto accept occupants or false only the owner of motel can accept Occupants
		Mlo = false, -- if MLO you need to configure each doors coordinates,stash etc. if false resource will use shells
		shell = 'modern', -- shell type, configure only if using Mlo = true
		label = 'Motel Modern', -- hotel label
		rental_period = 'day',-- hour, day, month
		payment = 'money', -- money, bank
		rate = 1000, -- cost per period
		door = `gabz_pinkcage_doors_front`, -- door hash for MLO type
		motel = 'hotelmodern3', -- hotel index name
		rentcoord = vec3(514.55, 231.21, 104.91),
		coord = vec3(505.55709838867,213.49201965332,102.89), -- center of the motel location
		radius = 50.0, -- radius of motel location
		maxoccupants = 5, -- maximum renters per room
		uniquestash = true, -- if true. each players has unique stash ID (non sharable and non stealable). if false stash is shared to all Occupants if maxoccupans is > 1
		doors = { -- doors and other function of each rooms
			[1] = {
				door = vec3(496.90872192383,237.74664306641,105.28434753418),
				-- stash = vec3(-944.08,-1317.83,6.19),
				-- wardrobe = vec3(-941.21,-1324.9,6.19),
				--fridge = vec3(305.26,-206.43,54.22),
				-- luckyme = vec3(0.0,0.0,0.0) -- extra shit
			},
		},
	}  ]]
}
config.extrafunction = {
	['bed'] = function(data, identifier)
		TriggerEvent('luckyme')
	end,
	['fridge'] = function(data, identifier)
		TriggerEvent('ox_inventory:openInventory', 'stash',
			{
				id = 'fridge_' .. data.motel .. '_' .. identifier .. '_' .. data.index,
				name = 'Fridge',
				slots = 30,
				weight = 20000,
				coords =
					GetEntityCoords(cache.ped)
			})
	end,
	['exit'] = function(data)
		local coord = LocalPlayer.state.lastloc or vec3(data.coord.x, data.coord.y, data.coord.z)
		DoScreenFadeOut(500)
		while not IsScreenFadedOut() do
			Wait(10)
		end
		SendNUIMessage({
			type = 'door'
		})
		return Teleport(coord.x, coord.y, coord.z, 0.0, true)
	end,
}

config.Text = {
	['stash'] = 'Baú',
	['fridge'] = 'O Meu Frigorífico',
	['wardrobe'] = 'Roupeiro',
	['bed'] = 'Dormir',
	['door'] = 'Porta',
	['exit'] = 'Sair',
}

config.icons = {
	['door'] = 'fas fa-door-open',
	['stash'] = 'fas fa-box',
	['wardrobe'] = 'fas fa-tshirt',
	['fridge'] = 'fas fa-ice-cream',
	['bed'] = 'fas fa-bed',
	['exit'] = 'fas fa-door-open',
}

config.stashblacklist = {
	['stash'] = { -- type of inventory
		blacklist = { -- list of blacklists items
			water = true,
		},
	},
	['fridge'] = { -- type of inventory
		blacklist = { -- list of blacklists items
			WEAPON_PISTOL = true,
		},
	},
}

PlayerData, ESX, QBCORE, zones, shelzones, blips = {}, nil, nil, {}, {}, {}

function import(file)
	local name = ('%s.lua'):format(file)
	local content = LoadResourceFile(GetCurrentResourceName(), name)
	local f, err = load(content)
	return f()
end

if GetResourceState('es_extended') == 'started' then
	ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
	QBCORE = exports['qb-core']:GetCoreObject()
end
