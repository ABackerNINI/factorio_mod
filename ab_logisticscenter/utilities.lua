require("config")
------------------------------------------------------------------------------------------------------
--LOCAL VARS/FUNCTIONS
local config = get_config()
local names = get_names()

local function calc_distance_between_two_points(p1,p2)
    local dx = math.abs(p1.x-p2.x)
    local dy = math.abs(p1.y-p2.y)
    return math.sqrt(dx*dx+dy*dy)
end

local function position_to_string(p)
    return p.x .. "," .. p.y
end

------------------------------------------------------------------------------------------------------
--META TABLE Stack(First In,Last Out)
Stack = {
    data = {},
    p = 1
}

function Stack:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function Stack:push(v)
    self.data[self.p] = v
    self.p = self.p + 1
end

function Stack:pop()
    self.p = self.p - 1
    return self.data[self.p]
end

function Stack:count()
    return self.p - 1
end

------------------------------------------------------------------------------------------------------
--INIT FUNCTIONS
--call on mod init.should call it only once
function init_globals()
    --{index,items = {["item_name"] = {index,stock}}}
    global.items_stock = global.items_stock or {
        index = 1,
        items = {}
    }

    --multi-lc causes a severe bug on energy consumption
    --{count,entities = {["pos_str"] = {lc,eei}}}
    global.lc_entities = global.lc_entities or {
        count = 0,
        entities = {}
    } 

    --{count,empty_stack,entities = {[index] = {entity,nearest_lc = {distance,lc_pos_str}}}}
    global.cc_entities = global.cc_entities or {
        count = 0,
        empty_stack = Stack:new(),
        entities = {}
    } 

    --{count,empty_stack,entities = {[index] = {entity,nearest_lc = {distance,lc_pos_str}}}}
    global.rc_entities = global.rc_entities or {
        count = 0,
        empty_stack = Stack:new(),
        entities = {}
    }
end

--call this before calling functions of Stock,Lc,Cc,Rc
function init_utilities()
    Stock.data = global.items_stock
    Lc.data = global.lc_entities
    Cc.data = global.cc_entities
    Cc.check_percentage = config.check_cc_percentage
    Rc.data = global.rc_entities
    Rc.check_percentage = config.check_rc_percentage

    --cc/rc counts may change after migrations
    Cc:_recalc_cpr()
    Rc:_recalc_cpr()
end

function migrations_during_alpha()
    if global.cc_entities ~= nil and global.cc_entities.index ~= nil then
        --global.cc_entities
        --OLD {index,entities = {["index_str"] = {index,entity,nearest_lc = {distance,lc_pos_str}}}}
        --NEW {count,empty_stack,entities = {[index] = {entity,nearest_lc = {distance,lc_pos_str}}}}
        local cc_entities = {
            count = 0,
            empty_stack = Stack:new(),
            entities = {}
        }
        local cc_count = 0
        for k,v in pairs(global.cc_entities.entities) do
            cc_count = cc_count + 1
            cc_entities.entities[cc_count] = {entity = v.entity,nearest_lc = v.nearest_lc}
        end
        cc_entities.count = cc_count
        global.cc_entities = nil
        global.cc_entities = cc_entities

        --global.rc_entities
        --OLD {index,entities = {["index_str"] = {index,entity,nearest_lc = {distance,lc_pos_str}}}}
        --NEW {count,empty_stack,entities = {[index] = {entity,nearest_lc = {distance,lc_pos_str}}}}
        local rc_entities = {
            count = 0,
            empty_stack = Stack:new(),
            entities = {}
        }
        local rc_count = 0
        for k,v in pairs(global.rc_entities.entities) do
            rc_count = rc_count + 1
            rc_entities.entities[rc_count] = {entity = v.entity,nearest_lc = v.nearest_lc}
        end
        rc_entities.count = rc_count
        global.rc_entities = nil
        global.rc_entities = rc_entities
    end
end

------------------------------------------------------------------------------------------------------
--META TABLE Stock
Stock = {data = nil}

function Stock:_add_new_item(item_name)
    self.data.items[item_name] = {index = self.data.index,stock = 0}
    self.data.index = self.data.index + 1
end

function Stock:get_item(item_name)
    local item = self.data.items[item_name]
    if item == nil then
        self:_add_new_item(item_name)
        item = self.data.items[item_name]
    end
    return item
end

function Stock:update_all_signals()
    for k,_ in pairs(self.data.items) do
        Lc:update_signals(k)
    end
end

------------------------------------------------------------------------------------------------------
--META TABLE Lc
Lc = {data = nil}

function Lc:on_built(entity)
    --disable signal output on default,this will cause a problem that signals don't show up immediately after control-behavior enabled
    entity.get_or_create_control_behavior().enabled = false

    --will confilct when entity on diffrent surfaces?
    self.data.entities[position_to_string(entity.position)] = { 
        lc = entity,
        eei = entity.surface.create_entity{
            name = names.electric_energy_interface,
            position = entity.position,
            force = entity.force
        }
    }
    self.data.count = self.data.count + 1
    
    --re-calc distance
    Cc:recalc_distance()
    Rc:recalc_distance()
end

function Lc:on_destroyed(entity)
    local p_str = position_to_string(entity.position)

    global.lc_entities.count = global.lc_entities.count - 1

    --destroy the electric energy interface
    global.lc_entities.entities[p_str].eei.destroy()
    global.lc_entities.entities[p_str] = nil

    --re-calc distance
    Cc:recalc_distance()
    Rc:recalc_distance()
end

