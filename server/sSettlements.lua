local unpack = table.unpack

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
			self.settlements[id] = {
				id = id,
				name = data[1],
				angle = Angle(unpack(data[2])),
				position = Vector3(unpack(data[3])),
			}
		else
			self.settlements[id] = {
				id = id,
				name = data[1],
				angle = Angle(unpack(data[2])),
				position = Vector3(unpack(data[3])),
			}
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

Events:Subscribe('PlayerEnterSettlement', function(args)
	tprint(args)
end)

Settlements = Settlements()
