local unpack = table.unpack

class 'Settlements'

function Settlements:__init()

	self.settlements = {}

	Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
	Network:Subscribe("Enter", self, self.Enter)
	Network:Subscribe("Exit", self, self.Exit)

end

function Settlements:ModuleLoad()

	local settlements = {}
	for k, v in ipairs(data) do
		settlements[k] = {
			id = k,
			name = v[1],
			angle = Angle(unpack(v[2])),
			position = Vector3(unpack(v[3])),
		}
	end

	data = nil
	collectgarbage()
	self.settlements = settlements

end

function Settlements:Enter(args, sender)
	Events:Fire("PlayerEnterSettlement", {
		settlement = self.settlements[args.id],
		player = sender
	})
end

function Settlements:Exit(args, sender)
	Events:Fire("PlayerExitSettlement", {
		settlement = self.settlements[args.id],
		player = sender
	})
end

Settlements = Settlements()
