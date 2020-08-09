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

# prepareInstallCommand will generate a string containg the full command
# required to install all the npm packages as specified by provided sequence.
proc prepareInstallCommand(packages: seq[string]): string =
    var cmd = "npm install --save-dev "
    for i, package in packages:
        cmd = cmd & " " & package

    return cmd

# checkInstallSucceeded will check that status provided to it is 0, and if it
# is not, will inform the user and terminate the application.
proc checkCmdSucceded(status: int, cmd: string): void =
    if status != 0:
        echo &"{cmd} exited with a non 0 status code"
        quit(status)

# init will use npx to run create-react-app and then install the other packages
# required to develop the project.
proc init(name: string): void =
    var res: int

    echo "hip: running create-react-app"
    res = execShellCmd(&"npx create-react-app {name} --template typescript")
    checkCmdSucceded(res, "create-react-app")

    echo "hip: moving to project folder"
    setCurrentDir(name)

    echo "hip: installing packages"
    res = execShellCmd(prepareInstallCommand(@[
        "prettier",
        "eslint-config-prettier",
        "eslint-plugin-prettier",
        "styled-components",
        "@types/styled-components"
    ]))
    checkCmdSucceded(res, "installing packages")

    echo "hip: adding .eslintrc.json"
    const eslintrc = staticRead("eslint.json")
    writeFile(".eslintrc.json", eslintrc)

    echo "hip: updating package.json"
    let package = parseFile("package.json")
    let formatScript = %"tsc && eslint . --fix --ext .ts,.tsx"
    add(package["scripts"], "format", formatScript)
    delete(package, "eslintConfig")
    writeFile("package.json", package.pretty())

    echo "hip: done"

# format will run the created npm format script but with the silent flag
proc format(): void =
    discard execShellCmd("npm run format --silent")

# help displays the help menu as it is defined in usage.txt
proc help(): void =
    const usage = staticRead("usage.txt")
    echo usage
    quit(0)

# writeErrorAndQuit will echo an error before terminating the application.
proc writeErrorAndQuit(msg: string): void =
    echo &"hip: {msg} See 'hip help'."
    quit(0)

# safeGetArg will attempt to get the argument passed to the program at the
# specified position, checking first to see if the number of arguments is
# greater than the specified position. If it is not, the error message will be
# printed and the program terminated.
proc safeGetArg(pos: int, err: string): string =
    if paramCount() < pos:
        writeErrorAndQuit(err)
        quit(0)

    return paramStr(pos)

# Program begins here
var action: string = "help"
if paramCount() != 0:
    action = paramStr(1)

case action:
of "init":
    let name = safeGetArg(2, "init needs a name for the project")
    init(name)
of "format":
    format()
of "help":
    help()
else:
    writeErrorAndQuit(&"'{action}' is not a valid action.")
