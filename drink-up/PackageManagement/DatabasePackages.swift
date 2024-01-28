//
//  DatabasePackages.swift
//  drink-up
//
//  Created by Ricardo Herrera on 1/28/24.
//

import SwiftUI
struct DatabasePackages: View {
	@State private var vm = VM()
	@State var databasePackagesSelection: Set<BrewPackage>
	var body: some View {
		VStack {
			HStack {
				TextField("Search", text: $vm.searchText)
					.onChange(of: vm.searchText) {
						vm.searching()
					}
				if vm.searchText == "" {
					Text("\(vm.databasePackageCount) Packages in the Database")
				} else {
					Text("\(vm.databaseSearchPackageCount) Packages found")
				}
			}
			Divider()


				List(selection: $databasePackagesSelection) {
					ForEach(vm.filteredPackages, id: \.self) {
						package in
						NavigationLink(package.name, value: package)
							.accessibilityAddTraits(.isStaticText)
					}


				}
			Button("Load Packages from Database") {
				Task {
					await vm.loadData()
				}
			}
		}
	}
}

@Observable
private class VM {
	var databasePackageCount: Int { databasePackages.count	}
	var databaseSearchPackageCount: Int { filteredPackages.count }
	var searchText = ""
	var databasePackages: [BrewPackage] = []
	var filteredPackages: [BrewPackage] = []
	func loadData() async {
		let urlString: String = "https://formulae.brew.sh/api/formula.json"
		guard let url = URL(string: urlString) else {
			print("Invalid url")
			return
		}
		do {
			let (data, _ ) = try await URLSession.shared.data(from: url)
			if let json = try? JSONDecoder().decode([BrewPackage].self, from: data) {
				databasePackages = json
				filteredPackages = json
			}
		} catch {
			print(error)
		}
	}
	@MainActor
	func searching() {
		if searchText == "" {
			filteredPackages = databasePackages
		} else {
			filteredPackages = databasePackages.filter {
				$0.name.contains(searchText)
			}
		}
	}
}
