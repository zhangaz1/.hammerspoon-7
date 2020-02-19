var patterns;
if (direction == 'next') {
  patterns = ['next', '>'];
} else {
  patterns = ['prev(ious)?', '<'];
}
var links = document.querySelectorAll('a');
for (var i = 0; i < links.length; i += 1) {
  var element = links[i];
  var linkText = element.text;
  var linkClassName = element.className;
  for (let index = 0; index < patterns.length; index += 1) {
    var pattern = patterns[index];
    var re = new RegExp(pattern, 'i');
    var afterClassContent = getComputedStyle(element, ':after').content;
    if (
      re.test(linkText) ||
      re.test(afterClassContent) ||
      re.test(linkClassName)
    ) {
      element.click();
      break;
    }
  }
}