function Lc:find_nearest(entity)
    local nearest_lc_pack = nil
    local nearest_distance = 1000000000 --should big enough
    for _,v in pairs(self.data.entities) do
        local distance = calc_distance_between_two_points(entity.position,v.lc.position)
        if distance < nearest_distance then
            nearest_distance = distance
            nearest_lc_pack = v
        end
    end

    if nearest_lc_pack ~= nil then 
        return {
            distance = nearest_distance,
            lc_pos_str = position_to_string(nearest_lc_pack.lc.position)
        }
    else
        return nil
    end
end

function Lc:update_signals(item_name)
    for _,v in pairs(self.data.entities) do
        local control_behavior = v.lc.get_or_create_control_behavior()
        if control_behavior.enabled then
            local item = Stock:get_item(item_name)
            
            if item.index < config.lc_item_slot_count then
                --TODO if item.index > config.lc_item_slot_count
                if item.stock > 0 then
                    local signal = {signal = {type = "item",name = item_name},count = item.stock}
                    control_behavior.set_signal(item.index,signal)
                else
                    control_behavior.set_signal(item.index,nil)
                end
            end
        end
    end
end

function Lc:get_eei(pos_str)
    return self.data.entities[pos_str].eei
end

------------------------------------------------------------------------------------------------------
--META TABLE CRc(Cc and Rc)
CRc = {data = nil,check_percentage = 0,check_per_round = 0,checked_index = 0}

function CRc:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

--call after cc/rc counts changed
function CRc:_recalc_cpr()
    self.check_per_round = math.ceil(self.data.count * self.check_percentage)
end

--add cc/rc to the watch-list
function CRc:_add(entity)
    self.data.count = self.data.count + 1

    local index = self.data.count
    if self.data.empty_stack:count() > 0 then
        index = self.data.empty_stack:pop()
    end
    self.data.entities[index] = {entity = entity,nearest_lc = Lc:find_nearest(entity)}

    self:_recalc_cpr()
end

--remove cc/rc from the watch-list
function CRc:_remove(index)
    self.data.count = self.data.count - 1
    self.data.entities[index] = nil
    self.data.empty_stack:push(index)

    self:_recalc_cpr()
end

function CRc:on_built(entity)
    self:_add(entity)
end

function CRc:on_destroyed(entity)
    --can't get index by entity except using 'for'
    --no need to call _remove here,
    --but should check valid before using entities stored in the watch-list
    -- self:_remove()
end

--recalc distance from cc/rc to the nearest lc
--call after lc entity being created or destoried 
function CRc:recalc_distance()
    for _,v in ipairs(self.data.entities) do
        if v.entity.valid then
            v.nearest_lc = Lc:find_nearest(v.entity)
        else
            self:_remove(v.index)
        end
    end
end

function CRc:check()
    if global.lc_entities.count < 1 then return end

    local index_begin = self.checked_index + 1
    local index_end = index_begin + self.check_per_round

    self:_check(index_begin,index_end)

    if self.data.count ~= 0 then
        self.checked_index = index_end % self.data.count
    else
        self.checked_index = 0
    end
end

------------------------------------------------------------------------------------------------------
--META TABLE Cc
Cc = CRc:new()

function Cc:_check(index_begin,index_end)
    -- game.print(index_begin.." "..index_end)
    for index = index_begin,index_end,1 do
        local idx = index
        if idx > self.data.count then idx = idx - self.data.count end
        local v = self.data.entities[idx]
        if v ~= nil then 
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()
                if not inventory.is_empty() then
                    local power_consumption = config.cc_power_consumption * v.nearest_lc.distance
                    local contents = inventory.get_contents()

                    for name,count in pairs(contents) do
                        local eei = Lc:get_eei(v.nearest_lc.lc_pos_str)

                        local item = Stock:get_item(name)
                        
                        --enough energy?
                        count = math.min(count,math.floor(eei.energy/power_consumption))
                        --enough capacity?
                        count = math.min(count,config.lc_capacity - item.stock)

                        if count > 0 then
                            inventory.remove({name = name,count = count})
                            item.stock = item.stock + count
                            eei.energy = eei.energy - count * power_consumption
                            Lc:update_signals(name)
                        end
                    end
                end
            else
                --remove invalid collecter chest
                self:_remove(idx)
            end
        end
    end
end

------------------------------------------------------------------------------------------------------
--META TABLE Rc
Rc = CRc:new()

function Rc:_check(index_begin,index_end)
    -- game.print(index_begin.." "..index_end)
    for index = index_begin,index_end,1 do
        local idx = index
        if idx > self.data.count then idx = idx - self.data.count end
        local v = self.data.entities[idx]
        if v ~= nil then
            if v.entity.valid then
                local inventory = v.entity.get_output_inventory()

                for i = 1,config.rc_logistic_slots_count do
                    local request_slot = v.entity.get_request_slot(i)
                    if request_slot ~= nil then
                        local eei = Lc:get_eei(v.nearest_lc.lc_pos_str)
                        local power_consumption = config.rc_power_consumption * v.nearest_lc.distance
                        local name = request_slot.name
                        local count = request_slot.count

                        local item = Stock:get_item(name)

                        --calc shortage
                        count = count - inventory.get_item_count(name)
                        --enough stock?
                        count = math.min(count,item.stock)
                        --enough energy?
                        count = math.min(count,math.floor(eei.energy/power_consumption))

                        if count > 0 then
                            --in case the inventory is full
                            local inserted_count = inventory.insert({name = name,count = count})
                            item.stock = item.stock - inserted_count
                            eei.energy = eei.energy - inserted_count * power_consumption
                            Lc:update_signals(name)
                        end
                    end
                end
            else
                --remove invalid requester chest
                self:_remove(idx)
            end
        end
    end
end

------------------------------------------------------------------------------------------------------
