--!strict
--!optimize 2
--!native
--
-- GoodClasses
-- Copyright (C) 2026  VerseNOVA
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--
local GoodClasses = {}
GoodClasses.interface = {}

export type PropertyConfig = {
	readonly: boolean,
	hidden: boolean,
}

export type Partial<t> = {[any]: any}

export type InternalWriter = (index: any, value: any) -> ()
export type InternalReader = (index: any) -> any

export type Getter<t> = (self: t, read: InternalReader) -> any
export type Setter<t> = (self: t, attemptedValue: any, write: InternalWriter) -> ()
export type Method<t> = (self: t, ...any) -> ...any
export type SchemaEntry = {
	default: any,
	definedIn: string, --formatted as "originalClass.otherClass.classDefinedIn"
}

export type Class<t=any> = {
	new: (self: Class<t>, initial: Partial<t>?) -> t,
	property: (self: Class<t>, name: any, default: any?, config: PropertyConfig?) -> Class<t>,
	getter: (self: Class<t>, property: any, fn: Getter<t>) -> Class<t>,
	setter: (self: Class<t>, property: any, fn: Setter<t>) -> Class<t>,
	method: (self: Class<t>, method: any, fn: Method<t>) -> Class<t>,
	extend: (self: Class<t>, newClassName: string) -> Class<t>,
	errors: {
		InvalidWrite: (index: any?, customText: string?) -> (),
	}
}

type env<t> = {
	parent: env<t>?,
	fullClassName: string,
	schema: {[any]: SchemaEntry},
	getters: {[any]: Getter<t>},
	setters: {[any]: Setter<t>},
	methods: {[any]: Method<t>},
	readonly: {[any]: boolean},
	hidden: {[any]: boolean},
}

function GoodClasses.__new<t>(className: string, parentEnv: env<any>?): Class<t>
	local class = {}

	local env: env<any> = {
		parent = parentEnv,
		fullClassName = className,
		schema = {},
		getters = {},
		setters = {},
		methods = {},
		readonly = {},
		hidden = {},
	}

	if parentEnv then
		setmetatable(env.schema, {__index = parentEnv.schema})
		setmetatable(env.getters, {__index = parentEnv.getters})
		setmetatable(env.setters, {__index = parentEnv.setters})
		setmetatable(env.methods, {__index = parentEnv.methods})
		setmetatable(env.readonly, {__index = parentEnv.readonly})
		setmetatable(env.hidden, {__index = parentEnv.hidden})
		env.fullClassName = `{parentEnv.fullClassName}.{className}`
	end

	function class:property(name: any, default: any?, config: PropertyConfig?)
		assert(env.methods[name] == nil, `Method {name} already exists`)
		config = config or {
			readonly = false,
			hidden = false,
		}
		assert(config)
		env.schema[name] = { default = default, definedIn = env.fullClassName}
		if config.readonly then
			env.readonly[name] = true
		end
		if config.hidden then
			env.hidden[name] = true
		end
		return self
	end

	function class:getter<t>(name: any, fn: Getter<t>): Class<t>
		env.getters[name] = fn
		return self
	end

	function class:setter<t>(name: any, fn: Setter<t>): Class<t>
		env.setters[name] = fn
		return self
	end

	function class:method<t>(name: any, fn: Method<t>): Class<t>
		assert(env.schema[name] == nil, `Property {name} already exists`)
		env.methods[name] = fn
		return self
	end

	function class:extend<t>(newClassName: string): Class<t>
		return GoodClasses.__new(newClassName, env) :: Class<t> --this assertion may be cause for some errors.
		--adding it silences the setmetatable(..., {__call = ...}) error later
	end

	class.errors = {}
	function class.errors.InvalidWrite(index: any?, customString: string?)
		index = index or "[NO INDEX PROVIDED]"
		error(debug.traceback(`Invalid write to index "{index}" in class "{env.fullClassName}":\n\t{customString}`))
	end

	function class:new<t>(initial: {}?): t
		initial = initial or {}
		assert(initial)
		local internal = {}

		for k, v in pairs(env.schema) do
			internal[k] = v.default
		end

		local proxy = {}

		local function write(index: any, value: any)
			internal[index] = value
		end

		local function read(index: any)
			return internal[index]
		end

		setmetatable(proxy, {
			__index = function(_, key: any)
				if env.hidden[key] then
					error(debug.traceback(`Cannot read hidden property {key} of {env.fullClassName}`))
				end

				if env.methods[key] then
					return env.methods[key]
				end

				if env.getters[key] then
					return env.getters[key](proxy, read)
				end

				if env.schema[key] ~= nil then
					return internal[key]
				end

				error(debug.traceback(`Attempt to read nonexistent property {key} of {env.fullClassName}`))
			end,
			__newindex = function(_, key: any, value: any)
				if env.hidden[key] then
					error(debug.traceback(`Cannot write to hidden property {key} of {env.fullClassName}`))
				end

				if env.readonly[key] then
					error(debug.traceback(`Cannot write to readonly property {key} of {env.fullClassName}`))
				end

				if env.setters[key] then
					env.setters[key](proxy, value, write)
					return
				end

				if env.schema[key] ~= nil then
					internal[key] = value
					return
				end

				error(debug.traceback(`Attempt to write to nonexistent property {key} of {env.fullClassName}`))
			end
		})	

		for k, v in pairs(initial) do
			if env.schema[k] == nil then
				error(`Attempt to initialize with nonexistent property {k} of {env.fullClassName}`)
			end
			if env.readonly[k] then
				error(`Attempt to set readonly property {k} of {env.fullClassName} on initialization`)
			end
			proxy[k] = v
		end

		return proxy :: t & never
	end

	return setmetatable(class, {
		__call = function(_, initial)
			return class:new(initial)
		end
	}) :: Class<t> & never

end

function GoodClasses.interface.new(className: string)
	return GoodClasses.__new(className)
end

return GoodClasses.interface
