struct AnimeResponse: Codable {
    var current_page: Int
    var data: [Anime]
}

struct Anime: Identifiable, Codable {
    var id: Int { mal_id }
    
    var mal_id: Int
    var url: String?
    var images: AnimeImages
    var title_english: String
    var title_japanese: String
    var episodes: Int
    var status: String
}

struct AnimeImages: Codable {
    let jpg: ImageDetails
}

struct ImageDetails: Codable {
    let image_url: String
    let small_image_url: String
    let large_image_url: String
}
