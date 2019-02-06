require 'uri'

pages << {
    page_type: 'products_search',
    method: 'GET',
    url: "https://api.redmart.com/v1.6.0/catalog/search?pageSize=18&sort=1024&category=energy-drinks",
    vars: {
        'input_type' => 'taxonomy',
        'search_term' => '-',
        'page' => 1
    }


}
search_terms = ['Red Bull', 'RedBull', 'Energidryck', 'Energidrycker']
search_terms.each do |search_term|

  pages << {
      page_type: 'products_search',
      method: 'GET',
      url: "https://api.redmart.com/v1.6.0/catalog/search?q=#{URI.encode(search_term)}&pageSize=108&sort=1024",
      vars: {
          'input_type' => 'search',
          'search_term' => search_term,
          'page' => 1
      }


  }

end