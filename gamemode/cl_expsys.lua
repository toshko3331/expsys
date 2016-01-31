--TODO: Make this into a class so no global variables and shit like that.
experience = 0
function UpdateExp(len)
	experience = net.ReadInt(32)
	print("I have been updated! Exp: "..experience)
end
net.Receive("UpdateExp",UpdateExp)

function PrintExp()
	print(experience)
end
concommand.Add("print_exp",PrintExp)