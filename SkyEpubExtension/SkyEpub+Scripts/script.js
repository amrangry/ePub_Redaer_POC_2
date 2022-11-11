function reformImages() {
    var imgElements = document.getElementsByTagName("img");
    for (var i=0; i<imgElements.length;i++) {
        var element = imgElements[i];
        if (element.className=="append") continue;
        var nw = element.naturalWidth;
        var nh = element.naturalHeight;
        var aspectRatio = (nw/nh);
        var mh,mw;
        if (aspectRatio>0.9) { // landscape image
            if (isDoublePaged) {
                mw = Math.floor(((innerWidth/2)*0.6));
            }else {
                mw = Math.floor((innerWidth*0.85));
            }
            mh = mw * (1/aspectRatio);
        }else { // portrait image
            mh = Math.floor(innerHeight*0.58);
            mw = Math.floor(mh * (aspectRatio));
        }
        element.style.maxWidth = mw+"px";
        element.style.maxHeight= mh+"px";;
    }
}
                       
                       

reformImages();



