local unpack, insert = table.unpack, table.insert

class 'Settlements'

function Settlements:__init()

	self.counts = {}
	self.fire_local = true
	self.fire_network = true

	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	Events:Subscribe("ShapeTriggerEnter", self, self.Enter)
	Events:Subscribe("ShapeTriggerExit", self, self.Exit)

end

function Settlements:Enter(args)

	local settlement = self.triggers[args.trigger:GetId()]
	if not settlement then return end
	local id = settlement.id
	local player = args.entity:GetSteamId().id

	local counts = self.counts
	counts[player] = counts[player] or {}
	counts[player][id] = counts[player][id] and counts[player][id] + 1 or 1

	if counts[player][id] == 1 then
		if args.entity.__type == "LocalPlayer" then
			if self.fire_local then
				Events:Fire("LocalPlayerEnterSettlement", {
					settlement = settlement
				})
			end
			if self.fire_network then
				Network:Send("Enter", {id = id})
			end
		elseif args.entity.__type == "Player" then
			if self.fire_local then
				Events:Fire("PlayerEnterSettlement", {
					settlement = settlement,
					player = args.entity
				})
			end
		end
	end

end

function Settlements:Exit(args)

	local settlement = self.triggers[args.trigger:GetId()]
	if not settlement then return end
	local id = settlement.id
	local player = args.entity:GetSteamId().id

	local counts = self.counts
	counts[player] = counts[player] or {}
	counts[player][id] = counts[player][id] and counts[player][id] - 1 or 0

	if counts[player][id] == 0 then
		if args.entity.__type == "LocalPlayer" then
			if self.fire_local then
				Events:Fire("LocalPlayerExitSettlement", {
					settlement = settlement
				})
			end
			if self.fire_network then
				Network:Send("Exit", {id = id})
			end
		elseif args.entity.__type == "Player" then
			if self.fire_local then
				Events:Fire("PlayerExitSettlement", {
					settlement = settlement,
					player = args.entity
				})
			end
		end
	end

end

function Settlements:ModuleLoad()

	local triggers = {}
	local settlements = {}

	for k, v in ipairs(data) do

		if #v[4] == 3 then

			local settlement = {
				id = k,
				name = v[1],
				angle = Angle(unpack(v[2])),
				position = Vector3(unpack(v[3])),
				triggers = {}
			}

			local trigger = ShapeTrigger.Create({
				angle = settlement.angle,
				position = settlement.position,
				components = {{size = Vector3(unpack(v[4])), type = v[5]}},
				trigger_player = true,
				trigger_player_in_vehicle = true
			})

			settlements[k] = settlement
			triggers[trigger:GetId()] = settlement
			insert(settlement.triggers, trigger)

		else

			local settlement = {
				id = k,
				name = v[1],
				angle = Angle(unpack(v[2])),
				position = Vector3(unpack(v[3])),
				triggers = {}
			}

			for i = 4, #v do

				local component = v[i]
				local trigger = ShapeTrigger.Create({
					angle = Angle(unpack(component[1])),
					position = settlement.position + settlement.angle * Vector3(unpack(component[2])),
					components = {{size = Vector3(unpack(component[3])), type = component[4]}},
					trigger_player = true,
					trigger_player_in_vehicle = true
				})

				triggers[trigger:GetId()] = settlement
				insert(settlement.triggers, trigger)

			end

			settlements[k] = settlement

		end

	end

	data = nil
	collectgarbage()
	self.triggers = triggers
	self.settlements = settlements

end

function Settlements:ModuleUnload()
	for _, settlement in pairs(self.settlements) do
		for _, trigger in ipairs(settlement.triggers) do
			trigger:Remove()
		end
	end
end

Settlements = Settlements()
