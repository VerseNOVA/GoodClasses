# GoodClasses

GoodClasses is a python-inspired class encapsulation module for Luau that intends to bring powerful, python-like features to luau classes while allowing users to maintain clean type strictness. 

---

## Development Philosophy

GoodClasses is free and open-sourced software (FOSS) published under the AGPL-v3.0 license.

I developed this based on the backbone of my old [OOP paradigm](https://notaddedyet.com), which has similar capabilities but struggles with type inference in inheritance. GoodClasses gives developers easier gateways to manage property behavior so that they can focus on writing useful code instead of settling the rowdy Luau typechecker (God I hate Luau [intersection types](https://luau.org/types/unions-and-intersections "The bane of my existence; why does a simple intersection of tables turn to a hundred line type definition?")).
___

## Getting Started

To start using GoodClasses, you must [install](#installation) the module first. If you already have it, then see the [documentation](#documentation) to start learning.

It is highly recommended to use [strict typechecking](https://luau.org/types) alongside GoodClasses for the best experience.

___

### Installation

There are several ways to install GoodClasses. The best is with [Wally](#wally), but you can also do it [manually](#manual).

___

#### Wally

**Best for developers using external tools such as VScode or Vim**

**NOTE: the Wally package has not been published yet**

The preferred way to install GoodClasses is with [Wally](https://wally.run/package/versenova/goodclasses "A package manager for Roblox inspired by Cargo (Rust) and npm (JavaScript)").

1. enter your project directory  

2. if you havent already, run `wally init`

3. add the line `goodclasses = "versenova/goodclasses@0.1.0` to your `wally.toml` file  

    example `wally.toml`:
    ```toml
        [package]
        name = "My Wonderful Package"
        version = "0.1.0"
        registry = "https://github.com/UpliftGame/wally-index"
        realm = "shared"

        [place]
        shared-packages = "game.ReplicatedStorage.Packages"
        server-packages = "game.ServerScriptServices.ServerPackages"

        [dependencies]
        goodinstance = "versenova/goodclasses@0.1.0"
    ```
***TODO*** add the package location on the underlines
4. run `wally install`

To update the package, run `wally update`

Now, if your sourcemap is set up properly, you will be able to use GoodInstance. I would also recommend using [wally-package-types](https://github.com/JohnnyMorganz/wally-package-types "A small tool which fixes the issue of wally thunks not including exported types, necessary for proper Luau type checking support.") to get the type exportations from the file.

each time you update run `wally update`, you should also run `wally-package-types --sourcemap /path/to/sourcemap.json Packages/ ServerPackages/` (assuming `Packages/` and `ServerPackages/` are your package folders).

___

#### Manual

**Best option for Roblox Studio users**

You can also install manually. Just copy the [Init.luau](https://github.com/VerseNOVA/GoodClasses/blob/main/src/init.luau) file and use it as a standard Roblox module.

**In the future, GoodClasses may require more than one module.** In this case, you will have to download [GoodClasses from Github](https://github.com/VerseNOVA/GoodClasses). If you do so, **you will have to provide the dependencies (which don't exist right now) yourself.**

### Documentation

___

#### Type Exports

GoodClasses is created with [strict typechecking](https://luau.org/types) in mind. Thus, it exports the following useful types:
```luau
export type PropertyConfig = {
	readonly: boolean?,
	hidden: boolean?,
}

export type Partial<t> = {[any]: any}

export type InternalWriter = (index: any, value: any) -> ()

export type Getter<t> = (self: t) -> any
export type Setter<t> = (self: t, attemptedValue: any, write: InternalWriter) -> ()
export type Method<t> = (self: t, ...any) -> ...any
export type SchemaEntry = {
	default: any,
	definedIn: string, --formatted as "originalClass.otherClass.classDefinedIn"
}

export type Class<t=any> = typeof(setmetatable({}::{
	new: (self: Class<t>, initial: Partial<t>?) -> t,
	property: (self: Class<t>, name: any, default: any?, config: PropertyConfig?) -> Class<t>,
	getter: (self: Class<t>, property: any, fn: Getter<t>) -> Class<t>,
	setter: (self: Class<t>, property: any, fn: Setter<t>) -> Class<t>,
	method: (self: Class<t>, method: any, fn: Method<t>) -> Class<t>,
	extend: (self: Class<t>, newClassName: string) -> Class<t>,
	errors: {
		InvalidWrite: (index: any?, customText: string?) -> (),
	}
}, {}::{__call: (self: Class<t>, initial: Partial<t>?) -> t}))
```

---

#### Class

##### type:
```luau
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

```
##### creating classes:
Classes are returned by GoodClasses.new (`(className: string) -> Class`)

example:
```luau
local newClass: Class = GoodClasses.new("exampleClass")
```

you can explicitly define the type of a class for autofill like so:
```luau
type Player = {
    Name: string,
    Health: number
}

local PlayerClass: Class<Player> = GoodClasses.new("Player")
```

On its own, defining a class does nothing. To make them useful, we must add [features](#features) to them

---

##### features:

Classes have the following methods to add features:
```luau
property: (self: Class<t>, name: any, default: any?, config: PropertyConfig?) -> Class<t>,
getter: (self: Class<t>, property: any, fn: Getter<t>) -> Class<t>,
setter: (self: Class<t>, property: any, fn: Setter<t>) -> Class<t>,
method: (self: Class<t>, method: any, fn: Method<t>) -> Class<t>,
extend: (self: Class<t>, newClassName: string) -> Class<t>,
```
##### property

`(self: Class<t>, name: any, default: any?, config: PropertyConfig?) -> Class<t>`

`PropertyConfig` is defined in [type exports](#type-exports)

Adding a property to a class is as simple as calling `Class:property()` and giving it an index, a default value (optional), and an config (optional)

**examples**

```luau
local class = GoodClasses.new("exampleClass")
class:property("Name", "Unknown")
```

```luau
type Player = {
    Health: number,
    Name: string,
}
local PlayerClass: Class<Player> = GoodClasses.new("Player")
PlayerClass:property("Health", 100)
PlayerClass:property("Name", "Unknown")
```

##### getters and setters

getters and setters add additional functionality to properties. With them, you can define custom functions for type handling and error checking (**TODO** add links for these). You can even make computed values (**TODO** add link for this)

**examples**
```luau
type Player = {
    Health: number,
    Name: string,
}
local PlayerClass: Class<Player> = GoodClasses.new("Player")
PlayerClass:property("Health", 100)
PlayerClass:property("Name", "Unknown")
--note that all setters have the inputs attemptedValue and write. They dont necessarily have
--to have those names.
--write allows a setter to modify any index in the class, making it useful to reactively
--update other properties as well
PlayerClass:setter("Health", function(self: Player, attemptedValue: any, write: InternalWriter)
    if type(attemptedValue) == "number" and attemptedValue >= 0 then
        write("Health", attemptedValue)
    else
        --handle errors here. See error handling in documentation for help
    end
end)
PlayerClass:getter("Name", function(self: Player, read: InternalReader)
    local name = read(self, "Name")
    if name == "Unknown" then
        return "anonymous"
    end
    return name
end)
```

##### methods

`Class:method()` is used to define a method. Similar to traditional LUAU OOP, this allows you to create a function shared between all instances of a class

***examples***

```luau
type Player = {
    Health: number,
    Name: string,
    Die: () -> ()
}
local PlayerClass: Class<Player> = GoodClasses.new("Player")
PlayerClass:property("Health", 100)
PlayerClass:property("Name", "Unknown")
PlayerClass:method("Die", function(self: Player)
    if self.Health == 0 then
        print(`{self.Name} is dead :(`)
    else
        print(`Can't kill {self.Name} if he is healthy :)`)
    end
end)
```

##### inheritance

To make traditional inheritance-based OOP using GoodClasses, you can use `Class:Extend()`. This returns a new class with a new environment, so adding new features to that class doesn't alter the original class.
**examples**

```luau
type Player = {
    Health: number,
    Name: string,
}
local PlayerClass: Class<Player> = GoodClasses.new("Player")
PlayerClass:property("Health", 100)
PlayerClass:property("Name", "Unknown")

type Wizard = Player & {
    Mana: number
}
local WizardClass: Class<Wizard> = PlayerClass:extend()
WizardClass:property("Mana", 50) --mana is not added to PlayerClass, but it is added to WizardClass
```

##### extras

If you haven't already noticed, feature definition functions return the class. This makes it so that you can chain features together.

**examples**

```luau
type Player = {
    Health: number,
    Name: string,
}
local PlayerClass: Class<Player> = GoodClasses.new("Player")
PlayerClass:property("Name", "unknown"):property("Health", 100):setter(...):getter(...):property(...)
--you can chain in whatever order you want as long as you dont use :extend() in the middle
```

Currently, I am unsure of the exact behavior of shadowing features. It seems that doing so would lead to no major changes, but it could be used to overwrite behavior. **It is not recommended to shadow features because GoodClasses was not made with this in mind. Do so at your own risk**
