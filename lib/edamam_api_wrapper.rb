require 'httparty'
# require 'awesome_print'
#purpose of api  wrapper
#api wrapper protects us from changes from someone eslse server
#take in dta for us #make it nice and neat #hand it to the rest of the program in a uniform way

class EdamamApiWrapper
  BASE_URL = "https://api.edamam.com/"
  APP_ID = ENV["APP_ID"] #this keeps our token private
  APP_KEY = ENV["APP_KEY"]


  #list the channels  **
  # base_url = https://api.edamam.com/search?app_id=cce9a91f&app_key=d0f4da3c9d8a64a9be87b192561284b7&q=chocolate mouse

  def self.list_recipes(user_search) #i passed search_term in the controller and view to use this
    url = BASE_URL + "search?" + "app_id=#{APP_ID}" + "&app_key=#{APP_KEY}" + "&q=#{user_search}" + "&to=100"
    encoded_url = URI.encode(url) #add this because the user might search for something with spaces and this gets rid
    data = HTTParty.get(encoded_url)
    recipe_list = []
    if data["hits"]
      data["hits"].each do |recipe_data|
        recipe_list << create_recipe(recipe_data["recipe"])
      end
    end
    return recipe_list
  end
  # chocolate mouse "uri": "http://www.edamam.com/ontologies/edamam.owl#recipe_7543ecfa28b7506a97360748f017a83e",
  # kimchi pasta "uri": "http://www.edamam.com/ontologies/edamam.owl#recipe_b3ce18c4a415f62086a858c54f2c3f19",
  # https://api.edamam.com/search?app_id=cce9a91f&app_key=d0f4da3c9d8a64a9be87b192561284b7&r=http:%2F%2Fwww.edamam.com%2Fontologies%2Fedamam.owl%23recipe_b3ce18c4a415f62086a858c54f2c3f19

  #this method takes a uri (which will come from params) and returns a recipe
  def self.find_recipe_by(uri)
    url = BASE_URL + "search?" + "r=http%3A%2F%2Fwww.edamam.com%2Fontologies%2Fedamam.owl%23recipe_#{uri}" + "&app_id=#{APP_ID}" + "&app_key=#{APP_KEY}"
    # encoded_url = URI.encode(url) #add this because the user might search for something with spaces and this gets rid
    data = HTTParty.get(url)
    if data[0]
      recipe = self.create_recipe(data[0])
    end
    return recipe
  end



  private

  def self.create_recipe(api_params)
    # need to parse this: http:%2F%2Fwww.edamam.com%2Fontologies%2Fedamam.owl%23recipe_7543ecfa28b7506a97360748f017a83e
    parsed_uri = api_params["uri"].partition('_').last

    return Recipe.new(
      api_params["label"],
      parsed_uri,
      {
        healthLabels: api_params["healthLabels"],
        ingredients: api_params["ingredients"],
        image: api_params["image"],
        url:  api_params["url"]
      }
    )
  end
end #end of class method

#### delete everything under here
# [1] pry(EdamamApiWrapper)> create_recipe(data["hits"][0]["recipe"])
# => #<Recipe:0x007f9902d61f08
#  @healthLabels=["Vegetarian", "Peanut-Free", "Tree-Nut-Free", "Alcohol-Free"],
#  @image="https://www.edamam.com/web-img/bb2/bb221d581497fa559f5817ca1800ea65.jpg",
#  @ingredients=
#   [{"text"=>"1 ounce semisweet or bittersweet chocolate, per person", "weight"=>28.349523125, "foodCategory"=>"Pantry"},
#    {"text"=>"1 tablespoon water, per person", "weight"=>14.786764781, "foodCategory"=>"Beverages"},
#    {"text"=>"1 large egg, per person", "weight"=>50.0, "foodCategory"=>"Dairy"}],
#  @label="Chocolate Mousse",
#  @uri="http://www.edamam.com/ontologies/edamam.owl#recipe_7543ecfa28b7506a97360748f017a83e",
#  @url="http://leitesculinaria.com/74504/recipes-chocolate-mousse.html">
