print("Willkommen beim Cobblestone-Generator")
print("Es muss eine Kiste unter der Turtle stehen!")
print("Wie viele Stacks möchtest du herstellen? Doppeltruhe = 54")
stacks = read()

turtle.select(1)

for i=0, stacks*64 do
	turtle.dig()
	turtle.dropDown()
	os.sleep(1.5)
end
