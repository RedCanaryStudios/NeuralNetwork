local neural = {}
neural.create = {}
neural.math = {}

local create = neural.create
local nmath = neural.math

function neural.math.sigmoid(x)
    return 1/(1 + math.exp(-x))
end

function neural.create.synapse(n1, n2, w)
    local handle = {}
    handle.weight = w or 1

    function handle.catch()
        return n1.post*handle.weight
    end

    table.insert(n2.synapses, handle)

    return handle
end

function neural.create.neuron(b)
    local handle = {}
    handle.synapses = {}
    handle.bias = b or 0
    handle.post = 0

    function handle.signal(input)
        handle.post = input
    end

    function handle.receive()
        local value = handle.bias
        for _, synapse in ipairs(handle.synapses) do
            value = value + synapse.catch()
        end
        handle.signal(nmath.sigmoid(value))
    end

    return handle
end

function neural.create.brain(inputs, layers, outputs, seed)
    local rawdump = {}
    rawdump.neurons = {}
    rawdump.synapses = {}

    math.randomseed(seed or os.time())

    local copy = not layers

    local i = {}
    local l = {} 
    local o = {} 
    
    if copy then
        local other, oinputs, olayers, ooutputs = unpack(inputs)

        for name, oneuron in pairs(oinputs) do
            i[name] = create.neuron(oneuron.bias)
            table.insert(rawdump.neurons, i[name])
        end

        for num, layer in ipairs(olayers) do
            l[num] = {}
            for i, oneuron in ipairs(layer) do
                l[num][i] = create.neuron(oneuron.bias)
            end
        end

        for name, oneuron in pairs(ooutputs) do
            o[name] = create.neuron(oneuron.bias)
            table.insert(rawdump.neurons, o[name])
        end

        for lc, olayer in ipairs(olayers) do
            if lc == 1 then
                for c, op in ipairs(l[lc]) do
                    for name, ip in pairs(i) do
                        table.insert(rawdump.synapses, create.synapse(ip, op))
                    end
                end
            else
                for c, op in ipairs(l[lc]) do
                    for c2, ip in ipairs(l[lc-1]) do
                        table.insert(rawdump.synapses, create.synapse(ip, op, olayer[c].synapses[c2].weight))
                    end
                end
            end
        end
    else
        for _, name in ipairs(inputs) do
            i[name] = create.neuron()
            table.insert(rawdump.neurons, i[name])
        end
        
        for layer, num in ipairs(layers) do
            l[layer] = {}
            for c = 1, num do
                l[layer][c] = create.neuron()
                table.insert(rawdump.neurons, l[layer][c])
            end
        end
        
        for _, name in ipairs(outputs) do
            o[name] = create.neuron()
            table.insert(rawdump.neurons, o[name])
        end

        for lc, layer in ipairs(l) do
            if lc == 1 then
                for c, op in ipairs(l[lc]) do
                    for name, ip in pairs(i) do
                        table.insert(rawdump.synapses, create.synapse(ip, op))
                    end
                end
            else
                for c, op in ipairs(l[lc]) do
                    for c2, ip in ipairs(l[lc-1]) do
                        table.insert(rawdump.synapses, create.synapse(ip, op))
                    end
                end
            end
        end
    
        for name, op in pairs(o) do
            for c, ip in ipairs(l[#l]) do
                table.insert(rawdump.synapses, create.synapse(ip, op))
            end
        end
    end

    local handle = {}

    function handle.set(name, value)
        i[name].signal(value)
    end

    function handle.get(name, value)
        return o[name].post
    end

    function handle.calculate()
        for name, layer in pairs(l) do
            for c, neuron in ipairs(layer) do
                neuron.receive()
            end
        end

        for c, neuron in pairs(o) do
            neuron.receive()
        end
    end

    function handle.nudge(gravity)
        gravity = gravity or 1

        for _, syn in ipairs(rawdump.synapses) do
            syn.weight = syn.weight*(1 + (math.random()*2 - 1)*gravity/10)
        end

        for _, neur in ipairs(rawdump.neurons) do
            neur.bias = neur.bias + (math.random(0, 1) == 0 and -1 or 1)*(gravity*math.random()/3)
        end
    end

    function handle.clone()
        return create.brain({handle, i, l, o})
    end

    return handle
end

return neural