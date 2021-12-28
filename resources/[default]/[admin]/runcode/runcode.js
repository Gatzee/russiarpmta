var resultstext;

function onBodyLoad () {
	resultstext = CodeMirror.fromTextArea(document.getElementById("code"),{tabMode: "indent",matchBrackets: true,theme: "neat"});
}

function webRun () {
	httpRun(resultstext.getValue(),
		function () {
			//alert(arguments[0])
		}
	);
}

function refresh( ) {
	httpGetConsole( resultstext.getValue(),
		function () {
			var ele = document.getElementById("console");
			ele.innerHTML=arguments[0]; 
			ele.scrollTop = ele.scrollHeight;
			setTimeout( refresh, 1000 );
		}
	);
}

setTimeout( refresh, 1000 );