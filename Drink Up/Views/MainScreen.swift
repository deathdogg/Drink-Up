import Foundation
import SwiftUI

struct MainScreen: View {
	@Binding var path: NavigationPath
	@State var packages: [BrewPackage] = []
	@State var filteredPackages: [BrewPackage] = []
	@State var searchText: String = ""
	var body: some View {
		VStack {
			TextField("Search", text: $searchText)
			Text("\(self.packages.count) packages")
			Button("Load packages") {
				print("Loading Packages")
				Task {
					await self.loadData()
				}
			}
			// Display a list of packages
			List {
				ForEach(packages, id: \.self) {
					package in
					NavigationLink(package.name, value: package)
				}
				.onChange(of: searchText) {
					searching()
				}
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
				self.packages = json
			}
		} catch {
			print(error)
		}
	}
	@MainActor
	func searching() {
		if searchText == "" {
			self.filteredPackages = packages
		} else {
			filteredPackages = packages.filter {
				$0.name.contains(searchText)
			}
		}
	}
}



