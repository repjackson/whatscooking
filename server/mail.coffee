mailgun = require('mailgun-js')
# DOMAIN = 'whatscookin.at'


Meteor.methods
    send_mail:()->
        mg = mailgun(
            apiKey: Meteor.settings.private.mailgun_key
            domain: 'mg.whatscookin.at')
        # mg = mailgun(
        #     apiKey: Meteor.settings.private.mailgun_key
        #     domain: Meteor.settings.private.mailgun_url)
        data =
            from: 'Excited User <eric@whatscookin.at>'
            to: 'repjackson@gmail.com'
            subject: 'Hello'
            text: 'Testing some Mailgun '
        mg.messages().send data, (err, body)->
            if err
                console.log 'err', err
            else
                console.log 'body', body
