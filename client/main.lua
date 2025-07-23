local kvpname = GetCurrentServerEndpoint()..'_inshells'

CreateBlips = function()
	for k,v in pairs(config.motels) do
		local blip = AddBlipForCoord(v.rentcoord.x,v.rentcoord.y,v.rentcoord.z)
		SetBlipSprite(blip,475)
		SetBlipColour(blip,2)
		SetBlipAsShortRange(blip,true)
		SetBlipScale(blip,0.6)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(v.label) 
		EndTextCommandSetBlipName(blip)
	end
end

RegisterNetEvent('renzu_motels:invoice')
AddEventHandler('renzu_motels:invoice', function(data)
	local motels = GlobalState.Motels
    local buy = lib.alertDialog({
		header = 'Fatura',
		content = '![motel](nui://renzu_motels/data/image/'..data.motel..'.png) \n ## INFORMAÇÃO \n **Descrição:** '..data.description..'  \n  **Valor:** $ '..data.amount..'  \n **Método de Pagamento:** '..data.payment,
		centered = true,
		labels = {
			cancel = 'fechar',
			confirm = 'Pagar'
		},
		cancel = true
	})
	if buy ~= 'cancel' then
		local success = lib.callback.await('renzu_motels:payinvoice',false,data)
		if success then
			Notify('Pagaste a fatura com sucesso','success')
		else
			Notify('Falha ao pagar a fatura','error')
		end
	end
end)

DoesPlayerHaveAccess = function(data)
    for identifier, _ in pairs(data) do
        if identifier == PlayerData?.identifier then return true end
    end
    return false
end

DoesPlayerHaveKey = function(data, room)
    local items = GetInventoryItems('keys')
    if not items then return false end
    for k, v in pairs(items) do
        if v.metadata?.type == data.motel and v.metadata?.serial == data.index then
            return v.metadata?.owner and room?.players[v.metadata?.owner] or false
        end
    end
    return false
end

GetPlayerKeys = function(data,room)
	local items = GetInventoryItems('keys')
	if not items then return false end
	local keys = {}
	for k,v in pairs(items) do
		if v.metadata?.type == data.motel and v.metadata?.serial == data.index then
			local key = v.metadata?.owner and room?.players[v.metadata?.owner]
			if key then
				keys[v.metadata.owner] = key.name
			end
		end
	end
	return keys
end

SetDoorState = function(data)
	local motels = GlobalState.Motels or {}
	local doorindex = data.index + (joaat(data.motel))
	DoorSystemSetDoorState(doorindex, 1)
end

RegisterNetEvent('renzu_motels:Door', function(data)
	if not data.Mlo then return end
	local doorindex = data.index + (joaat(data.motel))
	DoorSystemSetDoorState(doorindex, DoorSystemGetDoorState(doorindex) == 0 and 1 or 0, false, false)
end)

Door = function(data)
    local dist = #(data.coord - GetEntityCoords(cache.ped)) < 2
    local motel = GlobalState.Motels[data.motel]
	local moteldoor = motel and motel.rooms[data.index]
    if (moteldoor and (DoesPlayerHaveAccess(moteldoor.players) or DoesPlayerHaveKey(data, moteldoor))) or IsOwnerOrEmployee(data.motel) then
		lib.RequestAnimDict('mp_doorbell')
		TaskPlayAnim(PlayerPedId(), "mp_doorbell", "open_door", 1.0, 1.0, 1000, 1, 1, 0, 0, 0)
        TriggerServerEvent('renzu_motels:Door', {
            motel = data.motel,
            index = data.index,
            coord = data.coord,
			Mlo = data.Mlo,
        })
		local text
		if data.Mlo then
			local doorindex = data.index + (joaat(data.motel))
			text = DoorSystemGetDoorState(doorindex) == 0 and 'Trancaste a porta do motel' or 'Destrancaste a porta do motel'
		else
			text = not moteldoor?.lock and 'Trancaste a porta do motel' or 'Destrancaste a porta do motel'
		end
		Wait(1000)
		--PlaySoundFromEntity(-1, "Hood_Open", cache.ped , 'Lowrider_Super_Mod_Garage_Sounds', 0, 0)
		local data = {
			file = 'door',
			volume = 0.5
		}
		SendNUIMessage({
			type = "playsound",
			content = data
		})
		Notify(text, 'inform')
	else
		Notify('Não tens acesso', 'error')
    end
