--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GoodClasses = require(ReplicatedStorage.GoodClasses)
type Class<t=any> = GoodClasses.Class<t>
type Setter<t> = GoodClasses.Setter<t>
type Getter<t> = GoodClasses.Getter<t>
type PropertyConfig = GoodClasses.PropertyConfig
type InternalWriter = GoodClasses.InternalWriter
type InternalReader = GoodClasses.InternalReader

local GoodClassesTestingUtils = require(ReplicatedStorage.GoodClassesTestingUtils)
type Tester = GoodClassesTestingUtils.Tester
type TestConfig = GoodClassesTestingUtils.TestConfig
type Diagnostic = GoodClassesTestingUtils.Diagnostic
type TestReturnCallback = GoodClassesTestingUtils.TestReturnCallback

local diagnostic: {[string]: Diagnostic} = {}

local TestingClass: Class<Tester> = GoodClasses.new("ClientTester")
TestingClass:property("publicProperty")
TestingClass:property("readonlyProperty", nil, {
	readonly = true,
	hidden = false
})
TestingClass:property("hiddenProperty", nil, {
	readonly = true,
	hidden = true
})
TestingClass:method("testMethod", function(self: Tester, ...)
	--TODO: may want to format better
	--or make it so that it only prints failures
	print("GoodClasses client test results:")
	print(diagnostic)
end)

local tester: Tester = TestingClass:new()

diagnostic.publicDefaultRead = GoodClassesTestingUtils.TestRead(tester, "publicProperty", {
	testReturn = function(response)
		return response == nil
	end,
	successExpected = true,
})

diagnostic.readonlyDefaultRead = GoodClassesTestingUtils.TestRead(tester, "readonlyProperty", {
	testReturn = function(response)
		return response == nil
	end,
	successExpected = true,
})
diagnostic.hiddenDefaultRead = GoodClassesTestingUtils.TestRead(tester, "hiddenProperty", {
	testReturn = function(response)
		return response ~= nil
	end,
	successExpected = false,
})

diagnostic.publicDefaultWrite = GoodClassesTestingUtils.TestWrite(tester, "publicProperty", "testValue", {
	testReturn = function(response)
		return response == "testValue"
	end,
	successExpected = true
})
diagnostic.readonlyDefaultWrite = GoodClassesTestingUtils.TestWrite(tester, "readonlyProperty", "testValue", {
	testReturn = function(response)
		return response ~= "testValue"
	end,
	successExpected = false,
})
diagnostic.hiddenDefaultWrite = GoodClassesTestingUtils.TestWrite(tester, "hiddenProperty", "testValue", {
	testReturn = function(response)
		return response ~= "testValue"
	end,
	successExpected = false
})

tester:testMethod()
