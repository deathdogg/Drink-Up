import Foundation
struct BrewResponse: Codable, Hashable {
	var packages: [BrewPackage]
}
struct BrewPackage: Codable, Hashable {
	var name: String
	var full_name: String
	var desc: String
	
}
