local lang = vRP.lang
local Luang = module("vrp", "lib/Luang")
local htmlEntities = module("lib/htmlEntities")

local SellVeh = class("SellVeh", vRP.Extension)

local function menu_sv_vehicles(self)
	
	local function m_sub(menu, model)
		local user = menu.user
		local veh = menu.data.vehicles[model]
		local veh_name = veh[1]
		local nuser
		local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source, self.cfg.radius)
		
		if nplayer then
			nuser = vRP.users_by_source[nplayer]
			local nvehicles = nuser:getVehicles()
			if nvehicles[model] == 1 or nvehicles[model] == 0 then		--check if nuser ownes vehicle already
				vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.owned())
				vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.owned())
			else
				if nuser then
					local price = tonumber(user:prompt(self.lang.sell.user.prompt({veh_name,self.cfg.min_price}), ""))
					if price and price > self.cfg.min_price then
						vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.offer())
						user:closeMenus()
						if nuser:request(self.lang.sell.nuser.offer({veh_name,price}), self.cfg.time) then
							if vRP.EXT.Survival.remote.isInComa(nuser.source) then
								vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.dead())
								vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.dead())
							else
								if veh and nuser:tryFullPayment(price) then
									local uvehicles = user:getVehicles()
									if uvehicles[model] == 0 then
										if vRP.EXT.Garage.remote.despawnVehicle(user.source, model) then
											vRP.EXT.Garage.remote._removeOutVehicles(user.source, {[model] = true})
										end
										nvehicles[model] = 1	--gives nuser vehicle
										uvehicles[model] = nil	--removes vehicle form user
										-- despawn user vehicles
										vRP.EXT.Garage.remote._despawnVehicles(user.source, model)
										vRP.EXT.Garage.remote._removeOutVehicles(user.source, {[model] = true})
										if self.cfg.bank then	--payment goes to either bank or wallet(wallet by default)
											user:giveBank(price)
										else
											user:giveWallet(price)
										end
										vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.sold({veh_name,price}))
										vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.bought({veh_name,price}))
										if not vRP.EXT.Survival.remote._isInComa(nuser.source) then
											local vstate = user:getVehicleState(model)
											local state = {
												customization = vstate.customization,
												condition = vstate.condition,
												locked = vstate.locked
											}
											nvehicles[model] = 0
											-- spawn nuser vehicles
											vRP.EXT.Garage.remote._spawnVehicle(nuser.source, model, state)
											vRP.EXT.Garage.remote._setOutVehicles(nuser.source, {[model] = {state, vstate.position, vstate.rotation}})
											user:closeMenus()		
										else
											vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.store({veh_name}))
										end
									end
								else
									vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.money())
									if user then
										vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.money())
									end
								end
							end
						else
							vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.decline())
							vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.decline())
						end
					else
						vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.canceled())
					end
				end
			end
		else
			vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.players({veh_name}))
		end
	end
	
	vRP.EXT.GUI:registerMenuBuilder("sv.vehicles", function(menu)
		menu.title = self.lang.menu.titles.veh.name()
		menu.css.header_color = "rgba(0,125,200,0.75)"
		local user = menu.user
		local uvehicles = user:getVehicles()

		for model,veh in pairs(menu.data.vehicles) do
			if model ~= "_config" and uvehicles[model] then
				menu:addOption(veh[1], m_sub, self.lang.menu.titles.veh.value({veh[2]*(self.cfg.resale/100),self.cfg.resale}), model)
			end
		end
	end)
end

