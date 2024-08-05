
const index = [
	['Index', 'main.html'],
	['Misc. Utilities', 'pages/misc_utils.html'],
	['Auto-Boilerplate', 'pages/reg_utils.html'],
	['Validation Utils', 'pages/err_utils.html'],
	['Item/Stack Utils', 'pages/item_utils.html'],
	['Player Utilities', 'pages/player_utils.html'],
	['Math Utilities', 'pages/math_utils.html'],
	['Text Utilities', 'pages/text_utils.html'],
	['Node Utilities', 'pages/node_utils.html'],
	['Display Entities', 'pages/display_ents.html'],
];

function sidebar (current_file, lookup_prefix) {
	const sidebar = document.createElement('div');
	sidebar.id = 'sidebar';
	
	sidebar.appendChild(document.createElement('hr'))
	const title = document.createElement('h2')
	title.innerHTML = 'Navigation';
	sidebar.appendChild(title);
	
	for (let i = 0; i < index.length; i++) {
		var current_page = index[i]
		if (current_page[1] != current_file) {
			var link = document.createElement('a')
			link.innerHTML = current_page[0];
			link.href = lookup_prefix + current_page[1];
			sidebar.appendChild(link);
			sidebar.appendChild(document.createElement('br'));
		} else {
			var link = document.createElement('p')
			link.innerHTML = current_page[0];
			link.className = 'disabledLink';
			sidebar.appendChild(link);
		}
	}
	
	sidebar.appendChild(document.createElement('hr'))
	
	document.body.appendChild(sidebar);
}
