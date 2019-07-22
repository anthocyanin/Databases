######大微信客小二后台商品最新推广信息
select
  h1.shop_id as shop_id,
  h2.app_item_id as app_item_id,
  h1.ad_id as ad_id,
  h1.ad_name as ad_name,
 (h1.ad_price/100)as ad_price,---券前价
 (h1.cck_rate/1000) as cck_rate,---楚客佣金率
 (h1.cck_price/100) as cck_price,---楚客佣金额
 ((h1.cck_price/100)/(h1.cck_rate/1000)) as discount_price,---券后价
  h1.audit_status as audit_status,---审核状态（0待审核，1审核通过，2驳回）
  h1.status as status,---商品状态（0下架，1在架）  
  h1.shop_title as shop_title,
  h1.shop_cname1 as shop_title
from
(
  select 
    item_id, 
    app_item_id
  from cc_ods_dwxk_fs_wk_items
  where shop_id in (18024,18871,18495,18346,17078,18325,19172,18419,17806,18602,11336,18157,18647,18432,18687,17744,18221,19436,17903,
        18574,16288,19164,17488,7731,18451,19011,12403,19230,2369,15318,17976,934,17026,11952,19210,17912,17948,18800,18283,8960,18435,
        9509,18200,12381,18190,18795,17563,18786,10759,18756,18165,17492,18050,19341,8163,11275,3803,17691,9716,18695,18014,13907,18613,
        2829,11338,18919,10064,18191,18924,15595,19131,17766,11568,18540,19078,19144,18012,16701,18624,12540,19120,17154,18753,19320,17935,
        18620,18211,17876,18744,17655,17489,18124,18879,19187,18774,18750,18092,17728,19265,17578,18207,18214,17928,9543,17446,18023,18587,
        18689,4489,11382,8527,19273,18420,17845,19518,19426,15550,15012,15378,19270,18544,9181,7823,9735,4457,17516,8563,10928,14562,18634,
        18791,13170,16294,19224,9734,17363,18459,18054,18932,9920)
) h2
inner join
(
   select
     t1.shop_id as shop_id,
     t1.ad_id as ad_id,
     t1.ad_name as ad_name,
     t1.item_id as item_id,
     t1.ad_price as ad_price,
     t1.cck_rate as cck_rate,
     t1.cck_price as cck_price,
     t1.audit_status as audit_status,
     t1.status as status,
     t3.shop_title as shop_title,
     t3.shop_cname1 as shop_title
   from
  (
   select
     id,
     app_shop_id as shop_id,
     ad_id, 
     ad_name, 
     item_id, 
     ad_price, 
     cck_rate, 
     cck_price, 
     audit_status, 
     status
   from cc_ods_fs_dwxk_ad_items_daily
   where app_shop_id in (18024,18871,18495,18346,17078,18325,19172,18419,17806,18602,11336,18157,18647,18432,18687,17744,18221,19436,17903,
         18574,16288,19164,17488,7731,18451,19011,12403,19230,2369,15318,17976,934,17026,11952,19210,17912,17948,18800,18283,8960,18435,
         9509,18200,12381,18190,18795,17563,18786,10759,18756,18165,17492,18050,19341,8163,11275,3803,17691,9716,18695,18014,13907,18613,
         2829,11338,18919,10064,18191,18924,15595,19131,17766,11568,18540,19078,19144,18012,16701,18624,12540,19120,17154,18753,19320,17935,
         18620,18211,17876,18744,17655,17489,18124,18879,19187,18774,18750,18092,17728,19265,17578,18207,18214,17928,9543,17446,18023,18587,
         18689,4489,11382,8527,19273,18420,17845,19518,19426,15550,15012,15378,19270,18544,9181,7823,9735,4457,17516,8563,10928,14562,18634,
         18791,13170,16294,19224,9734,17363,18459,18054,18932,9920)
  ）t1
inner join
  (
   select
     max(id) as id,--最新的推广id
     app_shop_id as shop_id,
     item_id
   from cc_ods_fs_dwxk_ad_items_daily
   where app_shop_id in (18024,18871,18495,18346,17078,18325,19172,18419,17806,18602,11336,18157,18647,18432,18687,17744,18221,19436,17903,
         18574,16288,19164,17488,7731,18451,19011,12403,19230,2369,15318,17976,934,17026,11952,19210,17912,17948,18800,18283,8960,18435,
         9509,18200,12381,18190,18795,17563,18786,10759,18756,18165,17492,18050,19341,8163,11275,3803,17691,9716,18695,18014,13907,18613,
         2829,11338,18919,10064,18191,18924,15595,19131,17766,11568,18540,19078,19144,18012,16701,18624,12540,19120,17154,18753,19320,17935,
         18620,18211,17876,18744,17655,17489,18124,18879,19187,18774,18750,18092,17728,19265,17578,18207,18214,17928,9543,17446,18023,18587,
         18689,4489,11382,8527,19273,18420,17845,19518,19426,15550,15012,15378,19270,18544,9181,7823,9735,4457,17516,8563,10928,14562,18634,
         18791,13170,16294,19224,9734,17363,18459,18054,18932,9920)
   group by item_id,app_shop_id
  ) t2
on t1.id=t2.id
left join 
  (
    select
      shop_id,
      shop_title,
      shop_cname1
    from cc_dw_fs_products_shops
  ) t3
on t1.shop_id=t3.shop_id
) h1
on h1.item_id=h2.item_id

///////////////////////////////////////////////


