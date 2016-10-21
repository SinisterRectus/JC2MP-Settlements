local unpack, insert = table.unpack, table.insert

class 'Settlements'

function Settlements:__init()

	self.triggers = {}
	self.settlements = {}
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

	self.counts[id] = self.counts[id] + 1

	if self.counts[id] == 1 then
		if args.entity.__type == "LocalPlayer" then
			if self.fire_local then
				Events:Fire("LocalPlayerEnterSettlement", {
					settlement = settlement
				})
			end
			if self.fire_network then
				Network:Send("Enter", {
					id = id,
					player = args.entity
				})
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

	self.counts[id] = self.counts[id] - 1

	if self.counts[id] == 0 then
		if args.entity.__type == "LocalPlayer" then
			if self.fire_local then
				Events:Fire("LocalPlayerExitSettlement", {
					settlement = settlement
				})
			end
			if self.fire_network then
				Network:Send("Exit", {
					id = id,
					player = args.entity
				})
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

	for id, data in ipairs(settlements) do

		if #data[4] == 3 then

			local settlement = {
				id = id,
				name = data[1],
				angle = Angle(unpack(data[2])),
				position = Vector3(unpack(data[3])),
				triggers = {}
			}

			local trigger = ShapeTrigger.Create({
				angle = settlement.angle,
				position = settlement.position,
				components = {{size = Vector3(unpack(data[4])), type = data[5]}},
				trigger_player = true,
				trigger_player_in_vehicle = true
			})

			self.settlements[id] = settlement
			self.triggers[trigger:GetId()] = settlement
			insert(settlement.triggers, trigger)

		else

			local settlement = {
				id = id,
				name = data[1],
				angle = Angle(unpack(data[2])),
				position = Vector3(unpack(data[3])),
				triggers = {}
			}

			for i = 4, #data do

				local component = data[i]

				local trigger = ShapeTrigger.Create({
					angle = Angle(unpack(component[1])),
					position = settlement.position + settlement.angle * Vector3(unpack(component[2])),
					components = {{size = Vector3(unpack(component[3])), type = component[4]}},
					trigger_player = true,
					trigger_player_in_vehicle = true
				})

				self.triggers[trigger:GetId()] = settlement
				insert(settlement.triggers, trigger)

			end

			self.settlements[id] = settlement

		end

		self.counts[id] = 0

	end

	settlements = nil
	collectgarbage()

end

function Settlements:ModuleUnload()
	for _, settlement in pairs(self.settlements) do
		for _, trigger in ipairs(settlement.triggers) do
			trigger:Remove()
		end
	end
end

Settlements = Settlements()
