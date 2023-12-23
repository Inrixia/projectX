--- @alias Register fun(methods: table<any, fun(event: EventData)>)
--- @alias RegisterWithFilters fun(methods: table<any, fun(event: EventData)>, filters: EventFilter[])

--- @alias MakeFilter fun(key: any): EventFilter

--- @alias EventType defines.events

--- @class EventHandler
--- @field private eventType EventType
--- @field private register Register | RegisterWithFilters
--- @field private makeFilter MakeFilter
--- @field private methods table<any, fun(event: EventData)>
--- @field private filters table<any, EventFilter>
--- @field private filtersKeyIndex table<any, number>
local EventHandler = {}
EventHandler.__index = EventHandler

--- @param eventType EventType
--- @param register Register
--- @overload fun(eventType: EventType, register: RegisterWithFilters, makeFilter: MakeFilter)
function EventHandler.new(eventType, register, makeFilter)
	local self = setmetatable({}, EventHandler)
	self.eventType = eventType
	self.register = register
	self.makeFilter = makeFilter
	self.methods = {}
	self.filters = {}
	self.filtersKeyIndex = {}

	return self
end

function EventHandler:add(key, method)
	self.methods[key] = method

	if self.makeFilter ~= nil then
		self.filters[key] = self.makeFilter(key)
		self.filtersKeyIndex[key] = #self.filters
		self.register(self.methods, self.filters)
	elseif next(self.methods) ~= nil then
		self.register(self.methods)
	end
end

function EventHandler:remove(key)
	self.methods[key] = nil

	if next(self.methods) ~= nil then
		script.on_event(self.eventType, nil)
		self.filters = {}
		self.filtersKeyIndex = {}
	elseif self.makeFilter ~= nil then
		table.remove(self.filters, self.filtersKeyIndex[key])
		self.filtersKeyIndex[key] = nil

		self.register(self.methods, self.filters)
	end
end

return EventHandler