end

isRentExpired = function(data)
	local motels = GlobalState.Motels[data.motel]
	local room = motels?.rooms[data.index] or {}
	local player = room?.players[PlayerData.identifier] or {}
	return player?.duration and player?.duration < GlobalState.MotelTimer
end

RoomFunction = function(data,identifier)
	if isRentExpired(data) then
		return Notify('A tua renda está em atraso.  \n  Por favor paga para teres acesso')
	end
	if data.type == 'door' then
		return Door(data)
	elseif data.type == 'stash' then
		local stashid = identifier or data.uniquestash and PlayerData.identifier or 'room'
		return OpenStash(data,stashid)
	elseif data.type == 'wardrobe' then
		return config.wardrobes[config.wardrobe]()
	elseif config.extrafunction[data.type] then
		local stashid = identifier or data.uniquestash and PlayerData.identifier or 'room'
		return config.extrafunction[data.type](data,stashid)
	end
end

LockPick = function(data)
	local success = nil
	SetTimeout(1000,function()
		repeat
		local lockpick = lib.progressBar({
			duration = 10000,
			label = 'A arrombar...',
			useWhileDead = false,
			canCancel = true,
			anim = {
				dict = 'veh@break_in@0h@p_m_one@',
				clip = 'low_force_entry_ds' 
			},
		})
		Wait(0)
		until success ~= nil
	end)
	success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'easy'})
	if lib.progressActive() then
		lib.cancelProgress()
	end
	if success then
		TriggerServerEvent('renzu_motels:Door', {
            motel = data.motel,
            index = data.index,
            coord = data.coord,
			Mlo = data.Mlo
        })
		local doorindex = data.index + (joaat(data.motel))
		Notify(DoorSystemGetDoorState(doorindex) == 0 and 'Trancaste a porta do motel' or 'Destrancaste a porta do motel', 'inform')
	end
end

Notify = function(msg,type)
	lib.notify({
		description = msg,
		type = type or 'inform'
	})
end

MyRoomMenu = function(data)
	local motels = GlobalState.Motels
	local rate = motels[data.motel].hour_rate or data.rate

	local options = {
		{
			title = 'O Meu Quarto ['..data.index..'] - Pagar renda',
			description = 'Paga a tua renda (em atraso ou adiantado) para a Porta '..data.index..' \n Duração da Renda: '..data.duration..' \n Preço: $ '..rate,
			--description = 'Paga a tua renda (em atraso ou adiantado) para a Porta '..data.index..' \n Duração da Renda: '..data.duration..' \n '..data.rental_period..' Preço: $ '..rate,
			icon = 'money-bill-wave-alt',
			onSelect = function()
				local input = lib.inputDialog('Pagar ou Depositar no motel', {
					{type = 'number', label = 'Valor a Depositar', description = '$ '..rate..' por '..data.rental_period..'  \n  Método de Pagamento: '..data.payment, icon = 'money', default = rate},
				})
				if not input then return end
				local success = lib.callback.await('renzu_motels:payrent',false,{
					payment = data.payment,
					index = data.index,
					motel = data.motel,
					amount = input[1],
					rate = rate,
					rental_period = data.rental_period
				})
				if success then
					Notify('Renda paga com sucesso', 'success')
				else
					Notify('Falha ao pagar a renda', 'error')
				end
			end,
			arrow = true,
		},
		{
			title = 'Criar Chave',
			description = 'Solicita uma chave da porta',
			icon = 'key',
			onSelect = function()
				local success = lib.callback.await('renzu_motels:motelkey',false,{
					index = data.index,
					motel = data.motel,
				})
				if success then
					Notify('Solicitaste com sucesso uma chave partilhável do motel', 'success')
				else
					Notify('Falha ao criar chave', 'error')
				end
			end,
			arrow = true,
		},
		{
			title = 'Terminar Renda',
			description = 'Termina o teu período de arrendamento',
			icon = 'ban',
			onSelect = function()
				if isRentExpired(data) then
					Notify('Falha ao terminar a renda do quarto '..data.index..'  \n  Motivo: tens dívidas por pagar','error')
					return
				end
				local End = lib.alertDialog({
					header = '## Aviso',
					content = ' Deixarás de ter acesso à porta e aos teus cofres.',
					centered = true,
					labels = {
						cancel = 'fechar',
						confirm = 'Terminar',
					},
					cancel = true
				})
				if End == 'cancel' then return end
				local success = lib.callback.await('renzu_motels:removeoccupant',false,data,data.index,PlayerData.identifier)
				if success then
					Notify('Terminaste com sucesso a tua renda do quarto '..data.index,'success')
				else
					Notify('Falha ao terminar a renda do quarto '..data.index,'error')
				end
			end,
			arrow = true,
		},
	}
	lib.registerContext({
        id = 'myroom',
		menu = 'roomlist',
        title = 'Opções do Meu Quarto de Motel',
        options = options
    })
	lib.showContext('myroom')
