ntangle
=======

Description
-----------

**ntangle** is a plugin which allows you to program in a literal programming style directly in vim. Its features are:

* Automatic code generation on save
* Syntax highlighting
* Build an index of sections for quick access (requires [ctrlp](https://github.com/ctrlpvim/ctrlp.vim))
* Jump to line

Install
-------

The easiest method is install through plugin manager such as [vim-plug](https://github.com/junegunn/vim-plug).

Add this to your plug-in list:

```
Plug 'jbyuki/ntangle.vim'
```

Basic usage
-----------

Open a \*.tl to start editing a ntangle file.  The plug-in should automatically detect the file. To verify it detected the file, type:

```
set ft
```

and it should return

```
ft=tangle
```

Type a ntangle literal program such as:

```
@test.txt=
Hello ntangle
```

After saving the file, it should automatically create an ntangle folder besides the \*.tl which contains test.txt with the following content:

```
Hello ntangle
```

Syntax
------

The **root sections** are defined using the following syntax:

```
@file=
some text
```

Notice it's an `@` sign followed by the name with no spaces followed by a simple `=` sign. ntangle will automatically generate a file for every root nodes. Roots nodes can also contains dots to put an extension such as:

```
@hello.cpp=
std::cout << "hello world" << std::endl;
```

Or it can even contain slashes to put the file in a subdirectory

```
@src/hello.cpp=
std::cout << "hello world" << std::endl;
```

The plain **sections** are defined using the following syntax:

```
@do_something+=
some text
```

Notice it's same as **root sections** except the `+=` signs at the end. These sections will not be output as a file. These are referenced in other sections and eventually in root sections.

Sections can be referenced with the following syntax:

```
@file=
@do_something
@do_something_else
```

This will include the text contained in the section and recursively. **root sections** can also be referenced.

Finally, there is a special section denotated by the `*` sign which will output a file with the \*.tl filename without the extension.

This means that for **hello.cpp.txt** containing:

```
@*=
some text
```

It will output it in a file named **hello.cpp**.

Caching
-------

ntangle also allows to fuzzy search in all sections on your filesystem. [ctrlp](https://github.com/ctrlpvim/ctrlp.vim) is **required** in order to use this functionality. 

Some additional configurations needs to made in order to work. In your $VIMRC add the following global variables definition:

```
let g:tangle_code_dir = "~/allmycode"
```

This will inform the plugin where all the code resides.
Type the following command the index all the sections:

```
:TangleBuildCache
```

This will search for all the \*.tl files and uniquely index in each file all the sections. By default it will skip, section names which are file names. This behaviour can be changed using the `g:tangle_cache_skip_filenames`. Once done, it will echo a message saying it 

```
Cache saved to ~/tangle_cache.txt
```

The cache path can be changed using the `g:tangle_cache_file` configuration variable.
Once the cache has been generated the ctrlp fuzzy search can be invoked using:

```
:call ctrlp#init(ctrlp#tangle#id())
```

It's a good idea to bind this to a shortcut key with nnoremap for more convinence.

Additional notes
----------------

* Section and section references can be escaped with a double `@` sign
* Section text will append at the end using `+=` but with the operator `-=`, it can also be appended at the beginning
* The destination folder can be configured using the `g:tangle_dir` variable
