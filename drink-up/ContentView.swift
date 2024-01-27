import Foundation
import SwiftUI

struct ContentView: View {
	@State var path = NavigationPath()
	var body: some View {
		NavigationStack {
			MainScreen(path: $path)
				.navigationDestination(for: BrewPackage.self) {
					package in
					PackageDetails(package: package)
				}
		}
	}
}
