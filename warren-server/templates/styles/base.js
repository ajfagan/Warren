const buttons = document.querySelectorAll('.glow-button');

buttons.forEach(button => {
  button.addEventListener('mouseover', () => {
    button.style.boxShadow = '0 0 30px #FF00FF';
  });

  button.addEventListener('mouseout', () => {
    button.style.boxShadow = '0 0 20px #00FFFF';
  });
});
