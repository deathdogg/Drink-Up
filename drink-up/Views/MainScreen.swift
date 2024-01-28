import Foundation
import SwiftUI

struct MainScreen: View {
	@Binding var path: NavigationPath
	@State var databasePackages: [BrewPackage] = []
	@State var databasePackagesSelection = Set<BrewPackage>()
	@State var filteredPackages: [BrewPackage] = []
	@State var searchText: String = ""
	@State var installedPackages: [String] = []
	@State var installedPackagesSelection = Set<String>()
	@State var output = ""
	@State var errorOutput = ""
	var body: some View {
		VStack {
			Group {
				ForEach(output.split(separator: "\n"), id: \.self) {
					Text($0)
				}
			}
			TextField("Search", text: $searchText)
			Text("\(self.databasePackages.count) packages")
			Button("Load packages") {
				print("Loading Packages")
				Task {
					await self.loadData()
				}
			}
			// Display a list of packages
			List(selection: $databasePackagesSelection) {
				ForEach(filteredPackages, id: \.self) {
					package in
					NavigationLink(package.name, value: package)
						.accessibilityAddTraits(.isStaticText)
				}
				.onChange(of: searchText) {
					self.searching()
				}
			}
			.toolbar { Button("Install") {
				self.installPackages()
			} }
			// Display list of installed packages
			List(installedPackages, id: \.self, selection: $installedPackagesSelection) {
				Text($0)
			}
			.onAppear {
				self.installedPackages = LocalInstalls.getInstalledFormulae()
			}
		}
	}
	func loadData() async {
		let urlString: String = "https://formulae.brew.sh/api/formula.json"
		guard let url = URL(string: urlString) else {
			print("Invalid url")
			return
		}
		do {
			let (data, _ ) = try await URLSession.shared.data(from: url)
			if let json = try? JSONDecoder().decode([BrewPackage].self, from: data) {
				self.databasePackages = json
				self.filteredPackages = json
			}
		} catch {
			print(error)
		}
	}
	@MainActor
	func searching() {
		if self.searchText == "" {
			self.filteredPackages = self.databasePackages
		} else {
			filteredPackages = databasePackages.filter {
				$0.name.contains(searchText)
			}
		}
	}
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
			self.output = results
		}
	}
}



