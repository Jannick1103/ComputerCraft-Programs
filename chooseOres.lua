print("=====================")
print("Willkommen bei der Erz-Konfiguration!")
print(" ")
print("Gebe den Namen der Konfigurationsdatei ein!")
print("Standardwert: ores")

fname = read()
if fname == nil then fname = "ores" end

f = fs.open(fname, "w")

function question() 
	local ans = read()
	if ans == "y" then
		return true
	else 
		return false
	end
end

print("Im Folgenden wirst du gefragt welche Erze gemint werden sollen. Antworte mit y oder n")

print("Kohle?")
if question() then
	f.writeLine("minecraft:coal_ore")
	f.writeLine("minecraft:coal")
end

print("Diamanten?")
if question() then
	f.writeLine("minecraft:diamond_ore")
	f.writeLine("minecraft:diamond")
end

print("Redstone?")
if question() then
	f.writeLine("minecraft:redstone_ore")
	f.writeLine("minecraft:redstone")
end

print("Eisen?")
if question() then
	f.writeLine("minecraft:iron_ore")
end

print("Gold?")
if question() then
	f.writeLine("minecraft:gold_ore")
end

print("Lapis?")
if question() then
	f.writeLine("minecraft:lapis_ore")
	f.writeLine("minecraft:lapis_lazuli")
end

print("Emeralds?")
if question() then
	f.writeLine("minecraft:emerald_ore")
	f.writeLine("minecraft:emerald")
end

print("Netherite?")
if question() then
	f.writeLine("minecraft:netherite_scrap")
	f.writeLine("minecraft:ancient_debris")
end

print("Kupfer?")
if question() then
	f.writeLine("techreborn:copper_ore")
end

print("Zinn?")
if question() then
	f.writeLine("techreborn:tin_ore")
end

print("Silber?")
if question() then
	f.writeLine("techreborn:silver_ore")
end

print("Nikolite?")
if question() then
	f.writeLine("indrev:nikolite_ore")
	f.writeLine("indrev:nikolite_dust")
end

print("Certus Quartz?")
if question() then
	f.writeLine("appliedenergistics2:quartz_ore")
	f.writeLine("appliedenergistics2:charged_quartz_ore")
	f.writeLine("appliedenergistics2:charged_certus_quartz_crystal")
	f.writeLine("appliedenergistics2:certus_quartz_crystal")
end

print("Lead?")
if question() then
	f.writeLine("techreborn:lead_ore")
end


print(" ")
print("Konfiguration abgeschlossen!")
f.close()