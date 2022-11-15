local neuron = require "neural"

local inputs = {"a", "b", "c"}
local layers = {5, 5}
local outputs = {"foo", "bar", "baz"}

local handle = neuron.create.brain(inputs, layers, outputs, os.time())

for i = 1, 500 do
    handle.nudge()
end

local other = handle.clone()


handle.set("a", 3)
handle.set("b", 0.2)
handle.set("c", 7)

handle.calculate()

other.set("a", 3)
other.set("b", 0.2)
other.set("c", 7)

other.calculate()

print(handle.get("foo"), handle.get("bar"), handle.get("baz"))
print(other.get("foo"), other.get("bar"), other.get("baz"))