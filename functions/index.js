const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();
exports.createUser = functions.firestore
    .document('deneme/{userId}')
    .onCreate((snap, context) => {
    context.console.log("bisey yaz artık amk");
    admin.firestore().collection("asdasd").add({
        "aciklama":"asdasasf"
    });
    });