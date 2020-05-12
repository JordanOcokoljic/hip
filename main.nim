# This file is part of Hip, a tool for manaing Typescript React projects and
# components.
# Copyright (C) 2020 Jordan Ocokoljic.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import os
import strformat
import json
import strutils

# help displays the help menu as it is defined in usage.txt
proc help(): void =
    const usage = staticRead("usage.txt")
    echo usage
    quit(0)

# prepareInstallCommand will generate a string containg the full command
# required to install all the npm packages as specified by provided sequence.
proc prepareInstallCommand(packages: seq[string]): string =
    var cmd = "npm install --save-dev "
    for i, package in packages:
        cmd = cmd & " " & package

    return cmd

# writeErrorAndQuit will echo an error before terminating the application.
proc writeErrorAndQuit(msg: string): void =
    echo "hip: ", msg, " See 'hip help'."
    quit(0)

# safeGetArg will attempt to get the argument passed to the program at the
# specified position, checking first to see if the number of arguments is
# greater than the specified position. If it is not, the error message will be
# printed and the program terminated.
proc safeGetArg(pos: int, err: string): string =
    if paramCount() < pos:
        writeErrorAndQuit(err)

    return paramStr(pos)

# checkInstallSucceeded will check that status provided to it is 0, and if it
# is not, will inform the user and terminate the application.
proc checkCmdSucceded(status: int, cmd: string): void =
    if status != 0:
        echo &"{cmd} exited with a non 0 status code"
        quit(status)

# removeFiles will remove all the files in the provided sequence.
proc removeFiles(files: seq[string]): void =
    for i, file in files:
        removeFile(file)

# init creates a new React application in accordance with the steps provided by
# the usage guide.
proc init(name: string): void =
    var res: int

    echo "hip: running create-react-app"
    res = execShellCmd(&"npx create-react-app {name} --template typescript")
    checkCmdSucceded(res, "create-react-app")

    echo "hip: moving into project folder"
    setCurrentDir(name)

    echo "hip: installing node-sass"
    res = execShellCmd(prepareInstallCommand(@["node-sass"]))
    checkCmdSucceded(res, "install")

    echo "hip: installing ESLint, Prettier and plugins"
    res = execShellCmd(prepareInstallCommand(@[
        "@typescript-eslint/eslint-plugin",
        "@typescript-eslint/parser",
        "eslint",
        "eslint-config-prettier",
        "eslint-plugin-prettier",
        "eslint-plugin-react",
        "prettier"
    ]))

    checkCmdSucceded(res, "install")

    echo "hip: creating .eslintrc.js"
    const eslintrc = staticRead("templates/eslintrc.txt")
    writeFile(".eslintrc.js", eslintrc)

    echo "hip: creating .eslintignore"
    writeFile(".eslintignore", "build/*")

    echo "hip: adding format script to package.json"
    let package = parseFile("package.json")
    let formatValue = %"eslint . --ext .ts,.tsx --fix"
    add(package["scripts"], "format", formatValue)
    writeFile("package.json", package.pretty())

    echo "hip: deleting React boilerplate"
    removeFiles(@[
        "src/logo.svg",
        "src/serviceWorker.ts",
        "src/App.css",
        "src/App.test.tsx",
        "src/App.tsx",
        "src/index.css",
        "src/index.tsx"
    ])

    echo "hip: writing index.tsx"
    const index = staticRead("templates/index.txt")
    writeFile("src/index.tsx", index)

    echo "hip: creating object folders"
    createDir("src/components")
    createDir("src/pages")
    createDir("src/contexts")
    createDir("src/models")

    echo "hip: done"

# parseComponentTemplate will parse the templates/component.txt file and return
# the strings that make up the two files.
proc useComponentTemplate(name: string, basePath: string): void = 
    const componentTemplate = staticRead("templates/component.txt")
    let parts = split(replace(componentTemplate, "$NAME$", name), ":::")
    createDir(basePath)
    writeFile(&"{basePath}/{name}.tsx", strip(parts[0]))
    writeFile(&"{basePath}/index.ts", strip(parts[1]))
    writeFile(&"{basePath}/{name}.module.scss", "")

# useSingleFileTemplate will replace the $NAME$ identifier in the templates
# before writing the files to the base path provided.
proc useSingleFileTemplate(tmpl: string, name: string, path: string): void =
    let code = replace(tmpl, "$NAME$", name)
    createDir(path)
    writeFile(&"{path}/{name}.ts", code)

# newObject will create a new project object based on the parameters passed to
# it.
proc newObject(objType: string, name: string): void = 
    if fileExists("package.json") == false:
        writeErrorAndQuit("action 'new' must be run from project root.")

    case objType:
    of "component", "page":
        useComponentTemplate(name, &"src/components/{name}")
    of "model":
        const modelTemplate = staticRead("templates/model.txt")
        useSingleFileTemplate(modelTemplate, name, &"src/components/{name}")
    of "context":
        const contextTemplate = staticRead("templates/context.txt")
        useSingleFileTemplate(contextTemplate, name, &"src/contexts/{name}")
    else:
        writeErrorAndQuit(&"'{objType}' is not a valid object type")

# Program begins here
var action: string = "help"
if paramCount() != 0:
    action = paramStr(1)

case action
of "init":
    let name = safeGetArg(2, "init needs a name for the project.")
    init(name)
of "new":
    let objType = safeGetArg(2, "new needs an object type to create")
    let name = safeGetArg(3, "new needs a name for the object")
    newObject(objType, name)
of "help":
    help()
else:
    writeErrorAndQuit(&"'{action}' is not a valid action.")
