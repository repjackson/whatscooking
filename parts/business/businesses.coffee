if Meteor.isServer
    Meteor.publish 'members', (business_id)->
        Meteor.users.find
            _id:$in:@member_ids

    Meteor.publish 'business_by_slug', (business_slug)->
        Docs.find
            model:'business'
            slug:business_slug
    Meteor.methods
        calc_business_stats: (business_slug)->
            business = Docs.findOne
                model:'business'
                slug: business_slug

            member_count =
                business.member_ids.length

            business_members =
                Meteor.users.find
                    _id: $in: business.member_ids

            dish_count = 0
            dish_ids = []
            for member in business_members.fetch()
                member_dishes =
                    Docs.find(
                        model:'dish'
                        _author_id:member._id
                    ).fetch()
                for dish in member_dishes
                    console.log 'dish', dish.title
                    dish_ids.push dish._id
                    dish_count++
            # dish_count =
            #     Docs.find(
            #         model:'dish'
            #         business_id:business._id
            #     ).count()
            business_count =
                Docs.find(
                    model:'business'
                    business_id:business._id
                ).count()

            order_cursor =
                Docs.find(
                    model:'order'
                    business_id:business._id
                )
            order_count = order_cursor.count()
            total_credit_exchanged = 0
            for order in order_cursor.fetch()
                if order.order_price
                    total_credit_exchanged += order.order_price
            business_businesss =
                Docs.find(
                    model:'business'
                    business_id:business._id
                ).fetch()

            console.log 'total_credit_exchanged', total_credit_exchanged


            Docs.update business._id,
                $set:
                    member_count:member_count
                    business_count:business_count
                    dish_count:dish_count
                    total_credit_exchanged:total_credit_exchanged
                    dish_ids:dish_ids
