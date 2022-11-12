function handler(event) {
    // const isn't supported
    var index = "index.html";
    var request = event.request;
    var uri = request.uri;
    var lastIndex = uri.lastIndexOf("/");
    var filename = uri.substring(lastIndex);
    if(lastIndex === uri.length - 1) {
        // .../something/ -> .../something/index.html
        request.uri += index;
    } else if(!filename.includes(".")) {
        // .../something -> .../something/index.html
        request.uri += "/"+index;
    }
    // .../something.ext remains unchanged
    return request;
}