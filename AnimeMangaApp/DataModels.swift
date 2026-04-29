struct AnimeResponse: Codable {
    let data: [Anime]
    let pagination: Pagination
}

struct AnimeDetailResponse: Codable {
    let data: Anime
}

struct Anime: Identifiable, Codable {
    let mal_id: Int
    var id: Int { mal_id }
    let title: String
    let images: Images?
    let score: Double?    
    let synopsis: String?
}

struct MangaResponse: Codable {
    let data: [Manga]
    let pagination: Pagination
}

struct MangaDetailResponse: Codable {
    let data: Manga
}
 
struct Manga: Identifiable, Codable {
    let mal_id: Int
    var id: Int { mal_id }
    let title: String
    let images: Images?
    let score: Double?
    let synopsis: String?
}

struct Images: Codable {
    let jpg: JPG
}

struct JPG: Codable {
    let image_url: String
}

struct Pagination: Codable {
    let has_next_page: Bool
}
