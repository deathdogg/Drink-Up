import Foundation
struct BrewResponse: Codable, Hashable {
	var packages: [BrewPackage]
}
struct BrewPackage: Codable, Hashable {
	var name: String
	var full_name: String
	var desc: String
}
struct LocalInstalls {
	var packageList: [String] = []
	 static func getInstalledFormulae() -> [String] {
			let task = Process()
			task.currentDirectoryURL = .homeDirectory
			task.executableURL = URL(fileURLWithPath:  "/bin/zsh")
//		task.arguments = ["-c", "brew", "list", "-1"]
			task.arguments = ["-c", "-l", "brew list -1"]
		let pipe = Pipe()
		task.standardOutput = pipe
			task.standardError = pipe

			task.environment = ProcessInfo.processInfo.environment
			try? task.run()
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
			guard let list = String(data: data, encoding: .utf8) else {
				return []
			}
		var newList: [String] = []
		list.split(separator: "\n")
			.forEach {
				ss in
				newList.append(String(ss))
			}
		return newList
	}
}