end

CountOccupants = function(players)
	local count = 0
	for k,v in pairs(players or {}) do
		count += 1
	end
	return count
end

RoomList = function(data)
	local motels , time = lib.callback.await('renzu_motels:getMotels',false)
	local rate = motels[data.motel].hour_rate or data.rate
	local options = {}
	--local motels = GlobalState.Motels
	for doorindex,v in ipairs(data.doors) do
		local playerroom = motels[data.motel].rooms[doorindex].players[PlayerData.identifier]
		local duration = playerroom?.duration
		local occupants = CountOccupants(motels[data.motel].rooms[doorindex].players)
		if occupants < data.maxoccupants and not duration then
			table.insert(options,{
				title = 'Alugar Quarto de Motel #'..doorindex,
				description = 'Escolhe o quarto #'..doorindex..' \n Ocupantes: '..occupants..'/'..data.maxoccupants,
				icon = 'door-closed',
				onSelect = function()
					local input = lib.inputDialog('Duração do Aluguer', {
						{type = 'number', label = 'Seleciona uma duração em '..data.rental_period..'s', description = '$ '..rate..' por '..data.rental_period..'   \n   Método de Pagamento: '..data.payment, icon = 'clock', default = 1},
					})
					if not input then return end
					local success = lib.callback.await('renzu_motels:rentaroom',false,{
						index = doorindex,
						motel = data.motel,
						duration = input[1],
						rate = rate,
						rental_period = data.rental_period,
						payment = data.payment,
						uniquestash = data.uniquestash
					})
					if success then
						Notify('Alugaste o quarto com sucesso', 'success')
					else
						Notify('Falha ao alugar o quarto', 'error')
					end
				end,
				arrow = true,
			})
		elseif duration then
			local hour = math.floor((duration - time) / 3600)
			local duration_left = hour .. ' Horas : '..math.floor(((duration - time) / 60) - (60 * hour))..' Minutos'
			table.insert(options,{
				title = 'Porta do Meu Quarto #'..doorindex..' Opções',
				description = 'Paga a tua renda ou pede uma chave do motel',
				icon = 'cog',
				onSelect = function()
					return MyRoomMenu({
						payment = data.payment,
						index = doorindex,
						motel = data.motel,
						duration = duration_left,
						rate = rate,
						rental_period = data.rental_period
					})
				end,
				arrow = true,
			})
		end
	end
    lib.registerContext({
        id = 'roomlist',
		menu = 'rentmenu',
        title = 'Escolhe um Quarto',
        options = options
    })
	lib.showContext('roomlist')
end

IsOwnerOrEmployee = function(motel)
	local motels = GlobalState.Motels
	return motels[motel].owned == PlayerData.identifier or motels[motel].employees[PlayerData.identifier]
end

