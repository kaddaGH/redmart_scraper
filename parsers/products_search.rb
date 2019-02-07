require 'cgi'
data = JSON.parse(content)
scrape_url_nbr_products = data['total']
products = data['products']
products_details = {}
ids=[]
products.each_with_index do |product, i|

promotion = product['promotions']['savings_text'] rescue ''
availability =product['inventories'][0]['stock_status']==1?'1':''
if  product['category_tags'].include? 'energy-drinks'
  category = 'energy-drinks'
else


  category = product['category_tags'][0]


end

  product_details = {
      # - - - - - - - - - - -
      RETAILER_ID: '95',
      RETAILER_NAME: 'redmart',
      GEOGRAPHY_NAME: 'SG',
      # - - - - - - - - - - -
      SCRAPE_INPUT_TYPE: page['vars']['input_type'],
      SCRAPE_INPUT_SEARCH_TERM: page['vars']['search_term'],
      SCRAPE_INPUT_CATEGORY: page['vars']['input_type'] == 'taxonomy' ? category: '-',
      SCRAPE_URL_NBR_PRODUCTS: scrape_url_nbr_products,
      # - - - - - - - - - - -
      SCRAPE_URL_NBR_PROD_PG1: scrape_url_nbr_products,
      # - - - - - - - - - - -
      PRODUCT_BRAND: product['filters']['brand_name'],
      PRODUCT_RANK: i + 1,
      PRODUCT_PAGE: page['vars']['page'],
      PRODUCT_ID: product['id'],
      PRODUCT_NAME: product['title'],
      EAN: product['sku'],
      PRODUCT_DESCRIPTION: product['desc'],
      PRODUCT_MAIN_IMAGE_URL: 'https://s3-ap-southeast-1.amazonaws.com/media.redmart.com/newmedia/150x'+product['img']['name'],
      PRODUCT_ITEM_SIZE: product['warehouse']['measure']['vol'],
      PRODUCT_ITEM_SIZE_UOM: product['warehouse']['measure']['vol_metric'],
      PRODUCT_ITEM_QTY_IN_PACK: '',
      SALES_PRICE: product['pricing']['price'],
      IS_AVAILABLE: availability,
      PROMOTION_TEXT: promotion,

  }




products_details[product_details[:PRODUCT_ID]] =product_details
ids<< product_details[:PRODUCT_ID]



end



pages << {
    page_type: 'products_reviews',
    method: 'GET',
    url:"https://api.bazaarvoice.com/data/batch.json?passkey=3aqde2lhhpwod1c1ve03mx30j&apiversion=5.5&displaycode=13815-en_sg&resource.q0=statistics&filter.q0="+CGI.escape("productid:eq:#{ids.join(',')}")+"&filter.q0="+CGI.escape("contentlocale:eq:en,en_US,zh_SG,en_SG")+"&stats.q0=reviews&filter_reviews.q0="+CGI.escape("contentlocale:eq:en,en_US,zh_SG,en_SG")+"&filter_reviewcomments.q0="+CGI.escape("contentlocale:eq:en,en_US,zh_SG,en_SG")+"&limit.q0=48&callback=bv_1111_41303",
    vars: {
        'input_type' => page['vars']['input_type'],
        'search_term' => page['vars']['search_term'],
        'page' => page['vars']['page'],
        'products'=>products_details
    }


}