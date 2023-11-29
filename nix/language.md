# Langauge Basics
Taken from [here](https://nix.dev/tutorials/nix-language).

- Covers languages basics, not fully
    - This uses the Developers Guide
- For a full exposition, use the Manual

## Interactive mode
To use nix interactively, run `nix repl` in a terminal. This will open a nix repl, where you can evaluate nix expressions. To exit a, use `:q`.

```{sh}
nix repl
1+1
:q
```

You can store a nix expression in a file and run it with `nix-instantiate --eval`. This will evaluate the expression.

```{sh}
cd ~/code/general/nix
mkdir nixScripts && cd nixScripts
echo 1+1 > add.nix
nix-instantiate --eval add.nix
```

Nix uses lazy evaluation, so it will only evaluate things when they are needed.

```{sh}
echo "{ a.b.c = 1; }" > lazy.nix
nix-instantiate --eval lazy.nix # not work
nix-instantiate --eval --strict lazy.nix # works
```

Nix does not care about whitespaces, so you can write the following:

```{sh}
nix repl
let 
    a = 1;
    b = 2;
in a + b

# or...
let a = 1; b = 2; in a + b
```

To a value to a variable, we use `=` and `;` to demarcat the end of a line. We use `let` to define a variable when it is needed several times. We can also use `in` to use the variable.

To create an attribute set/list in Nix we can do:
```{sh}
{
    string = "hello";
    integer = 1;
    float = 3.141;
    bool = true;
    null = null;
    list = [ 1 "two" false ]; # sep. by whitespace
    attribute-set = {
        a = "hello";
        b = 2;
        c = 2.718;
        d = false;
    }; # comments are supported
}
```
If we want to recursively set attributes, we can prepend with `rec`:

```{sh}
rec {
    a = 1;
    b = a + 1; # use a to get b
}
```
Whenever we want to access attributes, we can use `attributes.elementName`.

```{sh}
let
    attrset = { x = 1; };
in
    attrset.x
```
Nested access works the same way.

We can also assign elements using the `.elementName` syntax.

```{sh}
let 
    attrset = { x = 1; };

attrset.b = 2;
in
    attrset.b
```

We can use `with` to access attributes without having to use the `.` syntax.

```{sh}
let
    attrset = { x = 1; y = 2; z = 3;};
in with attrset; x + y + z
```
Attributes made available through with are only in scope of the expression following the semicolon (`;`).

We can use `inherit` to inherit attributes from another attribute set.

```{sh}
let
    x = 1;
    a = {x=50; y=56; };
in {
    inherit (a) x y;
}
```

We can interpolate strings:
```{sh}
let
  name = "Oskar";
in
"hello ${name}"
```

## File system
Paths work the same way in Nix as for other shells (it seems like).

The angle bracket syntax can be used to identify a path from an object.
```{sh}
<nixpkgs>
# gives...
/nix/var/nix/profiles/per-user/root/channels/nixpkgs
```
These should be used interactively.

We can use multi-strings using `''`
```{sh}
''
    hello
    world
''
```

## Functions
A nix function only accepts on argument. We use `:` followed by whitespace to declare a function and its body. Functions can look in many ways in nix.

```{sh}
let f = x: x + 1;
in f 1
```

If we want a function to have to arguments, we need to curry them.

```{sh}
let f = x: y: x + y;
in f 1 2
```

We can use keyword arguments to make functions more readable.

```{sh}
let f = { x, y }: x + y;
in f { x = 1; y = 2; }
```
But not like:
```{sh}
let
    f = {a, b, c}: a + b + c;
in
f { a = 1; b = 2; }
# OR
let
    f = {a, b}: a + b;
in
f { a = 1; b = 2; c = 3; }
```

We can list default values:
```{sh}
let
    f = { a, b ? 100 }: a + b;
in
f { a = 1; }
```
- `?` denotes an if missing then operator.

```
let
    f = {a ? 0, b ? 0}: a + b;
in
f { } # empty attribute set
```

We can use `...` to pass additional arguments to a function.

```{sh}
let
    f = { a, b, ... }: a + b;
in
f { a = 1; b = 2; c = 3; }
```
Unlike the example above, this did not throw and error.

We can use `@` to pass a set of arguments to a function.

```{sh}
let
    f = {a, b, ...}@dots: a + b + dots.c;
in
f { a = 1; b = 2; c = 3; }
```

## Functional libraries
Together with the standard operators in Nix, the packages `lib` and `builtins` are available and may be described as the "base" of Nix.

```{sh}
1 == 1;
2 >= 2
1 - 1
(1-1) < 1
```
### builtins
```{sh}
builtins.toString 1
builtins.toString 1.0
builtins.toString true
builtins.toString null
builtins.toString [ 1 2 3 ]
builtins.toString { a = 1; b = 2; }
```

### import
```{sh}
let pkgs = import <nixpkgs> {}; # imports the nixpkgs attribute set
in
    pkgs.lib.strings.toUpper "lookup paths considered harmful"

# We can also use a file
import ./add.nix
```

## Derivations
Derivations are the core of Nix. They are used to build packages with specific settings. They are functions that take a set of arguments and return attrbiutes.

For example, show the path to the nix packages:
```{sh}
let
  pkgs = import <nixpkgs> {};
in "${pkgs.nix}"
```

## Examples
The below example should be saved in a file called `shell.nix` and run with `nix-shell`.


```{sh}
cd ~/code/general/nix
mkdir declarativeExample && cd declarativeExample
vim shell.nix
# -- Paste the following:
{ pkgs ? import <nixpkgs> {} }:
let
  message = "Nix shell is ready, get to work!";
in
pkgs.mkShell {
  buildInputs = with pkgs; [ cowsay lolcat ];
  shellHook = ''
    cowsay ${message} | lolcat
  '';
}

# Build
nix-shell
```

