function submitFeedback(url, authenticity_token) {
  var params,
      messageField = document.getElementById("inputComment"),
      emailAddressField = document.getElementById("inputEmail"),
      message = messageField.value,
      emailAddress = emailAddressField.value;

  if (message == null || message.length == 0) {
    alert("Please enter a message.");
    return;
  }

  var regexp = new RegExp("\\w+@\\w+\\.\\w+");

  if (emailAddress == null || emailAddress.length == 0 || !emailAddress.match(regexp)) {
      alert("Please enter a valid email address.");
      return;
  }

  params  = "name=Unknown";		// feedback_controller.rb expects a name -- make one up.
  params += "&email=" + emailAddress;
  params += "&message=" + message;
  params += "&utf8=#x2713;";

  if (url != null && url != "") {
    params += "&url=" + url;
  }

  if (authenticity_token != null && authenticity_token != "") {
    params += "&authenticity_token=" + authenticity_token;
  }

  $.ajax({
    type: "POST",
    url: "/feedback",
    data: encodeURI(params)
  });

  messageField.value = "";
  emailAddressField.value = "";

  $('#comment_modal').modal('hide');
}
