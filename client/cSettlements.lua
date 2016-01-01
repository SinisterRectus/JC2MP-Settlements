class 'Settlements'

function Settlements:__init()

	self.triggers = {}
	self.city_count = {}

	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
	Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
	Events:Subscribe("ShapeTriggerEnter", self, self.TriggerEnter)
	Events:Subscribe("ShapeTriggerExit", self, self.TriggerExit)

end

function Settlements:TriggerEnter(args)

	if args.entity.__type ~= "LocalPlayer" then return end
	local trigger = self.triggers[args.trigger:GetId()]
	if not trigger then return end

	local name = trigger[1]
	if not trigger[3] then
		Events:Fire("SettlementEnter", {name = name})
	else
		self.city_count[name] = self.city_count[name] + 1
		if self.city_count[name] == 1 then
			Events:Fire("SettlementEnter", {name = name})
		end
	end

end

function Settlements:TriggerExit(args)

	if args.entity.__type ~= "LocalPlayer" then return end
	local trigger = self.triggers[args.trigger:GetId()]
	if not trigger then return end

	local name = trigger[1]
	if not trigger[3] then
		Events:Fire("SettlementExit", {name = name})
	else
		self.city_count[name] = self.city_count[name] - 1
		if self.city_count[name] == 0 then
			Events:Fire("SettlementExit", {name = name})
		end
	end

end

function Settlements:ModuleLoad()

	for _, trigger in ipairs(triggers) do
	
		local entity = ShapeTrigger.Create({
			position = Vector3(table.unpack(trigger[3])),
			angle = Angle(table.unpack(trigger[2])),
			components = {{size = Vector3(table.unpack(trigger[4])), type = trigger[5]}},
			trigger_player = true,
			trigger_player_in_vehicle = true
		})
		
		self.triggers[entity:GetId()] = {trigger[1], entity, false}

	end

	triggers = nil
	collectgarbage()
	
	for _, trigger in ipairs(city_triggers) do
	
		local origin = Vector3(table.unpack(trigger[3]))
		local angle = Angle(table.unpack(trigger[2]))
	
		for i = 4, #trigger do

			local component = trigger[i]
		
			local entity = ShapeTrigger.Create({
				position = origin + angle * Vector3(table.unpack(component[2])),
				angle = Angle(table.unpack(component[1])),
				components = {{size = Vector3(table.unpack(component[3])), type = component[4]}},
				trigger_player = true,
				trigger_player_in_vehicle = true
			})
			
			self.triggers[entity:GetId()] = {trigger[1], entity, true}
			self.city_count[trigger[1]] = 0

		end
	
	end

	city_triggers = nil
	collectgarbage()
	
end

function Settlements:ModuleUnload()

	for _, trigger in pairs(self.triggers) do
		trigger[2]:Remove()
	end

end

Settlements = Settlements()

Events:Subscribe("SettlementEnter", function(args)

    Chat:Print(string.format("You have entered %s.", args.name), Color.White)

end)

Events:Subscribe("SettlementExit", function(args)

    Chat:Print(string.format("You have exited %s.", args.name), Color.White)

end)
