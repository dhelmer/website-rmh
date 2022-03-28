document.onreadystatechange = function(event) {
  if (document.readyState === "complete") {

    // Test: display current page url
    // console.log(document.URL);

    // Add 'current' class to current page links
    let current = 0;
    for (var i = 0; i < document.links.length; i++) {
        if (document.links[i].href === document.URL) {
            current = i;
        }
    }
    document.links[current].className = 'current';

    // Add current year to footer's copyright statement.
    let date =  new Date().getFullYear();
    document.getElementById("copyright").innerHTML = '&copy; Copyright ' + date +'. Munro Publishing. All Rights Reserved.';

  }
};
