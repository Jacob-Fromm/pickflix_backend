require 'uri'
require 'net/http'
require 'openssl'
require 'JSON'
require "pry"

def get_all_films
    page_num = 1
    genre_ids_string = genres_request
    genre_ids_array = genres_request.split(", ")
    genre_array_for_strings = []
    # 20.times do
    #     genre_array_for_strings.push(genre_ids_array[rand(0..genre_ids_array.length)])
    # end
    # while page_num < 60
    #     unogs_request(genre_array_for_strings.join(","), page_num)
    #     page_num += 1
    # end
    byebug
end

def genres_request
    url = URI("https://unogs-unogs-v1.p.rapidapi.com/api.cgi?t=genres")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-key"] = '8afd7ffa98msh66c5e14a405f912p133da5jsne6eb4d751d16'
    request["x-rapidapi-host"] = 'unogs-unogs-v1.p.rapidapi.com'

    response = http.request(request)
    genre_list = JSON.parse(response.read_body)
    genre_ids_with_names = genre_list["ITEMS"]
    genre_ids_string = create_genre_string_array(genre_ids_with_names)
    return genre_ids_string
end

def create_genre_string_array(data)
    genre_id_array = []
    data.map do |genre_hash| 
        genre_hash.map do |name, ids|
            genre_id_array.push(ids)
        end
    end
    flattened_array = genre_id_array.flatten
    joined_genre_id_array = flattened_array.join(", ")
end



def unogs_request(genre_id_string, page_num)
    url = URI("https://rapidapi.p.rapidapi.com/aaapi.cgi?q=%7Bquery%7D-!1900%2C2020-!0%2C5-!0%2C10-!#{genre_id_string}-!Any-!Any-!Any-!gt100-!%7Bdownloadable%7D&t=ns&cl=all&st=adv&ob=Relevance&p=#{page_num}&sa=and")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-key"] = '8afd7ffa98msh66c5e14a405f912p133da5jsne6eb4d751d16'
    request["x-rapidapi-host"] = 'unogs-unogs-v1.p.rapidapi.com'

    response = http.request(request)
    readable_response = JSON.parse(response.read_body)
    
    create_movie_objects(readable_response)
    
end

$api_key = "91b02583"

def omdb_request(imdb_id, api_key)
    url = URI("http://omdbapi.com/?i=#{imdb_id}&apikey=#{$api_key}&plot=full")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    readable_response = JSON.parse(response.read_body)
end

$all_flix_array = []

def create_movie_objects(movie_hash)
        movie_hash["ITEMS"].each do |movie|
            omdb_hash = omdb_request(movie["imdbid"], $api_key)
            new_movie_obj = {
                "netflixid": movie["netflixid"],
                "title": movie["title"],
                "image": movie["image"],
                "rating": movie["rating"],
                "media": movie["type"],
                "runtime": movie["runtime"],
                "largeimage": movie["largeimage"],
                "imdbid": movie["imdbid"],
                "priority": 10,
                "genre": omdb_hash["Genre"],
                "year": omdb_hash["Year"],
                "released": omdb_hash["Released"],
                "rated": omdb_hash["Rated"],
                "director": omdb_hash["Director"],
                "writer": omdb_hash["Writer"],
                "actors": omdb_hash["Actors"],
                "plot": omdb_hash["Plot"],
                "language": omdb_hash["Language"],
                "country": omdb_hash["Country"],
                "awards": omdb_hash["Awards"],
                "poster": omdb_hash["Poster"],
                "imdbRating": omdb_hash["imdbRating"],
                "imdbVotes": omdb_hash["imdbVotes"]

            }
            $all_flix_array.push(new_movie_obj)
    end    
end

# def return_all_films
#     all_films = get_all_films
#     byebug
# end


get_all_films

