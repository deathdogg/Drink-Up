import SwiftUI

struct PackageDetails: View {
	@State var package: BrewPackage
	var body: some View {
		VStack {
			Text(package.name)
			Text(package.desc)
		}
	}
}
