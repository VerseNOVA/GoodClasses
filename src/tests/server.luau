--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local diagnostics = {}

local GoodClasses = require(ReplicatedStorage.GoodClasses)
type Class<t> = GoodClasses.Class<t>
type Getter<t> = GoodClasses.Getter<t>
type Setter<t> = GoodClasses.Setter<t>
type InternalWrite = GoodClasses.InternalWriter
type InternalReader = GoodClasses.InternalReader
type PropertyConfig = GoodClasses.PropertyConfig

type Tester = {
	publicProperty: any,
	readonlyProperty: any,
	hiddenProperty: any,
	testMethod: (self: Tester) -> ()
}

local ServerTestClass: Class<Tester> = GoodClasses.new("ServerTester")
ServerTestClass:property("publicProperty")
ServerTestClass:property("readonlyProperty", nil, {
	readonly = true,
	hidden = false
})
ServerTestClass:property("hiddenProperty", nil, {
	readonly = false,
	hidden = true
})
ServerTestClass:method("testMethod", function(self: Tester, ...) 
	local defaultPublicGetSuccess, defaultPublicGetResponse = pcall(function()
		return self.publicProperty
	end)
	diagnostics.defaultPublicPropertyGet = {
		working = defaultPublicGetSuccess,
		response = defaultPublicGetResponse,
		intendedValue = nil,
	}

	local defaultPublicSetSuccess, defaultPublicSetResponse = pcall(function()
		self.publicProperty = "test"
		return self.publicProperty
	end)
	diagnostics.defaultPublicPropertySet = {
		working = defaultPublicSetSuccess,
		message = defaultPublicSetResponse,
		attemptedSetValue = "test",
		intendedValue = "test",
	}
	
	local defaultReadonlyGetSuccess, defaultReadonlyGetResponse = pcall(function()
		return self.readonlyProperty
	end)
	diagnostics.defaultReadonlyPropertyGet = {
		working = defaultReadonlyGetSuccess,
		message = defaultReadonlyGetResponse,
		intendedValue = nil,
	}

	local defaultReadonlySetSuccess, defaultReadonlySetResponse = pcall(function()
		self.readonlyProperty = "test"
	end)
	diagnostics.defaultReadonlyPropertySet = {
		working = not defaultReadonlySetSuccess,
		response = defaultReadonlySetResponse,
		attemptedSetValue = "test",
		intendedValue = nil,
	}

	local defaultHiddenGetSuccess, defaultHiddenGetResponse = pcall(function()
		return self.hiddenProperty
	end)
	diagnostics.defaultHiddenPropertyGet = {
		working = not defaultHiddenGetSuccess,
		message = defaultHiddenGetResponse,
		intendedValue = "nil",
	}

	local defaultHiddenSetSuccess, defaultHiddenSetResponse = pcall(function()
		self.hiddenProperty = "test"
		return self.hiddenProperty
	end)
	diagnostics.defaultHiddenPropertySet = {
		working = not defaultHiddenSetSuccess,
		message = defaultHiddenSetResponse,
		attemptedSetValue = "test",
		intendedValue = nil
	}
end)

local new = ServerTestClass:new()
new:testMethod()
--TODO: abstract testing more so its easier to update tests as this is developed. Utils is in progress.
