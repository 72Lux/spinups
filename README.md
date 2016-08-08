# spinups
deploy autoScaleReplicas
  azure group deployment create -f azuredeployAS.json -e azuredeploy.parametersASsc2East.json sc-2 auto-scale
  azure group deployment create -f azuredeployAS.json -e azuredeploy.parametersASsc1West.json sc-1 auto-scale






  var formatProduct = function(docs) {
    console.log("In formatProduct");
      var results = [];
      console.log ("docs length" + docs.length)
      if (docs.length >= 1) {
          if (!docs[0].onSale){
              docs[0].sale_price = null;
          }
        var product = new Product({
          part_number: docs[0].part_number,
          name: docs[0].name,
          brand: docs[0].brand,
          merchant: docs[0].merchant,
          merchant_id: docs[0].merchant_id,
          ship_free_min: docs[0].ship_free_min,
          ship_flat_rate: docs[0].ship_flat_rate,
          description: docs[0].description,
          url: docs[0].url,
          category: (docs[0].category) ? docs[0].category.slice(-1)[0] : null,
          material: docs[0].material,
          merchant_item_id: docs[0].merchant_item_id,
          customer_service_url: docs[0].customer_service_url,
          return_policy_url: docs[0].return_policy_url,
          product_status: constants.STATUS_ACTIVE, //docs[0].status, //ASSUME ACTIVE FOR NOW.
          image: docs[0].image.join('|'),
          sale_price: docs[0].sale_price,
          retail_price: docs[0].retail_price
        });
        // log.debug('doc description:' + docs[0].description);
        for (var i = 0; i < docs.length; i++) {
            if (!docs[i].onSale){
                docs[i].sale_price= null;
            }
          //@TODO //override images for this color from api now.
          console.log ("adding skus:" + docs[i].id);
          product.addSku({
            id: docs[i].id,
            sku: docs[i].id,
            upc: docs[i].upc,
            url: docs[i].url,
            sku_status: docs[i].status,
            stock: (docs[i].status === constants.STATUS_ACTIVE || docs[i].status === constants.STATUS_PENDING_REVIEW) ? constants.DEFAULT_STOCK_VALUE : 0, // Hack: since we don't have a stock value in Solr
            merchant_sku: docs[i].merchant_sku,
            size: docs[i].size,
            color: docs[i].color,
            name: docs[i].name,
            sale_price: (docs[i].sale_price ? docs[i].sale_price:null),
            retail_price: docs[i].retail_price,
            shipping_charge: docs[i].shipping_charge,
            image: docs[i].image.join('|') //override images here
          });

        }
        //coupon logic
        log.debug("Saving product to cache");
        var coupon, i, len, ref, tempPrice;
        tempPrice = product.retail_price;
        if (product.sale_price > 0 && product.sale_price < product.retail_price) {
          tempPrice = product.sale_price;
        }
        if (product.coupons){
          ref = product.coupons;
          for (i = 0, len = ref.length; i < len; i++) {
            coupon = ref[i];
              couponInfo= coupon.split('|');
            if (couponInfo[0] === '$off' && tempPrice >couponInfo[1]) {
              product.discount_price = tempPrice - couponInfo[2];
            }
            if (coupon.type === '%off'  && tempPrice > couponInfo[1]) {
              product.discount_price = tempPrice - (tempPrice * couponInfo[2]);
            }
          }
        }
      return product;
      } else { //product not found;
        return false;
      }
  };
