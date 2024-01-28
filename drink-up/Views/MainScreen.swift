import Foundation
import SwiftUI

struct MainScreen: View {
	@Binding var path: NavigationPath
@State private var vm = VM()
	var body: some View {
		VStack {
			Group {
				ForEach(vm.output.split(separator: "\n"), id: \.self) {
					Text($0)
				}
			}
			// Display a list of packages
			DatabasePackages(databasePackagesSelection: vm.databasePackagesSelection)
			.toolbar { Button("Install") {
				vm.installPackages()
			} }
			// Display list of installed packages
			List(vm.installedPackages, id: \.self, selection: $vm.installedPackagesSelection) {
				Text($0)
			}
			.onAppear {
				vm.installedPackages = LocalInstalls.getInstalledFormulae()
			}
		}
	}

}



@Observable
private class VM {
	var databasePackagesSelection = Set<BrewPackage>()
	var installedPackages: [String] = []
	var installedPackagesSelection = Set<String>()
	var output = ""
	var errorOutput = ""
	
	@MainActor
	func installPackages() {
		guard databasePackagesSelection.count > 0 else {
			return
		}
		for package in databasePackagesSelection {
			let installProcess = Process()
			installProcess.executableURL = URL(fileURLWithPath: "/bin/zsh")
			installProcess.currentDirectoryURL = .homeDirectory
			installProcess.arguments = ["-c", "-l", "brew install \(package.name)"]
			let pipe = Pipe()
			installProcess.standardOutput = pipe
			installProcess.standardError = pipe
			do {
				try installProcess.run()
			} catch {
				print("Unable to install package")
				print(error)
				return
			}
			let data = pipe.fileHandleForReading.readDataToEndOfFile()
			guard let results = String(data: data, encoding: .utf8) else {
				return
			}
			output = results
		}
	}
}
