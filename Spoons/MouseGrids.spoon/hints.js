#!/usr/local/bin/node

// https://github.com/televator-apps/vimari/blob/master/Vimari%20Extension/js/link-hints.js
// linkHintCharacters: "asdfjklqwerzxc" (Vimari) / asdfgqwertzxcvb (sVim)

// Converts a number like "8" into a hint string like "JK". This is used to sequentially generate all of the hint text.
// The hint string will be "padded with zeroes" to ensure its length is equal to digitsNeeded.
const linkHintCharacters = process.argv[2];
const requiredNumberOfHints = process.argv[3];
const hintMarkers = [];
// Builds and displays link hints for every visible clickable item on the page.
// function buildLinkHints() {
// Initialize the number used to generate the character hints to be as many digits as we need to
// highlight all the links on the page; we don't want some link hints to have more chars than others.
const digitsNeeded = Math.ceil(
  Math.log(requiredNumberOfHints) / Math.log(linkHintCharacters.length)
);
let linkHintNumber = 0;
for (let i = 0; i < requiredNumberOfHints; i += 1) {
  //
  // hintMarkers.push(numberToHintString(linkHintNumber, digitsNeeded));
  //
  let number = linkHintNumber;
  const base = linkHintCharacters.length;
  const hintString = [];
  let remainder = 0;
  while (number > 0) {
    remainder = number % base;
    hintString.unshift(linkHintCharacters[remainder]);
    number -= remainder;
    number /= Math.floor(base);
  }
  // Pad the hint string we're returning so that it matches digitsNeeded.
  const hintStringLength = hintString.length;
  for (let j = 0; j < digitsNeeded - hintStringLength; j += 1) {
    hintString.unshift(linkHintCharacters[0]);
  }
  hintMarkers.push(hintString.reverse().join(""));
  //
  linkHintNumber += 1;
}

console.log(hintMarkers.join("\n"));
