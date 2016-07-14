//
//  main.swift
//  hdshell
//
//  Created by Saagar Jha on 7/11/16.
//  Copyright © 2016 Saagar Jha. All rights reserved.
//

import Foundation

func evaluate(shellCommand command: String) -> String? {
	let task = Task()
	task.launchPath = "/bin/bash"
	task.arguments = ["-c", command]
	let pipe = Pipe()
	task.standardOutput = pipe
	task.launch()
	return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding:  String.Encoding.utf8)
}

let homePath = UserDefaults.standard.object(forKey: "homeDirectory") as? String ?? "/user/\(evaluate(shellCommand: "whoami")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")"
var path = homePath

func createAbsoluteHDFSPath(with hdfsPath: String) -> String {
	if hdfsPath.hasPrefix("hdfs://") {
		return hdfsPath
	} else if hdfsPath.hasPrefix("/") {
		return "/\(clean(path: hdfsPath))"
	} else if hdfsPath.hasPrefix("~") {
		return "/\(clean(path: hdfsPath.replacingOccurrences(of: "~", with: homePath)))"
	} else {
		return "/\(clean(path: "\(path)/\(hdfsPath)"))"
	}
}

func clean(path hdfsPath: String) -> String {
	var cleanPath = [String]()
	for folder in hdfsPath.components(separatedBy: "/").filter({ !$0.isEmpty })  {
		switch folder {
		case "." :
			break
		case "..":
			if cleanPath.count > 0 {
				cleanPath.removeLast()
			}
		default:
			cleanPath.append(folder)
		}
	}
	return cleanPath.joined(separator: "/")
}

if let firstArgument = Process.arguments.dropFirst().first {
	switch firstArgument {
	case "-h":
		fallthrough
	case "--help":
		print("hdshell usage:")
		print("-h, --help: print this help message")
		print("-d, --set-home-directory [hdfs filepath]: set the home directory")
		exit(EXIT_SUCCESS)
	case "-d":
		fallthrough
	case "--set-home-directory":
		if Process.arguments.count == 2 {
			UserDefaults.standard.set(Process.arguments[1], forKey: "homeDirectory")
		} else {
			
		}
		exit(EXIT_SUCCESS)
	default:
		print("\(firstArgument) isn't a recognized option. Aborting.")
		exit(EXIT_FAILURE)
	}
}

while(true) {
	print("\(path)$ ", terminator: "")
	guard var input = readLine()?.trimmingCharacters(in: .whitespaces) else {
		exit(EXIT_SUCCESS)
	}
	let shellCommand = input.hasPrefix("$")
	while(true) {
		if let startRange = input.range(of: "$("), let endRange = input.range(of: ")", range: startRange.lowerBound..<input.endIndex) {
			let command = input.substring(with: startRange.upperBound..<endRange.lowerBound)
			if let result = evaluate(shellCommand: command) {
				input.replaceSubrange(startRange.lowerBound..<endRange.upperBound, with: result)
			} else {
				print("There was an error running your command.")
				break
			}
		} else {
			break
		}
	}
	if shellCommand {
		print(input)
		continue
	}
	var arguments = input.components(separatedBy: .whitespaces)
	if let command = arguments.first {
		switch command {
		case "cd":
			path = createAbsoluteHDFSPath(with: arguments.last ?? path)
			continue
		case "pwd":
			print(path)
			continue
		case "ls":
			if arguments.count < 2 {
				arguments.append(path)
			}
		case "exit":
			exit(EXIT_SUCCESS)
		default:
			break
		}
		arguments = [command] + arguments.dropFirst().map {
			if $0.hasPrefix("@") {
				return createAbsoluteHDFSPath(with: String($0.characters.dropFirst()))
			} else {
				return $0
			}
		}
	}
	if let result = evaluate(shellCommand: "/usr/local/hadoop/bin/hdfs dfs -\(arguments.joined(separator: " "))") {
		print(result, terminator: "")
	} else {
		print("There was an error running your command.")
	}
}
