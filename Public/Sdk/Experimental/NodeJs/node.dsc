// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

import {Artifact, Cmd, Tool, Transformer} from "Sdk.Transformers";

namespace Node {

    @@public
    export const tool = getNodeTool();
    
    @@public
    export const npmCli = getNpmCli();

    @@public
    export function run(args: Transformer.ExecuteArguments) : Transformer.ExecuteResult {
        // Node code can access any of the following user specific environment variables.
        const userSpecificEnvrionmentVariables = [
            "APPDATA",
            "LOCALAPPDATA",
            "USERPROFILE",
            "USERNAME",
            "HOMEDRIVE",
            "HOMEPATH",
            "INTERNETCACHE",
            "INTERNETHISTORY",
            "INETCOOKIES",
            "LOCALLOW",
        ];
        const execArgs = Object.merge<Transformer.ExecuteArguments>(
            {
                tool: tool,
                workingDirectory: tool.exe.parent,
                unsafe: {
                    passThroughEnvironmentVariables: userSpecificEnvrionmentVariables
                }
            },
            args
        );

        return Transformer.execute(execArgs);
    }

    const nodeWinDir = "node-v13.3.0-win-x64";
    const nodeOsxDir = "node-v13.3.0-darwin-x64";
    const nodeLinuxDir = "node-v13.3.0-linux-x64";

    function getNodeTool() : Transformer.ToolDefinition {
        const host = Context.getCurrentHost();
    
        Contract.assert(host.cpuArchitecture === "x64", "Only 64bit versions supported.");
    
        let executable : RelativePath = undefined;
        let pkgContents : StaticDirectory = undefined;
        
        switch (host.os) {
            case "win":
                pkgContents = importFrom("NodeJs.win-x64").extracted;
                executable = r`${nodeWinDir}/node.exe`;
                break;
            case "macOS": 
                pkgContents = importFrom("NodeJs.osx-x64").extracted;
                executable = r`${nodeOsxDir}/bin/node`;
                break;
            case "unix": 
                pkgContents = importFrom("NodeJs.linux-x64").extracted;
                executable = r`${nodeLinuxDir}/bin/node`;
                break;
            default:
                Contract.fail(`The current NodeJs package doesn't support the current OS: ${host.os}. Esure you run on a supported OS -or- update the NodeJs package to have the version embdded.`);
        }
  
        return {
            exe: pkgContents.getFile(executable),
            runtimeDirectoryDependencies: [
                pkgContents,
            ],
            prepareTempDirectory: true,
            dependsOnCurrentHostOSDirectories: true,
            dependsOnAppDataDirectory: true,
        };
    }

    function getNpmCli() {
        const host = Context.getCurrentHost();
    
        Contract.assert(host.cpuArchitecture === "x64", "Only 64bit verisons supported.");
    
        let executable : RelativePath = undefined;
        let pkgContents : StaticDirectory = undefined;
        
        switch (host.os) {
            case "win":
                pkgContents = importFrom("NodeJs.win-x64").extracted;
                executable = r`${nodeWinDir}/node_modules/npm/bin/npm-cli.js`;
                break;
            case "macOS": 
                pkgContents = importFrom("NodeJs.osx-x64").extracted;
                executable = r`${nodeOsxDir}/lib/node_modules/npm/bin/npm-cli.js`;
                break;
            case "unix": 
                pkgContents = importFrom("NodeJs.linux-x64").extracted;
                executable = r`${nodeLinuxDir}/lib/node_modules/npm/bin/npm-cli.js`;
                break;
            default:
                Contract.fail(`The current NodeJs package doesn't support the current OS: ${host.os}. Ensure you run on a supported OS -or- update the NodeJs package to have the version embedded.`);
        }

        return pkgContents.getFile(executable);
    }

    @@public
    export function tscCompile(workingDirectory: Directory, dependencies: Transformer.InputArtifact[]) : SharedOpaqueDirectory {
        const outPath = d`${workingDirectory}/out`;
        const arguments: Argument[] = [
            Cmd.argument(Artifact.none(f`${workingDirectory}/node_modules/typescript/lib/tsc.js`)),
            Cmd.argument("-p"),
            Cmd.argument("."),
        ];

        const result = Node.run({
            arguments: arguments,
            workingDirectory: workingDirectory,
            dependencies: dependencies,
            outputs: [
                { directory: outPath, kind: "shared" }
            ]
        });

        return <SharedOpaqueDirectory>result.getOutputDirectory(outPath);
    }
}
