function submitFeedback(url, authenticity_token) {
  var params,
      messageField = document.getElementById("inputComment"),
      emailAddressField = document.getElementById("inputEmail"),
      nameField = document.getElementById("inputName"),
      message = messageField.value,
      emailAddress = emailAddressField.value;
      name = nameField.value;

  if (message == null || message.length == 0) {
    alert("Please enter a message.");
    return;
  }

  var regexp = new RegExp("\\w+@\\w+\\.\\w+");

  if (emailAddress == null || emailAddress.length == 0 || !emailAddress.match(regexp)) {
      alert("Please enter a valid email address.");
      return;
  }

  if (name == null || name.length == 0) {
    alert("Please enter your name.");
    return;
  }

  params  = "name=" + name;
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
  nameField.value = "";

  $('#comment_modal').modal('hide');
}
