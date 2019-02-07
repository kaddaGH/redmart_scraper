
search_terms = ['Red Bull', 'RedBull']
search_terms.each do |search_term|

  pages << {
      page_type: 'products_search',
      method: 'GET',
      url: "https://api.redmart.com/v1.6.0/catalog/search?q=#{search_term.gsub(/\s/,'+')}&pageSize=18&sort=1024",
      vars: {
          'input_type' => 'search',
          'search_term' => search_term,
          'page' => 1
      }


  }

end