MotelRentalMenu = function(data)
	local motels = GlobalState.Motels
	local rate = motels[data.motel].hour_rate or data.rate
	local options = {}
	if not data.manual then
		table.insert(options,{
			title = 'Aluga um Quarto',
			--description = '![aluguer](nui://renzu_motels/data/image/'..data.motel..'.png) \n Escolhe um quarto para alugar \n '..data.rental_period..' Preço/dia: $'..rate,
			description = '![aluguer](nui://renzu_motels/data/image/'..data.motel..'.png) \n Escolhe um quarto para alugar \n Preço/dia: $'..rate,
			icon = 'hotel',
			onSelect = function()
				return RoomList(data)
			end,
			arrow = true,
		})
	end
	if not motels[data.motel].owned and config.business or IsOwnerOrEmployee(data.motel) and config.business then
	local title = not motels[data.motel].owned and 'Comprar Negócio do Motel' or 'Gestão do Motel'
	local description = not motels[data.motel].owned and 'Custo: '..data.businessprice or 'Gerir Funcionários, Hóspedes e Finanças.'
	table.insert(options,{
		title = title,
		description = description,
		icon = 'hotel',
		onSelect = function()
			return MotelOwner(data)
		end,
		arrow = true,
	})
end


	if #options == 0 then
		Notify('Este motel aceita ocupantes manualmente  \n  Contacta o proprietário')
		Wait(1500)
		return SendMessageApi(data.motel)
	end

    lib.registerContext({
        id = 'rentmenu',
        title = data.label,
        options = options
    })
	lib.showContext('rentmenu')
end

SendMessageApi = function(motel)
	local message = lib.alertDialog({
		header = 'Queres enviar uma mensagem ao proprietário?',
		content = '## Mensagem para o Proprietário do Motel',
		centered = true,
		labels = {
			cancel = 'fechar',
			confirm = 'Mensagem',
		},
		cancel = true
	})
	if message == 'cancel' then return end
	local input = lib.inputDialog('Mensagem', {
		{type = 'input', label = 'Título', description = 'título da tua mensagem', icon = 'hash', required = true},
		{type = 'textarea', label = 'Descrição', description = 'a tua mensagem', icon = 'mail', required = true},
		{type = 'number', label = 'Número de contacto', icon = 'phone', required = false},
	})
	
	config.messageApi({title = input[1], message = input[2], motel = motel})
end

Owner = {}
Owner.Rooms = {}
Owner.Rooms.Occupants = function(data,index)
	local motels , time = lib.callback.await('renzu_motels:getMotels',false)
	local motel = motels[data.motel]
	local players = motel.rooms[index] and motel.rooms[index].players or {}
	local options = {}
	for player,char in pairs(players) do
		local hour = math.floor((char.duration - time) / 3600)
		local name = char.name or 'Sem Nome'
		local duration_left = hour .. ' Horas : '..math.floor(((char.duration - time) / 60) - (60 * hour))..' Minutos'
		table.insert(options,{
			title = 'Ocupante '..name,
			description = 'Duração da Renda: '..duration_left,
			icon = 'hotel',
			onSelect = function()
				local kick = lib.alertDialog({
					header = 'Confirmação',
					content = '## Expulsar Ocupante \n  **Nome:** '..name,
					centered = true,
					labels = {
						cancel = 'fechar',
						confirm = 'Expulsar',
						waw = 'waw'
					},
					cancel = true
				})
				if kick == 'cancel' then return end
				local success = lib.callback.await('renzu_motels:removeoccupant',false,data,index,player)
				if success then
					Notify('Expulsaste o(a) '..name..' do quarto '..index,'success')
				else
					Notify('Falha ao expulsar '..name..' do quarto '..index,'error')
				end
			end,
			arrow = true,
		})
	end
	if data.maxoccupants > #options then
		for i = 1, data.maxoccupants-#options do
			table.insert(options,{
				title = 'Espaço Vago ',
				icon = 'hotel',
				onSelect = function()
					local input = lib.inputDialog('Novo Ocupante', {
						{type = 'number', label = 'ID do Cidadão', description = 'ID do cidadão que queres adicionar', icon = 'id-card', required = true},
						{type = 'number', label = 'Seleciona uma duração em '..data.rental_period..'s', description = 'quantos '..data.rental_period..'s', icon = 'clock', default = 1},
					})
					if not input then return end
					local success = lib.callback.await('renzu_motels:addoccupant',false,data,index,input)
					if success == 'exist' then
						Notify('Já existe no quarto '..index,'error')
					elseif success then
						Notify('Adicionaste '..input[1]..' ao quarto '..index,'success')
					else
						Notify('Falha ao adicionar '..input[1]..' ao quarto '..index,'error')
					end
				end,
				arrow = true,
			})
		end
	end
	lib.registerContext({
		menu = 'owner_rooms',
        id = 'occupants_lists',
        title = 'Quarto #'..index..' Ocupantes',
        options = options
    })
	lib.showContext('occupants_lists')
