# Hip
Hip is a tool for setting up React projects with Typescript, ESLint, and
Prettier. It also sets a convention for the project structure and handles the
generation of boilerplate code for Components, Pages, Models, and Contexts.

## Building Hip
Hip is built with [Nim](https://nim-lang.org/). To build it:
``` bash
nim compile -o:hip main.nim
```

## Usage
### Creating a Project
Using Hip is very simple. You can create a new project by using:

``` bash
hip init <name>
```

### Formatting Code
Hip also provides a small utility to run the format script it defines during 
the init step:

``` bash
hip format
```

It runs `npm run format --silent` as to avoid excess noise npm emits if the
silent option is not specified.

## Licensing
Hip is licensed under the the GPLv3 license. However, because it generates code
and copies it into the projects it is used to create an exception has been made
to allow projects that contain those file to be distributed under any terms
that project's maintainer chooses. If you have any questions about this, or are
unsure if you can use Hip, please do not hesitate to contact me.