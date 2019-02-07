json_content = content[/(?<=\()(.+?)(?=\))/]


data = JSON.parse(json_content)
reviews = {}
products = data['BatchedResults']['q0']['Results']
products_details = page['vars']['products']
products.each do |product|

  product_id = product['ProductStatistics']['ProductId']
  product_reviews = product['ProductStatistics']['ReviewStatistics']
  reviews[product_id] = product_reviews
end

products_details.each do |product_details|

  product_id = product_details['PRODUCT_ID'].to_s

  if reviews.keys.include? product_id
    product_details['PRODUCT_STAR_RATING'] = reviews[product_id]['AverageOverallRating'].nil? ? '' : reviews[product_id]['AverageOverallRating'].round(2)
    product_details['PRODUCT_NBR_OF_REVIEWS'] = reviews[product_id]['TotalReviewCount']

  end

  product_details['_collection'] = 'products'
  product_details['EXTRACTED_ON']= Time.now.to_s
  outputs << product_details


end
