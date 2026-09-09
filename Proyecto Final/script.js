// Agrega este script en tu archivo .js principal
document.addEventListener('mousemove', (e) => {
  const fondo = document.querySelector('.menu-contenedor-fondo');
  if (fondo) {
    const x = (e.clientX / window.innerWidth - 0.5) * 20;
    const y = (e.clientY / window.innerHeight - 0.5) * 20;
    fondo.style.transform = `translate(${x}px, ${y}px) scale(1.02)`;
  }
});