end

Owner.Rooms.List = function(data)
	local motels = GlobalState.Motels
	local options = {}
	for doorindex,v in ipairs(data.doors) do
		local occupants = CountOccupants(motels[data.motel].rooms[doorindex].players)
		table.insert(options,{
			title = 'Quarto #'..doorindex,
			description = 'Adicionar ou Expulsar Ocupantes do quarto #'..doorindex..' \n ***Ocupantes:*** '..occupants,
			icon = 'hotel',
			onSelect = function()
				return Owner.Rooms.Occupants(data,doorindex)
			end,
			arrow = true,
		})
	end
	lib.registerContext({
		menu = 'motelmenu',
        id = 'owner_rooms',
        title = data.label,
        options = options
    })
	lib.showContext('owner_rooms')
end

Owner.Employee = {}
Owner.Employee.Manage = function(data)
	local motel = GlobalState.Motels[data.motel]
	local options = {
		{
			title = 'Adicionar Funcionário',
			description = 'Adiciona um cidadão próximo como funcionário do motel',
			icon = 'hotel',
			onSelect = function()
				local input = lib.inputDialog('Adicionar Funcionário', {
					{type = 'number', label = 'ID do Cidadão', description = 'ID do cidadão que queres adicionar', icon = 'id-card', required = true},
				})
				if not input then return end
				local success = lib.callback.await('renzu_motels:addemployee',false,data.motel,input[1])
				if success then
					Notify('Adicionado com sucesso à lista de funcionários','success')
				else
					Notify('Falha ao adicionar funcionário','error')
				end
			end,
			arrow = true,
		}
	}
    if motel and motel.employees then
       for identifier,name in pairs(motel.employees) do
          table.insert(options,{
			title = name,
			description = 'Remover '..name..' da tua lista de funcionários',
			icon = 'hotel',
			onSelect = function()
				local success = lib.callback.await('renzu_motels:removeemployee',false,data.motel,identifier)
					if success then
						Notify('Removido com sucesso da lista de funcionários','success')
					else
						Notify('Falha ao remover funcionário','error')
					end
			end,
			arrow = true,
		})
	   end
	end
	lib.registerContext({
        id = 'employee_manage',
        title = 'Gestão de Funcionários',
        options = options
    })
	lib.showContext('employee_manage')
end

