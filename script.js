document.addEventListener('DOMContentLoaded', function() {
    const titleScreen = document.querySelector('.title-screen');
    const stars = document.querySelectorAll('.star');
    const stars2 = document.querySelectorAll('.star2');

    // fade in title screen
    setTimeout(() => {
        titleScreen.classList.add('fade-in');
    }, 100);

    // twinkling
    stars.forEach((star, index) => {
        // random twinkling animation delays
        const randomDelay = Math.random() * 2;
        star.style.animationDelay = `${randomDelay}s`;
        
        // random star rotation
        const randomRotation = (Math.random() - 0.5) * 30; // -15 to +15 degrees
        const randomScale = 1 + (Math.random() - 0.5);
        
        // gen random values
        star.dataset.rotation = randomRotation;
        star.dataset.scale = randomScale;
        
        // twinkling + rotation
        const customTwinkle = document.createElement('style');
        customTwinkle.textContent = `
            @keyframes twinkle-${index} {
                0%, 100% {
                    opacity: 0.7;
                    transform: rotate(${randomRotation}deg) scale(${randomScale});
                }
                50% {
                    opacity: 1;
                    transform: rotate(${randomRotation}deg) scale(${randomScale * 1.1});
                }
            }
        `;
        document.head.appendChild(customTwinkle);
        star.style.animation = `twinkle-${index} 4s ease-in-out infinite`;
    });

    stars2.forEach((star, index) => {
        // random twinkling animation delays
        const randomDelay = Math.random() * 2;

        // twinkling
        const customTwinkle = document.createElement('style');
        customTwinkle.textContent = `
            @keyframes twinkle-${index} {
                0%, 100% {
                    opacity: 0.5;
                }
                50% {
                    opacity: 1;
                }
            }
        `;
        document.head.appendChild(customTwinkle);

        // Apply animation with delay
        star.style.animation = `twinkle-${index} 4s ease-in-out infinite`;
        star.style.animationDelay = `${randomDelay}s`;
        star.style.animationFillMode = 'both';
    });

});
    
// floating logo
const logo = document.querySelector('.logo');
logo.style.animation = 'float 4s ease-in-out infinite';

const style = document.createElement('style');
style.textContent = `
    @keyframes float {
        0%, 100% {
            transform: translateY(0px);
        }
        50% {
            transform: translateY(-10px);
        }
    }
`;
document.head.appendChild(style);
