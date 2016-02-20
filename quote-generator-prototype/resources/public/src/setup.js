// Link to Elm
var app = Elm.embed(Elm.App, document.getElementById('elm-div'), {
    responsePort: { actionType: "NoOp", data: null }
});

var Config = {
    validEmailExtension: "@gmail.com",
    invalidEmailMessage: "Email is not valid.<br/>Expecting an email from gmail.com"
};

// Google login/logout
function onSignIn(googleUser) {
    // Useful data for your client-side scripts:
    var profile = googleUser.getBasicProfile();
    console.log("ID: " + profile.getId()); // Don't send this directly to your server!
    console.log("Name: " + profile.getName());
    console.log("Image URL: " + profile.getImageUrl());
    console.log("Email: " + profile.getEmail());

    // The ID token you need to pass to your backend:
    var id_token = googleUser.getAuthResponse().id_token;
    console.log("ID Token: " + id_token);

    var email = profile.getEmail()

    var isValid = email && email.endsWith(Config.validEmailExtension)

    if (isValid) {
        console.log(email + " is a valid email.")
        app.ports.responsePort.send({ actionType: "LogIn", data: email });

    } else {
        signOut();
        app.ports.responsePort.send({ actionType: "LogOut", data: null });
        console.log(Config.invalidEmailMessage)

        if(toastr) toastr.error(Config.invalidEmailMessage)
    }
};

function signOut() {
    var auth2 = gapi.auth2.getAuthInstance();
    auth2.signOut().then(function () {
      console.log('User signed out.');
    });
};

// Elm setup
(function (Elm, app) {
    // Set up port
    app.ports.requestPort.subscribe(appPortRequestHandler);

    function appPortRequestHandler(appPortRequest) {
        switch (appPortRequest.actionType) {
            case "LogOut":
                signOut();
                // Let Elm know that log out succeeded
                app.ports.responsePort.send(appPortRequest);
                break;
            case "Error":
                toastr.error(appPortRequest.data);
                break;
            case "Notify":
                toastr.success(appPortRequest.data);
                break;
            case "RequestConsoleLog":
                console.log(appPortRequest.data);
                break;
            default:
                console.log("Ignoring Request: " + appPortRequest)
        }
    };

})(Elm, app);