MotelOwner = function(data)
	local motels = GlobalState.Motels
	if not motels[data.motel].owned then
		local buy = lib.alertDialog({
			header = data.label,
			content = '![motel](nui://renzu_motels/data/image/'..data.motel..'.png) \n ## INFORMAÇÃO \n **Quartos:** '..#data.doors..'  \n  **Ocupantes Máximos:** '..#data.doors * data.maxoccupants..'  \n  **Preço:** $'..data.businessprice,
			centered = true,
			labels = {
				cancel = 'fechar',
				confirm = 'Comprar'
			},
			cancel = true
		})
		if buy ~= 'cancel' then
			local success = lib.callback.await('renzu_motels:buymotel',false,data)
			if success then
				Notify('Compraste o motel com sucesso','success')
			else
				Notify('Falha ao comprar o motel','error')
			end
		end
	elseif IsOwnerOrEmployee(data.motel) then
		local revenue = motels[data.motel].revenue or 0
		local rate = motels[data.motel].hour_rate or data.rate
		local options = {
			{
				title = 'Quartos do Motel',
				description = 'Adicionar ou Expulsar Ocupantes',
				icon = 'hotel',
				onSelect = function()
					return Owner.Rooms.List(data)
				end,
				arrow = true,
			},
			{
				title = 'Enviar Fatura',
				description = 'Faturar cidadãos próximos',
				icon = 'hotel',
				onSelect = function()
					local input = lib.inputDialog('Enviar Fatura', {
						{type = 'number', label = 'ID do Cidadão', description = 'id do cidadão próximo', icon = 'money', required = true},
						{type = 'number', label = 'Valor', description = 'valor total a cobrar', icon = 'money', required = true},
						{type = 'input', label = 'Descrição', description = 'Descrição da fatura', icon = 'info'},
						{type = 'checkbox', label = 'Pagamento Banco'},
					})
					if not input then return end
					Notify('Enviaste a fatura para '..input[1]..' com sucesso','success')
					local success = lib.callback.await('renzu_motels:sendinvoice',false,data.motel,input)
					if success then
						Notify('A fatura foi paga','success')
					else
						Notify('A fatura não foi paga','error')
					end
				end,
				arrow = true,
			}
		}
		if motels[data.motel].owned == PlayerData.identifier then
			table.insert(options,{
				title = 'Ajustar Preços por Hora',
				description = 'Modificar os preços atuais por '..data.rental_period..'. \n Preço por '..data.rental_period..': '..rate,
				icon = 'hotel',
				onSelect = function()
					local input = lib.inputDialog('Editar Preço por '..data.rental_period, {
						{type = 'number', label = 'Preço', description = 'Preço por '..data.rental_period..'', icon = 'money', required = true},
					})
					if not input then return end
					local success = lib.callback.await('renzu_motels:editrate',false,data.motel,input[1])
					if success then
						Notify('Alteraste com sucesso o preço por '..data.rental_period,'success')
					else
						Notify('Falha ao modificar','error')
					end
				end,
				arrow = true,
			})
			table.insert(options,{
				title = 'Receita do Motel',
				description = 'Total: '..revenue,
				icon = 'hotel',
				onSelect = function()
					local input = lib.inputDialog('Levantar Fundos', {
						{type = 'number', label = 'Valor a Levantar', icon = 'money', required = true},
					})
					if not input then return end
					local success = lib.callback.await('renzu_motels:withdrawfund',false,data.motel,input[1])
					if success then
						Notify('Levantaste os fundos com sucesso','success')
					else
						Notify('Falha ao levantar os fundos','error')
					end
				end,
				arrow = true,
			})
			table.insert(options,{
				title = 'Gestão de Funcionários',
				description = 'Adicionar / Remover Funcionário',
				icon = 'hotel',
				onSelect = function()
					return Owner.Employee.Manage(data)
				end,
				arrow = true,
			})
			table.insert(options,{
				title = 'Transferir Propriedade',
				description = 'Transferir para outro cidadão próximo',
				icon = 'hotel',
				onSelect = function()
					local input = lib.inputDialog('Transferir Motel', {
						{type = 'number', label = 'ID do Cidadão', description = 'ID do cidadão para quem queres transferir', icon = 'id-card', required = true},
					})
					if not input then return end
					local success = lib.callback.await('renzu_motels:transfermotel',false,data.motel,input[1])
					if success then
						Notify('Transferiste a propriedade do motel com sucesso','success')
					else
						Notify('Falha ao transferir','error')
					end
				end,
				arrow = true,
			})
			table.insert(options,{
				title = 'Vender Motel',
				description = 'Vender o motel por metade do valor',
				icon = 'hotel',
				onSelect = function()
					local sell = lib.alertDialog({
						header = data.label,
						content = '![motel](nui://renzu_motels/data/image/'..data.motel..'.png) \n ## INFORMAÇÃO \n  **Valor de Venda:** $'..data.businessprice / 2,
						centered = true,
						labels = {
							cancel = 'fechar',
							confirm = 'Vender'
						},
						cancel = true
					})
					if sell ~= 'cancel' then
						local success = lib.callback.await('renzu_motels:sellmotel',false,data)
						if success then
							Notify('Vendeste o motel com sucesso','success')
						else
							Notify('Falha ao vender o motel','error')
						end
					end
				end,
				arrow = true,
			})
		end
		lib.registerContext({
			id = 'motelmenu',
			menu = 'rentmenu',
			title = data.label,
			options = options
		})
		lib.showContext('motelmenu')
	end
