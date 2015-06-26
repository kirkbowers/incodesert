# incodesert

[https://github.com/kirkbowers/incodesert](https://github.com/kirkbowers/incodesert)

## Description

    code insert
    code in      sert
         in code sert
         incodesert

`incodesert` (pronounced "in code sert", not "inco desert") 
is a utility for inserting code snippets from one file into another.
It was originally intended to facilitate autogenerating code and interlacing that
autogened code with hand written code.  It is also useful for performing
Pre-rolled Blackbox Testing.

## Usage

To use `incodesert`, first install it:

    [sudo] gem install incodesert
    
Most likely you will want to run it on the command line, like so:

    incodesert [flags] <source-file> <dest-file> [extractions-file]
    
If you run it with the `--help` flag, it gives a list of all flags and what they do.

Optionally, you can run it inside of Ruby code by passing Strings for the source and
the destination to the initializer of the `Incodesert::Documents` class and calling
`perform_insertions!`.  The property `destination` will contain the modified version
of the destination String, and the property `extractions` will contain the snippets
extracted (and replaced) from the original destination.

    require 'incodesert'
    
    documents = Incodesert::Documents.new(source, destination)
    documents.perform_insertions!

### Special comment format

`incodesert` depends on a special comment format to denote blocks of code that should
be inserted (and where they should be inserted in the destination).  

The format looks like this (in C-style languages):

      // <<< blockname

      ...  Stuff to insert
      
      // >>> blockname
      
Where "blockname" is some unique identifier.  

In script-style languages, the format is:

      # <<< blockname

      ...  Stuff to insert
      
      # >>> blockname

### Token replacements

The utility also replaces a set of recognized tokens in the source with values either 
supplied or deduced from the destination.  At this time the only token recognized is
`__CLASSNAME__`.  If `incodesert` is run from the command line, that token is replaced
by the camel cased filename of the destination file.  This is particularly useful if
you are autogenerating code for a language like C++ that needs the class name to 
provide method implementations.

To make this concrete, suppose you have a source file that looks like this: 

    // <<< method_impl
    void __CLASSNAME__::someMethod() {
      // ... do something
    }
    // >>> method_impl

And you had a destination file named `some_class.cpp`:

    // some stuff

    // <<< method_impl
    // >>> method_impl

    // some more stuff

After running the insertions, `some_class.cpp` would look like this:

    // some stuff

    // <<< method_impl
    void SomeClass::someMethod() {
      // ... do something
    }
    // >>> method_impl

    // some more stuff

## Dependencies

`incodesert` does not depend on any other gem in order to run.

It does, however, depend on by [hoe](https://github.com/seattlerb/hoe) and
[shoulda](https://github.com/thoughtbot/shoulda) for development and testing.
It also depends on [rdoc2md](https://github.com/kirkbowers/rdoc2md) to generate 
the github friendly README file.

## Developers/Contributing

`incodesert` is a Hoe project.  Like any other Hoe project, 
after checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

I welcome all enhancements/contributions to the project.  Please check the Issues first
before adding some functionality.  I use the Git Flow methodology for managing the 
development branch vs. the master branch.  Please create a "feature" branch of the 
development branch in order to add to the codebase.

## License

`incodesert` is released under the MIT license.  
