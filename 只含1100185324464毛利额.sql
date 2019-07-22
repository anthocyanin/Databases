--只含1100185324464
select
    h1.product_cname1_new as product_cname1_new,
    sum(h1.pb_price) as origin_price,
    sum(h1.commission) as commission,
    sum(h1.product_coupon) as product_coupon,
    sum(h1.item_price) as item_price,
    sum(h1.gross_profit) as gross_profit,
    sum(h1.gross_profit)/(sum(h1.item_price)+sum(h1.product_coupon)) as gross_profit_rate
from
(
    select
        (
        case
        when p1.product_cname1 in ('箱包','女装','运动户外','男装','配饰','鞋靴','女士内衣/男士内衣/家居服') then '服饰'
        when p1.product_cname1 in ('家用电器','手机数码') then '家电数码'
        when p1.product_cname1 = '家居百货' then '家居百货'
        when p1.product_cname1 = '美妆个护' then '美妆个护'
        when p1.product_cname1 = '母婴' and p1.product_cname2 in ('童装/亲子装','婴童鞋/亲子鞋') then '服饰'
        when p1.product_cname1 = '母婴' and p1.product_cname2 in ('玩具/模型/动漫/早教/益智','奶粉/辅食/营养品/零食','孕妇装/孕产妇用品/营养','尿片/洗护/喂哺/推车床') then '母婴'
        when p1.product_cname1 = '食品' and p1.product_cname2 = '水产肉类/新鲜蔬果/熟食' then '生鲜'
        when p1.product_cname1 = '食品' and p1.product_cname2 in ('零食/坚果/特产','传统滋补营养品','酒水/茶/冲饮','粮油米面/南北干货/调味品','保健食品/膳食营养补充食品') then '食品'
        else '其他' end 
        ) as product_cname1_new,
        p1.pb_price as pb_price,
        p1.commission as commission,
        p1.item_price as item_price,
        p1.product_coupon as product_coupon,
        p1.gross_profit
    from
    (
        select
            m1.product_cname1 as product_cname1,
            m1.product_cname2 as product_cname2,
            m1.pb_price as pb_price,
            m1.commission as commission,
            m1.item_price as item_price,
            m1.product_coupon as product_coupon,--楚币
            (m1.item_price+m1.product_coupon-m1.pb_price-0.7993*m1.commission) as gross_profit--毛利额
        from
        (---自营的商品毛利额计算
            select
                n1.product_id as product_id,
                n1.product_cname1 as product_cname1,
                n1.product_cname2 as product_cname2,
                n1.shop_id as shop_id,
                n1.pb_price as pb_price,
                n1.commission as commission,
                n1.item_price as item_price,
                if(n2.product_id is not null,n1.product_coupon,0) as product_coupon
            from
            ( 
                select
                    t1.product_id as product_id,
                    t3.product_cname1 as product_cname1,
                    t3.product_cname2 as product_cname2,
                    t3.shop_id as shop_id,
                    t5.pb_price as pb_price,
                    if(t5.order_sn is not null,t1.commission,0) as commission,
                    if(t5.order_sn is not null,t1.item_price,0) as item_price,
                    if(t1.item_price=0,t4.used_money,(t1.item_price*t4.used_money/t4.order_price)) as product_coupon
                from
                (
                    select
                        s1.product_id as product_id,
                        s1.product_sku_id as product_sku_id,
                        s1.third_tradeno as third_tradeno,
                        (s1.commission/100) as commission,
                        (s1.item_price/100) as item_price
                    from
                        origin_common.cc_ods_dwxk_wk_sales_deal_ctime s1
                    inner join 
                        origin_common.cc_ods_dwxk_fs_wk_cck_user s2
                    on 
                        s1.cck_uid = s2.cck_uid
                    where 
                        s1.ds = '${date1}'
                    and
                        s1.product_id=1100185324464 
                    and 
                        s2.ds = '${date1}'
                    and
                        s2.platform = 14
                ) t1
                left join 
                (
                    select
                        distinct
                        product_id,
                        product_cname1,
                        product_cname2,
                        shop_id
                    from
                        data.cc_dw_fs_products_shops
                ) t3
                on t1.product_id = t3.product_id
                left join 
                (
                    select
                        n1.third_tradeno as third_tradeno,
                        n1.order_price as order_price,
                        COALESCE(n2.used_money,0) as used_money
                    from
                    (
                        select
                            s1.third_tradeno as third_tradeno,
                            sum(s1.item_price/100) as order_price
                        from
                            origin_common.cc_ods_dwxk_wk_sales_deal_ctime s1
                        join 
                            origin_common.cc_ods_dwxk_fs_wk_cck_user s2
                        on 
                            s1.cck_uid = s2.cck_uid
                        where 
                            s1.ds = '${date1}'
                        and 
                            s2.ds = '${date1}'
                        and
                            s2.platform = 14
                        group by 
                            s1.third_tradeno
                    ) n1
                    left join 
                    (
                        select
                            s1.order_sn as order_sn,
                            s1.used_money as used_money
                        from
                        (
                            select
                                order_sn,
                                used_money,
                                template_id
                            from 
                                origin_common.cc_order_coupon_paytime
                            where 
                                ds='${date1}'
                        ) s1
                        inner join
                        (
                            select
                                id
                            from 
                                origin_common.cc_ods_fs_coupon_temp
                            where 
                                platform='ccj_cct' and range!='shop' and shop_id=0
                        ) s2
                        on s1.template_id=s2.id
                    ) n2
                    on n1.third_tradeno = n2.order_sn
                ) t4
                on t1.third_tradeno = t4.third_tradeno 
                left join
                (
                    select
                        s1.order_sn as order_sn,
                        s1.sku_id   as sku_id,
                        sum(s2.pb_price*s1.ob_count) as pb_price
                    from
                    (
                        select
                            distinct 
                            ob_pb_id as ob_pb_id,
                            ob_order_sn as order_sn,
                            ob_sku_id as sku_id,
                            ob_count
                        from origin_common.cc_ods_op_order_batches
                        where ds= '${date1}' and from_unixtime(ob_ctime,'yyyyMMdd')>= '${date2}'
                    ) s1
                    inner join
                    (
                        select
                            pb_id,
                            pb_price
                        from origin_common.cc_ods_fs_op_product_batches
                    ) s2
                    on s1.ob_pb_id=s2.pb_id
                    group by s1.order_sn,s1.sku_id
                ) t5 
                on t1.third_tradeno=t5.order_sn and t1.product_sku_id=t5.sku_id
            ) n1
            left join 
            (
                select
                    pm_pid as product_id
                from origin_common.cc_ods_op_products_map
                where ds='${date1}'
            ) n2
            on n1.product_id = n2.product_id
        ) m1
    ) p1     
) h1
group by h1.product_cname1_new