end

 --[[ MotelRentalPoints = function(data)
    local point = lib.points.new(data.rentcoord, 5, data)

    function point:onEnter() 
		lib.showTextUI('[E] - Aluguer de Motel', {
			position = "top-center",
			icon = 'hotel',
			style = {
				borderRadius = 0,
				backgroundColor = '#48BB78',
				color = 'white'
			}
		})
	end

    function point:onExit() 
		lib.hideTextUI()
	end

    function point:nearby()
        -- DrawMarker(...)
        if self.currentDistance < 1 and IsControlJustReleased(0, 38) then
            MotelRentalMenu(data)
        end
    end
	return point
end ]]
 
local function CreateMotelRentalTarget(data)
    local targetId = exports.ox_target:addBoxZone({
        coords = data.rentcoord, 
        size = vec3(2.0, 2.0, 2.0),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'motel_rental_' .. data.motel,
                icon = 'fas fa-hotel',
                label = 'Aluguer de Motel - ' .. data.label,
                onSelect = function()
                    MotelRentalMenu(data)
                end,
                canInteract = function(entity, distance, coords, name)
                    return distance < 3.0
                end
            }
        }
    })
    
    return targetId
end



local inMotelZone = false
MotelZone = function(data)
	local point = nil
    function onEnter(self) 
		inMotelZone = true
		Citizen.CreateThreadNow(function()
			for index, doors in pairs(data.doors) do
				for type, coord in pairs(doors) do
					MotelFunction({
						payment = data.payment or 'money',
						uniquestash = data.uniquestash, 
						shell = data.shell, 
						Mlo = data.Mlo, 
						type = type, 
						index = index, 
						coord = coord, 
						label = config.Text[type], 
						motel = data.motel, 
						door = data.door
					})
				end
			end
			point = CreateMotelRentalTarget(data) 
		end)
	end

    function onExit(self)
		inMotelZone = false
		point:remove()
		for k,id in pairs(zones) do
			removeTargetZone(id)
		end
		for k,id in pairs(blips) do
			if DoesBlipExist(id) then
				RemoveBlip(id)
			end
		end
		zones = {}
	end

    local sphere = lib.zones.sphere({
        coords = data.coord,
        radius = data.radius,
        debug = false,
        inside = inside,
        onEnter = onEnter,
        onExit = onExit
    })
end

--qb-interior func
local house
local inhouse = false
function Teleport(x, y, z, h ,exit)
    CreateThread(function()
        SetEntityCoords(cache.ped, x, y, z, 0, 0, 0, false)
        SetEntityHeading(cache.ped, h or 0.0)
        Wait(1001)
        DoScreenFadeIn(1000)
    end)
	if exit then
		inhouse = false
		TriggerEvent('qb-weathersync:client:EnableSync')
		for k,id in pairs(shelzones) do
			removeTargetZone(id)
		end
		DeleteEntity(house)
		lib.callback.await('renzu_motels:SetRouting',false,data,'exit')
		shelzones = {}
		DeleteResourceKvp(kvpname)
		LocalPlayer.state:set('inshell',false,true)
	end
end

