
# Prosody Coding Style Guide

This style guides lists the coding conventions used in the
[Prosody](https://prosody.im/) project. It is based heavily on the [style guide used by the LuaRocks project](https://github.com/luarocks/lua-style-guide).

## Indentation and formatting

* Prosody code is indented with tabs at the start of the line, a single
  tab per logical indent level:

```lua
for i, pkg in ipairs(packages) do
    for name, version in pairs(pkg) do
        if name == searched then
            print(version);
        end
    end
end
```

Tab width is configurable in editors, so never assume a particular width.
Specifically this means you should not mix tabs and spaces, or use tabs for
alignment of items at different indentation levels.

* Use LF (Unix) line endings.

## Comments

* Comments are encouraged where necessary to explain non-obvious code.

* In general comments should be used to explain 'why', not 'how'

### Comment tags

A comment may be prefixed with one of the following tags:

* **FIXME**: Indicates a serious problem with the code that should be addressed
* **TODO**: Indicates an open task, feature request or code restructuring that
  is primarily of interest to developers (otherwise it should be in the
  issue tracker).
* **COMPAT**: Must be used on all code that is present only for backwards-compatibility,
  and may be removed one day. For example code that is added to support old
  or buggy third-party software or dependencies.

**Example:**

```lua
-- TODO: implement method
local function something()
   -- FIXME: check conditions
end

```

## Variable names

* Variable names with larger scope should be more descriptive than those with
smaller scope. One-letter variable names should be avoided except for very
small scopes (less than ten lines) or for iterators.

* `i` should be used only as a counter variable in for loops (either numeric for
or `ipairs`).

* Prefer more descriptive names than `k` and `v` when iterating with `pairs`,
unless you are writing a function that operates on generic tables.

* Use `_` for ignored variables (e.g. in for loops:)

```lua
for _, item in ipairs(items) do
   do_something_with_item(item);
end
```

* Generally all identifiers (variables and function names) should use `snake_case`,
  i.e. lowercase words joined by `_`.

```lua
-- bad
local OBJEcttsssss = {}
local thisIsMyObject = {}
local c = function()
   -- ...stuff...
end

-- good
local this_is_my_object = {};

local function do_that_thing()
   -- ...stuff...
end
```

> **Rationale:** The standard library uses lowercase APIs, with `joinedlowercase`
names, but this does not scale too well for more complex APIs. `snake_case`
tends to look good enough and not too out-of-place along side the standard
APIs.

```lua
for _, name in pairs(names) do
   -- ...stuff...
end
```

* Prefer using `is_` when naming boolean functions:

```lua
-- bad
local function evil(alignment)
   return alignment < 100
end

-- good
local function is_evil(alignment)
   return alignment < 100;
end
```

* `UPPER_CASE` is to be used sparingly, with "constants" only.

> **Rationale:** "Sparingly", since Lua does not have real constants. This
notation is most useful in libraries that bind C libraries, when bringing over
constants from C.

* Do not use uppercase names starting with `_`, they are reserved by Lua.

## Tables

* When creating a table, prefer populating its fields all at once, if possible:

```lua
local player = { name = "Jack", class = "Rogue" };
```

* Items should be separated by commas. If there are many items, put each
  key/value on a separate line and use a semi-colon after each item (including
  the last one):

```lua
local player = {
   name = "Jack";
   class = "Rogue";
}
```

> **Rationale:** This makes the structure of your tables more evident at a glance.
Trailing semi-colons make it quicker to add new fields and produces shorter diffs.

* Use plain `key` syntax whenever possible, use `["key"]` syntax when using names
that can't be represented as identifiers and avoid mixing representations in
a declaration:

```lua
local mytable = {
   ["1394-E"] = val1;
   ["UTF-8"] = val2;
   ["and"] = val2;
}
```

## Strings

* Use `"double quotes"` for strings; use `'single quotes'` when writing strings
that contain double quotes.

```lua
local name = "Prosody";
local sentence = 'The name of the program is "Prosody"';
```

> **Rationale:** Double quotes are used as string delimiters in a larger number of
programming languages. Single quotes are useful for avoiding escaping when
using double quotes in literals.

## Line lengths

* There are no hard or soft limits on line lengths. Line lengths are naturally
limited by using one statement per line. If that still produces lines that are
too long (e.g. an expression that produces a line over 256-characters long,
for example), this means the expression is too complex and would do better
split into subexpressions with reasonable names.

> **Rationale:** No one works on VT100 terminals anymore. If line lengths are a proxy
for code complexity, we should address code complexity instead of using line
breaks to fit mind-bending statements over multiple lines.

## Function declaration syntax

* Prefer function syntax over variable syntax. This helps differentiate between
named and anonymous functions.

```lua
-- bad
local nope = function(name, options)
   -- ...stuff...
end

-- good
local function yup(name, options)
   -- ...stuff...
end
```

* Perform validation early and return as early as possible.

```lua
-- bad
local function is_good_name(name, options, arg)
   local is_good = #name > 3
   is_good = is_good and #name < 30

   -- ...stuff...

   return is_good
end

-- good
local function is_good_name(name, options, args)
   if #name < 3 or #name > 30 then
      return false;
   end

   -- ...stuff...

   return true;
end
```

## Function calls

* Even though Lua allows it, generally you should not omit parentheses
  for functions that take a unique string literal argument.

```lua
-- bad
local data = get_data"KRP"..tostring(area_number)
-- good
local data = get_data("KRP"..tostring(area_number));
local data = get_data("KRP")..tostring(area_number);
```

> **Rationale:** It is not obvious at a glace what the precedence rules are
when omitting the parentheses in a function call. Can you quickly tell which
of the two "good" examples in equivalent to the "bad" one? (It's the second
one).

* You should not omit parenthesis for functions that take a unique table
argument on a single line. You may do so for table arguments that span several
lines.

```lua
local an_instance = a_module.new {
   a_parameter = 42;
   another_parameter = "yay";
}
```

> **Rationale:** The use as in `a_module.new` above occurs alone in a statement,
so there are no precedence issues.

## Table attributes

* Use dot notation when accessing known properties.

```lua
local luke = {
   jedi = true;
   age = 28;
}

-- bad
local is_jedi = luke["jedi"]

-- good
local is_jedi = luke.jedi;
```

* Use subscript notation `[]` when accessing properties with a variable or if using a table as a list.

```lua
local vehicles = load_vehicles_from_disk("vehicles.dat")

if vehicles["Porsche"] then
   porsche_handler(vehicles["Porsche"]);
   vehicles["Porsche"] = nil;
end
for name, cars in pairs(vehicles) do
   regular_handler(cars);
end
```

> **Rationale:** Using dot notation makes it clearer that the given key is meant
to be used as a record/object field.

## Functions in tables

* When declaring modules and classes, declare functions external to the table definition:

```lua
local my_module = {};

function my_module.a_function(x)
   -- code
end
```

* When declaring metatables, declare function internal to the table definition.

```lua
local version_mt = {
   __eq = function(a, b)
      -- code
   end;
   __lt = function(a, b)
      -- code
   end;
}
```

> **Rationale:** Metatables contain special behavior that affect the tables
they're assigned (and are used implicitly at the call site), so it's good to
be able to get a view of the complete behavior of the metatable at a glance.

This is not as important for objects and modules, which usually have way more
code, and which don't fit in a single screen anyway, so nesting them inside
the table does not gain much: when scrolling a longer file, it is more evident
that `check_version` is a method of `Api` if it says `function Api:check_version()`
than if it says `check_version = function()` under some indentation level.

## Variable declaration

* Always use `local` to declare variables.

```lua
-- bad
superpower = get_superpower()

-- good
local superpower = get_superpower();
```

> **Rationale:** Not doing so will result in global variables to avoid polluting
the global namespace.

## Variable scope

* Assign variables with the smallest possible scope.

```lua
-- bad
local function good()
   local name = get_name()

   test()
   print("doing stuff..")

   --...other stuff...

   if name == "test" then
      return false
   end

   return name
end

-- good
local bad = function()
   test();
   print("doing stuff..");

   --...other stuff...

   local name = get_name();

   if name == "test" then
      return false;
   end

   return name;
end
```

> **Rationale:** Lua has proper lexical scoping. Declaring the function later means that its
scope is smaller, so this makes it easier to check for the effects of a variable.

## Conditional expressions

* False and nil are falsy in conditional expressions. Use shortcuts when you
can, unless you need to know the difference between false and nil.

```lua
-- bad
if name ~= nil then
   -- ...stuff...
end

-- good
if name then
   -- ...stuff...
end
```

* Avoid designing APIs which depend on the difference between `nil` and `false`.

* Use the `and`/`or` idiom for the pseudo-ternary operator when it results in
more straightforward code. When nesting expressions, use parentheses to make it
easier to scan visually:

```lua
local function default_name(name)
   -- return the default "Waldo" if name is nil
   return name or "Waldo";
end

local function brew_coffee(machine)
   return (machine and machine.is_loaded) and "coffee brewing" or "fill your water";
end
```

Note that the `x and y or z` as a substitute for `x ? y : z` does not work if
`y` may be `nil` or `false` so avoid it altogether for returning booleans or
values which may be nil.

## Blocks

* Use single-line blocks only for `then return`, `then break` and `function return` (a.k.a "lambda") constructs:

```lua
-- good
if test then break end

-- good
if not ok then return nil, "this failed for this reason: " .. reason end

-- good
use_callback(x, function(k) return k.last end);

-- good
if test then
  return false
end

-- bad
if test < 1 and do_complicated_function(test) == false or seven == 8 and nine == 10 then do_other_complicated_function() end

-- good
if test < 1 and do_complicated_function(test) == false or seven == 8 and nine == 10 then
   do_other_complicated_function();
   return false;
end
```

* Separate statements onto multiple lines. Use semicolons as statement terminators.

```lua
-- bad
local whatever = "sure"
a = 1 b = 2

-- good
local whatever = "sure";
a = 1;
b = 2;
```

## Spacing

* Use a space after `--`.

```lua
--bad
-- good
```

* Always put a space after commas and between operators and assignment signs:

```lua
-- bad
local x = y*9
local numbers={1,2,3}
numbers={1 , 2 , 3}
numbers={1 ,2 ,3}
local strings = { "hello"
                , "Lua"
                , "world"
                }
dog.set( "attr",{
  age="1 year",
  breed="Bernese Mountain Dog"
})

-- good
local x = y * 9;
local numbers = {1, 2, 3};
local strings = {
    "hello";
    "Lua";
    "world";
}
dog.set("attr", {
   age = "1 year";
   breed = "Bernese Mountain Dog";
});
```

* Indent tables and functions according to the start of the line, not the construct:

```lua
-- bad
local my_table = {
                    "hello",
                    "world",
                 }
using_a_callback(x, function(...)
                       print("hello")
                    end)

-- good
local my_table = {
    "hello";
    "world";
}
using_a_callback(x, function(...)
   print("hello");
end)
```

> **Rationale:** This keep indentation levels aligned at predictable places. You don't
need to realign the entire block if something in the first line changes (such as
replacing `x` with `xy` in the `using_a_callback` example above).

* The concatenation operator gets a pass for avoiding spaces:

```lua
-- okay
local message = "Hello, "..user.."! This is your day # "..day.." in our platform!";
```

> **Rationale:** Being at the baseline, the dots already provide some visual spacing.

* No spaces after the name of a function in a declaration or in its arguments:

```lua
-- bad
local function hello ( name, language )
   -- code
end

-- good
local function hello(name, language)
   -- code
end
```

* Add blank lines between functions:

```lua
-- bad
local function foo()
   -- code
end
local function bar()
   -- code
end

-- good
local function foo()
   -- code
end

local function bar()
   -- code
end
```

* Avoid aligning variable declarations:

```lua
-- bad
local a               = 1
local long_identifier = 2

-- good
local a = 1;
local long_identifier = 2;
```

> **Rationale:** This produces extra diffs which add noise to `hg annotate`.

* Alignment is occasionally useful when logical correspondence is to be highlighted:

```lua
-- okay
sys_command(form, UI_FORM_UPDATE_NODE, "a",      FORM_NODE_HIDDEN,  false);
sys_command(form, UI_FORM_UPDATE_NODE, "sample", FORM_NODE_VISIBLE, false);
```

## Typing

* In non-performance critical code, it can be useful to add type-checking assertions
for function arguments:

```lua
function manif.load_manifest(repo_url, lua_version)
   assert(type(repo_url) == "string");
   assert(type(lua_version) == "string" or not lua_version);

   -- ...
end
```

* Use the standard functions for type conversion, avoid relying on coercion:

```lua
-- bad
local total_score = review_score .. ""

-- good
local total_score = tostring(review_score);
```

## Errors

* Functions that can fail for reasons that are expected (e.g. I/O) should
return `nil` and a (string) error message on error, possibly followed by other
return values such as an error code.

* On errors such as API misuse, an error should be thrown, either with `error()`
or `assert()`.

## Modules

Follow [these guidelines](http://hisham.hm/2014/01/02/how-to-write-lua-modules-in-a-post-module-world/) for writing modules. In short:

* Always require a module into a local variable named after the last component of the module’s full name.

```lua
local bar = require("foo.bar"); -- requiring the module

bar.say("hello"); -- using the module
```

* Don’t rename modules arbitrarily:

```lua
-- bad
local skt = require("socket")
```

> **Rationale:** Code is much harder to read if we have to keep going back to the top
to check how you chose to call a module.

* Start a module by declaring its table using the same all-lowercase local
name that will be used to require it. You may use an LDoc comment to identify
the whole module path.

```lua
--- @module foo.bar
local bar = {};
```

* Try to use names that won't clash with your local variables. For instance, don't
name your module something like “size”.

* Use `local function` to declare _local_ functions only: that is, functions
that won’t be accessible from outside the module.

That is, `local function helper_foo()` means that `helper_foo` is really local.

* Public functions are declared in the module table, with dot syntax:

```lua
function bar.say(greeting)
   print(greeting);
end
```

> **Rationale:** Visibility rules are made explicit through syntax.

* Do not set any globals in your module and always return a table in the end.

* If you would like your module to be used as a function, you may set the
`__call` metamethod on the module table instead.

> **Rationale:** Modules should return tables in order to be amenable to have their
contents inspected via the Lua interactive interpreter or other tools.

* Requiring a module should cause no side-effect other than loading other
modules and returning the module table.

* A module should not have state. If a module needs configuration, turn
  it into a factory. For example, do not make something like this:

```lua
-- bad
local mp = require "MessagePack"
mp.set_integer("unsigned")
```

and do something like this instead:

```lua
-- good
local messagepack = require("messagepack");
local mpack = messagepack.new({integer = "unsigned"});
```

* The invocation of require may omit parentheses around the module name:

```lua
local bla = require "bla";
```

## Metatables, classes and objects

If creating a new type of object that has a metatable and methods, the
metatable and methods table should be separate, and the metatable name
should end with `_mt`.

```lua
local mytype_methods = {};
local mytype_mt = { __index = mytype_methods };

function mytype_methods:add_new_thing(thing)
end

local function new()
    return setmetatable({}, mytype_mt);
end

return { new = new };
```

* Use the method notation when invoking methods:

```
-- bad
my_object.my_method(my_object)

-- good
my_object:my_method();
```

> **Rationale:** This makes it explicit that the intent is to use the function as a method.

* Do not rely on the `__gc` metamethod to release resources other than memory.
If your object manage resources such as files, add a `close` method to their
APIs and do not auto-close via `__gc`. Auto-closing via `__gc` would entice
users of your module to not close resources as soon as possible. (Note that
the standard `io` library does not follow this recommendation, and users often
forget that not closing files immediately can lead to "too many open files"
errors when the program runs for a while.)

> **Rationale:** The garbage collector performs automatic *memory* management,
dealing with memory only. There is no guarantees as to when the garbage
collector will be invoked, and memory pressure does not correlate to pressure
on other resources.

## File structure

* Lua files should be named in all lowercase.

* Tests should be in a top-level `spec` directory. Prosody uses
[Busted](http://olivinelabs.com/busted/) for testing.

## Static checking

All code should pass [luacheck](https://github.com/mpeterv/luacheck) using
the `.luacheckrc` provided in the Prosody repository, and using minimal
inline exceptions.

* luacheck warnings of class 211, 212, 213 (unused variable, argument or loop
variable) may be ignored, if the unused variable was added explicitly: for
example, sometimes it is useful, for code understandability, to spell out what
the keys and values in a table are, even if you're only using one of them.
Another example is a function that needs to follow a given signature for API
reasons (e.g. a callback that follows a given format) but doesn't use some of
its arguments; it's better to spell out in the argument what the API the
function implements is, instead of adding `_` variables.

```
local foo, bar = some_function(); --luacheck: ignore 212/foo
print(bar);
```

* luacheck warning 542 (empty if branch) can also be ignored, when a sequence
of `if`/`elseif`/`else` blocks implements a "switch/case"-style list of cases,
and one of the cases is meant to mean "pass". For example:

```lua
if warning >= 600 and warning <= 699 then
   print("no whitespace warnings");
elseif warning == 542 then --luacheck: ignore 542
   -- pass
else
   print("got a warning: "..warning);
end
```

> **Rationale:** This avoids writing negated conditions in the final fallback
case, and it's easy to add another case to the construct without having to
edit the fallback.

