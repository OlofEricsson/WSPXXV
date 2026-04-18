document.addEventListener("DOMContentLoaded", () => {
    const menuButton = document.querySelector(".menu-button");
    const menu = document.querySelector(".menu");
    const fadeLayer = document.querySelector(".fade-layer");
    const kommer = document.querySelector(".kommer");
    const frånvarande = document.querySelector(".frånvarande");
    const kallad = document.querySelector(".kallad");

    menuButton.addEventListener("click", () => {
        menu.classList.add("show");
        fadeLayer.classList.add("visible");
    });

    fadeLayer.addEventListener("click", () => {
        menu.classList.remove("show");
        fadeLayer.classList.remove("visible");
    });


    
})