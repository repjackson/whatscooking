Meteor.methods
    log_view: (doc_id)->
        Docs.update doc_id,
            $inc:views:1

    create_delta: ->
        # console.log @
        Docs.insert
            model:'model'
            slug:'model'


    import_tests: ->
        # myobject = HTTP.get(Meteor.absoluteUrl("/public/tests.json")).data;
        myjson = JSON.parse(Assets.getText("tests.json"));
        console.log myjson


    add_user: (username)->
        options = {}
        options.username = username

        res= Accounts.createUser options
        if res
            return res
        else
            Throw.new Meteor.Error 'err creating user'

    parse_keys: ->
        cursor = Docs.find
            model:'key'
        for key in cursor.fetch()
            # new_building_number = parseInt key.building_number
            new_unit_number = parseInt key.unit_number
            Docs.update key._id,
                $set:
                    unit_number:new_unit_number


    change_username:  (user_id, new_username) ->
        user = Meteor.users.findOne user_id
        Accounts.setUsername(user._id, new_username)
        return "Updated Username to #{new_username}."


    add_email: (user_id, new_email) ->
        Accounts.addEmail(user_id, new_email);
        Accounts.sendVerificationEmail(user_id, new_email)
        return "updated Email to #{new_email}"

    remove_email: (user_id, email)->
        # user = Meteor.users.findOne username:username
        Accounts.removeEmail user_id, email


    verify_email: (user_id, email)->
        user = Meteor.users.findOne user_id
        console.log 'sending verification', user.username
        Accounts.sendVerificationEmail(user_id, email)

    validate_email: (email) ->
        re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        re.test String(email).toLowerCase()


    notify_message: (message_id)->
        message = Docs.findOne message_id
        if message
            to_user = Meteor.users.findOne message.to_user_id

            message_link = "https://www.dao.af/user/#{to_user.username}/messages"

        	Email.send({
                to:["<#{to_user.emails[0].address}>"]
                from:"relay@dao.af"
                subject:"dao message from #{message._author_username}"
                html: "<h3> #{message._author_username} sent you the message:</h3>"+"<h2> #{message.body}.</h2>"+
                    "<br><h4>view your messages here:<a href=#{message_link}>#{message_link}</a>.</h4>"
            })

    checkout_students: ()->
        now = Date.now()
        # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()
        checkedin_sessions = Docs.find(
            model:'healthclub_session',
            active:true
            garden_key:$ne:true
            ).fetch()


        for session in checkedin_sessions
            # checkedin_doc =
            #     Docs.findOne
            #         user_id:student._id
            #         model:'healthclub_checkin'
            #         active:true
            diff = now-session._timestamp
            minute_difference = diff/1000/60
            if minute_difference>60
                # Meteor.users.update(student._id,{$set:healthclub_checkedin:false})
                Docs.update session._id,
                    $set:
                        active:false
                        logout_timestamp:Date.now()
                # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()

    check_student_status: (user_id)->
        user = Meteor.users.findOne user_id



    checkout_user: (user_id)->
        Meteor.users.update user_id,
            $set:
                healthclub_checkedin:false
        checkedin_doc =
            Docs.findOne
                user_id:user_id
                model:'healthclub_checkin'
                active:true
        if checkedin_doc
            Docs.update checkedin_doc._id,
                $set:
                    active:false
                    logout_timestamp:Date.now()

        Docs.insert
            model:'log_event'
            parent_id:user_id
            object_id:user_id
            user_id:user_id
            body: "#{@first_name} #{@last_name} checked out."



    lookup_user: (username_query, role_filter)->
        if role_filter
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                roles:$in:[role_filter]
                },{limit:10}).fetch()
        else
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                },{limit:10}).fetch()

    lookup_user_by_code: (healthclub_code)->
        unless isNaN(healthclub_code)
            Meteor.users.findOne({
                healthclub_code:healthclub_code
                })

    lookup_doc: (guest_name, model_filter)->
        Docs.find({
            model:model_filter
            guest_name: {$regex:"#{guest_name}", $options: 'i'}
            },{limit:10}).fetch()

    lookup_project: (project_title)->
        Docs.find({
            model:'project'
            title: {$regex:"#{project_title}", $options: 'i'}
            }).fetch()

    lookup_task_list: (title)->
        Docs.find({
            model:'task_list'
            title: {$regex:"#{title}", $options: 'i'}
            }).fetch()

    # lookup_username: (username_query)->
    #     found_users =
    #         Docs.find({
    #             model:'person'
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             }).fetch()
    #     found_users

    # lookup_first_name: (first_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             first_name: {$regex:"#{first_name}", $options: 'i'}
    #             }).fetch()
    #     found_people
    #
    # lookup_last_name: (last_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             last_name: {$regex:"#{last_name}", $options: 'i'}
    #             }).fetch()
    #     found_people


    set_password: (user_id, new_password)->
        Accounts.setPassword(user_id, new_password)


    keys: (specific_key)->
        start = Date.now()

        if specific_key
            cursor = Docs.find({
                "#{specific_key}":$exists:true
                _keys:$exists:false
                }, { fields:{_id:1} })
        else
            cursor = Docs.find({
                _keys:$exists:false
            }, { fields:{_id:1} })

        found = cursor.count()

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id

        stop = Date.now()

        diff = stop - start

    key: (doc_id)->
        doc = Docs.findOne doc_id
        keys = _.keys doc

        light_fields = _.reject( keys, (key)-> key.startsWith '_' )

        Docs.update doc._id,
            $set:_keys:light_fields


    global_remove: (keyname)->
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})


    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()




    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        old_count = Docs.find({"#{old}":$exists:true}).count()
        new_count = Docs.find({"#{newk}":$exists:true}).count()
        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id




    detect_fields: (doc_id)->
        doc = Docs.findOne doc_id
        keys = _.keys doc
        light_fields = _.reject( keys, (key)-> key.startsWith '_' )

        Docs.update doc._id,
            $set:_keys:light_fields

        for key in light_fields
            value = doc["#{key}"]

            meta = {}

            js_type = typeof value


            if js_type is 'object'
                meta.object = true
                if Array.isArray value
                    meta.array = true
                    meta.length = value.length
                    meta.array_element_type = typeof value[0]
                    meta.field = 'array'
                else
                    if key is 'watson'
                        meta.field = 'object'
                        # meta.field = 'watson'
                    else
                        meta.field = 'object'

            else if js_type is 'boolean'
                meta.boolean = true
                meta.field = 'boolean'

            else if js_type is 'number'
                meta.number = true
                d = Date.parse(value)
                # nan = isNaN d
                # !nan
                if value < 0
                    meta.negative = true
                else if value > 0
                    meta.positive = false

                integer = Number.isInteger(value)
                if integer
                    meta.integer = true
                meta.field = 'number'


            else if js_type is 'string'
                meta.string = true
                meta.length = value.length

                html_check = /<[a-z][\s\S]*>/i
                html_result = html_check.test value

                url_check = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
                url_result = url_check.test value

                youtube_check = /((\w|-){11})(?:\S+)?$/
                youtube_result = youtube_check.test value

                if key is 'html'
                    meta.html = true
                    meta.field = 'html'
                if key is 'youtube_id'
                    meta.youtube = true
                    meta.field = 'youtube'
                else if html_result
                    meta.html = true
                    meta.field = 'html'
                else if url_result
                    meta.url = true
                    image_check = (/\.(gif|jpg|jpeg|tiff|png)$/i).test value
                    if image_check
                        meta.image = true
                        meta.field = 'image'
                    else
                        meta.field = 'url'
                # else if youtube_result
                #     meta.youtube = true
                #     meta.field = 'youtube'
                else if Meteor.users.findOne value
                    meta.user_id = true
                    meta.field = 'user_ref'
                else if Docs.findOne value
                    meta.doc_id = true
                    meta.field = 'doc_ref'
                else if meta.length is 20
                    meta.field = 'image'
                else if meta.length > 20
                    meta.field = 'textarea'
                else
                    meta.field = 'text'

            Docs.update doc_id,
                $set: "_#{key}": meta

        # Docs.update doc_id,
        #     $set:_detected:1

        return doc_id


    send_enrollment_email: (user_id, email)->
        user = Meteor.users.findOne(user_id)
        console.log 'sending enrollment email to username', user.username
        Accounts.sendEnrollmentEmail(user_id)
