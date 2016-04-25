"use strict";

function initialiser(){

	window.evenementsClic = {
	};

	document.addEventListener('click', gererClic);

}

function gererClic(evenement){

	var targetID = evenement.target.id;

	if(window.evenementsClic[targetID]){
		window.evenementsClic[targetID](evenement);
	}

}

window.onload = initialiser;