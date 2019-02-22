require 'cgi'
data = JSON.parse(content)
scrape_url_nbr_products = data['total'].to_i
current_page = data['page'].to_i
page_size = data['page_size'].to_i
products = data['products']
products_details = []
ids = []

# if ot's first page , generate pagination
if current_page==0 and scrape_url_nbr_products>page_size
  nbr_products_pg1 = page_size
  step_page = 1
  while step_page*page_size<=scrape_url_nbr_products
    pages << {
        page_type: 'products_search',
        method: 'GET',
        url: page['url']+"&page=#{step_page}",
        vars: {
            'input_type' => page['vars']['input_type'],
            'search_term' => page['vars']['search_term'],
            'page' => step_page,
            'nbr_products_pg1' => nbr_products_pg1
        }
    }

    step_page=step_page+1



  end
elsif current_page==0 and scrape_url_nbr_products==page_size
  nbr_products_pg1 = page_size
else
  nbr_products_pg1 = page['vars']['nbr_products_pg1']
end




products.each_with_index do |product, i|

  promotion = product['promotions'][0]['savings_text'] rescue ''
  pack = product['measure']['wt_or_vol'][/(.+?)(?=x)/].strip  rescue '1'
  availability = product['inventories'][0]['stock_status'].to_i == 1 ? '1' : ''
  item_size = product['warehouse']['measure']['wt'].to_i rescue  0
  if item_size<=0
    item_size = product['warehouse']['measure']['vol']
  end
  item_size_uom = product['warehouse']['measure']['vol_metric']+product['warehouse']['measure']['wt_metric'] rescue ''
  price = product['pricing']['promo_price'].to_f
  if price==0
    price = product['pricing']['price'].to_f
  end
  if product['category_tags'].include? 'energy-drinks'
    category = 'energy-drinks'
  else


    category = product['category_tags'][0]


  end

  brand = product['filters']['brand_name']
  if brand =='Red Bull' and product['filters']['country_of_origin'] == 'Vietnam'
    brand = 'Thai Red Bull'
  end


  product_details = {
      # - - - - - - - - - - -
      RETAILER_ID: '95',
      RETAILER_NAME: 'redmart',
      GEOGRAPHY_NAME: 'SG',
      # - - - - - - - - - - -
      SCRAPE_INPUT_TYPE: page['vars']['input_type'],
      SCRAPE_INPUT_SEARCH_TERM: page['vars']['search_term'],
      SCRAPE_INPUT_CATEGORY: page['vars']['input_type'] == 'taxonomy' ? category : '-',
      SCRAPE_URL_NBR_PRODUCTS: scrape_url_nbr_products,
      # - - - - - - - - - - -
      SCRAPE_URL_NBR_PROD_PG1:  nbr_products_pg1 ,
      # - - - - - - - - - - -
      PRODUCT_BRAND: brand,
      PRODUCT_RANK: i + 1,
      PRODUCT_PAGE: current_page+1,
      PRODUCT_ID: product['id'],
      PRODUCT_NAME: product['title'],
      EAN: product['sku'],
      PRODUCT_DESCRIPTION: product['desc'].gsub(/[\n\s]+/,' ').gsub(/,/,'.'),
      PRODUCT_MAIN_IMAGE_URL: 'https://s3-ap-southeast-1.amazonaws.com/media.redmart.com/newmedia/150x' + product['img']['name'],
      PRODUCT_ITEM_SIZE: item_size,
      PRODUCT_ITEM_SIZE_UOM: item_size_uom,
      PRODUCT_ITEM_QTY_IN_PACK:pack ,
      SALES_PRICE: price,
      IS_AVAILABLE: availability,
      PROMOTION_TEXT: promotion,

  }


  products_details << product_details
  ids << product_details[:PRODUCT_ID]


end


pages << {
    page_type: 'products_reviews',
    method: 'GET',
    url: "https://api.bazaarvoice.com/data/batch.json?passkey=3aqde2lhhpwod1c1ve03mx30j&apiversion=5.5&displaycode=13815-en_sg&resource.q0=statistics&filter.q0=" + CGI.escape("productid:eq:#{ids.join(',')}") + "&filter.q0=" + CGI.escape("contentlocale:eq:en,en_US,zh_SG,en_SG") + "&stats.q0=reviews&filter_reviews.q0=" + CGI.escape("contentlocale:eq:en,en_US,zh_SG,en_SG") + "&filter_reviewcomments.q0=" + CGI.escape("contentlocale:eq:en,en_US,zh_SG,en_SG") + "&limit.q0=48&callback=bv_1111_41303&searchkeyword=#{page['vars']['search_term']}&searchpage=#{page['vars']['page']}",
    vars: {
        'products' => products_details
    }


}