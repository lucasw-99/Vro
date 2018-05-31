const functions = require('firebase-functions');
const admin = require("firebase-admin");
admin.initializeApp();

const algoliasearch = require('algoliasearch');
const algolia = algoliasearch(functions.config().algolia.appid, functions.config().algolia.adminkey);

exports.updateEvents = functions.database.ref('/events/{eventId}').onWrite((event, context) => {
    console.log('event:', event)
    console.log('params:', context)
    const data = event.after.val()
    const index = algolia.initIndex('events')
    const eventId = context.params['eventId']
    if (!data) {
        return index.deleteObject(eventId, (err) => {
            if (err) { 
                console.log('err:', err)
                return false
            }
            console.log('Event Removed from Algolia Index with id:', eventId)
            return true
          })
    }

    data['objectID'] = eventId
    // TODO: Change client side key back to coordinate
    data['_geoloc'] = data['event']['_geoloc']
    console.log('data:', data)
    return index.saveObject(data, (err, content) => {
        if (err) { 
            console.log('err:', err)
            return false
        }
        console.log('Event Updated in Algolia Index with id:', data.objectID)
        return true
    })    
})