// Dependencies: jQuery, bootstrap 5
// Description: This script is used to manage user sessions. It checks if the user is logged in and if so, starts a session timer. If the user is inactive for a certain period of time, a modal is displayed to warn the user that their session will expire soon. The user can choose to stay logged in or log out. If the user does not respond to the modal, they will be logged out automatically. The script also checks the user's login status every 5 minutes and logs them out if they are not logged in.
// Created: 01/29/2024 by Ernest Pena Jr.
// Updated: 02/02/2024 by by Ernest Pena Jr.

    // Dynamically create and append the session timeout modal to the body
    $('body').append(
        '<div class="modal fade" id="sessionTimeoutModal" tabindex="-1" aria-labelledby="sessionTimeoutModalLabel" aria-hidden="true">' +
            '<div class="modal-dialog modal-dialog-centered">' +
                '<div class="modal-content">' +
                    '<div class="modal-header">' +
                        '<h5 class="modal-title text-dark text-uppercase" id="sessionTimeoutModalLabel"><i class="fas fa-exclamation-triangle"></i> Session Timeout Warning</h5>' +
                    '</div>' +
                    '<div class="modal-body">' +
                        '<div class="progress" role="progressbar" id="sessionTimeoutProgressBar" aria-label="Session Timeout" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">' +
                            '<div class="progress-bar progress-bar-striped progress-bar-animated" style="width: 100%"></div>' +
                        '</div>' +
                        '<p class="text-dark">Your session will expire in <code id="timeLeft">2:00</code> minutes. Do you want to stay logged in?</p>' +
                    '</div>' +
                    '<div class="modal-footer">' +
                        '<button type="button" class="btn btn-secondary" id="logoutButton">Log Out</button>' +
                        '<button type="button" class="btn btn-primary" id="stayLoggedInButton">Stay Logged In</button>' +
                    '</div>' +
                '</div>' +
            '</div>' +
        '</div>'
    );

    var timeoutWarning, sessionTimeout, countdownInterval;
    var totalTime = 120; // Total time for countdown in seconds (2 minutes)

    //display time left in session in minutes in navbar
    function displaySessionTimeLeft(){
        // time left 30 minutes
        var timeLeft = 1680;
        var minutes = Math.floor(timeLeft / 60);
        var seconds = timeLeft % 60;
        //set Interval to update time left every second
        setInterval(function(){
            timeLeft--;
            var minutes = Math.floor(timeLeft / 60);
            var seconds = timeLeft % 60;
            $('#timeLeftNavBar').html('Session warning in: <code>'+minutes + ':' + (seconds < 10 ? '0' : '') + seconds+'</code>');
        }, 1000);
    }

    // Function to check if the user is logged in
    function checkLoginStatus() {
        $.ajax({
            type: "POST",
            url: "assets/CFCs/functions.cfc",
            data: {method: "checkLoginStatus"},
            success: function(isLoggedIn) {
                if (!isLoggedIn) {
                    window.location.href = 'landingPage.html'; // Redirect to landing page
                } else {
                    // Start session timer if user is logged in
                    startSessionTimer();
                }
            },
            error: function() {
                console.error("Error checking login status");
                // Handle error appropriately
            }
        });
    }

    function startSessionTimer() {
        // Clear existing timers
        clearTimeout(timeoutWarning);
        clearTimeout(sessionTimeout);
        clearInterval(countdownInterval);
        // Set new timers for warning and session timeout 8 minutes  for testing
        //timeoutWarning = setTimeout(showTimeoutWarning, 480000); // 8 minutes
        //timeoutWarning = setTimeout(showTimeoutWarning, 120000); // 2 minutes
        // set the session timeout to 10 minutes for testing
        //sessionTimeout = setTimeout(logoutUser, 600000); // 10 minutes

        // Set new timers for warning and session timeout 28 minutes
        timeoutWarning = setTimeout(showTimeoutWarning, 1680000); // 28 minutes
        // set the session timeout to 30 minutes
        sessionTimeout = setTimeout(logoutUser, 1800000); // 30 minutes
    }

    function showTimeoutWarning() {
        $('#sessionTimeoutModal').modal('show');
        startCountdown(totalTime);
    }

    function startCountdown(timeLeft) {
        updateProgressBar(timeLeft);

        countdownInterval = setInterval(function() {
            timeLeft--;
            updateProgressBar(timeLeft);

            if (timeLeft <= 0) {
                clearInterval(countdownInterval);
                logoutUser();
            } else {
                var minutes = Math.floor(timeLeft / 60);
                var seconds = timeLeft % 60;
                $('#timeLeft').text(minutes + ':' + (seconds < 10 ? '0' : '') + seconds);
            }
        }, 1000);
    }

    function updateProgressBar(timeLeft) {
        var percent = (timeLeft / totalTime) * 100;
        $('#sessionTimeoutProgressBar').css('width', percent + '%').attr('aria-valuenow', percent);
    }

    function stayLoggedIn() {
        // AJAX call to refresh session (not implemented here)

        function refreshSession(){
            $.ajax({
                type: "POST",
                url: "assets/CFCs/functions.cfc",
                data: {method: "refreshSession"},
                success: function(data){
                    console.log(data);
                },
                error: function(data){
                    console.log(data); 
                }
            });
        }
        // Restart the session timer
        startSessionTimer();

        // Close the modal
        $('#sessionTimeoutModal').modal('hide');
    }

    function logoutUser() {
        window.location.href = 'landingPage.html'; // Redirect to login page
    }

    // Event listeners
    $('#stayLoggedInButton').on('click', function(){
        stayLoggedIn();
    });
    $('#logoutButton').on('click', function(){
        logoutUser();
    });

    /// Start the session timer
    startSessionTimer();

    // Check login status every 1 second


    setInterval(checkLoginStatus, 300000);

    // AJAX call to refresh session 
    function refreshSession(){
        $.ajax({
            type: "POST",
            url: "assets/CFCs/functions.cfc",
            data: {method: "refreshSession"},
            success: function(data){
                console.log(data);
            },
            error: function(data){
                console.log(data); 
            }
        });
    }



    