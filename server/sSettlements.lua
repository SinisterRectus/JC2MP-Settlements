class 'Settlements'

function Settlements:__init()

	self.settlements = {}

	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
	Network:Subscribe("Enter", self, self.Enter)
	Network:Subscribe("Exit", self, self.Exit)

end

function Settlements:ModuleLoad()

	for id, data in ipairs(settlements) do
	
		if #data[4] == 3 then
	
			local settlement = {
				id = id,
				name = data[1],
				angle = Angle(table.unpack(data[2])),
				position = Vector3(table.unpack(data[3])),
			}
			
			self.settlements[id] = settlement
			
		else
		
			local settlement = {
				id = id,
				name = data[1],
				angle = Angle(table.unpack(data[2])),
				position = Vector3(table.unpack(data[3])),
			}
			
			self.settlements[id] = settlement
		
		end
	
	end
	
	settlements = nil
	collectgarbage()

end

function Settlements:Enter(args)

	Events:Fire("PlayerEnterSettlement", {
		settlement = self.settlements[args.id],
		player = args.player
	})

end

function Settlements:Exit(args)

	Events:Fire("PlayerExitSettlement", {
		settlement = self.settlements[args.id],
		player = args.player
	})

end

Settlements = Settlements()