EnterShell = function(data,login)
	local motels = GlobalState.Motels
	if motels[data.motel].rooms[data.index].lock and not login then
		Notify('A porta está trancada', 'error')
		return false
	end
	local shelldata = config.shells[data.shell or data.motel]
	if not shelldata then 
		warn('Shell não está configurada')
		return 
	end
	lib.callback.await('renzu_motels:SetRouting',false,data,'enter')
	inhouse = true
	Wait(1000)
	local spawn = vec3(data.coord.x,data.coord.y,data.coord.z)+vec3(0.0,0.0,1500.0)
    local offsets = shelldata.offsets
	local model = shelldata.shell
	DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end
	inhouse = true
	TriggerEvent('qb-weathersync:client:DisableSync')
	RequestModel(model)
	while not HasModelLoaded(model) do
	    Wait(1000)
	end
	local lastloc = GetEntityCoords(cache.ped)
	house = CreateObject(model, spawn.x, spawn.y, spawn.z, false, false, false)
    FreezeEntityPosition(house, true)
	LocalPlayer.state:set('lastloc',data.lastloc or lastloc,false)
	data.lastloc = data.lastloc or lastloc
	if not login then
		SendNUIMessage({
			type = 'door'
		})
	end
	Teleport(spawn.x + offsets.exit.x, spawn.y + offsets.exit.y, spawn.z+0.1, offsets.exit.h)
	SetResourceKvp(kvpname,json.encode(data))

	Citizen.CreateThreadNow(function()
		ShellTargets(data,offsets,spawn,house)
		while inhouse do
			--SetRainLevel(0.0)
			SetWeatherTypePersist('CLEAR')
			SetWeatherTypeNow('CLEAR')
			SetWeatherTypeNowPersist('CLEAR')
			NetworkOverrideClockTime(18, 0, 0)
			Wait(1)
		end
	end)
    return house
end

function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance,flag)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =  vector3(cameraCoord.x + direction.x * distance, 
		cameraCoord.y + direction.y * distance, 
		cameraCoord.z + direction.z * distance 
    )
    if not flag then
        flag = 1
    end

	local a, b, c, d, e = GetShapeTestResultIncludingMaterial(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, flag, -1, 1))
	return b, c, e, destination
end

local lastweapon = nil
lib.onCache('weapon', function(weapon)
	if not inMotelZone then return end
	if not PlayerData.job then return end
	if not config.breakinJobs[PlayerData.job.name] then return end
	local motels = GlobalState.Motels
	lastweapon = weapon
    while weapon and weapon == lastweapon do
		Wait(33)
		if IsPedShooting(cache.ped) then
			local _, bullet, _ = RayCastGamePlayCamera(200.0,1)
			for k,data in pairs(config.motels) do
				for k,v in pairs(data.doors) do
					if #(vec3(bullet.x,bullet.y,bullet.z) - vec3(v.door.x,v.door.y,v.door.z)) < 2 and motels[data.motel].rooms[k].lock then
						TriggerServerEvent('renzu_motels:Door', {
							motel = data.motel,
							index = k,
							coord = v.door,
							Mlo = data.Mlo,
						})
						local text
						if data.Mlo then
							local doorindex = k + (joaat(data.motel))
							text = DoorSystemGetDoorState(doorindex) == 0 and 'Destruíste a porta do motel'
						else
							text = 'Destruíste a porta do motel'
						end
						Notify(text,'warning')
					end
				end
				Wait(1000)
			end
		end
	end
end)

RegisterNetEvent('renzu_motels:MessageOwner', function(data)
	AddTextEntry('esxAdvancedNotification', data.message)
    BeginTextCommandThefeedPost('esxAdvancedNotification')
	ThefeedSetNextPostBackgroundColor(1)
	AddTextComponentSubstringPlayerName(data.message)
    EndTextCommandThefeedPostMessagetext('CHAR_FACEBOOK', 'CHAR_FACEBOOK', false, 1, data.motel, data.title)
    EndTextCommandThefeedPostTicker(flash or false, true)
end)

Citizen.CreateThread(function()
	while GlobalState.Motels == nil do Wait(1) end
    for motel, data in pairs(config.motels) do
        MotelZone(data)
    end
	CreateBlips()
end)