local function menu_sv_veh(self)
	
	local function m_sub(menu, model, nuser)
		local user = menu.user
		local veh = menu.data.vehicles[model]
		local veh_name = veh[1]
		local nuser = menu.data.nuser
		
		local nvehicles = nuser:getVehicles()
		if nvehicles[model] == 1 or nvehicles[model] == 0 then		--check if nuser ownes vehicle already
			vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.owned())
			vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.owned())
		else
			local price = tonumber(user:prompt(self.lang.sell.user.prompt({veh_name,self.cfg.min_price}), ""))
			if price and price > self.cfg.min_price then
				vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.offer())
				user:closeMenus()
				if nuser:request(self.lang.sell.nuser.offer({veh_name,price}), self.cfg.time) then
					if vRP.EXT.Survival.remote.isInComa(nuser.source) then
						vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.dead())
						vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.dead())
					else
						if veh and nuser:tryFullPayment(price) then
							local uvehicles = user:getVehicles()
							if uvehicles[model] == 0 then
								if vRP.EXT.Garage.remote.despawnVehicle(user.source, model) then
									vRP.EXT.Garage.remote._removeOutVehicles(user.source, {[model] = true})
								end
								nvehicles[model] = 1	--gives nuser vehicle
								uvehicles[model] = nil	--removes vehicle form user
								-- despawn user vehicles
								vRP.EXT.Garage.remote._despawnVehicles(user.source, model)
								vRP.EXT.Garage.remote._removeOutVehicles(user.source, {[model] = true})
								if self.cfg.bank then	--payment goes to either bank or wallet(wallet by default)
									user:giveBank(price)
								else
									user:giveWallet(price)
								end
								vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.sold({veh_name,price}))
								vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.bought({veh_name,price}))
								if not vRP.EXT.Survival.remote._isInComa(nuser.source) then
									local vstate = user:getVehicleState(model)
									local state = {
										customization = vstate.customization,
										condition = vstate.condition,
										locked = vstate.locked
									}
									nvehicles[model] = 0
									-- spawn nuser vehicles
									vRP.EXT.Garage.remote._spawnVehicle(nuser.source, model, state)
									vRP.EXT.Garage.remote._setOutVehicles(nuser.source, {[model] = {state, vstate.position, vstate.rotation}})
									user:closeMenus()		
								else
									vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.store({veh_name}))
								end
							end
						else
							vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.money())
							if user then
								vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.money())
							end
						end
					end
				else
					vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.decline())
					vRP.EXT.Base.remote._notify(nuser.source, self.lang.sell.nuser.decline())
				end
			else
				vRP.EXT.Base.remote._notify(user.source, self.lang.sell.user.canceled())
			end
		end
	end
	
	vRP.EXT.GUI:registerMenuBuilder("sv.veh", function(menu,nuser)
		local user = menu.user
		local nuser = menu.data.nuser
		--local tuser = vRP.users[id]
		menu.title = self.lang.menu.titles.veh.sell({htmlEntities.encode(nuser.name)})
		menu.css.header_color = "rgba(0,125,200,0.75)"
		local uvehicles = user:getVehicles()

		for model,veh in pairs(menu.data.vehicles) do
			if model ~= "_config" and uvehicles[model] then
				menu:addOption(veh[1], m_sub, self.lang.menu.titles.veh.value({veh[2]*(self.cfg.resale/100),self.cfg.resale}), model)
			end
		end
	end)
end

local function menu_sv_user(self)

	local function m_user(menu, nuser)
		local user = menu.user
		for k, v in pairs(self.cfg.garages) do
			local ptype, x, y, z = table.unpack(v)
			local group = self.cfg.garage_types[ptype]

			if group then
				local gcfg = group._config
				local data = {type = ptype, vehicles = group, nuser = nuser}
				local menu = menu.user:openMenu("sv.veh", data)
				menu:listen("close", function(menu)
					menu.user:closeMenu(menu)
				end)
			end
		end
	end
	
	vRP.EXT.GUI:registerMenuBuilder("sv.user", function(menu)
		menu.title = self.lang.menu.titles.options.list()
		menu.css.header_color = "rgba(0,125,200,0.75)"
		local user = vRP.users_by_source[source] 
		local nuser
		local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,self.cfg.radius)
		if nplayer then nuser = vRP.users_by_source[nplayer] end

		if nuser then
			menu:addOption(self.lang.menu.titles.options.users({htmlEntities.encode(nuser.name)}), m_user, nil, nuser)
		else
			menu:addOption(self.lang.menu.titles.options.error(), nil, self.lang.menu.titles.options.dis())
		end
	end)
end

local function menu_sv(self)
	
	vRP.EXT.GUI:registerMenuBuilder("sv", function(menu)
		menu.title = self.lang.menu.titles.options.name()
		menu.css.header_color = "rgba(0,125,200,0.75)"
		
		--nearby players by name
		menu:addOption(self.lang.menu.titles.options.player(), function(menu)
			local user = menu.user
			for k, v in pairs(self.cfg.garages) do
				local ptype, x, y, z = table.unpack(v)
				local group = self.cfg.garage_types[ptype]

				if group then
					local gcfg = group._config
					local data = {type = ptype, vehicles = group}
					local menu = menu.user:openMenu("sv.user", data)
					menu:listen("close", function(menu)
						menu.user:closeMenu(menu)
					end)
				end
			end
		end)
		
		--all nearby players
		menu:addOption(self.lang.menu.titles.options.nearby(), function(menu)
			local user = menu.user
			for k, v in pairs(self.cfg.garages) do
				local ptype, x, y, z = table.unpack(v)
				local group = self.cfg.garage_types[ptype]

				if group then
					local gcfg = group._config
					local data = {type = ptype, vehicles = group}
					local menu = menu.user:openMenu("sv.vehicles", data)
					menu:listen("close", function(menu)
						menu.user:closeMenu(menu)
					end)
				end
			end
		end)
	end)
end

function SellVeh:__construct()
	vRP.Extension.__construct(self)
	
	self.cfg = module("vrp_sellveh", "cfg/cfg")
	
	-- load lang
	self.luang = Luang()
	self.luang:loadLocale(vRP.cfg.lang, module("vrp_sellveh", "cfg/lang/"..vRP.cfg.lang))
	self.lang = self.luang.lang[vRP.cfg.lang]
	
	menu_sv(self)
	menu_sv_user(self)
	menu_sv_veh(self)
	menu_sv_vehicles(self)

	vRP.EXT.GUI:registerMenuBuilder("identity", function(menu)
		menu:addOption(self.lang.menu.titles.main.name(), function(menu)
			menu.user:openMenu("sv")
		end)
	end)
end

vRP:registerExtension(SellVeh)
