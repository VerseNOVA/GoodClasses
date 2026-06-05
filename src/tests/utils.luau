local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TesterUtils = {}

local GoodClasses = require(ReplicatedStorage.GoodClasses)
type Class<t> = GoodClasses.Class<t>
type Getter<t> = GoodClasses.Getter<t>
type Setter<t> = GoodClasses.Setter<t>
type InternalWrite = GoodClasses.InternalWriter
type InternalReader = GoodClasses.InternalReader
type PropertyConfig = GoodClasses.PropertyConfig

export type Tester = {
	publicProperty: any,
	readonlyProperty: any,
	hiddenProperty: any,
	testMethod: (self: Tester) -> ()
}

export type TestConfig = {
	testReturn: ((any) -> boolean)?,
	successExpected: boolean?,
}

export type TestReturnCallback = (self: Tester, property: any, ...any) -> any

export type Diagnostic = {
	working: boolean,
	externalSuccess: boolean,
	internalSuccess: boolean,
	response: any?,
}

function TesterUtils.Test(self: Tester, property: any, config: TestConfig?, callback: TestReturnCallback, ...): Diagnostic
	config = config or {}
	assert(config)
	config.testReturn = config.testReturn or function() return true end
	config.successExpected = config.successExpected or true


	local success, response = pcall(callback, ...)

	local internalSuccess = success == config.successExpected
	local externalSuccess = if config.testReturn then config.testReturn(response) else true
	return{
		working = internalSuccess and externalSuccess,
		externalSuccess = externalSuccess,
		internalSuccess = internalSuccess,
		response = response,
	}
end

function TesterUtils.TestRead(self: Tester, property: any, config: TestConfig?): Diagnostic
	return TesterUtils.Test(self, property, config, function()
		--this and TestWrite dont put values in the callback parameters bc they already have everything they need
		return self[property]
	end)
end

function TesterUtils.TestWrite(self: Tester, property: any, value: any, config: TestConfig?): Diagnostic
	return TesterUtils.Test(self, property, config, function()
		--this and TestRead dont put values in the callback parameters bc they already have everything they need
		self[property] = value
		return self[property]
	end)
end

return TesterUtils
