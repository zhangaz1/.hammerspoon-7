var isElementInput = function(element) {
  return (
    (element.localName === 'textarea' ||
      element.localName === 'input' ||
      element.getAttribute('contenteditable') === 'true') &&
    !element.disabled &&
    !/button|radio|file|image|checkbox|submit/i.test(
      element.getAttribute('type')
    )
  );
};
var isElementVisible = function(element) {
  return (
    element.offsetParent &&
    !element.disabled &&
    element.getAttribute('type') !== 'hidden' &&
    getComputedStyle(element).visibility !== 'hidden' &&
    element.getAttribute('display') !== 'none'
  );
};
var isElementInView = function(element) {
  var rect = element.getClientRects()[0];
  return (
    rect.top + rect.height >= 0 &&
    rect.left + rect.width >= 0 &&
    rect.right - rect.width <= window.innerWidth &&
    rect.top < window.innerHeight
  );
};
var inputs = document.querySelectorAll('input,textarea');
var focusIndex;
// Find and focus on the first input in view, if none then use first on the page
for (var i = 0, l = inputs.length; i < l; i++) {
  if (isElementInput(inputs[i]) && isElementVisible(inputs[i])) {
    if (isElementInView(inputs[i])) {
      focusIndex = i;
      break;
    } else if (focusIndex == null) {
      focusIndex = i;
    }
  }
}
inputs[focusIndex].focus();
