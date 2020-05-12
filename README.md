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
Using Hip is very simple. You can create a new project by using:
``` bash
hip init <name>
```

Hip will perform the following actions once this is executed:
1. Use [create-react-app](https://create-react-app.dev/) to create 
the app with the Typescript template.
2. Install [node-sass](https://www.npmjs.com/package/node-sass)
to make working with stylesheets easier.
3. Install [ESLint](https://eslint.org/), [Prettier](https://prettier.io/) and
the plugins required to get them working together with React and Typescript. It
will also copy in valid .eslintrc.js and .eslintignore files.
4. Create the `format` script in `package.json` to lint and format the code in
the project.
5. Delete the `create-react-app` cruft, please note that this removes
`serviceWorker.ts` but it can be added back manually afterwards.
6. Sets up the folders for Components, Pages, Models and Contexts.

## Licensing
Hip is licensed under the the GPLv3 license. However, because it generates code
and copies it into the projects it is used to create an exception has been made
to allow projects that contain those file to be distributed under any terms
that project's maintainer chooses. If you have any questions about this, or are
unsure if you can use Zap, please do not hesitate to contact me.