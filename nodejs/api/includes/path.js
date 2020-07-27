window.getDomPath = function ( el ) {
  if ( !el ) {
    return;
  }
  var stack = [];
  var isShadow = false;
  while ( el.parentNode != null ) {
    // console.log(el.nodeName);
    var sibCount = 0;
    var sibIndex = 0;
    // get sibling indexes
    for ( var i = 0; i < el.parentNode.childNodes.length; i++ ) {
      var sib = el.parentNode.childNodes[i];
      if ( sib.nodeName == el.nodeName ) {
        if ( sib === el ) {
          sibIndex = sibCount;
        }
        sibCount++;
      }
    }
    // if ( el.hasAttribute('id') && el.id != '' ) { no id shortcuts, ids are not unique in shadowDom
    //   stack.unshift(el.nodeName.toLowerCase() + '#' + el.id);
    // } else
    var nodeName = el.nodeName.toLowerCase();
    if ( isShadow ) {
      nodeName += "::shadow";
      isShadow = false;
    }
    if ( sibCount > 1 ) {
      stack.unshift( nodeName + ':nth-of-type(' + ( sibIndex + 1 ) + ')' );
    } else {
      stack.unshift( nodeName );
    }
    el = el.parentNode;
    if ( el.nodeType === 11 ) { // for shadow dom, we
      isShadow = true;
      el = el.host;
    }
  }
  stack.splice( 0, 1 ); // removes the html element
  return stack.join( ' > ' );
}
